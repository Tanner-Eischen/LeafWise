/**
 * React Native hook for plant identification using Plant.id API
 * Provides authentication, state management, and error handling for plant identification features.
 * 
 * This hook encapsulates the complete plant identification workflow, including:
 * - Service initialization with API key
 * - Image submission for identification
 * - Result processing and formatting
 * - Error handling and recovery
 * - Caching for performance optimization
 * 
 * @module PlantIdentification
 */

import { useState, useCallback, useRef, useEffect } from 'react';
import {
  PlantIdentificationService,
  createPlantIdentificationService,
  IdentificationResult,
} from '../api/plantIdentificationService';
import { PlantInfo, PlantIdError } from '../types/plantIdentification';
import { ImageData, Location } from '../types';
import { createPlantIdServiceConfig } from '../../config/plantId';

/**
 * Hook state for plant identification
 * 
 * Internal state structure used by the hook to track identification status,
 * results, errors, and timing information.
 * 
 * @internal
 */
interface PlantIdentificationState {
  isLoading: boolean;
  isInitialized: boolean;
  result: IdentificationResult | null;
  error: PlantIdError | null;
  lastIdentificationTime: number | null;
}

/**
 * Options for plant identification hook configuration
 * 
 * @property {string} [apiKey] - Plant.id API key for authentication
 * @property {boolean} [enableCaching=true] - Whether to cache identification results
 * @property {number} [minConfidenceThreshold=0.1] - Minimum confidence threshold (0-1) for valid identifications
 * @property {number} [maxSuggestions=5] - Maximum number of plant suggestions to return
 * @property {boolean} [autoInitialize=true] - Whether to automatically initialize the service when API key is provided
 */
interface IdentificationHookOptions {
  apiKey?: string;
  enableCaching?: boolean;
  minConfidenceThreshold?: number;
  maxSuggestions?: number;
  autoInitialize?: boolean;
}

/**
 * Return type for the plant identification hook
 * 
 * Provides access to identification state, results, and methods for performing
 * plant identification operations.
 * 
 * @property {boolean} isLoading - Whether an identification request is in progress
 * @property {boolean} isInitialized - Whether the service has been initialized with an API key
 * @property {IdentificationResult|null} result - The most recent identification result
 * @property {PlantIdError|null} error - The most recent error, if any
 * @property {PlantInfo[]} plants - Array of identified plants from the most recent result
 * @property {number} confidence - Confidence score (0-1) of the top identification result
 * @property {number|null} processingTime - Processing time in milliseconds for the most recent request
 */
interface UsePlantIdentificationReturn {
  // State
  isLoading: boolean;
  isInitialized: boolean;
  result: IdentificationResult | null;
  error: PlantIdError | null;
  plants: PlantInfo[];
  confidence: number;
  processingTime: number | null;
  
  // Actions
  identifyPlant: (imageData: ImageData, location?: Location) => Promise<IdentificationResult>;
  getPlantDetails: (scientificName: string) => Promise<PlantInfo | null>;
  clearResult: () => void;
  clearError: () => void;
  initialize: (apiKey: string) => Promise<void>;
  
  // Service management
  getCacheStats: () => { size: number; entries: number };
  clearCache: () => void;
}

/**
 * Custom hook for plant identification using Plant.id API
 * 
 * This hook provides a complete interface for identifying plants from images,
 * managing identification state, and handling errors. It encapsulates the Plant.id
 * API integration and provides a React-friendly interface for use in components.
 * 
 * @example
 * ```tsx
 * function PlantIdentifierScreen() {
 *   const {
 *     isLoading,
 *     plants,
 *     confidence,
 *     error,
 *     identifyPlant,
 *     clearResult
 *   } = usePlantIdentification({
 *     apiKey: 'your-api-key',
 *     minConfidenceThreshold: 0.2
 *   });
 * 
 *   const handleCapture = async (imageData) => {
 *     try {
 *       await identifyPlant(imageData, userLocation);
 *     } catch (error) {
 *       console.error('Identification failed:', error);
 *     }
 *   };
 * 
 *   return (
 *     <View>
 *       {isLoading ? (
 *         <LoadingIndicator />
 *       ) : plants.length > 0 ? (
 *         <PlantResultsList plants={plants} confidence={confidence} />
 *       ) : error ? (
 *         <ErrorDisplay error={error} onRetry={() => clearError()} />
 *       ) : (
 *         <CameraView onCapture={handleCapture} />
 *       )}
 *     </View>
 *   );
 * }
 * ```
 * 
 * @param {IdentificationHookOptions} options - Configuration options for the hook
 * @returns {UsePlantIdentificationReturn} Plant identification hook interface with state and methods
 */
export function usePlantIdentification(
  options: IdentificationHookOptions = {}
): UsePlantIdentificationReturn {
  const {
    apiKey,
    enableCaching = true,
    minConfidenceThreshold = 0.1,
    maxSuggestions = 5,
    autoInitialize = true,
  } = options;

  // State management
  const [state, setState] = useState<PlantIdentificationState>({
    isLoading: false,
    isInitialized: false,
    result: null,
    error: null,
    lastIdentificationTime: null,
  });

  // Service reference
  const serviceRef = useRef<PlantIdentificationService | null>(null);
  const initializationRef = useRef<Promise<void> | null>(null);

  /**
   * Updates hook state with partial state changes
   * 
   * Internal utility function to update the hook's state while preserving
   * unchanged values.
   * 
   * @param {Partial<PlantIdentificationState>} updates - Partial state object with changes
   * @internal
   */
  const updateState = useCallback((updates: Partial<PlantIdentificationState>) => {
    setState(prevState => ({ ...prevState, ...updates }));
  }, []);

  /**
   * Initializes the plant identification service with an API key
   * 
   * This method must be called before using identification features unless
   * autoInitialize is enabled and an API key is provided to the hook options.
   * 
   * @param {string} providedApiKey - Plant.id API key for authentication
   * @returns {Promise<void>} Promise that resolves when initialization is complete
   * @throws {PlantIdError} When initialization fails
   */
  const initialize = useCallback(async (providedApiKey: string) => {
    // Prevent multiple simultaneous initializations
    if (initializationRef.current) {
      return initializationRef.current;
    }

    const initPromise = (async () => {
      try {
        updateState({ isLoading: true, error: null });

        // Create service configuration
        const serviceConfig = createPlantIdServiceConfig({
          apiKey: providedApiKey,
          enableCaching,
          minConfidenceThreshold,
          maxSuggestions,
        });

        // Create and store service instance
        serviceRef.current = createPlantIdentificationService(serviceConfig);
        
        updateState({ 
          isInitialized: true, 
          isLoading: false,
          error: null,
        });
      } catch (error) {
        const plantIdError: PlantIdError = {
          code: 'INITIALIZATION_FAILED',
          message: error instanceof Error ? error.message : 'Failed to initialize plant identification service',
          details: {
            statusCode: 500,
            apiResponse: error
          },
          timestamp: new Date().toISOString(),
          recoverable: true
        };
        
        updateState({ 
          isLoading: false, 
          error: plantIdError,
          isInitialized: false,
        });
        
        throw plantIdError;
      } finally {
        initializationRef.current = null;
      }
    })();

    initializationRef.current = initPromise;
    return initPromise;
  }, [enableCaching, minConfidenceThreshold, maxSuggestions, updateState]);

  /**
   * Identifies plants from image data using the Plant.id API
   * 
   * Submits the provided image to the Plant.id service for analysis and returns
   * identification results. Updates the hook state with results or errors.
   * 
   * @param {ImageData} imageData - Image data object with URI and dimensions
   * @param {Location} [location] - Optional location data for better accuracy
   * @returns {Promise<IdentificationResult>} Promise resolving to identification result
   * @throws {PlantIdError} When identification fails or service is not initialized
   */
  const identifyPlant = useCallback(async (
    imageData: ImageData,
    location?: Location
  ): Promise<IdentificationResult> => {
    if (!serviceRef.current) {
      throw new Error('Plant identification service not initialized. Call initialize() first.');
    }

    try {
      updateState({ 
        isLoading: true, 
        error: null,
        lastIdentificationTime: Date.now(),
      });

      const result = await serviceRef.current.identifyPlant(imageData, location);
      
      updateState({ 
        isLoading: false,
        result,
        error: result?.error || null,
      });
      
      return result;
    } catch (error) {
      const plantIdError: PlantIdError = {
        code: 'IDENTIFICATION_FAILED',
        message: error instanceof Error ? error.message : 'Plant identification failed',
        details: {
          statusCode: 500,
          apiResponse: error
        },
        timestamp: new Date().toISOString(),
        recoverable: true
      };
      
      updateState({ 
        isLoading: false,
        error: plantIdError,
        result: {
          success: false,
          plants: [],
          confidence: 0,
          processingTimeMs: 0,
          error: plantIdError,
        },
      });
      
      throw plantIdError;
    }
  }, [updateState]);

  /**
   * Gets detailed information for a specific plant by scientific name
   * 
   * Retrieves comprehensive plant details including care information, taxonomy,
   * and descriptions for a plant species.
   * 
   * @param {string} scientificName - Scientific name of the plant (e.g., "Rosa rubiginosa")
   * @returns {Promise<PlantInfo|null>} Promise resolving to plant information or null if not found
   * @throws {Error} When service is not initialized
   */
  const getPlantDetails = useCallback(async (scientificName: string): Promise<PlantInfo | null> => {
    if (!serviceRef.current) {
      throw new Error('Plant identification service not initialized');
    }

    try {
      return await serviceRef.current.getPlantDetails(scientificName);
    } catch (error) {
      console.warn(`Failed to get plant details for ${scientificName}:`, error);
      return null;
    }
  }, []);

  /**
   * Clears the current identification result and error state
   * 
   * Resets the hook state to allow for a new identification attempt.
   * Useful after completing an identification flow or when starting fresh.
   */
  const clearResult = useCallback(() => {
    updateState({ 
      result: null, 
      error: null,
      lastIdentificationTime: null,
    });
  }, [updateState]);

  /**
   * Clears the current error state while preserving results
   * 
   * Removes any error messages from the hook state without affecting
   * identification results. Useful for dismissing error notifications.
   */
  const clearError = useCallback(() => {
    updateState({ error: null });
  }, [updateState]);

  /**
   * Gets cache statistics from the identification service
   * 
   * Retrieves information about the current cache state, including size and entry count.
   * Useful for debugging and monitoring cache performance.
   * 
   * @returns {{ size: number; entries: number }} Cache statistics object
   */
  const getCacheStats = useCallback(() => {
    if (!serviceRef.current) {
      return { size: 0, entries: 0 };
    }
    return serviceRef.current.getCacheStats();
  }, []);

  /**
   * Clears the identification service cache
   * 
   * Removes all cached identification results, forcing future requests
   * to query the API even for previously identified images.
   */
  const clearCache = useCallback(() => {
    if (serviceRef.current) {
      serviceRef.current.clearCache();
    }
  }, []);

  // Auto-initialize if API key is provided and autoInitialize is true
  useEffect(() => {
    if (apiKey && autoInitialize && !state.isInitialized && !state.isLoading) {
      initialize(apiKey).catch(error => {
        console.warn('Auto-initialization failed:', error);
      });
    }
  }, [apiKey, autoInitialize, state.isInitialized, state.isLoading, initialize]);

  // Derived state
  const plants = state.result?.plants || [];
  const confidence = state.result?.confidence || 0;
  const processingTime = state.result?.processingTimeMs || null;

  return {
    // State
    isLoading: state.isLoading,
    isInitialized: state.isInitialized,
    result: state.result,
    error: state.error,
    plants,
    confidence,
    processingTime,
    
    // Actions
    identifyPlant,
    getPlantDetails,
    clearResult,
    clearError,
    initialize,
    
    // Service management
    getCacheStats,
    clearCache,
  };
}

/**
 * Hook for getting plant identification service status
 * 
 * Provides information about the current state of the plant identification service,
 * including API key availability and environment configuration.
 * Useful for debugging and monitoring service health.
 * 
 * @example
 * ```tsx
 * function ServiceStatusIndicator() {
 *   const { hasApiKey, environment, lastCheck, refresh } = usePlantIdentificationStatus();
 *   
 *   return (
 *     <View>
 *       <Text>API Key Available: {hasApiKey ? 'Yes' : 'No'}</Text>
 *       <Text>Environment: {environment}</Text>
 *       <Text>Last Checked: {new Date(lastCheck).toLocaleString()}</Text>
 *       <Button title="Refresh Status" onPress={refresh} />
 *     </View>
 *   );
 * }
 * ```
 * 
 * @returns {Object} Status object with service information and refresh method
 */
export function usePlantIdentificationStatus() {
  const [status, setStatus] = useState({
    hasApiKey: false,
    environment: 'unknown',
    lastCheck: Date.now(),
  });

  const checkStatus = useCallback(() => {
    try {
      // This would normally check environment variables
      // For now, we'll return basic status
      setStatus({
        hasApiKey: false, // Would check actual API key availability
        environment: typeof __DEV__ !== 'undefined' ? (__DEV__ ? 'development' : 'production') : 'unknown',
        lastCheck: Date.now(),
      });
    } catch (error) {
      console.warn('Failed to check plant identification status:', error);
    }
  }, []);

  useEffect(() => {
    checkStatus();
  }, [checkStatus]);

  return {
    ...status,
    refresh: checkStatus,
  };
}
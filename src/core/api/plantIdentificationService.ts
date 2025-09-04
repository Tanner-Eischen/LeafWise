/**
 * Plant identification service layer
 * Provides high-level plant identification functionality for the application
 * Handles caching, error recovery, and business logic
 * 
 * This service acts as an intermediary between the application and the Plant.id API,
 * providing additional features like caching, error handling, and result formatting.
 * It implements business logic for confidence thresholds and suggestion filtering.
 * 
 * @module PlantIdentification
 */

import { PlantIdClient, createPlantIdClient } from './plantIdClient';
import {
  PlantIdentificationResponse,
  IdentificationOptions,
  PlantInfo,
  PlantIdError,
} from '../types/plantIdentification';
import { ImageData, Location } from '../types';

/**
 * Configuration for the plant identification service
 * 
 * @property {string} apiKey - Plant.id API key for authentication
 * @property {boolean} [enableCaching=true] - Whether to cache identification results
 * @property {number} [cacheExpiryMs=86400000] - Cache expiry time in milliseconds (default: 24 hours)
 * @property {number} [minConfidenceThreshold=0.1] - Minimum confidence threshold (0-1) for valid identifications
 * @property {number} [maxSuggestions=5] - Maximum number of plant suggestions to return
 */
interface PlantIdentificationServiceConfig {
  apiKey: string;
  enableCaching?: boolean;
  cacheExpiryMs?: number;
  minConfidenceThreshold?: number;
  maxSuggestions?: number;
}

/**
 * Result of plant identification with application-specific formatting
 * 
 * @property {boolean} success - Whether the identification was successful
 * @property {PlantInfo[]} plants - Array of identified plants with details
 * @property {number} confidence - Confidence score (0-1) of the top identification result
 * @property {number} processingTimeMs - Total processing time in milliseconds
 * @property {PlantIdError} [error] - Error information if identification failed
 */
export interface IdentificationResult {
  success: boolean;
  plants: PlantInfo[];
  confidence: number;
  processingTimeMs: number;
  error?: PlantIdError;
}

/**
 * Cache entry for storing identification results
 * 
 * @property {IdentificationResult} result - The cached identification result
 * @property {number} timestamp - Unix timestamp when the entry was cached
 * @property {string} imageHash - Hash of the image data for lookup
 * 
 * @internal
 */
interface CacheEntry {
  result: IdentificationResult;
  timestamp: number;
  imageHash: string;
}

/**
 * Plant identification service class
 * 
 * Provides caching, error handling, and business logic for plant identification.
 * This service encapsulates the Plant.id API client and adds application-specific
 * functionality like result caching, confidence filtering, and error recovery.
 * 
 * @example
 * ```typescript
 * // Create a new service instance
 * const plantService = new PlantIdentificationService({
 *   apiKey: 'your-api-key',
 *   minConfidenceThreshold: 0.2,
 *   maxSuggestions: 3
 * });
 * 
 * // Identify a plant from image data
 * const result = await plantService.identifyPlant(imageData, userLocation);
 * 
 * if (result.success) {
 *   console.log(`Identified ${result.plants.length} plants`);
 *   console.log(`Top match: ${result.plants[0].commonName}`);
 *   console.log(`Confidence: ${result.confidence * 100}%`);
 * } else {
 *   console.error(`Identification failed: ${result.error?.message}`);
 * }
 * ```
 */
export class PlantIdentificationService {
  private client: PlantIdClient;
  private config: Required<PlantIdentificationServiceConfig>;
  private cache = new Map<string, CacheEntry>();

  constructor(config: PlantIdentificationServiceConfig) {
    this.config = {
      enableCaching: true,
      cacheExpiryMs: 24 * 60 * 60 * 1000, // 24 hours
      minConfidenceThreshold: 0.1, // 10% minimum confidence
      maxSuggestions: 5,
      ...config,
    };

    this.client = createPlantIdClient(this.config.apiKey, {
      timeout: 30000,
      retryAttempts: 3,
    });
  }

  /**
   * Identifies plants from an image with caching and error handling
   * 
   * This method is the primary entry point for plant identification. It handles:
   * - Checking the cache for existing results
   * - Submitting the image to the Plant.id API
   * - Processing and formatting the response
   * - Caching successful results
   * - Error handling and recovery
   * 
   * @param {ImageData} imageData - Image data to analyze (URI and dimensions)
   * @param {Location} [location] - Optional location data for better accuracy
   * @param {Partial<IdentificationOptions>} [options={}] - Additional identification options
   * @returns {Promise<IdentificationResult>} Promise resolving to identification result
   * @throws {PlantIdError} When the API request fails or returns invalid data
   */
  async identifyPlant(
    imageData: ImageData,
    location?: Location,
    options: Partial<IdentificationOptions> = {}
  ): Promise<IdentificationResult> {
    const startTime = Date.now();
    
    try {
      // Check cache first if enabled
      if (this.config.enableCaching) {
        const cachedResult = await this.getCachedResult(imageData);
        if (cachedResult) {
          return {
            ...cachedResult,
            processingTimeMs: Date.now() - startTime,
          };
        }
      }

      // Prepare identification options
      const identificationOptions: IdentificationOptions = {
        location,
        includeDetails: true,
        includeSimilarImages: false,
        language: 'en',
        classificationLevel: 'species',
        ...options,
      };

      // Call Plant.id API
      const response = await this.client.identifyPlant(imageData, identificationOptions);
      
      // Process and format results
      const result = await this.processIdentificationResponse(response, startTime);
      
      // Cache the result if enabled
      if (this.config.enableCaching && result.success) {
        await this.cacheResult(imageData, result);
      }
      
      return result;
    } catch (error) {
      return this.handleIdentificationError(error, startTime);
    }
  }

  /**
   * Gets detailed information for a specific plant by scientific name
   * 
   * Retrieves comprehensive plant details including care information, taxonomy,
   * and descriptions for a plant species. This method handles API errors gracefully
   * and returns null if the plant information cannot be retrieved.
   * 
   * @param {string} scientificName - Scientific name of the plant (e.g., "Rosa rubiginosa")
   * @returns {Promise<PlantInfo|null>} Promise resolving to plant information or null if not found
   */
  async getPlantDetails(scientificName: string): Promise<PlantInfo | null> {
    try {
      return await this.client.getPlantDetails(scientificName);
    } catch (error) {
      console.warn(`Failed to get plant details for ${scientificName}:`, error);
      return null;
    }
  }

  /**
   * Processes raw API response into application format
   * 
   * Transforms the raw Plant.id API response into the application's standardized
   * format. This includes filtering suggestions by confidence threshold, limiting
   * the number of suggestions, and formatting plant information.
   * 
   * @param {PlantIdentificationResponse} response - Raw Plant.id API response
   * @param {number} startTime - Processing start timestamp in milliseconds
   * @returns {Promise<IdentificationResult>} Formatted identification result
   * @internal
   */
  private async processIdentificationResponse(
    response: PlantIdentificationResponse,
    startTime: number
  ): Promise<IdentificationResult> {
    const plants: PlantInfo[] = [];
    let highestConfidence = 0;

    // Filter and process suggestions
    const validSuggestions = response.suggestions
      .filter(suggestion => suggestion.probability >= this.config.minConfidenceThreshold)
      .slice(0, this.config.maxSuggestions);

    for (const suggestion of validSuggestions) {
      try {
        const plantInfo = this.client.formatPlantInfo({
          ...response,
          suggestions: [suggestion],
        });
        
        plants.push(plantInfo);
        highestConfidence = Math.max(highestConfidence, suggestion.probability);
      } catch (error) {
        console.warn('Failed to format plant suggestion:', error);
      }
    }

    return {
      success: plants.length > 0,
      plants,
      confidence: highestConfidence,
      processingTimeMs: Date.now() - startTime,
    };
  }

  /**
   * Handles identification errors and returns formatted error result
   * 
   * Converts various error types into a standardized error format for the application.
   * This ensures consistent error handling throughout the app regardless of the
   * underlying error source (network, API, parsing, etc.).
   * 
   * @param {unknown} error - Original error from any source
   * @param {number} startTime - Processing start timestamp in milliseconds
   * @returns {IdentificationResult} Error result with standardized error information
   * @internal
   */
  private handleIdentificationError(
    error: unknown,
    startTime: number
  ): IdentificationResult {
    const plantIdError: PlantIdError = error instanceof Error
      ? {
          code: 'IDENTIFICATION_FAILED',
          message: error.message,
          details: { apiResponse: error.message },
          timestamp: new Date().toISOString(),
          recoverable: true
        }
      : {
          code: 'UNKNOWN_ERROR',
          message: 'Unknown error during plant identification',
          details: { apiResponse: error },
          timestamp: new Date().toISOString(),
          recoverable: true
        };

    return {
      success: false,
      plants: [],
      confidence: 0,
      processingTimeMs: Date.now() - startTime,
      error: plantIdError,
    };
  }

  /**
   * Generates a simple hash for image data (for caching)
   * 
   * @param imageData - Image data to hash
   * @returns Promise resolving to hash string
   */
  private async generateImageHash(imageData: ImageData): Promise<string> {
    // Simple hash based on URI and file size
    const hashInput = `${imageData.uri}_${imageData.width}_${imageData.height}`;
    
    // Use a simple string hash for now (in production, consider crypto.subtle.digest)
    let hash = 0;
    for (let i = 0; i < hashInput.length; i++) {
      const char = hashInput.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    
    return Math.abs(hash).toString(36);
  }

  /**
   * Retrieves cached identification result if available and valid
   * 
   * @param imageData - Image data to check cache for
   * @returns Cached result or null if not found/expired
   */
  private async getCachedResult(imageData: ImageData): Promise<IdentificationResult | null> {
    try {
      const imageHash = await this.generateImageHash(imageData);
      const cacheEntry = this.cache.get(imageHash);
      
      if (!cacheEntry) {
        return null;
      }
      
      // Check if cache entry is expired
      const isExpired = Date.now() - cacheEntry.timestamp > this.config.cacheExpiryMs;
      if (isExpired) {
        this.cache.delete(imageHash);
        return null;
      }
      
      return cacheEntry.result;
    } catch (error) {
      console.warn('Failed to retrieve cached result:', error);
      return null;
    }
  }

  /**
   * Caches identification result
   * 
   * @param imageData - Image data used for identification
   * @param result - Result to cache
   */
  private async cacheResult(imageData: ImageData, result: IdentificationResult): Promise<void> {
    try {
      const imageHash = await this.generateImageHash(imageData);
      
      this.cache.set(imageHash, {
        result,
        timestamp: Date.now(),
        imageHash,
      });
      
      // Clean up old cache entries periodically
      if (this.cache.size > 100) {
        this.cleanupCache();
      }
    } catch (error) {
      console.warn('Failed to cache identification result:', error);
    }
  }

  /**
   * Removes expired entries from cache
   */
  private cleanupCache(): void {
    const now = Date.now();
    const expiredKeys: string[] = [];
    
    for (const [key, entry] of this.cache.entries()) {
      if (now - entry.timestamp > this.config.cacheExpiryMs) {
        expiredKeys.push(key);
      }
    }
    
    expiredKeys.forEach(key => this.cache.delete(key));
  }

  /**
   * Clears all cached results
   */
  clearCache(): void {
    this.cache.clear();
  }

  /**
   * Gets cache statistics
   * 
   * @returns Cache statistics object
   */
  getCacheStats(): { size: number; entries: number } {
    return {
      size: this.cache.size,
      entries: Array.from(this.cache.values()).length,
    };
  }

  /**
   * Updates service configuration
   * 
   * @param newConfig - New configuration values
   */
  updateConfig(newConfig: Partial<PlantIdentificationServiceConfig>): void {
    Object.assign(this.config, newConfig);
    
    // Recreate client if API key changed
    if (newConfig.apiKey) {
      this.client = createPlantIdClient(newConfig.apiKey, {
        timeout: 30000,
        retryAttempts: 3,
      });
    }
  }
}

/**
 * Factory function to create plant identification service
 * 
 * @param config - Service configuration
 * @returns Configured PlantIdentificationService instance
 */
export function createPlantIdentificationService(
  config: PlantIdentificationServiceConfig
): PlantIdentificationService {
  return new PlantIdentificationService(config);
}

/**
 * Default plant identification service instance
 * Should be configured with actual API key before use
 */
let defaultService: PlantIdentificationService | null = null;

/**
 * Gets or creates the default plant identification service
 * 
 * @param apiKey - Plant.id API key (required on first call)
 * @returns Default service instance
 */
export function getPlantIdentificationService(apiKey?: string): PlantIdentificationService {
  if (!defaultService) {
    if (!apiKey) {
      throw new Error('API key is required to initialize plant identification service');
    }
    
    defaultService = createPlantIdentificationService({ apiKey });
  }
  
  return defaultService;
}
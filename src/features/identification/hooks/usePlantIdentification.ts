/**
 * Plant Identification Hook
 * Provides a React hook for identifying plants using the plant identification service
 * Handles loading states, errors, and caching
 */

import { useState, useCallback } from 'react';
import { plantIdentificationService } from '../services';
import { PlantInfo, PlantIdError, IdentificationOptions } from '../../../core/types/plantIdentification';

/**
 * Hook return type for plant identification
 */
interface UsePlantIdentificationReturn {
  /** Identified plants information */
  plants: PlantInfo[];
  /** Whether identification is in progress */
  isLoading: boolean;
  /** Error information if identification failed */
  error: PlantIdError | null;
  /** Confidence level of the identification (0-1) */
  confidence: number;
  /** Function to identify a plant from a base64 image */
  identifyPlant: (base64Image: string, options?: IdentificationOptions) => Promise<void>;
  /** Function to identify a plant from multiple base64 images */
  identifyPlantFromMultipleImages: (base64Images: string[], options?: IdentificationOptions) => Promise<void>;
  /** Function to retry the last identification request */
  retry: () => Promise<void>;
  /** Function to clear current results */
  clearResults: () => void;
  /** Function to check if the service is available */
  checkServiceAvailability: () => Promise<boolean>;
}

/**
 * React hook for plant identification
 * 
 * @returns {UsePlantIdentificationReturn} Plant identification methods and state
 */
export function usePlantIdentification(): UsePlantIdentificationReturn {
  const [plants, setPlants] = useState<PlantInfo[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<PlantIdError | null>(null);
  const [confidence, setConfidence] = useState<number>(0);
  const [lastRequest, setLastRequest] = useState<{
    images: string[];
    options?: IdentificationOptions;
  } | null>(null);

  /**
   * Calculate the overall confidence level from plant results
   * 
   * @param {PlantInfo[]} plants - Identified plants
   * @returns {number} Overall confidence level (0-1)
   */
  const calculateConfidence = useCallback((plants: PlantInfo[]): number => {
    if (!plants || plants.length === 0) return 0;
    
    // Use the highest confidence plant as the overall confidence
    return Math.max(...plants.map(plant => plant.confidence || 0));
  }, []);

  /**
   * Identify a plant from a single base64 image
   * 
   * @param {string} base64Image - Base64-encoded image data
   * @param {IdentificationOptions} options - Optional identification options
   */
  const identifyPlant = useCallback(async (
    base64Image: string,
    options?: IdentificationOptions
  ): Promise<void> => {
    await identifyPlantFromMultipleImages([base64Image], options);
  }, []);

  /**
   * Identify a plant from multiple base64 images
   * 
   * @param {string[]} base64Images - Array of base64-encoded image data
   * @param {IdentificationOptions} options - Optional identification options
   */
  const identifyPlantFromMultipleImages = useCallback(async (
    base64Images: string[],
    options?: IdentificationOptions
  ): Promise<void> => {
    if (!base64Images || base64Images.length === 0) {
      setError({
        code: 'INVALID_INPUT',
        message: 'No images provided for identification'
      });
      return;
    }

    // Save request for retry functionality
    setLastRequest({ images: base64Images, options });
    
    // Reset state
    setError(null);
    setIsLoading(true);
    
    try {
      const results = await plantIdentificationService.identifyPlantFromMultipleImages(
        base64Images,
        options
      );
      
      setPlants(results);
      setConfidence(calculateConfidence(results));
    } catch (err) {
      setPlants([]);
      setConfidence(0);
      setError(err as PlantIdError);
    } finally {
      setIsLoading(false);
    }
  }, [calculateConfidence]);

  /**
   * Retry the last identification request
   */
  const retry = useCallback(async (): Promise<void> => {
    if (!lastRequest) {
      setError({
        code: 'NO_PREVIOUS_REQUEST',
        message: 'No previous identification request to retry'
      });
      return;
    }

    await identifyPlantFromMultipleImages(
      lastRequest.images,
      lastRequest.options
    );
  }, [lastRequest, identifyPlantFromMultipleImages]);

  /**
   * Clear current identification results
   */
  const clearResults = useCallback((): void => {
    setPlants([]);
    setError(null);
    setConfidence(0);
    setLastRequest(null);
  }, []);

  /**
   * Check if the plant identification service is available
   * 
   * @returns {Promise<boolean>} True if service is available
   */
  const checkServiceAvailability = useCallback(async (): Promise<boolean> => {
    try {
      return await plantIdentificationService.checkServiceAvailability();
    } catch (err) {
      return false;
    }
  }, []);

  return {
    plants,
    isLoading,
    error,
    confidence,
    identifyPlant,
    identifyPlantFromMultipleImages,
    retry,
    clearResults,
    checkServiceAvailability
  };
}
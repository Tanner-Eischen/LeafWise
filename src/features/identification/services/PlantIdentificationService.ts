/**
 * Plant Identification Service Implementation
 * Implements the IPlantIdentificationService interface using the Plant.id API
 * Provides plant identification functionality with error handling and caching
 */

import { 
  PlantIdentificationRequest, 
  PlantIdentificationResponse, 
  PlantInfo, 
  PlantIdError,
  IdentificationOptions,
  PlantIdApiConfig,
  PlantSuggestion
} from '../../../core/types/plantIdentification';
import { IPlantIdentificationService } from './IPlantIdentificationService';
import { plantIdApiClient } from '../api';

// Default API configuration
const DEFAULT_CONFIG: PlantIdApiConfig = {
  apiKey: process.env.PLANT_ID_API_KEY || '',
  baseUrl: 'https://api.plant.id/v3/identification',
  timeout: 30000, // 30 seconds
  retryAttempts: 3
};

// Cache configuration
const CACHE_EXPIRY = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
const MAX_CACHE_SIZE = 50; // Maximum number of cached items

/**
 * Implementation of the Plant Identification Service using Plant.id API
 * Provides plant identification with error handling, retries, and caching
 */
export class PlantIdentificationService implements IPlantIdentificationService {
  private config: PlantIdApiConfig;
  private cache: Map<string, { data: PlantInfo[], timestamp: number }>;
  
  /**
   * Creates a new instance of the Plant Identification Service
   * 
   * @param {Partial<PlantIdApiConfig>} config - Optional configuration overrides
   */
  constructor(config?: Partial<PlantIdApiConfig>) {
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.cache = new Map();
    
    if (!this.config.apiKey) {
      console.warn('Plant.id API key not provided. Service will not function correctly.');
    }
  }
  
  /**
   * Identify a plant from a base64-encoded image
   * 
   * @param {string} base64Image - Base64-encoded image data
   * @param {IdentificationOptions} options - Optional configuration for the identification request
   * @returns {Promise<PlantInfo[]>} Array of identified plants with confidence scores
   * @throws {PlantIdError} If identification fails
   */
  async identifyPlant(base64Image: string, options?: IdentificationOptions): Promise<PlantInfo[]> {
    return this.identifyPlantFromMultipleImages([base64Image], options);
  }
  
  /**
   * Identify a plant from multiple base64-encoded images
   * 
   * @param {string[]} base64Images - Array of base64-encoded image data
   * @param {IdentificationOptions} options - Optional configuration for the identification request
   * @returns {Promise<PlantInfo[]>} Array of identified plants with confidence scores
   * @throws {PlantIdError} If identification fails
   */
  async identifyPlantFromMultipleImages(base64Images: string[], options?: IdentificationOptions): Promise<PlantInfo[]> {
    if (!base64Images || base64Images.length === 0) {
      throw this.createError('INVALID_INPUT', 'No images provided for identification');
    }
    
    if (!this.config.apiKey) {
      throw this.createError('MISSING_API_KEY', 'Plant.id API key is not configured');
    }
    
    // Generate cache key from images and options
    const cacheKey = this.generateCacheKey(base64Images, options);
    
    // Check cache first
    const cachedResult = this.getFromCache(cacheKey);
    if (cachedResult) {
      return cachedResult;
    }
    
    // Prepare request payload
    const request: PlantIdentificationRequest = {
      images: base64Images,
      modifiers: ['crops_fast'],
      plant_details: [
        'common_names',
        'url',
        'wiki_description',
        'taxonomy',
        'watering',
        'edible_parts'
      ],
      plant_language: options?.language || 'en',
      classification_level: options?.classificationLevel || 'all'
    };
    
    // Add location if provided
    if (options?.location) {
      request.latitude = options.location.latitude;
      request.longitude = options.location.longitude;
    }
    
    // Add similar images flag if requested
    if (options?.includeSimilarImages) {
      request.similar_images = true;
    }
    
    // Execute API request with retry logic
    let response: PlantIdentificationResponse | null = null;
    let lastError: Error | null = null;
    
    for (let attempt = 0; attempt < this.config.retryAttempts; attempt++) {
      try {
        response = await this.executeApiRequest(request);
        break; // Success, exit retry loop
      } catch (error) {
        lastError = error as Error;
        
        // Don't retry for certain error types
        if (error instanceof Error && 
            (error.message.includes('INVALID_INPUT') || 
             error.message.includes('MISSING_API_KEY'))) {
          throw error;
        }
        
        // Wait before retrying (exponential backoff)
        if (attempt < this.config.retryAttempts - 1) {
          await this.delay(Math.pow(2, attempt) * 1000);
        }
      }
    }
    
    // If all retries failed, throw the last error
    if (!response) {
      throw this.createError(
        'API_REQUEST_FAILED',
        `Failed to identify plant after ${this.config.retryAttempts} attempts`,
        { details: { error: lastError?.message } }
      );
    }
    
    // Map API response to application-specific format
    const plantInfo = this.mapResponseToPlantInfo(response);
    
    // Cache the result
    this.addToCache(cacheKey, plantInfo);
    
    return plantInfo;
  }
  
  /**
   * Convert API response to application-specific PlantInfo format
   * 
   * @param {PlantIdentificationResponse} response - Raw API response
   * @returns {PlantInfo[]} Formatted plant information for application use
   */
  mapResponseToPlantInfo(response: PlantIdentificationResponse): PlantInfo[] {
    if (!response.suggestions || response.suggestions.length === 0) {
      return [];
    }
    
    return response.suggestions.map(suggestion => this.mapSuggestionToPlantInfo(suggestion));
  }
  
  /**
   * Check if the service is available and API key is valid
   * 
   * @returns {Promise<boolean>} True if service is available
   */
  async checkServiceAvailability(): Promise<boolean> {
    try {
      // Use the API client to check availability
      return await plantIdApiClient.checkAvailability();
    } catch (error) {
      console.error('Error checking Plant.id API availability:', error);
      return false;
    }
  }
  
  /**
   * Clear cached identification results
   * 
   * @returns {Promise<void>}
   */
  async clearCache(): Promise<void> {
    this.cache.clear();
  }
  
  /**
   * Execute the API request to identify plants
   * 
   * @param {PlantIdentificationRequest} request - Request payload
   * @returns {Promise<PlantIdentificationResponse>} API response
   * @throws {PlantIdError} If the API request fails
   */
  private async executeApiRequest(request: PlantIdentificationRequest): Promise<PlantIdentificationResponse> {
    try {
      // Use the API client to make the request
      return await plantIdApiClient.identifyPlant(request);
    } catch (error) {
      // Rethrow the error as it's already formatted by the API client
      throw error;
    }
  }
  
  /**
   * Map a suggestion from the API to the application-specific PlantInfo format
   * 
   * @param {PlantSuggestion} suggestion - Plant suggestion from API
   * @returns {PlantInfo} Formatted plant information
   */
  private mapSuggestionToPlantInfo(suggestion: PlantSuggestion): PlantInfo {
    const details = suggestion.plant_details;
    
    return {
      scientificName: suggestion.plant_name,
      commonNames: details.common_names || [],
      family: details.taxonomy?.family,
      genus: details.taxonomy?.genus,
      confidence: suggestion.probability,
      description: details.wiki_description?.value,
      imageUrl: details.image?.value || suggestion.similar_images?.[0]?.url,
      careInfo: {
        watering: details.watering ? 
          `${details.watering.min}-${details.watering.max}` : undefined,
        lightRequirements: undefined, // Not provided by Plant.id API
        growthRate: details.growth_rate,
        edibleParts: details.edible_parts
      }
    };
  }
  
  /**
   * Generate a cache key from images and options
   * 
   * @param {string[]} images - Array of base64-encoded images
   * @param {IdentificationOptions} options - Identification options
   * @returns {string} Cache key
   */
  private generateCacheKey(images: string[], options?: IdentificationOptions): string {
    // Use image hashes instead of full base64 strings for efficiency
    const imageHashes = images.map(img => this.simpleHash(img));
    const optionsString = options ? JSON.stringify(options) : '';
    return `${imageHashes.join('_')}_${this.simpleHash(optionsString)}`;
  }
  
  /**
   * Get cached identification results
   * 
   * @param {string} key - Cache key
   * @returns {PlantInfo[] | null} Cached results or null if not found/expired
   */
  private getFromCache(key: string): PlantInfo[] | null {
    const cached = this.cache.get(key);
    
    if (!cached) {
      return null;
    }
    
    // Check if cache entry has expired
    if (Date.now() - cached.timestamp > CACHE_EXPIRY) {
      this.cache.delete(key);
      return null;
    }
    
    return cached.data;
  }
  
  /**
   * Add identification results to cache
   * 
   * @param {string} key - Cache key
   * @param {PlantInfo[]} data - Plant information to cache
   */
  private addToCache(key: string, data: PlantInfo[]): void {
    // Implement LRU cache behavior if cache is full
    if (this.cache.size >= MAX_CACHE_SIZE) {
      // Find the oldest entry
      let oldestKey = key;
      let oldestTime = Date.now();
      
      this.cache.forEach((value, cacheKey) => {
        if (value.timestamp < oldestTime) {
          oldestTime = value.timestamp;
          oldestKey = cacheKey;
        }
      });
      
      // Remove the oldest entry
      if (oldestKey !== key) {
        this.cache.delete(oldestKey);
      }
    }
    
    // Add new entry to cache
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }
  
  /**
   * Create a standardized error object
   * 
   * @param {string} code - Error code
   * @param {string} message - Error message
   * @param {Object} [additionalInfo] - Additional error details
   * @returns {PlantIdError} Standardized error object
   */
  private createError(code: string, message: string, additionalInfo?: { details?: Record<string, unknown> }): PlantIdError {
    return {
      code,
      message,
      details: additionalInfo?.details,
      timestamp: new Date().toISOString(),
      recoverable: ['NO_PLANT_DETECTED', 'LOW_CONFIDENCE', 'POOR_IMAGE_QUALITY'].includes(code)
    };
  }
  
  /**
   * Simple string hashing function for cache keys
   * 
   * @param {string} str - String to hash
   * @returns {string} Hash string
   */
  private simpleHash(str: string): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.toString(16);
  }
  
  /**
   * Delay execution for a specified time
   * 
   * @param {number} ms - Milliseconds to delay
   * @returns {Promise<void>}
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Export a singleton instance with default configuration
export const plantIdentificationService = new PlantIdentificationService();
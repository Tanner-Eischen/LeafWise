/**
 * Plant.id API client for plant identification services
 * Handles authentication, image upload, and identification requests
 * Implements retry logic and error handling for production use
 * 
 * This module provides a direct interface to the Plant.id REST API,
 * handling the low-level communication details including authentication,
 * request formatting, and response parsing. It serves as the foundation
 * for the plant identification feature.
 * 
 * @module PlantIdentification
 */

import {
  PlantIdentificationRequest,
  PlantIdentificationResponse,
  PlantIdApiConfig,
  PlantIdError,
  IdentificationOptions,
  PlantInfo,
} from '../types/plantIdentification';
import { ImageData, Location } from '../types';

/**
 * Plant.id API client class for handling plant identification requests
 * 
 * This client encapsulates all direct communication with the Plant.id API,
 * providing methods for plant identification and retrieving detailed plant information.
 * It handles authentication, request formatting, and error handling.
 * 
 * @example
 * ```typescript
 * // Create a client instance
 * const client = new PlantIdClient({
 *   apiKey: 'your-api-key',
 *   baseUrl: 'https://api.plant.id',
 *   timeout: 30000
 * });
 * 
 * // Identify a plant from an image
 * const result = await client.identifyPlant(imageData, {
 *   language: 'en',
 *   includeSimilarImages: true,
 *   location: userLocation
 * });
 * ```
 */
export class PlantIdClient {
  private config: PlantIdApiConfig;
  private baseHeaders: Record<string, string>;

  constructor(config: PlantIdApiConfig) {
    this.config = config;
    this.baseHeaders = {
      'Content-Type': 'application/json',
      'Api-Key': config.apiKey,
    };
  }

  /**
   * Identifies a plant from image data
   * 
   * Submits an image to the Plant.id API for analysis and identification.
   * This method handles image conversion, request formatting, and API communication.
   * 
   * @param {ImageData} imageData - The image data to identify (URI and dimensions)
   * @param {IdentificationOptions} [options={}] - Optional identification parameters
   * @returns {Promise<PlantIdentificationResponse>} Promise resolving to plant identification response
   * @throws {PlantIdError} When identification fails due to API errors, network issues, or invalid inputs
   */
  async identifyPlant(
    imageData: ImageData,
    options: IdentificationOptions = {}
  ): Promise<PlantIdentificationResponse> {
    try {
      const base64Image = await this.convertImageToBase64(imageData.uri);
      
      const request: PlantIdentificationRequest = {
        images: [base64Image],
        modifiers: ['crops_fast', 'similar_images'],
        plant_details: this.buildPlantDetails(options),
        plant_language: options.language || 'en',
        classification_level: options.classificationLevel || 'species',
        similar_images: options.includeSimilarImages || false,
      };

      // Add location data if available
      if (options.location) {
        request.latitude = options.location.latitude;
        request.longitude = options.location.longitude;
      }

      const response = await this.makeRequest('/v3/identification', {
        method: 'POST',
        body: JSON.stringify(request),
      });

      return response.result as PlantIdentificationResponse;
    } catch (error) {
      throw this.handleError(error, 'Failed to identify plant');
    }
  }

  /**
   * Gets detailed information about a specific plant species
   * 
   * Retrieves comprehensive information about a plant species from the Plant.id
   * knowledge base, including taxonomy, care instructions, and descriptions.
   * 
   * @param {string} plantName - Scientific name of the plant (e.g., "Quercus robur")
   * @returns {Promise<PlantInfo>} Promise resolving to detailed plant information
   * @throws {PlantIdError} When the API request fails or the plant cannot be found
   */
  async getPlantDetails(plantName: string): Promise<PlantInfo> {
    try {
      const response = await this.makeRequest(`/v3/kb/plants/${encodeURIComponent(plantName)}`);
      return this.formatPlantInfo(response);
    } catch (error) {
      throw this.handleError(error, `Failed to get details for plant: ${plantName}`);
    }
  }

  /**
   * Converts Plant.id API response to simplified PlantInfo format
   * 
   * Transforms the complex API response into a simplified, application-friendly
   * format with only the essential plant information needed by the UI.
   * 
   * @param {PlantIdentificationResponse} response - Raw API response
   * @returns {PlantInfo} Formatted plant information ready for display
   * @throws {Error} When the response contains no valid plant suggestions
   */
  formatPlantInfo(response: PlantIdentificationResponse): PlantInfo {
    const topSuggestion = response.suggestions[0];
    
    if (!topSuggestion) {
      throw new Error('No plant suggestions found in response');
    }

    const details = topSuggestion.plant_details;
    
    return {
      scientificName: topSuggestion.plant_name,
      commonNames: details.common_names || [],
      family: details.taxonomy?.family,
      genus: details.taxonomy?.genus,
      confidence: topSuggestion.probability,
      description: details.wiki_description?.value,
      imageUrl: details.image?.value,
      careInfo: {
        watering: this.formatWateringInfo(details.watering),
        growthRate: details.growth_rate,
        edibleParts: details.edible_parts,
      },
    };
  }

  /**
   * Converts image URI to base64 string
   * 
   * @param imageUri - URI of the image to convert
   * @returns Promise resolving to base64 string
   */
  private async convertImageToBase64(imageUri: string): Promise<string> {
    try {
      const response = await fetch(imageUri);
      const blob = await response.blob();
      
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => {
          const base64String = reader.result as string;
          // Remove data URL prefix (data:image/jpeg;base64,)
          const base64Data = base64String.split(',')[1];
          resolve(base64Data);
        };
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      });
    } catch (error) {
      throw new Error(`Failed to convert image to base64: ${error}`);
    }
  }

  /**
   * Builds plant details array based on options
   * 
   * @param options - Identification options
   * @returns Array of detail strings to request
   */
  private buildPlantDetails(options: IdentificationOptions): string[] {
    const details = ['common_names', 'url'];
    
    if (options.includeDetails) {
      details.push(
        'name_authority',
        'wiki_description',
        'taxonomy',
        'synonyms',
        'image',
        'edible_parts',
        'watering',
        'propagation_methods'
      );
    }
    
    return details;
  }

  /**
   * Formats watering information for display
   * 
   * @param watering - Watering data from API
   * @returns Formatted watering string
   */
  private formatWateringInfo(watering?: { min: number; max: number }): string | undefined {
    if (!watering) return undefined;
    
    const { min, max } = watering;
    if (min === max) {
      return `Every ${min} days`;
    }
    return `Every ${min}-${max} days`;
  }

  /**
   * Makes HTTP request to Plant.id API with retry logic
   * 
   * @param endpoint - API endpoint to call
   * @param options - Fetch options
   * @returns Promise resolving to API response
   */
  private async makeRequest(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<any> {
    const url = `${this.config.baseUrl}${endpoint}`;
    const requestOptions: RequestInit = {
      ...options,
      headers: {
        ...this.baseHeaders,
        ...options.headers,
      },
      signal: AbortSignal.timeout(this.config.timeout),
    };

    let lastError: Error;
    
    for (let attempt = 1; attempt <= this.config.retryAttempts; attempt++) {
      try {
        const response = await fetch(url, requestOptions);
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
      } catch (error) {
        lastError = error as Error;
        
        // Don't retry on client errors (4xx)
        if (error instanceof Error && error.message.includes('HTTP 4')) {
          break;
        }
        
        // Wait before retry (exponential backoff)
        if (attempt < this.config.retryAttempts) {
          await this.delay(Math.pow(2, attempt) * 1000);
        }
      }
    }
    
    throw lastError!;
  }

  /**
   * Handles and formats API errors
   * 
   * @param error - Original error
   * @param context - Error context message
   * @returns Formatted PlantIdError
   */
  private handleError(error: unknown, context: string): PlantIdError {
    if (error instanceof Error) {
      return {
        code: 'PLANT_ID_API_ERROR',
        message: `${context}: ${error.message}`,
        details: {
          apiResponse: error.message,
        },
        timestamp: new Date().toISOString(),
        recoverable: true
      };
    }
    
    return {
      code: 'UNKNOWN_ERROR',
      message: `${context}: Unknown error occurred`,
      details: { apiResponse: error },
      timestamp: new Date().toISOString(),
      recoverable: false
    };
  }

  /**
   * Utility function to add delay
   * 
   * @param ms - Milliseconds to delay
   * @returns Promise that resolves after delay
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Validates API configuration
   * 
   * @param config - Configuration to validate
   * @throws Error if configuration is invalid
   */
  static validateConfig(config: PlantIdApiConfig): void {
    if (!config.apiKey) {
      throw new Error('Plant.id API key is required');
    }
    
    if (!config.baseUrl) {
      throw new Error('Plant.id API base URL is required');
    }
    
    if (config.timeout <= 0) {
      throw new Error('API timeout must be greater than 0');
    }
    
    if (config.retryAttempts < 1) {
      throw new Error('Retry attempts must be at least 1');
    }
  }
}

/**
 * Factory function to create configured Plant.id client
 * 
 * @param apiKey - Plant.id API key
 * @param options - Optional configuration overrides
 * @returns Configured PlantIdClient instance
 */
export function createPlantIdClient(
  apiKey: string,
  options: Partial<PlantIdApiConfig> = {}
): PlantIdClient {
  const config: PlantIdApiConfig = {
    apiKey,
    baseUrl: 'https://api.plant.id',
    timeout: 30000, // 30 seconds
    retryAttempts: 3,
    ...options,
  };
  
  PlantIdClient.validateConfig(config);
  return new PlantIdClient(config);
}
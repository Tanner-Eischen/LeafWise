/**
 * Plant.id API Client
 * Handles HTTP requests to the Plant.id API
 * Provides low-level access to the API endpoints
 */

import { 
  PlantIdentificationRequest, 
  PlantIdentificationResponse,
  PlantIdApiConfig,
  PlantIdError
} from '../../../core/types/plantIdentification';

// Default API configuration
const DEFAULT_CONFIG: PlantIdApiConfig = {
  apiKey: process.env.PLANT_ID_API_KEY || '',
  baseUrl: 'https://api.plant.id/v3/identification',
  timeout: 30000, // 30 seconds
  retryAttempts: 3
};

/**
 * Plant.id API Client
 * Handles direct communication with the Plant.id API
 */
export class PlantIdApiClient {
  private config: PlantIdApiConfig;
  
  /**
   * Creates a new instance of the Plant.id API client
   * 
   * @param {Partial<PlantIdApiConfig>} config - Optional configuration overrides
   */
  constructor(config?: Partial<PlantIdApiConfig>) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }
  
  /**
   * Send a plant identification request to the API
   * 
   * @param {PlantIdentificationRequest} request - Request payload
   * @returns {Promise<PlantIdentificationResponse>} API response
   * @throws {Error} If the API request fails
   */
  async identifyPlant(request: PlantIdentificationRequest): Promise<PlantIdentificationResponse> {
    if (!this.config.apiKey) {
      throw this.createError('MISSING_API_KEY', 'Plant.id API key is not configured');
    }
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);
      
      const response = await fetch(this.config.baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': this.config.apiKey
        },
        body: JSON.stringify(request),
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        const errorText = await response.text();
        throw this.createError(
          'API_ERROR',
          `Plant.id API error: ${response.status} ${response.statusText}`,
          { details: { statusCode: response.status, apiResponse: errorText } }
        );
      }
      
      return await response.json() as PlantIdentificationResponse;
    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        throw this.createError('TIMEOUT', 'Plant identification request timed out');
      }
      
      if (error instanceof Error && 'code' in error) {
        throw error;
      }
      
      throw this.createError(
        'NETWORK_ERROR',
        'Network error during plant identification',
        { details: { error: (error as Error).message } }
      );
    }
  }
  
  /**
   * Check if the API is available and the API key is valid
   * 
   * @returns {Promise<boolean>} True if the API is available
   */
  async checkAvailability(): Promise<boolean> {
    if (!this.config.apiKey) {
      return false;
    }
    
    try {
      const response = await fetch(this.config.baseUrl, {
        method: 'OPTIONS',
        headers: {
          'Api-Key': this.config.apiKey
        }
      });
      
      return response.ok;
    } catch (error) {
      return false;
    }
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
      recoverable: code !== 'MISSING_API_KEY' // Most errors are recoverable except configuration issues
    };
  }
}

// Export a singleton instance with default configuration
export const plantIdApiClient = new PlantIdApiClient();
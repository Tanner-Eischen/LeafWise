/**
 * Plant Identification Service Interface
 * Defines the contract for plant identification services
 * Provides methods for identifying plants from images
 */

import { 
  PlantIdentificationRequest, 
  PlantIdentificationResponse, 
  PlantInfo, 
  PlantIdError,
  IdentificationOptions
} from '../../../core/types/plantIdentification';

/**
 * Interface for plant identification services
 * Defines methods for identifying plants from images and managing identification data
 */
export interface IPlantIdentificationService {
  /**
   * Identify a plant from a base64-encoded image
   * 
   * @param {string} base64Image - Base64-encoded image data
   * @param {IdentificationOptions} options - Optional configuration for the identification request
   * @returns {Promise<PlantInfo[]>} Array of identified plants with confidence scores
   * @throws {PlantIdError} If identification fails
   */
  identifyPlant(base64Image: string, options?: IdentificationOptions): Promise<PlantInfo[]>;
  
  /**
   * Identify a plant from multiple base64-encoded images
   * 
   * @param {string[]} base64Images - Array of base64-encoded image data
   * @param {IdentificationOptions} options - Optional configuration for the identification request
   * @returns {Promise<PlantInfo[]>} Array of identified plants with confidence scores
   * @throws {PlantIdError} If identification fails
   */
  identifyPlantFromMultipleImages(base64Images: string[], options?: IdentificationOptions): Promise<PlantInfo[]>;
  
  /**
   * Convert API response to application-specific PlantInfo format
   * 
   * @param {PlantIdentificationResponse} response - Raw API response
   * @returns {PlantInfo[]} Formatted plant information for application use
   */
  mapResponseToPlantInfo(response: PlantIdentificationResponse): PlantInfo[];
  
  /**
   * Check if the service is available and API key is valid
   * 
   * @returns {Promise<boolean>} True if service is available
   */
  checkServiceAvailability(): Promise<boolean>;
  
  /**
   * Clear cached identification results
   * 
   * @returns {Promise<void>}
   */
  clearCache(): Promise<void>;
}
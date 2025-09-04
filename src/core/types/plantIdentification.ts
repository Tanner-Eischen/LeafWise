/**
 * TypeScript type definitions for Plant.id API integration
 * Defines request/response interfaces for plant identification service
 * Based on Plant.id API v3 documentation
 * 
 * This module contains all the type definitions required for the plant identification
 * feature, including API request/response types, configuration interfaces, and
 * application-specific data structures. These types ensure type safety and provide
 * documentation for the Plant.id API integration.
 * 
 * @module PlantIdentification
 */

import { BaseEntity, ImageData, Location } from './index';

/**
 * Plant identification request interface
 * 
 * Represents the request payload sent to the Plant.id API for plant identification.
 * 
 * @property {string[]} images - Base64 encoded images to be analyzed
 * @property {string[]} [modifiers] - Processing modifiers (e.g., 'crops_fast')
 * @property {string[]} [plant_details] - Plant details to include in response
 * @property {string} [plant_language] - Language for plant information (e.g., 'en')
 * @property {number} [latitude] - Geographical latitude where the plant was found
 * @property {number} [longitude] - Geographical longitude where the plant was found
 * @property {string} [datetime] - Date and time when the image was taken
 * @property {boolean} [similar_images] - Whether to include similar images in response
 * @property {'all' | 'species' | 'genus' | 'family'} [classification_level] - Taxonomic level for identification
 */
export interface PlantIdentificationRequest {
  images: string[]; // Base64 encoded images
  modifiers?: string[];
  plant_details?: string[];
  plant_language?: string;
  latitude?: number;
  longitude?: number;
  datetime?: string;
  similar_images?: boolean;
  classification_level?: 'all' | 'species' | 'genus' | 'family';
}

/**
 * Plant identification response interface
 * 
 * Represents the response from the Plant.id API after plant identification.
 * Contains identification results, suggestions, and metadata.
 * 
 * @property {number} id - Unique identification ID
 * @property {string} [custom_id] - Optional custom identifier
 * @property {Object} meta_data - Metadata about the identification request
 * @property {number} uploaded_datetime - Timestamp when the image was uploaded
 * @property {number} finished_datetime - Timestamp when identification was completed
 * @property {IdentificationImage[]} images - Images used for identification
 * @property {PlantSuggestion[]} suggestions - Plant identification suggestions
 * @property {Object} is_plant - Information about whether the image contains a plant
 * @property {Object} [is_healthy] - Optional information about plant health
 */
export interface PlantIdentificationResponse {
  id: number;
  custom_id?: string;
  meta_data: {
    latitude?: number;
    longitude?: number;
    date?: string;
    datetime?: string;
  };
  uploaded_datetime: number;
  finished_datetime: number;
  images: IdentificationImage[];
  suggestions: PlantSuggestion[];
  is_plant: {
    probability: number;
    threshold: number;
    binary: boolean;
  };
  is_healthy?: {
    probability: number;
    threshold: number;
    binary: boolean;
  };
}

/**
 * Identification image information
 * 
 * Represents an image used for plant identification.
 * 
 * @property {string} file_name - Name of the image file
 * @property {string} url - URL to access the image
 */
export interface IdentificationImage {
  file_name: string;
  url: string;
}

/**
 * Plant suggestion from identification
 * 
 * Represents a single plant suggestion from the identification process.
 * 
 * @property {number} id - Unique suggestion ID
 * @property {string} plant_name - Scientific name of the plant
 * @property {PlantDetails} plant_details - Detailed information about the plant
 * @property {number} probability - Confidence score (0-1) for this suggestion
 * @property {boolean} confirmed - Whether this suggestion has been confirmed
 * @property {SimilarImage[]} similar_images - Similar plant images from database
 */
export interface PlantSuggestion {
  id: number;
  plant_name: string;
  plant_details: PlantDetails;
  probability: number;
  confirmed: boolean;
  similar_images: SimilarImage[];
}

/**
 * Detailed plant information
 * 
 * Contains comprehensive information about a plant species.
 * 
 * @property {string[]} [common_names] - Common names for the plant
 * @property {string} [url] - URL to more information about the plant
 * @property {string} [name_authority] - Botanical authority for the plant name
 * @property {Object} [wiki_description] - Wikipedia description with citation
 * @property {Object} [taxonomy] - Taxonomic classification information
 * @property {string[]} [synonyms] - Scientific name synonyms
 * @property {Object} [image] - Reference image with attribution
 * @property {string[]} [edible_parts] - Edible parts of the plant
 * @property {Object} [watering] - Watering requirements
 * @property {string[]} [propagation_methods] - Methods for propagating the plant
 * @property {Object} [hardiness] - Climate hardiness zones
 * @property {string} [growth_rate] - Plant growth rate description
 */
export interface PlantDetails {
  common_names?: string[];
  url?: string;
  name_authority?: string;
  wiki_description?: {
    value: string;
    citation: string;
    license_name: string;
    license_url: string;
  };
  taxonomy?: {
    class: string;
    genus: string;
    order: string;
    family: string;
    phylum: string;
    kingdom: string;
  };
  synonyms?: string[];
  image?: {
    value: string;
    citation: string;
    license_name: string;
    license_url: string;
  };
  edible_parts?: string[];
  watering?: {
    max: number;
    min: number;
  };
  propagation_methods?: string[];
  hardiness?: {
    min: string;
    max: string;
  };
  growth_rate?: string;
}

/**
 * Similar image reference from the Plant.id database
 * 
 * Represents a similar plant image from the database that matches the submitted image.
 * 
 * @property {string} id - Unique image identifier
 * @property {string} url - URL to access the full-size image
 * @property {string} license_name - Name of the license for the image
 * @property {string} license_url - URL to the license details
 * @property {string} citation - Citation information for the image source
 * @property {number} similarity - Similarity score (0-1) to the submitted image
 * @property {string} url_small - URL to a smaller version of the image
 */
export interface SimilarImage {
  id: string;
  url: string;
  license_name: string;
  license_url: string;
  citation: string;
  similarity: number;
  url_small: string;
}

/**
 * Application-specific plant identification record
 * 
 * Represents a complete plant identification record stored in the application database.
 * Contains both the original input data and the API response.
 * 
 * @property {string} imageUri - URI to the image used for identification
 * @property {ImageData} originalImage - Original image data including dimensions
 * @property {Location} [location] - Optional geographical location where the plant was found
 * @property {PlantIdentificationResponse} apiResponse - Complete API response data
 * @property {PlantSuggestion} [selectedSuggestion] - User-selected or top suggestion
 * @property {'correct' | 'incorrect' | null} [userFeedback] - User feedback on identification accuracy
 * @property {number} confidence - Confidence score (0-1) of the identification
 * @property {boolean} isPlant - Whether the image contains a plant
 * @property {Date} timestamp - When the identification was performed
 */
export interface PlantIdentification extends BaseEntity {
  imageUri: string;
  originalImage: ImageData;
  location?: Location;
  apiResponse: PlantIdentificationResponse;
  selectedSuggestion?: PlantSuggestion;
  userFeedback?: 'correct' | 'incorrect' | null;
  confidence: number;
  isPlant: boolean;
  timestamp: Date;
}

// Simplified plant info for UI display
/**
 * Plant information for application use
 * 
 * Application-specific plant information format used throughout the UI.
 * This is a simplified version of the API response data.
 * 
 * @property {string} scientificName - Scientific name (genus + species)
 * @property {string[]} commonNames - Common names for the plant
 * @property {string} [family] - Taxonomic family
 * @property {string} [genus] - Taxonomic genus
 * @property {number} confidence - Confidence score (0-1) for identification
 * @property {string} [description] - Plant description text
 * @property {string} [imageUrl] - URL to a reference image
 * @property {Object} [careInfo] - Plant care information
 */
export interface PlantInfo {
  scientificName: string;
  commonNames: string[];
  family?: string;
  genus?: string;
  confidence: number;
  description?: string;
  imageUrl?: string;
  careInfo?: {
    temperature?: string;
    humidity?: string;
    watering?: string;
    lightRequirements?: string;
    growthRate?: string;
    edibleParts?: string[];
  };
}

/**
 * Plant.id API client configuration
 * 
 * Configuration options for the Plant.id API client.
 * 
 * @property {string} apiKey - API key for authentication
 * @property {string} baseUrl - Base URL for the API endpoint
 * @property {number} timeout - Request timeout in milliseconds
 * @property {number} retryAttempts - Number of retry attempts for failed requests
 */
export interface PlantIdApiConfig {
  apiKey: string;
  baseUrl: string;
  timeout: number;
  retryAttempts: number;
}

/**
 * Plant identification error
 * 
 * Standardized error format for plant identification failures.
 * 
 * @property {string} code - Error code for programmatic handling
 * @property {string} message - Human-readable error message
 * @property {string|Object} [details] - Additional error details (optional)
 * @property {string} [timestamp] - ISO timestamp when the error occurred
 * @property {boolean} [recoverable] - Whether the error is recoverable by retrying
 */
export interface PlantIdError {
  code: string;
  message: string;
  details?: string | {
    statusCode?: number;
    apiResponse?: unknown;
  };
  timestamp?: string;
  recoverable?: boolean;
}

/**
 * Plant identification request options
 * 
 * Configuration options for customizing plant identification requests.
 * 
 * @property {boolean} [includeDetails] - Whether to include detailed plant information
 * @property {boolean} [includeSimilarImages] - Whether to include similar images in results
 * @property {string} [language] - Language code for plant information (e.g., 'en')
 * @property {Location} [location] - Geographical location where the plant was found
 * @property {'all' | 'species' | 'genus' | 'family'} [classificationLevel] - Taxonomic level for identification
 */
export interface IdentificationOptions {
  includeDetails?: boolean;
  includeSimilarImages?: boolean;
  language?: string;
  location?: Location;
  classificationLevel?: 'all' | 'species' | 'genus' | 'family';
}
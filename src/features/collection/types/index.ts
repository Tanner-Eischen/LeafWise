/**
 * TypeScript type definitions for collection feature
 * Contains interfaces and types specific to the plant collection module
 * Defines data structures for managing user's plant collections
 */

import { BaseEntity, ImageData, Location } from '../../../core/types';
import { PlantDetails, PlantInfo, PlantSuggestion } from '../../../core/types/plantIdentification';

/**
 * Plant Collection interface
 * Represents a user's collection of saved plants
 */
export interface PlantCollection extends BaseEntity {
  /** User ID who owns this collection */
  userId: string;
  /** Name of the collection */
  name: string;
  /** Description of the collection */
  description?: string;
  /** Whether this is the default collection */
  isDefault: boolean;
  /** Collection items count */
  itemCount: number;
  /** Collection cover image (optional) */
  coverImage?: string;
  /** Collection tags for organization */
  tags?: string[];
  /** Whether the collection is public or private */
  isPublic: boolean;
}

/**
 * Collection Item interface
 * Represents a single plant saved in a collection
 */
export interface CollectionItem extends BaseEntity {
  /** ID of the collection this item belongs to */
  collectionId: string;
  /** User ID who owns this item */
  userId: string;
  /** Scientific name of the plant */
  scientificName: string;
  /** Common names of the plant */
  commonNames: string[];
  /** Plant family */
  family?: string;
  /** Plant genus */
  genus?: string;
  /** Plant description */
  description?: string;
  /** Plant image URL */
  imageUrl: string;
  /** Original image data */
  originalImage?: ImageData;
  /** Location where the plant was found */
  location?: Location;
  /** Date when the plant was added to collection */
  collectedAt: Date;
  /** User notes about this plant */
  notes?: string;
  /** Whether this plant is marked as favorite */
  isFavorite: boolean;
  /** Plant care information */
  careInfo?: PlantCareInfo;
  /** Plant identification details (if identified through the app) */
  identificationDetails?: IdentificationDetails;
  /** Custom tags for this plant */
  tags?: string[];
}

/**
 * Plant Care Information interface
 * Contains care instructions for a plant
 */
export interface PlantCareInfo {
  /** Watering requirements */
  watering?: string;
  /** Light requirements */
  lightRequirements?: string;
  /** Growth rate information */
  growthRate?: string;
  /** Soil preferences */
  soilPreferences?: string;
  /** Temperature range */
  temperatureRange?: string;
  /** Humidity preferences */
  humidityPreferences?: string;
  /** Fertilization recommendations */
  fertilization?: string;
  /** Propagation methods */
  propagationMethods?: string[];
  /** Edible parts of the plant */
  edibleParts?: string[];
  /** Toxicity information */
  toxicity?: string;
  /** Pest and disease information */
  pestsAndDiseases?: string[];
}

/**
 * Identification Details interface
 * Contains information about the plant identification process
 */
export interface IdentificationDetails {
  /** ID of the identification request */
  identificationId: string;
  /** Confidence score (0-1) of the identification */
  confidence: number;
  /** Whether the identification was confirmed by the user */
  isConfirmed: boolean;
  /** User feedback on identification accuracy */
  userFeedback?: 'correct' | 'incorrect' | null;
  /** Date when the identification was performed */
  identifiedAt: Date;
  /** Alternative suggestions from identification */
  alternativeSuggestions?: PlantSuggestion[];
  /** Source of identification (api, user, community) */
  source: 'api' | 'user' | 'community';
}

/**
 * Collection Creation Data interface
 * Contains the fields required to create a new collection
 */
export interface CollectionCreateData {
  /** Name of the collection */
  name: string;
  /** Description of the collection */
  description?: string;
  /** Collection cover image (optional) */
  coverImage?: string;
  /** Collection tags for organization */
  tags?: string[];
  /** Whether the collection is public or private */
  isPublic?: boolean;
}

/**
 * Collection Update Data interface
 * Contains the fields that can be updated in a collection
 */
export interface CollectionUpdateData {
  /** Name of the collection */
  name?: string;
  /** Description of the collection */
  description?: string;
  /** Collection cover image */
  coverImage?: string;
  /** Collection tags for organization */
  tags?: string[];
  /** Whether the collection is public or private */
  isPublic?: boolean;
}

/**
 * Collection Item Creation Data interface
 * Contains the fields required to create a new collection item
 */
export interface CollectionItemCreateData {
  /** ID of the collection this item belongs to */
  collectionId: string;
  /** Scientific name of the plant */
  scientificName: string;
  /** Common names of the plant */
  commonNames: string[];
  /** Plant family */
  family?: string;
  /** Plant genus */
  genus?: string;
  /** Plant description */
  description?: string;
  /** Plant image URL */
  imageUrl: string;
  /** Original image data */
  originalImage?: ImageData;
  /** Location where the plant was found */
  location?: Location;
  /** User notes about this plant */
  notes?: string;
  /** Whether this plant is marked as favorite */
  isFavorite?: boolean;
  /** Plant care information */
  careInfo?: PlantCareInfo;
  /** Plant identification details (if identified through the app) */
  identificationDetails?: IdentificationDetails;
  /** Custom tags for this plant */
  tags?: string[];
}

/**
 * Collection Item Update Data interface
 * Contains the fields that can be updated in a collection item
 */
export interface CollectionItemUpdateData {
  /** Scientific name of the plant */
  scientificName?: string;
  /** Common names of the plant */
  commonNames?: string[];
  /** Plant family */
  family?: string;
  /** Plant genus */
  genus?: string;
  /** Plant description */
  description?: string;
  /** Plant image URL */
  imageUrl?: string;
  /** Location where the plant was found */
  location?: Location;
  /** User notes about this plant */
  notes?: string;
  /** Whether this plant is marked as favorite */
  isFavorite?: boolean;
  /** Plant care information */
  careInfo?: Partial<PlantCareInfo>;
  /** Custom tags for this plant */
  tags?: string[];
}

/**
 * Collection Service interface
 * Defines the methods available for collection operations
 */
export interface ICollectionService {
  /** Initialize the collection service */
  initialize(): Promise<void>;
  
  /** Create a new plant collection */
  createCollection(userId: string, data: CollectionCreateData): Promise<PlantCollection>;
  
  /** Get a collection by ID */
  getCollectionById(collectionId: string): Promise<PlantCollection | null>;
  
  /** Get all collections for a user */
  getUserCollections(userId: string): Promise<PlantCollection[]>;
  
  /** Update a collection */
  updateCollection(collectionId: string, data: CollectionUpdateData): Promise<PlantCollection>;
  
  /** Delete a collection */
  deleteCollection(collectionId: string): Promise<void>;
  
  /** Add an item to a collection */
  addItemToCollection(userId: string, data: CollectionItemCreateData): Promise<CollectionItem>;
  
  /** Get a collection item by ID */
  getCollectionItemById(itemId: string): Promise<CollectionItem | null>;
  
  /** Get all items in a collection */
  getCollectionItems(collectionId: string): Promise<CollectionItem[]>;
  
  /** Update a collection item */
  updateCollectionItem(itemId: string, data: CollectionItemUpdateData): Promise<CollectionItem>;
  
  /** Delete a collection item */
  deleteCollectionItem(itemId: string): Promise<void>;
  
  /** Get user's favorite plants */
  getUserFavorites(userId: string): Promise<CollectionItem[]>;
  
  /** Toggle favorite status for a collection item */
  toggleFavorite(itemId: string): Promise<CollectionItem>;
  
  /** Search for plants in user's collections */
  searchUserPlants(userId: string, query: string): Promise<CollectionItem[]>;
  
  /** Get collection statistics for a user */
  getUserCollectionStats(userId: string): Promise<CollectionStatistics>;
}

/**
 * Collection Statistics interface
 * Contains statistics about a user's collections
 */
export interface CollectionStatistics {
  /** Total number of collections */
  totalCollections: number;
  /** Total number of plants saved */
  totalPlants: number;
  /** Number of plants marked as favorites */
  favoritePlants: number;
  /** Number of plants by family */
  plantsByFamily: Record<string, number>;
  /** Number of plants by collection */
  plantsByCollection: Record<string, number>;
  /** Most recent additions */
  recentAdditions: CollectionItem[];
}

/**
 * Collection Error interface
 * Represents an error that occurred during collection operations
 */
export interface CollectionError {
  /** Error code for programmatic handling */
  code: CollectionErrorCode;
  /** Human-readable error message */
  message: string;
  /** Additional error details, if available */
  details?: Record<string, any>;
  /** Timestamp when the error occurred */
  timestamp: string;
  /** Whether the error is recoverable */
  recoverable: boolean;
}

/**
 * Collection error codes
 * Used for programmatic handling of specific error cases
 */
export type CollectionErrorCode = 
  | 'collection/not-found'
  | 'collection/item-not-found'
  | 'collection/already-exists'
  | 'collection/invalid-data'
  | 'collection/permission-denied'
  | 'collection/network-error'
  | 'collection/unknown';

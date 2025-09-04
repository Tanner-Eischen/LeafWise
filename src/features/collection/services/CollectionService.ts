/**
 * Firebase Collection Service
 * Implements the ICollectionService interface using Firebase Firestore
 * Provides functionality for managing plant collections and saved plants
 */

import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import { 
  ICollectionService, 
  PlantCollection, 
  CollectionItem,
  CollectionCreateData, 
  CollectionUpdateData, 
  CollectionItemCreateData, 
  CollectionItemUpdateData,
  CollectionStatistics,
  CollectionError,
  CollectionErrorCode
} from '../types';

/**
 * Firebase Collection Service
 * Provides methods for plant collection management using Firebase Firestore
 */
export class CollectionService implements ICollectionService {
  private isInitialized = false;
  private readonly collectionsCollectionName = 'plantCollections';
  private readonly itemsCollectionName = 'collectionItems';

  /**
   * Initialize the collection service
   * Sets up Firebase Firestore and ensures it's ready for use
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    // Firestore is automatically initialized when imported
    // We just need to mark our service as initialized
    this.isInitialized = true;
  }

  /**
   * Create a new plant collection
   * 
   * @param {string} userId - User ID who owns this collection
   * @param {CollectionCreateData} data - Collection data
   * @returns {Promise<PlantCollection>} Created collection
   */
  async createCollection(userId: string, data: CollectionCreateData): Promise<PlantCollection> {
    try {
      // Check if this is the first collection for the user
      const userCollections = await this.getUserCollections(userId);
      const isDefault = userCollections.length === 0;

      const now = new Date().toISOString();
      
      // Create new collection object
      const newCollection: PlantCollection = {
        id: firestore().collection(this.collectionsCollectionName).doc().id, // Generate Firestore ID
        userId,
        name: data.name,
        description: data.description || '',
        isDefault,
        itemCount: 0,
        coverImage: data.coverImage,
        tags: data.tags || [],
        isPublic: data.isPublic ?? false,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      // Save to Firestore
      await firestore()
        .collection(this.collectionsCollectionName)
        .doc(newCollection.id)
        .set(newCollection);

      return newCollection;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get a collection by ID
   * 
   * @param {string} collectionId - Collection ID
   * @returns {Promise<PlantCollection | null>} Collection or null if not found
   */
  async getCollectionById(collectionId: string): Promise<PlantCollection | null> {
    try {
      const docSnapshot = await firestore()
        .collection(this.collectionsCollectionName)
        .doc(collectionId)
        .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot.data() as PlantCollection;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get all collections for a user
   * 
   * @param {string} userId - User ID
   * @returns {Promise<PlantCollection[]>} List of collections
   */
  async getUserCollections(userId: string): Promise<PlantCollection[]> {
    try {
      const querySnapshot = await firestore()
        .collection(this.collectionsCollectionName)
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .get();

      return querySnapshot.docs.map(doc => doc.data() as PlantCollection);
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Update a collection
   * 
   * @param {string} collectionId - Collection ID
   * @param {CollectionUpdateData} data - Updated collection data
   * @returns {Promise<PlantCollection>} Updated collection
   */
  async updateCollection(collectionId: string, data: CollectionUpdateData): Promise<PlantCollection> {
    try {
      // Get the collection to update
      const collection = await this.getCollectionById(collectionId);
      if (!collection) {
        throw {
          code: 'collection/not-found',
          message: 'Collection not found'
        };
      }

      // Update fields
      const updatedCollection: PlantCollection = {
        ...collection,
        name: data.name ?? collection.name,
        description: data.description ?? collection.description,
        coverImage: data.coverImage ?? collection.coverImage,
        tags: data.tags ?? collection.tags,
        isPublic: data.isPublic ?? collection.isPublic,
        updatedAt: new Date()
      };

      // Save to Firestore
      await firestore()
        .collection(this.collectionsCollectionName)
        .doc(collectionId)
        .update(updatedCollection);

      return updatedCollection;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Delete a collection
   * 
   * @param {string} collectionId - Collection ID
   * @returns {Promise<void>}
   */
  async deleteCollection(collectionId: string): Promise<void> {
    try {
      // Get the collection to check if it exists and get user ID
      const collection = await this.getCollectionById(collectionId);
      if (!collection) {
        throw {
          code: 'collection/not-found',
          message: 'Collection not found'
        };
      }

      // Check if this is the default collection
      if (collection.isDefault) {
        throw {
          code: 'collection/invalid-data',
          message: 'Cannot delete the default collection'
        };
      }

      // Delete all items in the collection first
      const items = await this.getCollectionItems(collectionId);
      const batch = firestore().batch();

      // Add delete operations for all items
      items.forEach(item => {
        const itemRef = firestore().collection(this.itemsCollectionName).doc(item.id);
        batch.delete(itemRef);
      });

      // Add delete operation for the collection
      const collectionRef = firestore().collection(this.collectionsCollectionName).doc(collectionId);
      batch.delete(collectionRef);

      // Execute the batch
      await batch.commit();
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Add an item to a collection
   * 
   * @param {string} userId - User ID
   * @param {CollectionItemCreateData} data - Collection item data
   * @returns {Promise<CollectionItem>} Created collection item
   */
  async addItemToCollection(userId: string, data: CollectionItemCreateData): Promise<CollectionItem> {
    try {
      // Check if the collection exists
      const collection = await this.getCollectionById(data.collectionId);
      if (!collection) {
        throw {
          code: 'collection/not-found',
          message: 'Collection not found'
        };
      }

      // Check if the user owns the collection
      if (collection.userId !== userId) {
        throw {
          code: 'collection/permission-denied',
          message: 'You do not have permission to add items to this collection'
        };
      }

      const now = new Date().toISOString();
      
      // Create new collection item
      const newItem: CollectionItem = {
        id: firestore().collection(this.itemsCollectionName).doc().id, // Generate Firestore ID
        collectionId: data.collectionId,
        userId,
        scientificName: data.scientificName,
        commonNames: data.commonNames,
        family: data.family,
        genus: data.genus,
        description: data.description,
        imageUrl: data.imageUrl,
        originalImage: data.originalImage,
        location: data.location,
        collectedAt: new Date(),
        notes: data.notes,
        isFavorite: data.isFavorite ?? false,
        careInfo: data.careInfo,
        identificationDetails: data.identificationDetails,
        tags: data.tags || [],
        createdAt: new Date(),
        updatedAt: new Date()
      };

      // Use a transaction to update both the item and the collection's item count
      await firestore().runTransaction(async (transaction) => {
        // Add the new item
        const itemRef = firestore().collection(this.itemsCollectionName).doc(newItem.id);
        transaction.set(itemRef, newItem);

        // Update the collection's item count
        const collectionRef = firestore().collection(this.collectionsCollectionName).doc(data.collectionId);
        transaction.update(collectionRef, {
          itemCount: firestore.FieldValue.increment(1),
          updatedAt: now
        });
      });

      return newItem;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get a collection item by ID
   * 
   * @param {string} itemId - Collection item ID
   * @returns {Promise<CollectionItem | null>} Collection item or null if not found
   */
  async getCollectionItemById(itemId: string): Promise<CollectionItem | null> {
    try {
      const docSnapshot = await firestore()
        .collection(this.itemsCollectionName)
        .doc(itemId)
        .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot.data() as CollectionItem;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get all items in a collection
   * 
   * @param {string} collectionId - Collection ID
   * @returns {Promise<CollectionItem[]>} List of collection items
   */
  async getCollectionItems(collectionId: string): Promise<CollectionItem[]> {
    try {
      const querySnapshot = await firestore()
        .collection(this.itemsCollectionName)
        .where('collectionId', '==', collectionId)
        .orderBy('createdAt', 'desc')
        .get();

      return querySnapshot.docs.map(doc => doc.data() as CollectionItem);
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Update a collection item
   * 
   * @param {string} itemId - Collection item ID
   * @param {CollectionItemUpdateData} data - Updated collection item data
   * @returns {Promise<CollectionItem>} Updated collection item
   */
  async updateCollectionItem(itemId: string, data: CollectionItemUpdateData): Promise<CollectionItem> {
    try {
      // Get the item to update
      const item = await this.getCollectionItemById(itemId);
      if (!item) {
        throw {
          code: 'collection/item-not-found',
          message: 'Collection item not found'
        };
      }

      // Update fields
      const updatedItem: CollectionItem = {
        ...item,
        scientificName: data.scientificName ?? item.scientificName,
        commonNames: data.commonNames ?? item.commonNames,
        family: data.family ?? item.family,
        genus: data.genus ?? item.genus,
        description: data.description ?? item.description,
        imageUrl: data.imageUrl ?? item.imageUrl,
        location: data.location ?? item.location,
        notes: data.notes ?? item.notes,
        isFavorite: data.isFavorite ?? item.isFavorite,
        careInfo: data.careInfo ? { ...item.careInfo, ...data.careInfo } : item.careInfo,
        tags: data.tags ?? item.tags,
        updatedAt: new Date()
      };

      // Save to Firestore
      await firestore()
        .collection(this.itemsCollectionName)
        .doc(itemId)
        .update(updatedItem);

      return updatedItem;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Delete a collection item
   * 
   * @param {string} itemId - Collection item ID
   * @returns {Promise<void>}
   */
  async deleteCollectionItem(itemId: string): Promise<void> {
    try {
      // Get the item to check if it exists and get collection ID
      const item = await this.getCollectionItemById(itemId);
      if (!item) {
        throw {
          code: 'collection/item-not-found',
          message: 'Collection item not found'
        };
      }

      // Use a transaction to update both the item and the collection's item count
      await firestore().runTransaction(async (transaction) => {
        // Delete the item
        const itemRef = firestore().collection(this.itemsCollectionName).doc(itemId);
        transaction.delete(itemRef);

        // Update the collection's item count
        const collectionRef = firestore().collection(this.collectionsCollectionName).doc(item.collectionId);
        transaction.update(collectionRef, {
          itemCount: firestore.FieldValue.increment(-1),
          updatedAt: new Date().toISOString()
        });
      });
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get user's favorite plants
   * 
   * @param {string} userId - User ID
   * @returns {Promise<CollectionItem[]>} List of favorite collection items
   */
  async getUserFavorites(userId: string): Promise<CollectionItem[]> {
    try {
      const querySnapshot = await firestore()
        .collection(this.itemsCollectionName)
        .where('userId', '==', userId)
        .where('isFavorite', '==', true)
        .orderBy('createdAt', 'desc')
        .get();

      return querySnapshot.docs.map(doc => doc.data() as CollectionItem);
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Toggle favorite status for a collection item
   * 
   * @param {string} itemId - Collection item ID
   * @returns {Promise<CollectionItem>} Updated collection item
   */
  async toggleFavorite(itemId: string): Promise<CollectionItem> {
    try {
      // Get the item to update
      const item = await this.getCollectionItemById(itemId);
      if (!item) {
        throw {
          code: 'collection/item-not-found',
          message: 'Collection item not found'
        };
      }

      // Toggle favorite status
      const updatedItem: CollectionItem = {
        ...item,
        isFavorite: !item.isFavorite,
        updatedAt: new Date()
      };

      // Save to Firestore
      await firestore()
        .collection(this.itemsCollectionName)
        .doc(itemId)
        .update({
          isFavorite: updatedItem.isFavorite,
          updatedAt: updatedItem.updatedAt
        });

      return updatedItem;
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Search for plants in user's collections
   * 
   * @param {string} userId - User ID
   * @param {string} query - Search query
   * @returns {Promise<CollectionItem[]>} List of matching collection items
   */
  async searchUserPlants(userId: string, query: string): Promise<CollectionItem[]> {
    try {
      // Normalize the query
      const normalizedQuery = query.toLowerCase().trim();
      
      // Get all user's plants
      const querySnapshot = await firestore()
        .collection(this.itemsCollectionName)
        .where('userId', '==', userId)
        .get();

      // Filter items client-side (Firestore doesn't support text search)
      const items = querySnapshot.docs.map(doc => doc.data() as CollectionItem);
      
      return items.filter(item => {
        // Search in scientific name
        if (item.scientificName.toLowerCase().includes(normalizedQuery)) {
          return true;
        }
        
        // Search in common names
        if (item.commonNames.some(name => name.toLowerCase().includes(normalizedQuery))) {
          return true;
        }
        
        // Search in family
        if (item.family && item.family.toLowerCase().includes(normalizedQuery)) {
          return true;
        }
        
        // Search in genus
        if (item.genus && item.genus.toLowerCase().includes(normalizedQuery)) {
          return true;
        }
        
        // Search in description
        if (item.description && item.description.toLowerCase().includes(normalizedQuery)) {
          return true;
        }
        
        // Search in notes
        if (item.notes && item.notes.toLowerCase().includes(normalizedQuery)) {
          return true;
        }
        
        // Search in tags
        if (item.tags && item.tags.some(tag => tag.toLowerCase().includes(normalizedQuery))) {
          return true;
        }
        
        return false;
      });
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Get collection statistics for a user
   * 
   * @param {string} userId - User ID
   * @returns {Promise<CollectionStatistics>} Collection statistics
   */
  async getUserCollectionStats(userId: string): Promise<CollectionStatistics> {
    try {
      // Get all user's collections
      const collections = await this.getUserCollections(userId);
      
      // Get all user's plants
      const querySnapshot = await firestore()
        .collection(this.itemsCollectionName)
        .where('userId', '==', userId)
        .get();
      
      const items = querySnapshot.docs.map(doc => doc.data() as CollectionItem);
      
      // Count plants by family
      const plantsByFamily: Record<string, number> = {};
      items.forEach(item => {
        if (item.family) {
          plantsByFamily[item.family] = (plantsByFamily[item.family] || 0) + 1;
        }
      });
      
      // Count plants by collection
      const plantsByCollection: Record<string, number> = {};
      collections.forEach(collection => {
        plantsByCollection[collection.id] = collection.itemCount;
      });
      
      // Get favorite plants count
      const favoritePlants = items.filter(item => item.isFavorite).length;
      
      // Get recent additions (up to 5)
      const recentAdditions = [...items]
        .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 5);
      
      return {
        totalCollections: collections.length,
        totalPlants: items.length,
        favoritePlants,
        plantsByFamily,
        plantsByCollection,
        recentAdditions
      };
    } catch (error: any) {
      throw this.formatCollectionError(error);
    }
  }

  /**
   * Format Firestore error to our application error format
   * 
   * @param {any} error - Firestore error
   * @returns {CollectionError} Formatted collection error
   * @private
   */
  private formatCollectionError(error: any): CollectionError {
    // Map Firestore error codes to our application error codes
    let code: CollectionErrorCode = 'collection/unknown';
    let message = error.message || 'An unknown collection error occurred';

    if (error.code) {
      // Handle Firestore specific error codes
      switch (error.code) {
        case 'firestore/not-found':
          code = 'collection/not-found';
          message = 'Collection not found';
          break;
        case 'firestore/permission-denied':
          code = 'collection/permission-denied';
          message = 'Permission denied to access collection';
          break;
        case 'firestore/unavailable':
          code = 'collection/network-error';
          message = 'Network error occurred while accessing collection';
          break;
        // Map our custom error codes
        case 'collection/not-found':
        case 'collection/item-not-found':
        case 'collection/already-exists':
        case 'collection/invalid-data':
        case 'collection/permission-denied':
        case 'collection/network-error':
          code = error.code;
          break;
      }
    }

    // Determine if the error is recoverable based on the error code
    const recoverable = code === 'collection/network-error';

    return {
      code,
      message,
      details: error,
      timestamp: new Date().toISOString(),
      recoverable
    };
  }
}

// Create and export a singleton instance
export const collectionService = new CollectionService();
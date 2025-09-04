/**
 * Firebase Profile Service
 * Implements the IProfileService interface using Firebase Firestore
 */

import firestore from '@react-native-firebase/firestore';
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { 
  IProfileService, 
  UserProfile, 
  ProfileUpdateData, 
  ProfileError, 
  ProfileErrorCode 
} from '../types';

/**
 * Firebase Profile Service
 * Provides methods for user profile management using Firebase Firestore
 */
export class ProfileService implements IProfileService {
  private isInitialized = false;
  private readonly collectionName = 'userProfiles';

  /**
   * Initialize the profile service
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
   * Create a new user profile
   * 
   * @param {FirebaseAuthTypes.User} user - Firebase user object
   * @returns {Promise<UserProfile>} Created user profile
   */
  async createProfile(user: FirebaseAuthTypes.User): Promise<UserProfile> {
    try {
      // Check if profile already exists
      const existingProfile = await this.getProfileByUserId(user.uid);
      if (existingProfile) {
        return existingProfile;
      }

      const now = new Date().toISOString();
      
      // Create new profile object
      const newProfile: UserProfile = {
        id: user.uid,
        email: user.email || '',
        displayName: user.displayName || '',
        profilePicture: user.photoURL,
        createdAt: now,
        updatedAt: now,
        notificationPreferences: {
          pushEnabled: true,
          emailEnabled: true,
          newIdentifications: true,
          communityActivity: true,
          appUpdates: true
        },
        settings: {
          theme: 'system',
          language: 'en',
          useMetricUnits: true,
          dataSavingMode: false,
          autoDownloadPlantInfo: true
        },
        statistics: {
          plantsIdentified: 0,
          plantsSaved: 0,
          plantsFavorited: 0,
          activeDays: 1
        }
      };

      // Save to Firestore
      await firestore()
        .collection(this.collectionName)
        .doc(user.uid)
        .set(newProfile);

      return newProfile;
    } catch (error: any) {
      throw this.formatProfileError(error);
    }
  }

  /**
   * Get a user profile by ID
   * 
   * @param {string} userId - User ID
   * @returns {Promise<UserProfile | null>} User profile or null if not found
   */
  async getProfileByUserId(userId: string): Promise<UserProfile | null> {
    try {
      const docSnapshot = await firestore()
        .collection(this.collectionName)
        .doc(userId)
        .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot.data() as UserProfile;
    } catch (error: any) {
      throw this.formatProfileError(error);
    }
  }

  /**
   * Update a user profile
   * 
   * @param {string} userId - User ID
   * @param {ProfileUpdateData} data - Profile data to update
   * @returns {Promise<UserProfile>} Updated user profile
   */
  async updateProfile(userId: string, data: ProfileUpdateData): Promise<UserProfile> {
    try {
      const profile = await this.getProfileByUserId(userId);
      
      if (!profile) {
        throw {
          code: 'profile/not-found',
          message: 'User profile not found'
        };
      }

      // Prepare update data
      const updateData = {
        ...data,
        updatedAt: new Date().toISOString()
      };

      // Handle nested objects
      if (data.notificationPreferences) {
        updateData.notificationPreferences = {
          ...profile.notificationPreferences,
          ...data.notificationPreferences
        };
      }

      if (data.settings) {
        updateData.settings = {
          ...profile.settings,
          ...data.settings
        };
      }

      // Update in Firestore
      await firestore()
        .collection(this.collectionName)
        .doc(userId)
        .update(updateData);

      // Get and return the updated profile
      return await this.getProfileByUserId(userId) as UserProfile;
    } catch (error: any) {
      throw this.formatProfileError(error);
    }
  }

  /**
   * Delete a user profile
   * 
   * @param {string} userId - User ID
   * @returns {Promise<void>}
   */
  async deleteProfile(userId: string): Promise<void> {
    try {
      await firestore()
        .collection(this.collectionName)
        .doc(userId)
        .delete();
    } catch (error: any) {
      throw this.formatProfileError(error);
    }
  }

  /**
   * Get the current user's profile
   * 
   * @returns {Promise<UserProfile | null>} Current user profile or null
   */
  async getCurrentUserProfile(): Promise<UserProfile | null> {
    const currentUser = auth().currentUser;
    
    if (!currentUser) {
      return null;
    }

    return this.getProfileByUserId(currentUser.uid);
  }

  /**
   * Listen to changes in the current user's profile
   * 
   * @param {Function} callback - Callback function for profile changes
   * @returns {Function} Unsubscribe function
   */
  onProfileChanged(callback: (profile: UserProfile | null) => void): () => void {
    const currentUser = auth().currentUser;
    
    if (!currentUser) {
      callback(null);
      return () => {};
    }

    return firestore()
      .collection(this.collectionName)
      .doc(currentUser.uid)
      .onSnapshot(
        (docSnapshot) => {
          if (!docSnapshot.exists) {
            callback(null);
            return;
          }
          
          callback(docSnapshot.data() as UserProfile);
        },
        (error) => {
          console.error('Profile listener error:', error);
          // Don't throw here as this is an event listener
        }
      );
  }

  /**
   * Format Firestore error to our application error format
   * 
   * @param {any} error - Firestore error
   * @returns {ProfileError} Formatted profile error
   * @private
   */
  formatProfileError(error: any): ProfileError {
    // Map Firestore error codes to our application error codes
    let code: ProfileErrorCode = 'profile/unknown';
    let message = error.message || 'An unknown profile error occurred';

    if (error.code) {
      // Handle Firestore specific error codes
      switch (error.code) {
        case 'firestore/not-found':
          code = 'profile/not-found';
          message = 'User profile not found';
          break;
        case 'firestore/permission-denied':
          code = 'profile/permission-denied';
          message = 'Permission denied to access profile';
          break;
        case 'firestore/unavailable':
          code = 'profile/network-error';
          message = 'Network error occurred while accessing profile';
          break;
        // Map our custom error codes
        case 'profile/not-found':
        case 'profile/already-exists':
        case 'profile/invalid-data':
        case 'profile/permission-denied':
        case 'profile/network-error':
          code = error.code;
          break;
      }
    }

    // Determine if the error is recoverable
    const recoverable = [
      'profile/network-error',
      'profile/invalid-data'
    ].includes(code);

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
export const profileService = new ProfileService();
/**
 * TypeScript type definitions for profile feature
 * Contains interfaces and types specific to the user profile module
 */

import { FirebaseAuthTypes } from '@react-native-firebase/auth';

/**
 * User Profile interface
 * Represents the user profile data structure
 */
export interface UserProfile {
  /** Unique identifier for the user profile */
  id: string;
  /** User's email address */
  email: string;
  /** User's display name */
  displayName: string;
  /** URL to user's profile picture (optional) */
  profilePicture: string | null;
  /** Timestamp when the profile was created */
  createdAt: string;
  /** Timestamp when the profile was last updated */
  updatedAt: string;
  /** User's bio or about information (optional) */
  bio?: string;
  /** User's location (optional) */
  location?: string;
  /** User's preferred plant categories (optional) */
  preferredCategories?: string[];
  /** User's notification preferences */
  notificationPreferences?: NotificationPreferences;
  /** User's application settings */
  settings?: UserSettings;
  /** User's statistics */
  statistics?: UserStatistics;
}

/**
 * Notification Preferences interface
 * Contains user preferences for different notification types
 */
export interface NotificationPreferences {
  /** Whether to receive push notifications */
  pushEnabled: boolean;
  /** Whether to receive email notifications */
  emailEnabled: boolean;
  /** Whether to receive notifications about new plant identifications */
  newIdentifications: boolean;
  /** Whether to receive notifications about community activity */
  communityActivity: boolean;
  /** Whether to receive notifications about app updates */
  appUpdates: boolean;
}

/**
 * User Settings interface
 * Contains user application settings
 */
export interface UserSettings {
  /** User's preferred theme (light/dark/system) */
  theme: 'light' | 'dark' | 'system';
  /** User's preferred language */
  language: string;
  /** Whether to use metric or imperial units */
  useMetricUnits: boolean;
  /** Whether to enable data saving mode */
  dataSavingMode: boolean;
  /** Whether to automatically download plant information */
  autoDownloadPlantInfo: boolean;
}

/**
 * User Statistics interface
 * Contains user activity statistics
 */
export interface UserStatistics {
  /** Number of plants identified */
  plantsIdentified: number;
  /** Number of plants saved to collection */
  plantsSaved: number;
  /** Number of plants marked as favorites */
  plantsFavorited: number;
  /** Number of days with app activity */
  activeDays: number;
  /** Date of last plant identification */
  lastIdentificationDate?: string;
  /** Identification accuracy rate (if applicable) */
  identificationAccuracy?: number;
}

/**
 * Profile Update Data interface
 * Contains the fields that can be updated in a user profile
 */
export interface ProfileUpdateData {
  /** User's display name */
  displayName?: string;
  /** URL to user's profile picture */
  profilePicture?: string | null;
  /** User's bio or about information */
  bio?: string;
  /** User's location */
  location?: string;
  /** User's preferred plant categories */
  preferredCategories?: string[];
  /** User's notification preferences */
  notificationPreferences?: Partial<NotificationPreferences>;
  /** User's application settings */
  settings?: Partial<UserSettings>;
}

/**
 * Profile Service interface
 * Defines the methods available for profile operations
 */
export interface IProfileService {
  /** Initialize the profile service */
  initialize(): Promise<void>;
  
  /** Create a new user profile */
  createProfile(user: FirebaseAuthTypes.User): Promise<UserProfile>;
  
  /** Get a user profile by ID */
  getProfileByUserId(userId: string): Promise<UserProfile | null>;
  
  /** Update a user profile */
  updateProfile(userId: string, data: ProfileUpdateData): Promise<UserProfile>;
  
  /** Delete a user profile */
  deleteProfile(userId: string): Promise<void>;
  
  /** Get the current user's profile */
  getCurrentUserProfile(): Promise<UserProfile | null>;
  
  /** Listen to changes in the current user's profile */
  onProfileChanged(callback: (profile: UserProfile | null) => void): () => void;
}

/**
 * Profile Error interface
 * Represents an error that occurred during profile operations
 */
export interface ProfileError {
  /** Error code for programmatic handling */
  code: ProfileErrorCode;
  /** Human-readable error message */
  message: string;
  /** Additional error details, if available */
  details?: Record<string, any>;
  /** ISO timestamp when the error occurred */
  timestamp?: string;
  /** Whether the error is recoverable by the user */
  recoverable?: boolean;
}

/**
 * Profile error codes
 * Used for programmatic handling of specific error cases
 */
export type ProfileErrorCode = 
  | 'profile/not-found'
  | 'profile/already-exists'
  | 'profile/invalid-data'
  | 'profile/permission-denied'
  | 'profile/network-error'
  | 'profile/unknown';
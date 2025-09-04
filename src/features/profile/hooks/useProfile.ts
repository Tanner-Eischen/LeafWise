/**
 * useProfile Hook
 * Custom hook for accessing and managing user profile data
 */

import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../../auth/hooks/useAuth';
import { ProfileService, profileService } from '../services/ProfileService';
import { UserProfile, ProfileUpdateData, ProfileError } from '../types';

/**
 * Return type for useProfile hook
 */
interface UseProfileResult {
  /** The current user's profile */
  profile: UserProfile | null;
  /** Whether the profile is currently loading */
  isLoading: boolean;
  /** Any error that occurred while loading or updating the profile */
  error: ProfileError | null;
  /** Function to reload the profile data */
  refreshProfile: () => Promise<void>;
  /** Function to update the profile */
  updateProfile: (data: ProfileUpdateData) => Promise<UserProfile>;
}

/**
 * Custom hook for accessing and managing user profile data
 * 
 * @returns {UseProfileResult} Profile data and management functions
 */
export function useProfile(): UseProfileResult {
  // State
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<ProfileError | null>(null);
  
  // Get current user from auth context
  const { user } = useAuth();
  
  /**
   * Load the current user's profile
   */
  const loadProfile = useCallback(async () => {
    // Reset state
    setIsLoading(true);
    setError(null);
    
    // If no user is logged in, clear profile and return
    if (!user) {
      setProfile(null);
      setIsLoading(false);
      return;
    }
    
    try {
      // Try to get existing profile
      try {
        const userProfile = await profileService.getCurrentUserProfile();
        setProfile(userProfile);
      } catch (err: any) {
        // If profile doesn't exist, create a new one
        if (err.message.includes('Profile not found')) {
          // Pass the Firebase user object directly to createProfile
          const newProfile = await profileService.createProfile(user);
          setProfile(newProfile);
        } else {
          throw err;
        }
      }
    } catch (err: any) {
      console.error('Error loading profile:', err);
      setError(profileService.formatProfileError(err));
    } finally {
      setIsLoading(false);
    }
  }, [user]);
  
  /**
   * Update the user's profile
   * 
   * @param {ProfileUpdateData} data - The data to update
   * @returns {Promise<UserProfile>} The updated profile
   */
  const updateProfile = async (data: ProfileUpdateData): Promise<UserProfile> => {
    if (!profile) {
      throw new Error('No profile loaded');
    }
    
    try {
      setIsLoading(true);
      setError(null);
      
      const updatedProfile = await profileService.updateProfile(profile.id, data);
      setProfile(updatedProfile);
      return updatedProfile;
    } catch (err: any) {
      console.error('Error updating profile:', err);
      const formattedError = profileService.formatProfileError(err);
      setError(formattedError);
      throw formattedError;
    } finally {
      setIsLoading(false);
    }
  };
  
  // Load profile when user changes
  useEffect(() => {
    loadProfile();
  }, [loadProfile]);
  
  return {
    profile,
    isLoading,
    error,
    refreshProfile: loadProfile,
    updateProfile,
  };
}
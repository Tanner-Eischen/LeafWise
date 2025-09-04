/**
 * Profile Provider Component
 * Provides profile context to the application
 */

import React, { createContext, useContext, ReactNode } from 'react';
import { useProfile } from '../hooks/useProfile';
import { UserProfile, ProfileUpdateData, ProfileError } from '../types';

/**
 * Profile context value interface
 */
interface ProfileContextValue {
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
 * Profile provider props
 */
interface ProfileProviderProps {
  /** Child components */
  children: ReactNode;
}

// Create context
const ProfileContext = createContext<ProfileContextValue | undefined>(undefined);

/**
 * Profile Provider Component
 * Provides profile context to the application
 * 
 * @param {ProfileProviderProps} props - Component props
 * @returns {JSX.Element} Profile provider component
 */
export function ProfileProvider({ children }: ProfileProviderProps): JSX.Element {
  const profileData = useProfile();
  
  return (
    <ProfileContext.Provider value={profileData}>
      {children}
    </ProfileContext.Provider>
  );
}

/**
 * Custom hook to use the profile context
 * 
 * @returns {ProfileContextValue} Profile context value
 * @throws {Error} If used outside of a ProfileProvider
 */
export function useProfileContext(): ProfileContextValue {
  const context = useContext(ProfileContext);
  
  if (context === undefined) {
    throw new Error('useProfileContext must be used within a ProfileProvider');
  }
  
  return context;
}
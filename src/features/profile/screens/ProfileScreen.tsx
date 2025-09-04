/**
 * Profile Screen
 * Displays user profile information and provides access to profile editing
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  ActivityIndicator,
  Alert
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../../auth/hooks/useAuth';
import { profileService } from '../services/ProfileService';
import { ProfileEditor } from '../components/ProfileEditor';
import ProfileStatistics from '../components/ProfileStatistics';
import { AccountDeletion } from '../components/AccountDeletion';
import { UserProfile } from '../types';

/**
 * Profile Screen Component
 * Displays user profile information and provides access to profile editing
 * 
 * @returns {JSX.Element} Profile screen component
 */
export function ProfileScreen(): JSX.Element {
  // State
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  
  // Hooks
  const { user } = useAuth();
  const navigation = useNavigation();
  
  /**
   * Load user profile data
   */
  const loadProfile = async () => {
    if (!user) {
      setError('You must be logged in to view your profile');
      setIsLoading(false);
      return;
    }
    
    try {
      setIsLoading(true);
      setError(null);
      
      // Try to get existing profile
      try {
        const userProfile = await profileService.getProfileByUserId(user.uid);
        setProfile(userProfile);
      } catch (error: any) {
        // If profile doesn't exist, create a new one
        if (error.message.includes('Profile not found')) {
          // Pass the Firebase user object directly to createProfile
          const newProfile = await profileService.createProfile(user);
          setProfile(newProfile);
        } else {
          throw error;
        }
      }
    } catch (error: any) {
      console.error('Error loading profile:', error);
      setError(error.message || 'Failed to load profile');
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * Handle profile update
   */
  const handleProfileUpdated = (updatedProfile: UserProfile) => {
    setProfile(updatedProfile);
    setIsEditing(false);
    Alert.alert('Success', 'Your profile has been updated successfully.');
  };
  
  /**
   * Format date for display
   */
  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };
  
  // Load profile on mount
  useEffect(() => {
    loadProfile();
  }, [user]);
  
  // Show loading state
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4CAF50" />
        <Text style={styles.loadingText}>Loading profile...</Text>
      </View>
    );
  }
  
  // Show error state
  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={loadProfile}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }
  
  // Show profile editor if editing
  if (isEditing && profile) {
    return (
      <ProfileEditor
        initialProfile={profile}
        onProfileUpdated={handleProfileUpdated}
        onCancel={() => setIsEditing(false)}
      />
    );
  }
  
  // Show profile view
  return (
    <ScrollView style={styles.container}>
      {profile && (
        <>
          {/* Profile Header */}
          <View style={styles.header}>
            <View style={styles.profileImageContainer}>
              {profile.profilePicture ? (
                <Image 
                  source={{ uri: profile.profilePicture }} 
                  style={styles.profileImage} 
                />
              ) : (
                <View style={[styles.profileImage, styles.profileImagePlaceholder]}>
                  <Text style={styles.profileImagePlaceholderText}>
                    {profile.displayName.charAt(0).toUpperCase()}
                  </Text>
                </View>
              )}
            </View>
            
            <Text style={styles.displayName}>{profile.displayName}</Text>
            {profile.bio && <Text style={styles.bio}>{profile.bio}</Text>}
            {profile.location && (
              <Text style={styles.location}>{profile.location}</Text>
            )}
            
            <TouchableOpacity 
              style={styles.editButton}
              onPress={() => setIsEditing(true)}
            >
              <Text style={styles.editButtonText}>Edit Profile</Text>
            </TouchableOpacity>
          </View>
          
          {/* User Statistics */}
          <View style={styles.section}>
            <ProfileStatistics statistics={profile.statistics} />
          </View>
          
          {/* Preferred Categories */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Preferred Plant Categories</Text>
            {profile.preferredCategories && profile.preferredCategories.length > 0 ? (
              <View style={styles.categoriesContainer}>
                {profile.preferredCategories.map((category) => (
                  <View key={category} style={styles.categoryChip}>
                    <Text style={styles.categoryChipText}>{category}</Text>
                  </View>
                ))}
              </View>
            ) : (
              <Text style={styles.emptyStateText}>
                No preferred categories selected. Edit your profile to add some!
              </Text>
            )}
          </View>
          
          {/* Settings */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Settings</Text>
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Theme</Text>
              <Text style={styles.settingValue}>
                {profile.settings?.theme === 'system' 
                  ? 'System Default' 
                  : profile.settings?.theme === 'dark' 
                    ? 'Dark Mode' 
                    : 'Light Mode'}
              </Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Units</Text>
              <Text style={styles.settingValue}>
                {profile.settings?.useMetricUnits ? 'Metric' : 'Imperial'}
              </Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Data Saving Mode</Text>
              <Text style={styles.settingValue}>
                {profile.settings?.dataSavingMode ? 'Enabled' : 'Disabled'}
              </Text>
            </View>
          </View>
          
          {/* Notification Preferences */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Notification Preferences</Text>
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Push Notifications</Text>
              <Text style={styles.settingValue}>
                {profile.notificationPreferences?.pushEnabled ? 'Enabled' : 'Disabled'}
              </Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Email Notifications</Text>
              <Text style={styles.settingValue}>
                {profile.notificationPreferences?.emailEnabled ? 'Enabled' : 'Disabled'}
              </Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>New Plant Identifications</Text>
              <Text style={styles.settingValue}>
                {profile.notificationPreferences?.newIdentifications ? 'Enabled' : 'Disabled'}
              </Text>
            </View>
          </View>
          
          {/* Account Information */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Account Information</Text>
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Email</Text>
              <Text style={styles.settingValue}>{profile.email}</Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Member Since</Text>
              <Text style={styles.settingValue}>
                {formatDate(new Date(profile.createdAt))}
              </Text>
            </View>
            
            <View style={styles.settingItem}>
              <Text style={styles.settingLabel}>Last Updated</Text>
              <Text style={styles.settingValue}>
                {formatDate(new Date(profile.updatedAt))}
              </Text>
            </View>
          </View>
          
          {/* Account Management */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Account Management</Text>
            <AccountDeletion />
          </View>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#555555',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    padding: 20,
  },
  errorText: {
    fontSize: 16,
    color: '#D32F2F',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  header: {
    alignItems: 'center',
    padding: 24,
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  profileImageContainer: {
    marginBottom: 16,
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
  },
  profileImagePlaceholder: {
    backgroundColor: '#E0E0E0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileImagePlaceholderText: {
    fontSize: 48,
    color: '#757575',
  },
  displayName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333333',
    marginBottom: 8,
  },
  bio: {
    fontSize: 16,
    color: '#555555',
    textAlign: 'center',
    marginBottom: 8,
    paddingHorizontal: 24,
  },
  location: {
    fontSize: 14,
    color: '#757575',
    marginBottom: 16,
  },
  editButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  editButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  section: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333333',
  },

  categoriesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryChip: {
    backgroundColor: '#E8F5E9',
    borderRadius: 16,
    paddingVertical: 8,
    paddingHorizontal: 16,
    margin: 4,
  },
  categoryChipText: {
    color: '#4CAF50',
    fontSize: 14,
  },
  emptyStateText: {
    fontSize: 14,
    color: '#757575',
    fontStyle: 'italic',
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#F5F5F5',
  },
  settingLabel: {
    fontSize: 16,
    color: '#555555',
  },
  settingValue: {
    fontSize: 16,
    color: '#333333',
    fontWeight: '500',
  },
});
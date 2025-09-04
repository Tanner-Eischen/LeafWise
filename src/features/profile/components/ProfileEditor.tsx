/**
 * Profile Editor Component
 * Provides a form for editing user profile information
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Switch,
  ActivityIndicator,
  Image,
  Alert
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { UserProfile, ProfileUpdateData } from '../types';
import { profileService } from '../services/ProfileService';

/**
 * Profile Editor props
 */
interface ProfileEditorProps {
  /** Initial profile data */
  initialProfile: UserProfile;
  /** Callback function called after successful profile update */
  onProfileUpdated?: (profile: UserProfile) => void;
  /** Callback function called when user cancels editing */
  onCancel?: () => void;
}

/**
 * Profile Editor Component
 * Provides a form for editing user profile information
 * 
 * @param {ProfileEditorProps} props - Component props
 * @returns {JSX.Element} Profile editor component
 */
export function ProfileEditor({
  initialProfile,
  onProfileUpdated,
  onCancel
}: ProfileEditorProps): JSX.Element {
  // Form state
  const [displayName, setDisplayName] = useState(initialProfile.displayName);
  const [bio, setBio] = useState(initialProfile.bio || '');
  const [location, setLocation] = useState(initialProfile.location || '');
  const [profilePicture, setProfilePicture] = useState<string | null>(initialProfile.profilePicture);
  const [preferredCategories, setPreferredCategories] = useState<string[]>(
    initialProfile.preferredCategories || []
  );
  
  // Settings state
  const [theme, setTheme] = useState(initialProfile.settings?.theme || 'system');
  const [useMetricUnits, setUseMetricUnits] = useState(
    initialProfile.settings?.useMetricUnits ?? true
  );
  const [dataSavingMode, setDataSavingMode] = useState(
    initialProfile.settings?.dataSavingMode ?? false
  );
  
  // Notification preferences state
  const [pushEnabled, setPushEnabled] = useState(
    initialProfile.notificationPreferences?.pushEnabled ?? true
  );
  const [emailEnabled, setEmailEnabled] = useState(
    initialProfile.notificationPreferences?.emailEnabled ?? true
  );
  const [newIdentifications, setNewIdentifications] = useState(
    initialProfile.notificationPreferences?.newIdentifications ?? true
  );
  
  // UI state
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isImagePickerVisible, setIsImagePickerVisible] = useState(false);
  
  // Available plant categories
  const availableCategories = [
    'Trees',
    'Flowers',
    'Succulents',
    'Vegetables',
    'Fruits',
    'Herbs',
    'Houseplants',
    'Cacti',
    'Grasses',
    'Ferns'
  ];
  
  /**
   * Handle profile picture selection
   */
  const handleSelectProfilePicture = async () => {
    try {
      // Request permissions
      const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
      
      if (!permissionResult.granted) {
        Alert.alert('Permission Required', 'You need to grant access to your photo library to select a profile picture.');
        return;
      }
      
      // Launch image picker
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });
      
      if (!result.canceled && result.assets && result.assets.length > 0) {
        setProfilePicture(result.assets[0].uri);
      }
    } catch (error) {
      console.error('Error selecting profile picture:', error);
      setError('Failed to select profile picture. Please try again.');
    }
  };
  
  /**
   * Toggle a category in the preferred categories list
   */
  const toggleCategory = (category: string) => {
    setPreferredCategories(current => {
      if (current.includes(category)) {
        return current.filter(c => c !== category);
      } else {
        return [...current, category];
      }
    });
  };
  
  /**
   * Handle form submission
   */
  const handleSubmit = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      // Validate display name
      if (!displayName.trim()) {
        setError('Display name is required');
        setIsLoading(false);
        return;
      }
      
      // Prepare update data
      const updateData: ProfileUpdateData = {
        displayName: displayName.trim(),
        profilePicture,
        bio: bio.trim() || undefined,
        location: location.trim() || undefined,
        preferredCategories: preferredCategories.length > 0 ? preferredCategories : undefined,
        settings: {
          theme,
          useMetricUnits,
          dataSavingMode
        },
        notificationPreferences: {
          pushEnabled,
          emailEnabled,
          newIdentifications
        }
      };
      
      // Update profile
      const updatedProfile = await profileService.updateProfile(
        initialProfile.id,
        updateData
      );
      
      // Call callback if provided
      if (onProfileUpdated) {
        onProfileUpdated(updatedProfile);
      }
    } catch (error: any) {
      console.error('Error updating profile:', error);
      setError(error.message || 'Failed to update profile. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Edit Profile</Text>
      </View>
      
      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}
      
      {/* Profile Picture */}
      <View style={styles.profilePictureContainer}>
        {profilePicture ? (
          <Image source={{ uri: profilePicture }} style={styles.profilePicture} />
        ) : (
          <View style={[styles.profilePicture, styles.profilePicturePlaceholder]}>
            <Text style={styles.profilePicturePlaceholderText}>
              {displayName.charAt(0).toUpperCase()}
            </Text>
          </View>
        )}
        <TouchableOpacity 
          style={styles.changeProfilePictureButton}
          onPress={handleSelectProfilePicture}
        >
          <Text style={styles.changeProfilePictureButtonText}>
            Change Profile Picture
          </Text>
        </TouchableOpacity>
      </View>
      
      {/* Basic Information */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Basic Information</Text>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Display Name *</Text>
          <TextInput
            style={styles.input}
            value={displayName}
            onChangeText={setDisplayName}
            placeholder="Enter your display name"
          />
        </View>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Bio</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={bio}
            onChangeText={setBio}
            placeholder="Tell us about yourself"
            multiline
            numberOfLines={4}
          />
        </View>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Location</Text>
          <TextInput
            style={styles.input}
            value={location}
            onChangeText={setLocation}
            placeholder="Enter your location"
          />
        </View>
      </View>
      
      {/* Preferred Categories */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Preferred Plant Categories</Text>
        <View style={styles.categoriesContainer}>
          {availableCategories.map(category => (
            <TouchableOpacity
              key={category}
              style={[
                styles.categoryChip,
                preferredCategories.includes(category) && styles.categoryChipSelected
              ]}
              onPress={() => toggleCategory(category)}
            >
              <Text 
                style={[
                  styles.categoryChipText,
                  preferredCategories.includes(category) && styles.categoryChipTextSelected
                ]}
              >
                {category}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>
      
      {/* Settings */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Settings</Text>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>Theme</Text>
          <View style={styles.themeSelector}>
            <TouchableOpacity
              style={[
                styles.themeOption,
                theme === 'light' && styles.themeOptionSelected
              ]}
              onPress={() => setTheme('light')}
            >
              <Text style={styles.themeOptionText}>Light</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.themeOption,
                theme === 'dark' && styles.themeOptionSelected
              ]}
              onPress={() => setTheme('dark')}
            >
              <Text style={styles.themeOptionText}>Dark</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.themeOption,
                theme === 'system' && styles.themeOptionSelected
              ]}
              onPress={() => setTheme('system')}
            >
              <Text style={styles.themeOptionText}>System</Text>
            </TouchableOpacity>
          </View>
        </View>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>Use Metric Units</Text>
          <Switch
            value={useMetricUnits}
            onValueChange={setUseMetricUnits}
          />
        </View>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>Data Saving Mode</Text>
          <Switch
            value={dataSavingMode}
            onValueChange={setDataSavingMode}
          />
        </View>
      </View>
      
      {/* Notification Preferences */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Notification Preferences</Text>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>Push Notifications</Text>
          <Switch
            value={pushEnabled}
            onValueChange={setPushEnabled}
          />
        </View>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>Email Notifications</Text>
          <Switch
            value={emailEnabled}
            onValueChange={setEmailEnabled}
          />
        </View>
        
        <View style={styles.settingContainer}>
          <Text style={styles.settingLabel}>New Plant Identifications</Text>
          <Switch
            value={newIdentifications}
            onValueChange={setNewIdentifications}
          />
        </View>
      </View>
      
      {/* Action Buttons */}
      <View style={styles.actionButtons}>
        <TouchableOpacity 
          style={[styles.button, styles.cancelButton]}
          onPress={onCancel}
          disabled={isLoading}
        >
          <Text style={styles.cancelButtonText}>Cancel</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.saveButton, isLoading && styles.disabledButton]}
          onPress={handleSubmit}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator size="small" color="#FFFFFF" />
          ) : (
            <Text style={styles.saveButtonText}>Save Changes</Text>
          )}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  header: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333333',
  },
  errorContainer: {
    backgroundColor: '#FFEBEE',
    padding: 12,
    margin: 16,
    borderRadius: 8,
  },
  errorText: {
    color: '#D32F2F',
    fontSize: 14,
  },
  profilePictureContainer: {
    alignItems: 'center',
    padding: 16,
  },
  profilePicture: {
    width: 120,
    height: 120,
    borderRadius: 60,
  },
  profilePicturePlaceholder: {
    backgroundColor: '#E0E0E0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  profilePicturePlaceholderText: {
    fontSize: 48,
    color: '#757575',
  },
  changeProfilePictureButton: {
    marginTop: 12,
    padding: 8,
  },
  changeProfilePictureButtonText: {
    color: '#2196F3',
    fontSize: 16,
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
  inputContainer: {
    marginBottom: 16,
  },
  inputLabel: {
    fontSize: 16,
    marginBottom: 8,
    color: '#555555',
  },
  input: {
    borderWidth: 1,
    borderColor: '#DDDDDD',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#FAFAFA',
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  categoriesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryChip: {
    backgroundColor: '#EEEEEE',
    borderRadius: 16,
    paddingVertical: 8,
    paddingHorizontal: 16,
    margin: 4,
  },
  categoryChipSelected: {
    backgroundColor: '#4CAF50',
  },
  categoryChipText: {
    color: '#555555',
    fontSize: 14,
  },
  categoryChipTextSelected: {
    color: '#FFFFFF',
  },
  settingContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  settingLabel: {
    fontSize: 16,
    color: '#555555',
  },
  themeSelector: {
    flexDirection: 'row',
  },
  themeOption: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderWidth: 1,
    borderColor: '#DDDDDD',
    marginLeft: 8,
  },
  themeOptionSelected: {
    backgroundColor: '#2196F3',
    borderColor: '#2196F3',
  },
  themeOptionText: {
    color: '#555555',
    fontSize: 14,
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 16,
    marginBottom: 32,
  },
  button: {
    flex: 1,
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cancelButton: {
    backgroundColor: '#EEEEEE',
    marginRight: 8,
  },
  saveButton: {
    backgroundColor: '#4CAF50',
    marginLeft: 8,
  },
  disabledButton: {
    opacity: 0.7,
  },
  cancelButtonText: {
    color: '#555555',
    fontSize: 16,
    fontWeight: 'bold',
  },
  saveButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
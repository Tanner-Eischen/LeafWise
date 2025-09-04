/**
 * Account Deletion Component
 * Provides functionality for users to delete their account with confirmation
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  TextInput,
  ActivityIndicator,
  Alert
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../../app/navigation/types';
import { authService } from '../../auth/services/AuthService';
import { profileService } from '../services/ProfileService';
import { useAuth } from '../../auth/hooks/useAuth';

/**
 * Props for the AccountDeletion component
 */
interface AccountDeletionProps {
  /** Optional custom styles for the container */
  style?: object;
}

/**
 * Account Deletion Component
 * Provides a secure way for users to delete their account with confirmation
 * 
 * @param {AccountDeletionProps} props - Component props
 * @returns {JSX.Element} Account deletion component
 */
export function AccountDeletion({ style }: AccountDeletionProps): JSX.Element {
  // State
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Hooks
  const { user, logout } = useAuth();
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  
  /**
   * Open the confirmation modal
   */
  const handleOpenModal = () => {
    setIsModalVisible(true);
    setPassword('');
    setError(null);
  };
  
  /**
   * Close the confirmation modal
   */
  const handleCloseModal = () => {
    setIsModalVisible(false);
    setPassword('');
    setError(null);
  };
  
  /**
   * Handle account deletion process
   */
  const handleDeleteAccount = async () => {
    if (!user || !user.email) {
      setError('User information is not available');
      return;
    }
    
    if (!password) {
      setError('Please enter your password to confirm');
      return;
    }
    
    try {
      setIsLoading(true);
      setError(null);
      
      // Re-authenticate user before deletion
      await authService.reauthenticate({
        email: user.email,
        password
      });
      
      // Delete profile data first
      await profileService.deleteProfile(user.uid);
      
      // Delete user account
      await authService.deleteUserAccount();
      
      // Close modal
      setIsModalVisible(false);
      
      // Show success message
      Alert.alert(
        'Account Deleted',
        'Your account and all associated data have been permanently deleted.',
        [{ text: 'OK', onPress: () => {
          // Navigate to login screen
          navigation.reset({
            index: 0,
            routes: [{ name: 'Auth', params: { screen: 'Login' } }],
          });
        }}]
      );
    } catch (error: any) {
      console.error('Error deleting account:', error);
      setError(error.message || 'Failed to delete account. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <View style={[styles.container, style]}>
      <TouchableOpacity 
        style={styles.deleteButton}
        onPress={handleOpenModal}
      >
        <Text style={styles.deleteButtonText}>Delete Account</Text>
      </TouchableOpacity>
      
      <Modal
        visible={isModalVisible}
        transparent
        animationType="fade"
        onRequestClose={handleCloseModal}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Delete Account</Text>
            
            <Text style={styles.modalText}>
              This action is permanent and cannot be undone. All your data, including your profile, 
              plant identifications, and collections will be permanently deleted.
            </Text>
            
            <Text style={styles.passwordLabel}>Enter your password to confirm:</Text>
            
            <TextInput
              style={styles.passwordInput}
              value={password}
              onChangeText={setPassword}
              placeholder="Password"
              secureTextEntry
              autoCapitalize="none"
            />
            
            {error && <Text style={styles.errorText}>{error}</Text>}
            
            <View style={styles.buttonRow}>
              <TouchableOpacity 
                style={styles.cancelButton}
                onPress={handleCloseModal}
                disabled={isLoading}
              >
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.confirmButton}
                onPress={handleDeleteAccount}
                disabled={isLoading}
              >
                {isLoading ? (
                  <ActivityIndicator size="small" color="#FFFFFF" />
                ) : (
                  <Text style={styles.confirmButtonText}>Delete Account</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginTop: 16,
  },
  deleteButton: {
    backgroundColor: '#F44336',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
  },
  deleteButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalContent: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 24,
    width: '100%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#D32F2F',
    marginBottom: 16,
  },
  modalText: {
    fontSize: 16,
    color: '#555555',
    marginBottom: 24,
    lineHeight: 22,
  },
  passwordLabel: {
    fontSize: 16,
    color: '#333333',
    marginBottom: 8,
  },
  passwordInput: {
    borderWidth: 1,
    borderColor: '#DDDDDD',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 16,
  },
  errorText: {
    color: '#D32F2F',
    fontSize: 14,
    marginBottom: 16,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelButton: {
    flex: 1,
    backgroundColor: '#EEEEEE',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginRight: 8,
  },
  cancelButtonText: {
    color: '#555555',
    fontSize: 16,
    fontWeight: 'bold',
  },
  confirmButton: {
    flex: 1,
    backgroundColor: '#D32F2F',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginLeft: 8,
  },
  confirmButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
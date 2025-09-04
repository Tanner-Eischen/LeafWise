/**
 * Password Reset Screen
 * Screen for password reset functionality
 */

import React from 'react';
import { View, StyleSheet, ScrollView, SafeAreaView } from 'react-native';
import { PasswordResetForm } from '../components';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AuthStackParamList } from './LoginScreen';

type PasswordResetScreenProps = NativeStackScreenProps<AuthStackParamList, 'PasswordReset'>;

/**
 * Password Reset Screen Component
 * Displays the password reset form and handles navigation
 * 
 * @param {PasswordResetScreenProps} props - Navigation props
 * @returns {JSX.Element} Password reset screen component
 */
export function PasswordResetScreen({ navigation }: PasswordResetScreenProps): JSX.Element {
  /**
   * Navigate back to login screen
   */
  const handleBackToLoginPress = () => {
    navigation.navigate('Login');
  };

  /**
   * Handle successful password reset request
   */
  const handleResetRequestSuccess = () => {
    // Success message is shown in the form component
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContainer}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.container}>
          <PasswordResetForm
            onBackToLoginPress={handleBackToLoginPress}
            onResetRequestSuccess={handleResetRequestSuccess}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollContainer: {
    flexGrow: 1,
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
});
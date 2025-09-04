/**
 * Login Screen
 * Screen for user authentication
 */

import React from 'react';
import { View, StyleSheet, ScrollView, SafeAreaView } from 'react-native';
import { LoginForm } from '../components';
import { NativeStackScreenProps } from '@react-navigation/native-stack';

/**
 * Navigation params for auth stack
 */
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  PasswordReset: undefined;
  // Add other auth-related screens here
};

type LoginScreenProps = NativeStackScreenProps<AuthStackParamList, 'Login'>;

/**
 * Login Screen Component
 * Displays the login form and handles navigation to other auth screens
 * 
 * @param {LoginScreenProps} props - Navigation props
 * @returns {JSX.Element} Login screen component
 */
export function LoginScreen({ navigation }: LoginScreenProps): JSX.Element {
  /**
   * Navigate to registration screen
   */
  const handleRegisterPress = () => {
    navigation.navigate('Register');
  };

  /**
   * Navigate to password reset screen
   */
  const handleForgotPasswordPress = () => {
    navigation.navigate('PasswordReset');
  };

  /**
   * Handle successful login
   */
  const handleLoginSuccess = () => {
    // Navigation will be handled by the AuthProvider
    // which will redirect to the main app flow
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContainer}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.container}>
          <LoginForm
            onRegisterPress={handleRegisterPress}
            onForgotPasswordPress={handleForgotPasswordPress}
            onLoginSuccess={handleLoginSuccess}
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
/**
 * Register Screen
 * Screen for user registration
 */

import React from 'react';
import { View, StyleSheet, ScrollView, SafeAreaView } from 'react-native';
import { RegisterForm } from '../components';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AuthStackParamList } from './LoginScreen';

type RegisterScreenProps = NativeStackScreenProps<AuthStackParamList, 'Register'>;

/**
 * Register Screen Component
 * Displays the registration form and handles navigation
 * 
 * @param {RegisterScreenProps} props - Navigation props
 * @returns {JSX.Element} Register screen component
 */
export function RegisterScreen({ navigation }: RegisterScreenProps): JSX.Element {
  /**
   * Navigate to login screen
   */
  const handleLoginPress = () => {
    navigation.navigate('Login');
  };

  /**
   * Handle successful registration
   */
  const handleRegisterSuccess = () => {
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
          <RegisterForm
            onLoginPress={handleLoginPress}
            onRegisterSuccess={handleRegisterSuccess}
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
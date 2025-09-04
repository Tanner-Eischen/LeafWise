/**
 * Registration Form Component
 * Provides a form for user registration
 */

import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { useAuthContext } from './AuthProvider';
import { UserRegistrationData } from '../types';

/**
 * Registration Form props
 */
interface RegisterFormProps {
  /** Callback function called after successful registration */
  onRegisterSuccess?: () => void;
  /** Callback function called when user wants to login instead */
  onLoginPress?: () => void;
}

/**
 * Registration Form Component
 * Provides a form for user registration
 * 
 * @param {RegisterFormProps} props - Component props
 * @returns {JSX.Element} Registration form component
 */
export function RegisterForm({
  onRegisterSuccess,
  onLoginPress,
}: RegisterFormProps): JSX.Element {
  // Get authentication context
  const { register, isLoading, error } = useAuthContext();
  
  // Form state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [validationError, setValidationError] = useState<string | null>(null);
  
  /**
   * Validate form inputs
   * 
   * @returns {boolean} Whether the form is valid
   */
  const validateForm = (): boolean => {
    // Reset validation error
    setValidationError(null);
    
    // Check if all required fields are filled
    if (!email || !password || !confirmPassword) {
      setValidationError('All fields are required');
      return false;
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setValidationError('Please enter a valid email address');
      return false;
    }
    
    // Check if passwords match
    if (password !== confirmPassword) {
      setValidationError('Passwords do not match');
      return false;
    }
    
    // Check password strength
    if (password.length < 8) {
      setValidationError('Password must be at least 8 characters long');
      return false;
    }
    
    return true;
  };
  
  /**
   * Handle registration form submission
   */
  const handleSubmit = async () => {
    // Validate form
    if (!validateForm()) {
      return;
    }
    
    try {
      const registrationData: UserRegistrationData = {
        email,
        password,
        displayName: displayName || undefined,
      };
      
      await register(registrationData);
      
      // Call success callback if provided
      if (onRegisterSuccess) {
        onRegisterSuccess();
      }
    } catch (err) {
      // Error is already handled by the auth context
      console.log('Registration failed:', err);
    }
  };
  
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create Account</Text>
      
      {/* Error message */}
      {(error || validationError) && (
        <Text style={styles.errorText}>
          {validationError || error?.message}
        </Text>
      )}
      
      {/* Display name input */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Display Name (Optional)</Text>
        <TextInput
          style={styles.input}
          value={displayName}
          onChangeText={setDisplayName}
          placeholder="Enter your name"
          autoCorrect={false}
          testID="register-name-input"
        />
      </View>
      
      {/* Email input */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Email</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="Enter your email"
          keyboardType="email-address"
          autoCapitalize="none"
          autoCorrect={false}
          testID="register-email-input"
        />
      </View>
      
      {/* Password input */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Password</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="Create a password"
          secureTextEntry
          testID="register-password-input"
        />
      </View>
      
      {/* Confirm password input */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Confirm Password</Text>
        <TextInput
          style={styles.input}
          value={confirmPassword}
          onChangeText={setConfirmPassword}
          placeholder="Confirm your password"
          secureTextEntry
          testID="register-confirm-password-input"
        />
      </View>
      
      {/* Register button */}
      <TouchableOpacity
        style={styles.button}
        onPress={handleSubmit}
        disabled={isLoading}
        testID="register-submit-button"
      >
        {isLoading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign Up</Text>
        )}
      </TouchableOpacity>
      
      {/* Login link */}
      <View style={styles.loginContainer}>
        <Text style={styles.loginText}>Already have an account? </Text>
        <TouchableOpacity
          onPress={onLoginPress}
          testID="register-login-button"
        >
          <Text style={styles.linkText}>Sign In</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 20,
    width: '100%',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  inputContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: 16,
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#4CAF50',
    borderRadius: 8,
    padding: 14,
    alignItems: 'center',
    marginBottom: 16,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  linkText: {
    color: '#4CAF50',
    fontSize: 14,
    fontWeight: 'bold',
  },
  loginContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 16,
  },
  loginText: {
    fontSize: 14,
  },
  errorText: {
    color: 'red',
    marginBottom: 16,
    textAlign: 'center',
  },
});
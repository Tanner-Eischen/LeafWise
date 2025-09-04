/**
 * Login Form Component
 * Provides a form for user login
 */

import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { useAuthContext } from './AuthProvider';
import { UserLoginCredentials } from '../types';

/**
 * Login Form props
 */
interface LoginFormProps {
  /** Callback function called after successful login */
  onLoginSuccess?: () => void;
  /** Callback function called when user wants to register */
  onRegisterPress?: () => void;
  /** Callback function called when user wants to reset password */
  onForgotPasswordPress?: () => void;
}

/**
 * Login Form Component
 * Provides a form for user authentication
 * 
 * @param {LoginFormProps} props - Component props
 * @returns {JSX.Element} Login form component
 */
export function LoginForm({
  onLoginSuccess,
  onRegisterPress,
  onForgotPasswordPress,
}: LoginFormProps): JSX.Element {
  // Get authentication context
  const { login, isLoading, error } = useAuthContext();
  
  // Form state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  
  /**
   * Handle login form submission
   */
  const handleSubmit = async () => {
    try {
      const credentials: UserLoginCredentials = {
        email,
        password,
        rememberMe,
      };
      
      await login(credentials);
      
      // Call success callback if provided
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (err) {
      // Error is already handled by the auth context
      console.log('Login failed:', err);
    }
  };
  
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Sign In</Text>
      
      {/* Error message */}
      {error && (
        <Text style={styles.errorText}>{error.message}</Text>
      )}
      
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
          testID="login-email-input"
        />
      </View>
      
      {/* Password input */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Password</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="Enter your password"
          secureTextEntry
          testID="login-password-input"
        />
      </View>
      
      {/* Remember me checkbox */}
      <View style={styles.checkboxContainer}>
        <TouchableOpacity
          style={[styles.checkbox, rememberMe && styles.checkboxChecked]}
          onPress={() => setRememberMe(!rememberMe)}
          testID="login-remember-checkbox"
        >
          {rememberMe && <Text style={styles.checkmark}>✓</Text>}
        </TouchableOpacity>
        <Text style={styles.checkboxLabel}>Remember me</Text>
      </View>
      
      {/* Login button */}
      <TouchableOpacity
        style={styles.button}
        onPress={handleSubmit}
        disabled={isLoading}
        testID="login-submit-button"
      >
        {isLoading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign In</Text>
        )}
      </TouchableOpacity>
      
      {/* Forgot password link */}
      <TouchableOpacity
        onPress={onForgotPasswordPress}
        testID="login-forgot-password-button"
      >
        <Text style={styles.linkText}>Forgot Password?</Text>
      </TouchableOpacity>
      
      {/* Register link */}
      <View style={styles.registerContainer}>
        <Text style={styles.registerText}>Don't have an account? </Text>
        <TouchableOpacity
          onPress={onRegisterPress}
          testID="login-register-button"
        >
          <Text style={styles.linkText}>Sign Up</Text>
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
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 4,
    marginRight: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxChecked: {
    backgroundColor: '#4CAF50',
    borderColor: '#4CAF50',
  },
  checkmark: {
    color: '#fff',
    fontSize: 14,
  },
  checkboxLabel: {
    fontSize: 14,
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
  registerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 16,
  },
  registerText: {
    fontSize: 14,
  },
  errorText: {
    color: 'red',
    marginBottom: 16,
    textAlign: 'center',
  },
});
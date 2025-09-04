/**
 * Password Reset Form Component
 * Provides a form for users to reset their password
 */

import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { useAuthContext } from './AuthProvider';

/**
 * Password Reset Form props
 */
interface PasswordResetFormProps {
  /** Callback function called after successful password reset request */
  onResetRequestSuccess?: () => void;
  /** Callback function called when user wants to go back to login */
  onBackToLoginPress?: () => void;
}

/**
 * Password Reset Form Component
 * Provides a form for users to reset their password
 * 
 * @param {PasswordResetFormProps} props - Component props
 * @returns {JSX.Element} Password reset form component
 */
export function PasswordResetForm({
  onResetRequestSuccess,
  onBackToLoginPress,
}: PasswordResetFormProps): JSX.Element {
  // Get authentication context
  const { resetPassword, isLoading, error } = useAuthContext();
  
  // Form state
  const [email, setEmail] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);
  
  /**
   * Validate form inputs
   * 
   * @returns {boolean} Whether the form is valid
   */
  const validateForm = (): boolean => {
    // Reset validation error
    setValidationError(null);
    
    // Check if email is provided
    if (!email) {
      setValidationError('Email is required');
      return false;
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setValidationError('Please enter a valid email address');
      return false;
    }
    
    return true;
  };
  
  /**
   * Handle password reset form submission
   */
  const handleSubmit = async () => {
    // Validate form
    if (!validateForm()) {
      return;
    }
    
    try {
      await resetPassword({ email });
      setIsSubmitted(true);
      
      // Call success callback if provided
      if (onResetRequestSuccess) {
        onResetRequestSuccess();
      }
    } catch (err) {
      // Error is already handled by the auth context
      console.log('Password reset request failed:', err);
    }
  };
  
  // Show success message if form was submitted successfully
  if (isSubmitted) {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Password Reset Email Sent</Text>
        <Text style={styles.message}>
          We've sent a password reset link to {email}. Please check your email and follow the instructions to reset your password.
        </Text>
        <TouchableOpacity
          style={styles.button}
          onPress={onBackToLoginPress}
          testID="reset-back-to-login-button"
        >
          <Text style={styles.buttonText}>Back to Login</Text>
        </TouchableOpacity>
      </View>
    );
  }
  
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Reset Password</Text>
      <Text style={styles.subtitle}>
        Enter your email address and we'll send you a link to reset your password.
      </Text>
      
      {/* Error message */}
      {(error || validationError) && (
        <Text style={styles.errorText}>
          {validationError || error?.message}
        </Text>
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
          testID="reset-email-input"
        />
      </View>
      
      {/* Submit button */}
      <TouchableOpacity
        style={styles.button}
        onPress={handleSubmit}
        disabled={isLoading}
        testID="reset-submit-button"
      >
        {isLoading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Send Reset Link</Text>
        )}
      </TouchableOpacity>
      
      {/* Back to login link */}
      <TouchableOpacity
        onPress={onBackToLoginPress}
        style={styles.backLink}
        testID="reset-back-link"
      >
        <Text style={styles.linkText}>Back to Login</Text>
      </TouchableOpacity>
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
    marginBottom: 12,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 20,
    textAlign: 'center',
  },
  message: {
    fontSize: 16,
    color: '#333',
    marginBottom: 24,
    textAlign: 'center',
    lineHeight: 22,
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
  backLink: {
    alignItems: 'center',
  },
  linkText: {
    color: '#4CAF50',
    fontSize: 14,
    fontWeight: 'bold',
  },
  errorText: {
    color: 'red',
    marginBottom: 16,
    textAlign: 'center',
  },
});
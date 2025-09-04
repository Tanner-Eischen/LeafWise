/**
 * Firebase Authentication Service
 * Implements the IAuthService interface using Firebase Authentication
 */

import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { IAuthService, UserRegistrationData, UserLoginCredentials, PasswordResetRequest, AuthError } from '../types';

/**
 * Firebase Authentication Service
 * Provides methods for user authentication using Firebase
 */
export class AuthService implements IAuthService {
  private isInitialized = false;

  /**
   * Initialize the authentication service
   * Sets up Firebase Authentication and ensures it's ready for use
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    // Firebase Auth is automatically initialized when imported
    // We just need to mark our service as initialized
    this.isInitialized = true;
  }

  /**
   * Register a new user with email and password
   * 
   * @param {UserRegistrationData} data - User registration data
   * @returns {Promise<FirebaseAuthTypes.UserCredential>} User credential
   */
  async registerWithEmailAndPassword(
    data: UserRegistrationData
  ): Promise<FirebaseAuthTypes.UserCredential> {
    try {
      const { email, password, displayName } = data;
      
      // Create user with email and password
      const userCredential = await auth().createUserWithEmailAndPassword(email, password);
      
      // Update display name if provided
      if (displayName && userCredential.user) {
        await userCredential.user.updateProfile({ displayName });
      }
      
      return userCredential;
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  /**
   * Log in a user with email and password
   * 
   * @param {UserLoginCredentials} credentials - User login credentials
   * @returns {Promise<FirebaseAuthTypes.UserCredential>} User credential
   */
  async loginWithEmailAndPassword(
    credentials: UserLoginCredentials
  ): Promise<FirebaseAuthTypes.UserCredential> {
    try {
      const { email, password } = credentials;
      return await auth().signInWithEmailAndPassword(email, password);
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  /**
   * Log out the current user
   */
  async logout(): Promise<void> {
    try {
      await auth().signOut();
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  /**
   * Send a password reset email
   * 
   * @param {PasswordResetRequest} request - Password reset request
   */
  async sendPasswordResetEmail(request: PasswordResetRequest): Promise<void> {
    try {
      await auth().sendPasswordResetEmail(request.email);
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  /**
   * Get the current authenticated user
   * 
   * @returns {FirebaseAuthTypes.User | null} Current user or null
   */
  getCurrentUser(): FirebaseAuthTypes.User | null {
    return auth().currentUser;
  }

  /**
   * Subscribe to authentication state changes
   * 
   * @param {Function} listener - Callback function for auth state changes
   * @returns {Function} Unsubscribe function
   */
  onAuthStateChanged(
    listener: (user: FirebaseAuthTypes.User | null) => void
  ): () => void {
    return auth().onAuthStateChanged(listener);
  }

  /**
 * Re-authenticate the current user
 * 
 * @param {UserLoginCredentials} credentials - User login credentials
 * @returns {Promise<FirebaseAuthTypes.UserCredential>} User credential
 */
async reauthenticate(
  credentials: UserLoginCredentials
): Promise<FirebaseAuthTypes.UserCredential> {
  try {
    const { email, password } = credentials;
    const currentUser = auth().currentUser;
    
    if (!currentUser) {
      throw new Error('No user is currently signed in');
    }
    
    const credential = auth.EmailAuthProvider.credential(email, password);
    return await currentUser.reauthenticateWithCredential(credential);
  } catch (error: any) {
    throw this.formatAuthError(error);
  }
}

/**
 * Delete the current user's account
 * User must be recently authenticated
 * 
 * @returns {Promise<void>}
 */
async deleteUserAccount(): Promise<void> {
  try {
    const currentUser = auth().currentUser;
    
    if (!currentUser) {
      throw new Error('No user is currently signed in');
    }
    
    await currentUser.delete();
  } catch (error: any) {
    throw this.formatAuthError(error);
  }
}

  /**
   * Format Firebase auth error to our application error format
   * 
   * @param {any} error - Firebase auth error
   * @returns {AuthError} Formatted auth error
   * @private
   */
  private formatAuthError(error: any): AuthError {
    // Extract Firebase error code and message
    const code = error.code || 'auth/unknown';
    const message = error.message || 'An unknown authentication error occurred';
    
    // Determine if the error is recoverable based on the error code
    // Network-related errors are typically recoverable
    const recoverable = [
      'auth/network-request-failed',
      'auth/timeout',
      'auth/web-storage-unsupported'
    ].includes(code);
    
    return {
      code,
      message,
      details: error,
      timestamp: new Date().toISOString(),
      recoverable
    };
  }
}

// Create and export a singleton instance
export const authService = new AuthService();
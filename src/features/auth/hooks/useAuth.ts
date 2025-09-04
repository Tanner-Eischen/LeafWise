/**
 * Authentication Hook
 * Provides authentication state and methods for components
 */

import { useState, useEffect, useCallback } from 'react';
import { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { authService } from '../services';
import { 
  AuthState, 
  AuthError, 
  UserRegistrationData, 
  UserLoginCredentials, 
  PasswordResetRequest 
} from '../types';

/**
 * Return type for the useAuth hook
 */
interface UseAuthReturn extends AuthState {
  // Authentication methods
  register: (data: UserRegistrationData) => Promise<void>;
  login: (credentials: UserLoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  resetPassword: (request: PasswordResetRequest) => Promise<void>;
  reauthenticate: (credentials: UserLoginCredentials) => Promise<void>;
}

/**
 * Authentication hook for managing user authentication state
 * 
 * @returns {UseAuthReturn} Authentication state and methods
 */
export function useAuth(): UseAuthReturn {
  // Initialize auth state
  const [state, setState] = useState<AuthState>({
    isAuthenticated: false,
    isLoading: true,
    user: null,
    error: null,
    isInitialized: false,
  });

  /**
   * Updates auth state with partial state changes
   * 
   * @param {Partial<AuthState>} updates - Partial state object with changes
   */
  const updateState = useCallback((updates: Partial<AuthState>) => {
    setState(prevState => ({ ...prevState, ...updates }));
  }, []);

  /**
   * Initialize the authentication service
   */
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        updateState({ isLoading: true, error: null });
        await authService.initialize();
        updateState({ isInitialized: true });
      } catch (error: any) {
        updateState({ 
          error: {
            code: 'auth/unknown',
            message: 'Failed to initialize authentication service',
            details: error
          },
          isInitialized: false,
        });
      } finally {
        updateState({ isLoading: false });
      }
    };

    initializeAuth();
  }, [updateState]);

  /**
   * Subscribe to authentication state changes
   */
  useEffect(() => {
    if (!state.isInitialized) {
      return;
    }

    // Subscribe to auth state changes
    const unsubscribe = authService.onAuthStateChanged((user) => {
      updateState({ 
        user, 
        isAuthenticated: !!user,
        isLoading: false,
      });
    });

    // Cleanup subscription on unmount
    return unsubscribe;
  }, [state.isInitialized, updateState]);

  /**
   * Register a new user
   * 
   * @param {UserRegistrationData} data - User registration data
   */
  const register = useCallback(async (data: UserRegistrationData): Promise<void> => {
    try {
      updateState({ isLoading: true, error: null });
      await authService.registerWithEmailAndPassword(data);
      // Auth state change listener will update the state
    } catch (error: any) {
      updateState({ error: error as AuthError });
      throw error;
    } finally {
      updateState({ isLoading: false });
    }
  }, [updateState]);

  /**
   * Log in a user
   * 
   * @param {UserLoginCredentials} credentials - User login credentials
   */
  const login = useCallback(async (credentials: UserLoginCredentials): Promise<void> => {
    try {
      updateState({ isLoading: true, error: null });
      await authService.loginWithEmailAndPassword(credentials);
      // Auth state change listener will update the state
    } catch (error: any) {
      updateState({ error: error as AuthError });
      throw error;
    } finally {
      updateState({ isLoading: false });
    }
  }, [updateState]);

  /**
   * Log out the current user
   */
  const logout = useCallback(async (): Promise<void> => {
    try {
      updateState({ isLoading: true, error: null });
      await authService.logout();
      // Auth state change listener will update the state
    } catch (error: any) {
      updateState({ error: error as AuthError });
      throw error;
    } finally {
      updateState({ isLoading: false });
    }
  }, [updateState]);

  /**
   * Send a password reset email
   * 
   * @param {PasswordResetRequest} request - Password reset request
   */
  const resetPassword = useCallback(async (request: PasswordResetRequest): Promise<void> => {
    try {
      updateState({ isLoading: true, error: null });
      await authService.sendPasswordResetEmail(request);
    } catch (error: any) {
      updateState({ error: error as AuthError });
      throw error;
    } finally {
      updateState({ isLoading: false });
    }
  }, [updateState]);

  /**
   * Re-authenticate the current user
   * 
   * @param {UserLoginCredentials} credentials - User login credentials
   */
  const reauthenticate = useCallback(async (credentials: UserLoginCredentials): Promise<void> => {
    try {
      updateState({ isLoading: true, error: null });
      await authService.reauthenticate(credentials);
    } catch (error: any) {
      updateState({ error: error as AuthError });
      throw error;
    } finally {
      updateState({ isLoading: false });
    }
  }, [updateState]);

  return {
    ...state,
    register,
    login,
    logout,
    resetPassword,
    reauthenticate,
  };
}
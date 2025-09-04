/**
 * Authentication Provider Component
 * Provides authentication context to the application
 */

import React, { createContext, useContext, ReactNode } from 'react';
import { useAuth } from '../hooks/useAuth';
import { 
  AuthState, 
  UserRegistrationData, 
  UserLoginCredentials, 
  PasswordResetRequest 
} from '../types';

/**
 * Authentication context interface
 * Extends AuthState with authentication methods
 */
interface AuthContextType extends AuthState {
  register: (data: UserRegistrationData) => Promise<void>;
  login: (credentials: UserLoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  resetPassword: (request: PasswordResetRequest) => Promise<void>;
  reauthenticate: (credentials: UserLoginCredentials) => Promise<void>;
}

// Create the authentication context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

/**
 * Authentication Provider props
 */
interface AuthProviderProps {
  /** Child components */
  children: ReactNode;
}

/**
 * Authentication Provider Component
 * Provides authentication state and methods to child components
 * 
 * @param {AuthProviderProps} props - Component props
 * @returns {JSX.Element} Provider component
 */
export function AuthProvider({ children }: AuthProviderProps): JSX.Element {
  const auth = useAuth();

  return (
    <AuthContext.Provider value={auth}>
      {children}
    </AuthContext.Provider>
  );
}

/**
 * Hook to use the authentication context
 * 
 * @returns {AuthContextType} Authentication context
 * @throws {Error} If used outside of AuthProvider
 */
export function useAuthContext(): AuthContextType {
  const context = useContext(AuthContext);
  
  if (context === undefined) {
    throw new Error('useAuthContext must be used within an AuthProvider');
  }
  
  return context;
}
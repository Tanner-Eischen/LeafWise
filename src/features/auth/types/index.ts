/**
 * TypeScript type definitions for auth feature
 * Contains interfaces and types specific to the auth module
 */

import { FirebaseAuthTypes } from '@react-native-firebase/auth';

/**
 * Authentication state interface
 * Represents the current state of user authentication
 */
export interface AuthState {
  /** Whether the user is currently authenticated */
  isAuthenticated: boolean;
  /** Whether authentication is currently in progress */
  isLoading: boolean;
  /** The currently authenticated user, if any */
  user: FirebaseAuthTypes.User | null;
  /** Any error that occurred during authentication */
  error: AuthError | null;
  /** Whether the auth state has been initialized */
  isInitialized: boolean;
}

/**
 * Authentication error interface
 * Represents an error that occurred during authentication
 */
export interface AuthError {
  /** Error code for programmatic handling */
  code: AuthErrorCode;
  /** Human-readable error message */
  message: string;
  /** Additional error details, if available */
  details?: Record<string, any>;
  /** Timestamp when the error occurred */
  timestamp: string;
  /** Whether the error is recoverable */
  recoverable: boolean;
}

/**
 * Authentication error codes
 * Used for programmatic handling of specific error cases
 */
export type AuthErrorCode = 
  | 'auth/invalid-email'
  | 'auth/user-disabled'
  | 'auth/user-not-found'
  | 'auth/wrong-password'
  | 'auth/email-already-in-use'
  | 'auth/weak-password'
  | 'auth/operation-not-allowed'
  | 'auth/invalid-credential'
  | 'auth/account-exists-with-different-credential'
  | 'auth/invalid-verification-code'
  | 'auth/invalid-verification-id'
  | 'auth/network-request-failed'
  | 'auth/too-many-requests'
  | 'auth/requires-recent-login'
  | 'auth/user-token-expired'
  | 'auth/web-storage-unsupported'
  | 'auth/unknown';

/**
 * User registration data interface
 * Contains the information needed to register a new user
 */
export interface UserRegistrationData {
  /** User's email address */
  email: string;
  /** User's chosen password */
  password: string;
  /** User's display name (optional) */
  displayName?: string;
}

/**
 * User login credentials interface
 * Contains the information needed to log in a user
 */
export interface UserLoginCredentials {
  /** User's email address */
  email: string;
  /** User's password */
  password: string;
  /** Whether to remember the user's login */
  rememberMe?: boolean;
}

/**
 * Password reset request interface
 * Contains the information needed to request a password reset
 */
export interface PasswordResetRequest {
  /** User's email address */
  email: string;
}

/**
 * Authentication service interface
 * Defines the methods available for authentication operations
 */
export interface IAuthService {
  /** Initialize the authentication service */
  initialize(): Promise<void>;
  
  /** Register a new user with email and password */
  registerWithEmailAndPassword(data: UserRegistrationData): Promise<FirebaseAuthTypes.UserCredential>;
  
  /** Log in a user with email and password */
  loginWithEmailAndPassword(credentials: UserLoginCredentials): Promise<FirebaseAuthTypes.UserCredential>;
  
  /** Log out the current user */
  logout(): Promise<void>;
  
  /** Send a password reset email */
  sendPasswordResetEmail(request: PasswordResetRequest): Promise<void>;
  
  /** Get the current authenticated user */
  getCurrentUser(): FirebaseAuthTypes.User | null;
  
  /** Subscribe to authentication state changes */
  onAuthStateChanged(listener: (user: FirebaseAuthTypes.User | null) => void): () => void;
  
  /** Re-authenticate the current user */
  reauthenticate(credentials: UserLoginCredentials): Promise<FirebaseAuthTypes.UserCredential>;
  
  /** Delete the current user's account */
  deleteUserAccount(): Promise<void>;
}

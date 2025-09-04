/**
 * Tests for AuthService
 */

import { AuthService } from './AuthService';
import { UserRegistrationData, UserLoginCredentials, PasswordResetRequest } from '../types';
import firebase from 'firebase/app';
import 'firebase/auth';

// Mock Firebase
jest.mock('firebase/app', () => {
  const auth = {
    createUserWithEmailAndPassword: jest.fn(),
    signInWithEmailAndPassword: jest.fn(),
    signOut: jest.fn(),
    sendPasswordResetEmail: jest.fn(),
    currentUser: null,
    onAuthStateChanged: jest.fn(),
    reauthenticateWithCredential: jest.fn(),
    EmailAuthProvider: {
      credential: jest.fn(),
    },
  };
  
  return {
    auth: jest.fn(() => auth),
    initializeApp: jest.fn(),
  };
});

describe('AuthService', () => {
  let authService: AuthService;
  let mockFirebaseAuth: any;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Setup mock Firebase auth
    mockFirebaseAuth = firebase.auth();
    
    // Create AuthService instance
    authService = new AuthService();
  });
  
  describe('initialize', () => {
    it('should initialize Firebase app with config', () => {
      const mockConfig = { apiKey: 'test-key' };
      authService.initialize(mockConfig);
      
      expect(firebase.initializeApp).toHaveBeenCalledWith(mockConfig);
    });
  });
  
  describe('register', () => {
    it('should register a new user', async () => {
      const userData: UserRegistrationData = {
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      };
      
      const mockUserCredential = {
        user: {
          updateProfile: jest.fn().mockResolvedValue(undefined),
        },
      };
      
      mockFirebaseAuth.createUserWithEmailAndPassword.mockResolvedValue(mockUserCredential);
      
      await authService.register(userData);
      
      expect(mockFirebaseAuth.createUserWithEmailAndPassword).toHaveBeenCalledWith(
        userData.email,
        userData.password
      );
      
      expect(mockUserCredential.user.updateProfile).toHaveBeenCalledWith({
        displayName: userData.displayName,
      });
    });
    
    it('should handle registration errors', async () => {
      const userData: UserRegistrationData = {
        email: 'test@example.com',
        password: 'password123',
      };
      
      const mockError = { code: 'auth/email-already-in-use', message: 'Email already in use' };
      mockFirebaseAuth.createUserWithEmailAndPassword.mockRejectedValue(mockError);
      
      await expect(authService.register(userData)).rejects.toEqual({
        code: 'email-already-in-use',
        message: 'Email already in use',
      });
    });
  });
  
  describe('login', () => {
    it('should log in a user', async () => {
      const credentials: UserLoginCredentials = {
        email: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      };
      
      mockFirebaseAuth.signInWithEmailAndPassword.mockResolvedValue({});
      
      await authService.login(credentials);
      
      expect(mockFirebaseAuth.signInWithEmailAndPassword).toHaveBeenCalledWith(
        credentials.email,
        credentials.password
      );
      
      // TODO: Test persistence setting when implemented
    });
    
    it('should handle login errors', async () => {
      const credentials: UserLoginCredentials = {
        email: 'test@example.com',
        password: 'wrong-password',
      };
      
      const mockError = { code: 'auth/wrong-password', message: 'Invalid password' };
      mockFirebaseAuth.signInWithEmailAndPassword.mockRejectedValue(mockError);
      
      await expect(authService.login(credentials)).rejects.toEqual({
        code: 'wrong-password',
        message: 'Invalid password',
      });
    });
  });
  
  describe('logout', () => {
    it('should log out the current user', async () => {
      mockFirebaseAuth.signOut.mockResolvedValue(undefined);
      
      await authService.logout();
      
      expect(mockFirebaseAuth.signOut).toHaveBeenCalled();
    });
    
    it('should handle logout errors', async () => {
      const mockError = { code: 'auth/no-current-user', message: 'No user is signed in' };
      mockFirebaseAuth.signOut.mockRejectedValue(mockError);
      
      await expect(authService.logout()).rejects.toEqual({
        code: 'no-current-user',
        message: 'No user is signed in',
      });
    });
  });
  
  describe('resetPassword', () => {
    it('should send a password reset email', async () => {
      const resetRequest: PasswordResetRequest = {
        email: 'test@example.com',
      };
      
      mockFirebaseAuth.sendPasswordResetEmail.mockResolvedValue(undefined);
      
      await authService.resetPassword(resetRequest);
      
      expect(mockFirebaseAuth.sendPasswordResetEmail).toHaveBeenCalledWith(resetRequest.email);
    });
    
    it('should handle password reset errors', async () => {
      const resetRequest: PasswordResetRequest = {
        email: 'invalid-email',
      };
      
      const mockError = { code: 'auth/invalid-email', message: 'Invalid email address' };
      mockFirebaseAuth.sendPasswordResetEmail.mockRejectedValue(mockError);
      
      await expect(authService.resetPassword(resetRequest)).rejects.toEqual({
        code: 'invalid-email',
        message: 'Invalid email address',
      });
    });
  });
  
  describe('getCurrentUser', () => {
    it('should return the current user', () => {
      const mockUser = { uid: '123', email: 'test@example.com' };
      mockFirebaseAuth.currentUser = mockUser;
      
      const result = authService.getCurrentUser();
      
      expect(result).toEqual(mockUser);
    });
    
    it('should return null if no user is signed in', () => {
      mockFirebaseAuth.currentUser = null;
      
      const result = authService.getCurrentUser();
      
      expect(result).toBeNull();
    });
  });
  
  describe('onAuthStateChanged', () => {
    it('should register an auth state change listener', () => {
      const mockCallback = jest.fn();
      const mockUnsubscribe = jest.fn();
      
      mockFirebaseAuth.onAuthStateChanged.mockImplementation((callback) => {
        callback(null);
        return mockUnsubscribe;
      });
      
      const unsubscribe = authService.onAuthStateChanged(mockCallback);
      
      expect(mockFirebaseAuth.onAuthStateChanged).toHaveBeenCalled();
      expect(mockCallback).toHaveBeenCalledWith(null);
      expect(unsubscribe).toBe(mockUnsubscribe);
    });
  });
  
  describe('reauthenticate', () => {
    it('should reauthenticate the current user', async () => {
      const password = 'password123';
      const mockUser = {
        email: 'test@example.com',
        reauthenticateWithCredential: jest.fn().mockResolvedValue(undefined),
      };
      
      mockFirebaseAuth.currentUser = mockUser;
      mockFirebaseAuth.EmailAuthProvider.credential.mockReturnValue('mock-credential');
      
      await authService.reauthenticate(password);
      
      expect(mockFirebaseAuth.EmailAuthProvider.credential).toHaveBeenCalledWith(
        mockUser.email,
        password
      );
      
      expect(mockUser.reauthenticateWithCredential).toHaveBeenCalledWith('mock-credential');
    });
    
    it('should throw an error if no user is signed in', async () => {
      mockFirebaseAuth.currentUser = null;
      
      await expect(authService.reauthenticate('password123')).rejects.toEqual({
        code: 'no-current-user',
        message: 'No user is currently signed in',
      });
    });
    
    it('should handle reauthentication errors', async () => {
      const password = 'wrong-password';
      const mockUser = {
        email: 'test@example.com',
        reauthenticateWithCredential: jest.fn(),
      };
      
      const mockError = { code: 'auth/wrong-password', message: 'Invalid password' };
      mockUser.reauthenticateWithCredential.mockRejectedValue(mockError);
      
      mockFirebaseAuth.currentUser = mockUser;
      mockFirebaseAuth.EmailAuthProvider.credential.mockReturnValue('mock-credential');
      
      await expect(authService.reauthenticate(password)).rejects.toEqual({
        code: 'wrong-password',
        message: 'Invalid password',
      });
    });
  });
});
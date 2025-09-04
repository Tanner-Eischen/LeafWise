/**
 * Tests for ProfileService
 */
import { ProfileService } from './ProfileService';
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import { UserProfile, ProfileUpdateData, ProfileErrorCode } from '../types';

// Mock Firebase modules
jest.mock('@react-native-firebase/firestore', () => ({
  __esModule: true,
  default: {
    collection: jest.fn(),
  },
}));

jest.mock('@react-native-firebase/auth', () => ({
  __esModule: true,
  default: {
    currentUser: null,
  },
}));

describe('ProfileService', () => {
  let profileService: ProfileService;
  let mockFirestore: any;
  let mockCollection: any;
  let mockDoc: any;
  let mockDocData: any;
  let mockDocSnapshot: any;
  let mockQuery: any;
  let mockQuerySnapshot: any;
  let mockAdd: any;
  let mockSet: any;
  let mockUpdate: any;
  let mockDelete: any;
  let mockWhere: any;
  let mockOnSnapshot: any;
  
  const mockUser = {
    uid: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
  };
  
  const mockProfile: UserProfile = {
    id: 'test-profile-id',
    userId: 'test-user-id',
    displayName: 'Test User',
    email: 'test@example.com',
    profilePicture: 'https://example.com/profile.jpg',
    bio: 'Test bio',
    location: 'Test location',
    createdAt: new Date('2023-01-01'),
    updatedAt: new Date('2023-01-02'),
    preferredCategories: ['Trees', 'Flowers'],
    settings: {
      theme: 'light',
      useMetricUnits: true,
      dataSavingMode: false,
    },
    notificationPreferences: {
      pushEnabled: true,
      emailEnabled: true,
      newIdentifications: true,
    },
    statistics: {
      plantsIdentified: 10,
      collectionsCreated: 2,
      contributionsSubmitted: 5,
    },
  };
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Setup mock implementations
    mockSet = jest.fn().mockResolvedValue(undefined);
    mockUpdate = jest.fn().mockResolvedValue(undefined);
    mockDelete = jest.fn().mockResolvedValue(undefined);
    mockAdd = jest.fn().mockResolvedValue({
      id: 'test-profile-id',
    });
    
    mockDocData = jest.fn().mockReturnValue({
      ...mockProfile,
      createdAt: { toDate: () => mockProfile.createdAt },
      updatedAt: { toDate: () => mockProfile.updatedAt },
    });
    
    mockDocSnapshot = {
      exists: true,
      id: 'test-profile-id',
      data: mockDocData,
    };
    
    mockDoc = jest.fn().mockReturnValue({
      set: mockSet,
      update: mockUpdate,
      delete: mockDelete,
      get: jest.fn().mockResolvedValue(mockDocSnapshot),
      onSnapshot: jest.fn(),
    });
    
    mockQuerySnapshot = {
      empty: false,
      docs: [mockDocSnapshot],
    };
    
    mockQuery = {
      get: jest.fn().mockResolvedValue(mockQuerySnapshot),
      onSnapshot: jest.fn(),
    };
    
    mockWhere = jest.fn().mockReturnValue(mockQuery);
    
    mockCollection = jest.fn().mockReturnValue({
      doc: mockDoc,
      add: mockAdd,
      where: mockWhere,
    });
    
    mockFirestore = {
      collection: mockCollection,
    };
    
    (firestore as any).collection = mockCollection;
    (auth as any).currentUser = mockUser;
    
    // Initialize service
    profileService = new ProfileService();
  });
  
  describe('initialize', () => {
    it('should initialize the service', async () => {
      await profileService.initialize();
      expect(mockCollection).toHaveBeenCalledWith('profiles');
    });
  });
  
  describe('createProfile', () => {
    it('should create a new profile', async () => {
      const profileData: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'> = {
        userId: 'test-user-id',
        displayName: 'Test User',
        email: 'test@example.com',
        profilePicture: 'https://example.com/profile.jpg',
        bio: 'Test bio',
        location: 'Test location',
        preferredCategories: ['Trees', 'Flowers'],
        settings: {
          theme: 'light',
          useMetricUnits: true,
          dataSavingMode: false,
        },
        notificationPreferences: {
          pushEnabled: true,
          emailEnabled: true,
          newIdentifications: true,
        },
        statistics: {
          plantsIdentified: 0,
          collectionsCreated: 0,
          contributionsSubmitted: 0,
        },
      };
      
      const result = await profileService.createProfile(profileData);
      
      expect(mockAdd).toHaveBeenCalledWith(expect.objectContaining({
        ...profileData,
        createdAt: expect.any(Object),
        updatedAt: expect.any(Object),
      }));
      
      expect(result).toEqual(expect.objectContaining({
        id: 'test-profile-id',
        ...profileData,
      }));
    });
    
    it('should throw an error if profile creation fails', async () => {
      mockAdd.mockRejectedValueOnce(new Error('Firestore error'));
      
      const profileData: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'> = {
        userId: 'test-user-id',
        displayName: 'Test User',
        email: 'test@example.com',
        profilePicture: null,
        bio: null,
        location: null,
        preferredCategories: [],
        settings: {
          theme: 'system',
          useMetricUnits: true,
          dataSavingMode: false,
        },
        notificationPreferences: {
          pushEnabled: true,
          emailEnabled: true,
          newIdentifications: true,
        },
        statistics: {
          plantsIdentified: 0,
          collectionsCreated: 0,
          contributionsSubmitted: 0,
        },
      };
      
      await expect(profileService.createProfile(profileData))
        .rejects
        .toThrow('Failed to create profile: Firestore error');
    });
  });
  
  describe('getProfile', () => {
    it('should get a profile by ID', async () => {
      const result = await profileService.getProfile('test-profile-id');
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
      expect(result).toEqual(mockProfile);
    });
    
    it('should throw an error if profile does not exist', async () => {
      mockDocSnapshot.exists = false;
      
      await expect(profileService.getProfile('test-profile-id'))
        .rejects
        .toThrow('Profile not found');
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
    });
  });
  
  describe('getProfileByUserId', () => {
    it('should get a profile by user ID', async () => {
      const result = await profileService.getProfileByUserId('test-user-id');
      
      expect(mockWhere).toHaveBeenCalledWith('userId', '==', 'test-user-id');
      expect(result).toEqual(mockProfile);
    });
    
    it('should throw an error if profile does not exist', async () => {
      mockQuerySnapshot.empty = true;
      
      await expect(profileService.getProfileByUserId('test-user-id'))
        .rejects
        .toThrow('Profile not found');
      
      expect(mockWhere).toHaveBeenCalledWith('userId', '==', 'test-user-id');
    });
  });
  
  describe('updateProfile', () => {
    it('should update a profile', async () => {
      const updateData: ProfileUpdateData = {
        displayName: 'Updated User',
        bio: 'Updated bio',
        settings: {
          theme: 'dark',
          useMetricUnits: false,
          dataSavingMode: true,
        },
      };
      
      // Mock the getProfile method
      jest.spyOn(profileService, 'getProfile').mockResolvedValueOnce(mockProfile);
      
      const result = await profileService.updateProfile('test-profile-id', updateData);
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
      expect(mockUpdate).toHaveBeenCalledWith(expect.objectContaining({
        displayName: 'Updated User',
        bio: 'Updated bio',
        settings: {
          theme: 'dark',
          useMetricUnits: false,
          dataSavingMode: true,
        },
        updatedAt: expect.any(Object),
      }));
      
      expect(result).toEqual(expect.objectContaining({
        ...mockProfile,
        displayName: 'Updated User',
        bio: 'Updated bio',
        settings: {
          theme: 'dark',
          useMetricUnits: false,
          dataSavingMode: true,
        },
      }));
    });
    
    it('should throw an error if profile update fails', async () => {
      mockUpdate.mockRejectedValueOnce(new Error('Firestore error'));
      
      // Mock the getProfile method
      jest.spyOn(profileService, 'getProfile').mockResolvedValueOnce(mockProfile);
      
      const updateData: ProfileUpdateData = {
        displayName: 'Updated User',
      };
      
      await expect(profileService.updateProfile('test-profile-id', updateData))
        .rejects
        .toThrow('Failed to update profile: Firestore error');
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
    });
  });
  
  describe('deleteProfile', () => {
    it('should delete a profile', async () => {
      await profileService.deleteProfile('test-profile-id');
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
      expect(mockDelete).toHaveBeenCalled();
    });
    
    it('should throw an error if profile deletion fails', async () => {
      mockDelete.mockRejectedValueOnce(new Error('Firestore error'));
      
      await expect(profileService.deleteProfile('test-profile-id'))
        .rejects
        .toThrow('Failed to delete profile: Firestore error');
      
      expect(mockDoc).toHaveBeenCalledWith('test-profile-id');
    });
  });
  
  describe('getCurrentUserProfile', () => {
    it('should get the current user profile', async () => {
      // Mock the getProfileByUserId method
      jest.spyOn(profileService, 'getProfileByUserId').mockResolvedValueOnce(mockProfile);
      
      const result = await profileService.getCurrentUserProfile();
      
      expect(profileService.getProfileByUserId).toHaveBeenCalledWith('test-user-id');
      expect(result).toEqual(mockProfile);
    });
    
    it('should throw an error if no user is logged in', async () => {
      (auth as any).currentUser = null;
      
      await expect(profileService.getCurrentUserProfile())
        .rejects
        .toThrow('No user is currently logged in');
    });
  });
  
  describe('formatProfileError', () => {
    it('should format a profile not found error', () => {
      const error = { code: 'firestore/not-found', message: 'Profile not found' };
      const formattedError = profileService.formatProfileError(error);
      
      expect(formattedError.code).toBe('profile/not-found');
      expect(formattedError.message).toBe('User profile not found');
      expect(formattedError.timestamp).toBeDefined();
      expect(typeof formattedError.timestamp).toBe('string');
      expect(formattedError.recoverable).toBe(false);
    });
    
    it('should format a permission denied error', () => {
      const error = { code: 'firestore/permission-denied', message: 'Permission denied' };
      const formattedError = profileService.formatProfileError(error);
      
      expect(formattedError.code).toBe('profile/permission-denied');
      expect(formattedError.message).toBe('Permission denied to access profile');
      expect(formattedError.timestamp).toBeDefined();
      expect(typeof formattedError.timestamp).toBe('string');
      expect(formattedError.recoverable).toBe(false);
    });
    
    it('should format a network error as recoverable', () => {
      const error = { code: 'firestore/unavailable', message: 'Network error' };
      const formattedError = profileService.formatProfileError(error);
      
      expect(formattedError.code).toBe('profile/network-error');
      expect(formattedError.message).toBe('Network error occurred while accessing profile');
      expect(formattedError.timestamp).toBeDefined();
      expect(typeof formattedError.timestamp).toBe('string');
      expect(formattedError.recoverable).toBe(true);
    });
    
    it('should format a generic error', () => {
      const error = new Error('Some other error');
      const formattedError = profileService.formatProfileError(error);
      
      expect(formattedError.code).toBe('profile/unknown');
      expect(formattedError.message).toBe('Some other error');
      expect(formattedError.timestamp).toBeDefined();
      expect(typeof formattedError.timestamp).toBe('string');
      expect(formattedError.recoverable).toBe(false);
    });
  });
});
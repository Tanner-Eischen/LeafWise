/**
 * Tests for usePlantIdentification React Native hook
 * Covers hook state management, API integration, and error handling
 */

import { renderHook, act } from '@testing-library/react-native';
import {
  usePlantIdentification,
  usePlantIdentificationStatus,
} from '../usePlantIdentification';
import {
  PlantIdentificationService,
  createPlantIdentificationService,
  IdentificationResult,
} from '../../api/plantIdentificationService';
import { PlantInfo, PlantIdError } from '../../types/plantIdentification';
import { ImageData, Location } from '../../types/index';

// Mock the service
jest.mock('../../api/plantIdentificationService');
const mockCreatePlantIdentificationService = createPlantIdentificationService as jest.MockedFunction<
  typeof createPlantIdentificationService
>;

// Mock the config
jest.mock('../../../config/plantId', () => ({
  createPlantIdServiceConfig: jest.fn(() => ({
    apiKey: 'test-key',
    enableCaching: true,
    cacheExpiryMs: 86400000,
    minConfidenceThreshold: 0.1,
    maxSuggestions: 5,
  })),
}));

describe('usePlantIdentification', () => {
  const mockImageData: ImageData = {
    uri: 'file://test-image.jpg',
    width: 800,
    height: 600,
    mimeType: 'image/jpeg',
  };

  const mockLocation: Location = {
    latitude: 40.7128,
    longitude: -74.0060,
  };

  const mockPlantInfo: PlantInfo = {
    scientificName: 'Rosa rubiginosa',
    commonNames: ['Sweet Briar'],
    family: 'Rosaceae',
    genus: 'Rosa',
    confidence: 0.85,
    description: 'A wild rose species',
    careInfo: {
      watering: 'Every 7-14 days',
      growthRate: 'medium',
      edibleParts: ['fruit'],
    },
  };

  const mockSuccessResult: IdentificationResult = {
    success: true,
    plants: [mockPlantInfo],
    confidence: 0.85,
    processingTimeMs: 1500,
  };

  const mockErrorResult: IdentificationResult = {
    success: false,
    plants: [],
    confidence: 0,
    processingTimeMs: 500,
    error: {
      code: 'IDENTIFICATION_FAILED',
      message: 'API request failed',
      details: { statusCode: 500, apiResponse: 'Network error' },
    },
  };

  let mockService: jest.Mocked<PlantIdentificationService>;

  beforeEach(() => {
    // Create mock service
    mockService = {
      identifyPlant: jest.fn(),
      getPlantDetails: jest.fn(),
      getCacheStats: jest.fn(),
      clearCache: jest.fn(),
    } as any;

    mockCreatePlantIdentificationService.mockReturnValue(mockService);
    
    // Reset all mocks
    jest.clearAllMocks();
  });

  describe('initialization', () => {
    it('should initialize with default state', () => {
      const { result } = renderHook(() => usePlantIdentification());

      expect(result.current.isLoading).toBe(false);
      expect(result.current.isInitialized).toBe(false);
      expect(result.current.result).toBeNull();
      expect(result.current.error).toBeNull();
      expect(result.current.plants).toEqual([]);
      expect(result.current.confidence).toBe(0);
      expect(result.current.processingTime).toBeNull();
    });

    it('should auto-initialize when API key is provided', async () => {
      const { result, waitForNextUpdate } = renderHook(() =>
        usePlantIdentification({
          apiKey: 'test-api-key',
          autoInitialize: true,
        })
      );

      await waitForNextUpdate();

      expect(result.current.isInitialized).toBe(true);
      expect(mockCreatePlantIdentificationService).toHaveBeenCalledWith(
        expect.objectContaining({
          apiKey: 'test-api-key',
          enableCaching: true,
          minConfidenceThreshold: 0.1,
          maxSuggestions: 5,
        })
      );
    });

    it('should not auto-initialize when autoInitialize is false', () => {
      const { result } = renderHook(() =>
        usePlantIdentification({
          apiKey: 'test-api-key',
          autoInitialize: false,
        })
      );

      expect(result.current.isInitialized).toBe(false);
      expect(mockCreatePlantIdentificationService).not.toHaveBeenCalled();
    });

    it('should handle initialization errors', async () => {
      mockCreatePlantIdentificationService.mockImplementation(() => {
        throw new Error('Invalid API key');
      });

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        try {
          await result.current.initialize('invalid-key');
        } catch (error: any) {
          // Expected to throw
        }
      });

      expect(result.current.isInitialized).toBe(false);
      expect(result.current.error).toEqual({
        code: 'INITIALIZATION_FAILED',
        message: 'Invalid API key',
        details: { error: expect.any(Error) },
      });
    });
  });

  describe('plant identification', () => {
    beforeEach(async () => {
      mockService.identifyPlant.mockResolvedValue(mockSuccessResult);
    });

    it('should identify plant successfully', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      expect(result.current.isInitialized).toBe(true);

      await act(async () => {
        const identificationResult = await result.current.identifyPlant(mockImageData, mockLocation);
        expect(identificationResult).toEqual(mockSuccessResult);
      });

      expect(result.current.isLoading).toBe(false);
      expect(result.current.result).toEqual(mockSuccessResult);
      expect(result.current.plants).toEqual([mockPlantInfo]);
      expect(result.current.confidence).toBe(0.85);
      expect(result.current.processingTime).toBe(1500);
      expect(result.current.error).toBeNull();

      expect(mockService.identifyPlant).toHaveBeenCalledWith(mockImageData, mockLocation);
    });

    it('should handle identification errors', async () => {
      mockService.identifyPlant.mockResolvedValue(mockErrorResult);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      await act(async () => {
        const identificationResult = await result.current.identifyPlant(mockImageData);
        expect(identificationResult).toEqual(mockErrorResult);
      });

      expect(result.current.result).toEqual(mockErrorResult);
      expect(result.current.plants).toEqual([]);
      expect(result.current.confidence).toBe(0);
      expect(result.current.error).toEqual(mockErrorResult.error);
    });

    it('should handle service exceptions', async () => {
      const serviceError = new Error('Service unavailable');
      mockService.identifyPlant.mockRejectedValue(serviceError);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      await act(async () => {
        try {
          await result.current.identifyPlant(mockImageData);
        } catch (error: any) {
          expect(error).toEqual({
            code: 'IDENTIFICATION_FAILED',
            message: 'Service unavailable',
            details: { error: serviceError },
          });
        }
      });

      expect(result.current.error).toEqual({
        code: 'IDENTIFICATION_FAILED',
        message: 'Service unavailable',
        details: { error: serviceError },
      });
    });

    it('should throw error when not initialized', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        try {
          await result.current.identifyPlant(mockImageData);
        } catch (error: any) {
          expect(error.message).toBe(
            'Plant identification service not initialized. Call initialize() first.'
          );
        }
      });
    });

    it('should update loading state during identification', async () => {
      let resolveIdentification: (result: IdentificationResult) => void;
      const identificationPromise = new Promise<IdentificationResult>((resolve) => {
        resolveIdentification = resolve;
      });
      
      mockService.identifyPlant.mockReturnValue(identificationPromise);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      // Start identification
      act(() => {
        result.current.identifyPlant(mockImageData);
      });

      expect(result.current.isLoading).toBe(true);

      // Complete identification
      await act(async () => {
        resolveIdentification!(mockSuccessResult);
      });

      expect(result.current.isLoading).toBe(false);
    });
  });

  describe('plant details', () => {
    it('should get plant details successfully', async () => {
      mockService.getPlantDetails.mockResolvedValue(mockPlantInfo);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      let plantDetails: PlantInfo | null = null;
      await act(async () => {
        plantDetails = await result.current.getPlantDetails('Rosa rubiginosa');
      });

      expect(plantDetails).toEqual(mockPlantInfo);
      expect(mockService.getPlantDetails).toHaveBeenCalledWith('Rosa rubiginosa');
    });

    it('should handle plant details errors', async () => {
      mockService.getPlantDetails.mockRejectedValue(new Error('Not found'));

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      let plantDetails: PlantInfo | null = null;
      await act(async () => {
        plantDetails = await result.current.getPlantDetails('Unknown plant');
      });

      expect(plantDetails).toBeNull();
    });

    it('should throw error when service not initialized', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        try {
          await result.current.getPlantDetails('Rosa rubiginosa');
        } catch (error: any) {
          expect(error.message).toBe('Plant identification service not initialized');
        }
      });
    });
  });

  describe('state management', () => {
    it('should clear result', async () => {
      mockService.identifyPlant.mockResolvedValue(mockSuccessResult);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
        await result.current.identifyPlant(mockImageData);
      });

      expect(result.current.result).toEqual(mockSuccessResult);

      act(() => {
        result.current.clearResult();
      });

      expect(result.current.result).toBeNull();
      expect(result.current.plants).toEqual([]);
      expect(result.current.confidence).toBe(0);
      expect(result.current.processingTime).toBeNull();
    });

    it('should clear error', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        try {
          await result.current.initialize('invalid-key');
        } catch (error) {
          // Expected to throw
        }
      });

      expect(result.current.error).toBeTruthy();

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
    });
  });

  describe('cache management', () => {
    it('should get cache stats', async () => {
      const mockStats = { size: 5, entries: 5 };
      mockService.getCacheStats.mockReturnValue(mockStats);

      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      const stats = result.current.getCacheStats();
      expect(stats).toEqual(mockStats);
    });

    it('should clear cache', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      act(() => {
        result.current.clearCache();
      });

      expect(mockService.clearCache).toHaveBeenCalled();
    });

    it('should return empty stats when service not initialized', () => {
      const { result } = renderHook(() => usePlantIdentification());

      const stats = result.current.getCacheStats();
      expect(stats).toEqual({ size: 0, entries: 0 });
    });
  });

  describe('configuration options', () => {
    it('should use custom configuration options', async () => {
      const { result } = renderHook(() =>
        usePlantIdentification({
          enableCaching: false,
          minConfidenceThreshold: 0.3,
          maxSuggestions: 3,
        })
      );

      await act(async () => {
        await result.current.initialize('test-api-key');
      });

      expect(mockCreatePlantIdentificationService).toHaveBeenCalledWith(
        expect.objectContaining({
          enableCaching: false,
          minConfidenceThreshold: 0.3,
          maxSuggestions: 3,
        })
      );
    });
  });

  describe('concurrent initialization', () => {
    it('should handle concurrent initialization calls', async () => {
      const { result } = renderHook(() => usePlantIdentification());

      // Start multiple initialization calls simultaneously
      const promises = [
        result.current.initialize('test-api-key'),
        result.current.initialize('test-api-key'),
        result.current.initialize('test-api-key'),
      ];

      await act(async () => {
        await Promise.all(promises);
      });

      expect(result.current.isInitialized).toBe(true);
      // Service should only be created once
      expect(mockCreatePlantIdentificationService).toHaveBeenCalledTimes(1);
    });
  });
});

describe('usePlantIdentificationStatus', () => {
  it('should return status information', () => {
    const { result } = renderHook(() => usePlantIdentificationStatus());

    expect(result.current.hasApiKey).toBe(false);
    expect(result.current.environment).toBeDefined();
    expect(result.current.lastCheck).toBeGreaterThan(0);
    expect(typeof result.current.refresh).toBe('function');
  });

  it('should refresh status', () => {
    const { result } = renderHook(() => usePlantIdentificationStatus());

    const initialLastCheck = result.current.lastCheck;

    act(() => {
      result.current.refresh();
    });

    expect(result.current.lastCheck).toBeGreaterThan(initialLastCheck);
  });

  it('should handle status check errors gracefully', () => {
    const consoleSpy = jest.spyOn(console, 'warn').mockImplementation();
    
    // Mock __DEV__ to throw an error
    const originalDev = (global as any).__DEV__;
    Object.defineProperty(global, '__DEV__', {
      get: () => {
        throw new Error('Test error');
      },
      configurable: true,
    });

    const { result } = renderHook(() => usePlantIdentificationStatus());

    expect(result.current.environment).toBe('unknown');
    expect(consoleSpy).toHaveBeenCalledWith(
      'Failed to check plant identification status:',
      expect.any(Error)
    );

    // Restore original value
    Object.defineProperty(global, '__DEV__', {
      value: originalDev,
      configurable: true,
    });
    consoleSpy.mockRestore();
  });
});
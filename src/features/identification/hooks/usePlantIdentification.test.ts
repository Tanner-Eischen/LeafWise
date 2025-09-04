/**
 * Tests for usePlantIdentification hook
 * Verifies the functionality of the plant identification hook
 */

import { renderHook, act } from '@testing-library/react-hooks';
import { usePlantIdentification } from './usePlantIdentification';
import { plantIdentificationService } from '../services';

// Mock the plant identification service
jest.mock('../services', () => ({
  plantIdentificationService: {
    identifyPlant: jest.fn(),
    identifyPlantFromMultipleImages: jest.fn(),
    checkServiceAvailability: jest.fn(),
    clearCache: jest.fn()
  }
}));

describe('usePlantIdentification', () => {
  // Sample mock data
  const mockBase64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD';
  const mockPlantInfo = [
    {
      scientificName: 'Monstera deliciosa',
      commonNames: ['Swiss cheese plant', 'Split-leaf philodendron'],
      family: 'Araceae',
      genus: 'Monstera',
      confidence: 0.95,
      description: 'Monstera deliciosa is a species of flowering plant native to tropical forests of southern Mexico.',
      imageUrl: 'https://example.com/monstera.jpg',
      careInfo: {
        watering: '1-2',
        lightRequirements: 'Bright indirect light',
        growthRate: 'Fast',
        edibleParts: ['Fruit']
      }
    },
    {
      scientificName: 'Philodendron bipinnatifidum',
      commonNames: ['Tree philodendron', 'Split-leaf philodendron'],
      family: 'Araceae',
      genus: 'Philodendron',
      confidence: 0.75,
      description: 'Philodendron bipinnatifidum is a tree-like plant with large, deeply lobed leaves.',
      imageUrl: 'https://example.com/philodendron.jpg',
      careInfo: {
        watering: '1-2',
        lightRequirements: 'Bright indirect light',
        growthRate: 'Medium',
        edibleParts: []
      }
    }
  ];
  
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('should initialize with default values', () => {
    const { result } = renderHook(() => usePlantIdentification());
    
    expect(result.current.plants).toEqual([]);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.confidence).toBe(0);
  });
  
  describe('identifyPlant', () => {
    it('should identify a plant successfully', async () => {
      // Mock the service response
      (plantIdentificationService.identifyPlant as jest.Mock).mockResolvedValue(mockPlantInfo);
      
      const { result, waitForNextUpdate } = renderHook(() => usePlantIdentification());
      
      // Initial state
      expect(result.current.isLoading).toBe(false);
      
      // Call the hook method
      act(() => {
        result.current.identifyPlant(mockBase64Image);
      });
      
      // Should be loading
      expect(result.current.isLoading).toBe(true);
      
      // Wait for the async operation to complete
      await waitForNextUpdate();
      
      // Should have results
      expect(result.current.isLoading).toBe(false);
      expect(result.current.plants).toEqual(mockPlantInfo);
      expect(result.current.confidence).toBe(0.95); // Highest confidence
      expect(result.current.error).toBeNull();
      
      // Verify service was called correctly
      expect(plantIdentificationService.identifyPlant).toHaveBeenCalledWith(
        mockBase64Image,
        undefined
      );
    });
    
    it('should handle identification errors', async () => {
      // Mock an error response
      const mockError = {
        code: 'API_ERROR',
        message: 'API request failed',
        details: { statusCode: 500 }
      };
      (plantIdentificationService.identifyPlant as jest.Mock).mockRejectedValue(mockError);
      
      const { result, waitForNextUpdate } = renderHook(() => usePlantIdentification());
      
      // Call the hook method
      act(() => {
        result.current.identifyPlant(mockBase64Image);
      });
      
      // Wait for the async operation to complete
      await waitForNextUpdate();
      
      // Should have error
      expect(result.current.isLoading).toBe(false);
      expect(result.current.plants).toEqual([]);
      expect(result.current.confidence).toBe(0);
      expect(result.current.error).toEqual(mockError);
    });
    
    it('should handle empty input', async () => {
      const { result } = renderHook(() => usePlantIdentification());
      
      // Call the hook method with empty input
      act(() => {
        result.current.identifyPlant('');
      });
      
      // Should set an error immediately
      expect(result.current.error).toEqual(expect.objectContaining({
        code: 'INVALID_INPUT'
      }));
      expect(result.current.isLoading).toBe(false);
      
      // Service should not be called
      expect(plantIdentificationService.identifyPlant).not.toHaveBeenCalled();
    });
  });
  
  describe('identifyPlantFromMultipleImages', () => {
    it('should identify a plant from multiple images', async () => {
      // Mock the service response
      (plantIdentificationService.identifyPlantFromMultipleImages as jest.Mock).mockResolvedValue(mockPlantInfo);
      
      const { result, waitForNextUpdate } = renderHook(() => usePlantIdentification());
      
      // Call the hook method
      act(() => {
        result.current.identifyPlantFromMultipleImages([mockBase64Image, mockBase64Image]);
      });
      
      // Wait for the async operation to complete
      await waitForNextUpdate();
      
      // Should have results
      expect(result.current.plants).toEqual(mockPlantInfo);
      
      // Verify service was called correctly
      expect(plantIdentificationService.identifyPlantFromMultipleImages).toHaveBeenCalledWith(
        [mockBase64Image, mockBase64Image],
        undefined
      );
    });
  });
  
  describe('retry', () => {
    it('should retry the last identification request', async () => {
      // Mock the service response
      (plantIdentificationService.identifyPlant as jest.Mock).mockResolvedValue(mockPlantInfo);
      
      const { result, waitForNextUpdate } = renderHook(() => usePlantIdentification());
      
      // Make an initial request
      act(() => {
        result.current.identifyPlant(mockBase64Image);
      });
      
      await waitForNextUpdate();
      
      // Clear the mock to verify it's called again
      jest.clearAllMocks();
      
      // Retry the request
      act(() => {
        result.current.retry();
      });
      
      // Wait for the async operation to complete
      await waitForNextUpdate();
      
      // Verify service was called again with the same parameters
      expect(plantIdentificationService.identifyPlant).toHaveBeenCalledWith(
        mockBase64Image,
        undefined
      );
    });
    
    it('should handle retry with no previous request', async () => {
      const { result } = renderHook(() => usePlantIdentification());
      
      // Try to retry without a previous request
      act(() => {
        result.current.retry();
      });
      
      // Should set an error
      expect(result.current.error).toEqual(expect.objectContaining({
        code: 'NO_PREVIOUS_REQUEST'
      }));
      
      // Service should not be called
      expect(plantIdentificationService.identifyPlant).not.toHaveBeenCalled();
      expect(plantIdentificationService.identifyPlantFromMultipleImages).not.toHaveBeenCalled();
    });
  });
  
  describe('clearResults', () => {
    it('should clear identification results', async () => {
      // Mock the service response
      (plantIdentificationService.identifyPlant as jest.Mock).mockResolvedValue(mockPlantInfo);
      
      const { result, waitForNextUpdate } = renderHook(() => usePlantIdentification());
      
      // Make an identification request
      act(() => {
        result.current.identifyPlant(mockBase64Image);
      });
      
      await waitForNextUpdate();
      
      // Verify we have results
      expect(result.current.plants).toEqual(mockPlantInfo);
      
      // Clear the results
      act(() => {
        result.current.clearResults();
      });
      
      // Verify results are cleared
      expect(result.current.plants).toEqual([]);
      expect(result.current.error).toBeNull();
      expect(result.current.confidence).toBe(0);
    });
  });
  
  describe('checkServiceAvailability', () => {
    it('should check if the service is available', async () => {
      // Mock the service response
      (plantIdentificationService.checkServiceAvailability as jest.Mock).mockResolvedValue(true);
      
      const { result } = renderHook(() => usePlantIdentification());
      
      // Check availability
      const available = await result.current.checkServiceAvailability();
      
      // Verify result
      expect(available).toBe(true);
      expect(plantIdentificationService.checkServiceAvailability).toHaveBeenCalled();
    });
    
    it('should handle service unavailability', async () => {
      // Mock the service response
      (plantIdentificationService.checkServiceAvailability as jest.Mock).mockResolvedValue(false);
      
      const { result } = renderHook(() => usePlantIdentification());
      
      // Check availability
      const available = await result.current.checkServiceAvailability();
      
      // Verify result
      expect(available).toBe(false);
    });
    
    it('should handle errors during availability check', async () => {
      // Mock an error
      (plantIdentificationService.checkServiceAvailability as jest.Mock).mockRejectedValue(
        new Error('Network error')
      );
      
      const { result } = renderHook(() => usePlantIdentification());
      
      // Check availability
      const available = await result.current.checkServiceAvailability();
      
      // Should return false on error
      expect(available).toBe(false);
    });
  });
});
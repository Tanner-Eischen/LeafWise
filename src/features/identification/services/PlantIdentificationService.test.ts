/**
 * Tests for PlantIdentificationService
 * Verifies the functionality of the plant identification service
 */

import { PlantIdentificationService } from './PlantIdentificationService';
import { plantIdApiClient } from '../api';
import { PlantIdentificationResponse, PlantSuggestion } from '../../../core/types/plantIdentification';

// Mock the API client
jest.mock('../api', () => ({
  plantIdApiClient: {
    identifyPlant: jest.fn(),
    checkAvailability: jest.fn()
  }
}));

describe('PlantIdentificationService', () => {
  let service: PlantIdentificationService;
  
  // Sample mock data
  const mockBase64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD';
  const mockApiResponse: PlantIdentificationResponse = {
    id: 123456,
    suggestions: [
      {
        id: 1,
        plant_name: 'Monstera deliciosa',
        plant_details: {
          common_names: ['Swiss cheese plant', 'Split-leaf philodendron'],
          taxonomy: {
            class: 'Liliopsida',
            family: 'Araceae',
            genus: 'Monstera',
            order: 'Alismatales',
            phylum: 'Tracheophyta'
          },
          wiki_description: {
            value: 'Monstera deliciosa is a species of flowering plant native to tropical forests of southern Mexico.',
            citation: 'https://en.wikipedia.org/wiki/Monstera_deliciosa',
            license_name: 'CC BY-SA 3.0',
            license_url: 'https://creativecommons.org/licenses/by-sa/3.0/'
          },
          watering: {
            min: 1,
            max: 2
          },
          image: {
            value: 'https://example.com/monstera.jpg',
            citation: 'Plant.id',
            license_name: 'CC0',
            license_url: 'https://creativecommons.org/publicdomain/zero/1.0/'
          }
        },
        probability: 0.95,
        confirmed: false,
        similar_images: [
          {
            id: 'abc123',
            url: 'https://example.com/similar1.jpg',
            similarity: 0.9,
            url_small: 'https://example.com/similar1_small.jpg'
          }
        ]
      },
      {
        id: 2,
        plant_name: 'Philodendron bipinnatifidum',
        plant_details: {
          common_names: ['Tree philodendron', 'Split-leaf philodendron'],
          taxonomy: {
            class: 'Liliopsida',
            family: 'Araceae',
            genus: 'Philodendron',
            order: 'Alismatales',
            phylum: 'Tracheophyta'
          },
          wiki_description: {
            value: 'Philodendron bipinnatifidum is a tree-like plant with large, deeply lobed leaves.',
            citation: 'https://en.wikipedia.org/wiki/Philodendron_bipinnatifidum',
            license_name: 'CC BY-SA 3.0',
            license_url: 'https://creativecommons.org/licenses/by-sa/3.0/'
          },
          watering: {
            min: 1,
            max: 2
          }
        },
        probability: 0.75,
        confirmed: false
      }
    ],
    is_plant: {
      probability: 0.98,
      binary: true
    },
    modifiers: ['crops_fast'],
    secret: 'abc123',
    uploaded_datetime: '2023-06-15T10:30:00.000Z'
  };

  beforeEach(() => {
    jest.clearAllMocks();
    service = new PlantIdentificationService();
  });

  describe('identifyPlant', () => {
    it('should identify a plant from a single image', async () => {
      // Mock the API client response
      (plantIdApiClient.identifyPlant as jest.Mock).mockResolvedValue(mockApiResponse);
      
      // Call the service
      const result = await service.identifyPlant(mockBase64Image);
      
      // Verify the result
      expect(result).toHaveLength(2);
      expect(result[0].scientificName).toBe('Monstera deliciosa');
      expect(result[0].commonNames).toEqual(['Swiss cheese plant', 'Split-leaf philodendron']);
      expect(result[0].confidence).toBe(0.95);
      expect(result[0].family).toBe('Araceae');
      expect(result[0].genus).toBe('Monstera');
      
      // Verify the API client was called correctly
      expect(plantIdApiClient.identifyPlant).toHaveBeenCalledWith(expect.objectContaining({
        images: [mockBase64Image],
        modifiers: ['crops_fast'],
        plant_details: expect.any(Array),
        plant_language: 'en'
      }));
    });
    
    it('should throw an error when no images are provided', async () => {
      await expect(service.identifyPlant('')).rejects.toEqual(expect.objectContaining({
        code: 'INVALID_INPUT'
      }));
    });
    
    it('should handle API errors gracefully', async () => {
      // Mock an API error
      const mockError = {
        code: 'API_ERROR',
        message: 'API request failed',
        details: { statusCode: 500 }
      };
      (plantIdApiClient.identifyPlant as jest.Mock).mockRejectedValue(mockError);
      
      // Verify the error is propagated
      await expect(service.identifyPlant(mockBase64Image)).rejects.toEqual(mockError);
    });
  });
  
  describe('identifyPlantFromMultipleImages', () => {
    it('should identify a plant from multiple images', async () => {
      // Mock the API client response
      (plantIdApiClient.identifyPlant as jest.Mock).mockResolvedValue(mockApiResponse);
      
      // Call the service
      const result = await service.identifyPlantFromMultipleImages([mockBase64Image, mockBase64Image]);
      
      // Verify the result
      expect(result).toHaveLength(2);
      
      // Verify the API client was called correctly
      expect(plantIdApiClient.identifyPlant).toHaveBeenCalledWith(expect.objectContaining({
        images: [mockBase64Image, mockBase64Image]
      }));
    });
  });
  
  describe('mapResponseToPlantInfo', () => {
    it('should map API response to PlantInfo format', () => {
      const result = service.mapResponseToPlantInfo(mockApiResponse);
      
      expect(result).toHaveLength(2);
      expect(result[0]).toEqual(expect.objectContaining({
        scientificName: 'Monstera deliciosa',
        commonNames: ['Swiss cheese plant', 'Split-leaf philodendron'],
        family: 'Araceae',
        genus: 'Monstera',
        confidence: 0.95,
        description: 'Monstera deliciosa is a species of flowering plant native to tropical forests of southern Mexico.',
        imageUrl: 'https://example.com/monstera.jpg',
        careInfo: expect.objectContaining({
          watering: '1-2'
        })
      }));
    });
    
    it('should handle empty suggestions', () => {
      const emptyResponse = { ...mockApiResponse, suggestions: [] };
      const result = service.mapResponseToPlantInfo(emptyResponse);
      
      expect(result).toEqual([]);
    });
  });
  
  describe('checkServiceAvailability', () => {
    it('should return true when service is available', async () => {
      (plantIdApiClient.checkAvailability as jest.Mock).mockResolvedValue(true);
      
      const result = await service.checkServiceAvailability();
      
      expect(result).toBe(true);
      expect(plantIdApiClient.checkAvailability).toHaveBeenCalled();
    });
    
    it('should return false when service is unavailable', async () => {
      (plantIdApiClient.checkAvailability as jest.Mock).mockResolvedValue(false);
      
      const result = await service.checkServiceAvailability();
      
      expect(result).toBe(false);
    });
    
    it('should handle errors and return false', async () => {
      (plantIdApiClient.checkAvailability as jest.Mock).mockRejectedValue(new Error('Network error'));
      
      const result = await service.checkServiceAvailability();
      
      expect(result).toBe(false);
    });
  });
  
  describe('caching', () => {
    it('should cache identification results', async () => {
      // Mock the API client response
      (plantIdApiClient.identifyPlant as jest.Mock).mockResolvedValue(mockApiResponse);
      
      // First call should hit the API
      await service.identifyPlant(mockBase64Image);
      
      // Second call with the same image should use the cache
      await service.identifyPlant(mockBase64Image);
      
      // API should only be called once
      expect(plantIdApiClient.identifyPlant).toHaveBeenCalledTimes(1);
    });
    
    it('should clear the cache when requested', async () => {
      // Mock the API client response
      (plantIdApiClient.identifyPlant as jest.Mock).mockResolvedValue(mockApiResponse);
      
      // First call should hit the API
      await service.identifyPlant(mockBase64Image);
      
      // Clear the cache
      await service.clearCache();
      
      // Second call should hit the API again
      await service.identifyPlant(mockBase64Image);
      
      // API should be called twice
      expect(plantIdApiClient.identifyPlant).toHaveBeenCalledTimes(2);
    });
  });
});
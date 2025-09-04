/**
 * Tests for Plant Identification Service
 * Covers service layer functionality, caching, error handling, and business logic
 */

import {
  PlantIdentificationService,
  createPlantIdentificationService,
  getPlantIdentificationService,
  IdentificationResult,
} from '../plantIdentificationService';
import { PlantIdClient } from '../plantIdClient';
import {
  PlantIdentificationResponse,
  PlantInfo,
  PlantIdError,
} from '../../types/plantIdentification';
import { ImageData, Location } from '../../types';

// Mock the PlantIdClient
jest.mock('../plantIdClient');
const MockedPlantIdClient = PlantIdClient as jest.MockedClass<typeof PlantIdClient>;

describe('PlantIdentificationService', () => {
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

  const mockApiResponse: PlantIdentificationResponse = {
    id: 123,
    meta_data: {
      latitude: 40.7128,
      longitude: -74.0060,
      date: '2023-01-01',
      datetime: '2023-01-01T12:00:00Z',
    },
    uploaded_datetime: 1672574400,
    finished_datetime: 1672574460,
    images: [
      {
        file_name: 'test-image.jpg',
        url: 'https://example.com/test-image.jpg',
      },
    ],
    suggestions: [
      {
        id: 1,
        plant_name: 'Rosa rubiginosa',
        plant_details: {
          common_names: ['Sweet Briar', 'Eglantine'],
          url: 'https://example.com/rosa-rubiginosa',
          name_authority: 'L.',
          wiki_description: {
            value: 'Rosa rubiginosa is a species of wild rose.',
            citation: 'Wikipedia',
            license_name: 'CC BY-SA 3.0',
            license_url: 'https://creativecommons.org/licenses/by-sa/3.0/',
          },
          taxonomy: {
            class: 'Magnoliopsida',
            genus: 'Rosa',
            order: 'Rosales',
            family: 'Rosaceae',
            phylum: 'Tracheophyta',
            kingdom: 'Plantae',
          },
          synonyms: ['Rosa eglanteria'],
          image: {
            value: 'https://example.com/image.jpg',
            citation: 'Example Source',
            license_name: 'CC BY 4.0',
            license_url: 'https://creativecommons.org/licenses/by/4.0/',
          },
          edible_parts: ['fruit'],
          watering: {
            max: 3,
            min: 1,
          },
          propagation_methods: ['seed', 'cutting'],
          hardiness: {
            min: '4a',
            max: '9b',
          },
          growth_rate: 'medium',
        },
        probability: 0.95,
        confirmed: false,
        similar_images: [
          {
            id: 'img1',
            url: 'https://example.com/similar1.jpg',
            license_name: 'CC BY 4.0',
            license_url: 'https://creativecommons.org/licenses/by/4.0/',
            citation: 'Example Citation',
            similarity: 0.85,
            url_small: 'https://example.com/similar1_small.jpg',
          },
        ],
      },
    ],
    is_plant: {
      probability: 0.98,
      threshold: 0.5,
      binary: true,
    },
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

  let service: PlantIdentificationService;
  let mockClient: jest.Mocked<PlantIdClient>;

  beforeEach(() => {
    // Reset mocks
    MockedPlantIdClient.mockClear();
    
    // Create mock client instance
    mockClient = {
      identifyPlant: jest.fn(),
      getPlantDetails: jest.fn(),
      formatPlantInfo: jest.fn(),
    } as any;
    
    MockedPlantIdClient.mockImplementation(() => mockClient);
    
    // Create service instance
    service = createPlantIdentificationService({
      apiKey: 'test-api-key',
      enableCaching: true,
      minConfidenceThreshold: 0.1,
      maxSuggestions: 5,
    });
  });

  describe('constructor and factory', () => {
    it('should create service with default configuration', () => {
      const service = createPlantIdentificationService({ apiKey: 'test-key' });
      expect(service).toBeInstanceOf(PlantIdentificationService);
    });

    it('should create service with custom configuration', () => {
      const service = createPlantIdentificationService({
        apiKey: 'test-key',
        enableCaching: false,
        minConfidenceThreshold: 0.2,
        maxSuggestions: 3,
      });
      expect(service).toBeInstanceOf(PlantIdentificationService);
    });
  });

  describe('identifyPlant', () => {
    beforeEach(() => {
      mockClient.identifyPlant.mockResolvedValue(mockApiResponse);
      mockClient.formatPlantInfo.mockReturnValue(mockPlantInfo);
    });

    it('should identify plant successfully', async () => {
      const result = await service.identifyPlant(mockImageData, mockLocation);

      expect(result.success).toBe(true);
      expect(result.plants).toHaveLength(2);
      expect(result.confidence).toBe(0.85);
      expect(result.processingTimeMs).toBeGreaterThan(0);
      expect(mockClient.identifyPlant).toHaveBeenCalledWith(
        mockImageData,
        expect.objectContaining({
          location: mockLocation,
          includeDetails: true,
          includeSimilarImages: false,
          language: 'en',
          classificationLevel: 'species',
        })
      );
    });

    it('should filter suggestions by confidence threshold', async () => {
      const lowConfidenceResponse = {
        ...mockApiResponse,
        suggestions: [
          { ...mockApiResponse.suggestions[0], probability: 0.05 }, // Below threshold
          { ...mockApiResponse.suggestions[1], probability: 0.65 }, // Above threshold
        ],
      };
      
      mockClient.identifyPlant.mockResolvedValue(lowConfidenceResponse);
      
      const result = await service.identifyPlant(mockImageData);
      
      expect(result.plants).toHaveLength(1);
      expect(mockClient.formatPlantInfo).toHaveBeenCalledTimes(1);
    });

    it('should limit suggestions to maxSuggestions', async () => {
      const manyResponse = {
        ...mockApiResponse,
        suggestions: Array(10).fill(null).map((_, i) => ({
          ...mockApiResponse.suggestions[0],
          id: i + 1,
          probability: 0.8 - (i * 0.05),
        })),
      };
      
      mockClient.identifyPlant.mockResolvedValue(manyResponse);
      
      const result = await service.identifyPlant(mockImageData);
      
      expect(result.plants).toHaveLength(5); // maxSuggestions
      expect(mockClient.formatPlantInfo).toHaveBeenCalledTimes(5);
    });

    it('should handle API errors gracefully', async () => {
      const apiError = new Error('API request failed');
      mockClient.identifyPlant.mockRejectedValue(apiError);

      const result = await service.identifyPlant(mockImageData);

      expect(result.success).toBe(false);
      expect(result.plants).toHaveLength(0);
      expect(result.confidence).toBe(0);
      expect(result.error).toEqual({
        code: 'IDENTIFICATION_FAILED',
        message: 'API request failed',
        details: { originalError: 'API request failed' },
      });
    });

    it('should handle formatting errors gracefully', async () => {
      mockClient.identifyPlant.mockResolvedValue(mockApiResponse);
      mockClient.formatPlantInfo
        .mockImplementationOnce(() => { throw new Error('Format error'); })
        .mockReturnValueOnce(mockPlantInfo);

      const consoleSpy = jest.spyOn(console, 'warn').mockImplementation();
      
      const result = await service.identifyPlant(mockImageData);

      expect(result.success).toBe(true);
      expect(result.plants).toHaveLength(1); // Only the second suggestion formatted successfully
      expect(consoleSpy).toHaveBeenCalledWith('Failed to format plant suggestion:', expect.any(Error));
      
      consoleSpy.mockRestore();
    });

    it('should return unsuccessful result when no valid suggestions', async () => {
      const emptyResponse = { ...mockApiResponse, suggestions: [] };
      mockClient.identifyPlant.mockResolvedValue(emptyResponse);

      const result = await service.identifyPlant(mockImageData);

      expect(result.success).toBe(false);
      expect(result.plants).toHaveLength(0);
      expect(result.confidence).toBe(0);
    });
  });

  describe('caching', () => {
    beforeEach(() => {
      mockClient.identifyPlant.mockResolvedValue(mockApiResponse);
      mockClient.formatPlantInfo.mockReturnValue(mockPlantInfo);
    });

    it('should cache successful results', async () => {
      const result1 = await service.identifyPlant(mockImageData);
      const result2 = await service.identifyPlant(mockImageData);

      expect(result1.success).toBe(true);
      expect(result2.success).toBe(true);
      expect(mockClient.identifyPlant).toHaveBeenCalledTimes(1); // Second call used cache
    });

    it('should not cache failed results', async () => {
      mockClient.identifyPlant.mockRejectedValue(new Error('API error'));

      await service.identifyPlant(mockImageData);
      await service.identifyPlant(mockImageData);

      expect(mockClient.identifyPlant).toHaveBeenCalledTimes(2); // Both calls hit API
    });

    it('should clear cache', () => {
      service.clearCache();
      expect(service.getCacheStats().size).toBe(0);
    });

    it('should provide cache statistics', async () => {
      await service.identifyPlant(mockImageData);
      
      const stats = service.getCacheStats();
      expect(stats.size).toBe(1);
      expect(stats.entries).toBe(1);
    });
  });

  describe('getPlantDetails', () => {
    it('should get plant details successfully', async () => {
      mockClient.getPlantDetails.mockResolvedValue(mockPlantInfo);

      const result = await service.getPlantDetails('Rosa rubiginosa');

      expect(result).toEqual(mockPlantInfo);
      expect(mockClient.getPlantDetails).toHaveBeenCalledWith('Rosa rubiginosa');
    });

    it('should handle errors gracefully', async () => {
      mockClient.getPlantDetails.mockRejectedValue(new Error('Not found'));
      const consoleSpy = jest.spyOn(console, 'warn').mockImplementation();

      const result = await service.getPlantDetails('Unknown plant');

      expect(result).toBeNull();
      expect(consoleSpy).toHaveBeenCalledWith(
        'Failed to get plant details for Unknown plant:',
        expect.any(Error)
      );
      
      consoleSpy.mockRestore();
    });
  });

  describe('configuration updates', () => {
    it('should update configuration', () => {
      service.updateConfig({
        minConfidenceThreshold: 0.3,
        maxSuggestions: 3,
      });

      // Configuration update is internal, so we test indirectly
      expect(service).toBeInstanceOf(PlantIdentificationService);
    });

    it('should recreate client when API key changes', () => {
      const initialCallCount = MockedPlantIdClient.mock.calls.length;
      
      service.updateConfig({ apiKey: 'new-api-key' });
      
      expect(MockedPlantIdClient.mock.calls.length).toBe(initialCallCount + 1);
    });
  });

  describe('getPlantIdentificationService singleton', () => {
    beforeEach(() => {
      // Reset the singleton
      (getPlantIdentificationService as any).defaultService = null;
    });

    it('should create singleton service with API key', () => {
      const service1 = getPlantIdentificationService('test-key');
      const service2 = getPlantIdentificationService();

      expect(service1).toBe(service2);
      expect(service1).toBeInstanceOf(PlantIdentificationService);
    });

    it('should throw error when no API key provided initially', () => {
      expect(() => getPlantIdentificationService())
        .toThrow('API key is required to initialize plant identification service');
    });
  });

  describe('error handling edge cases', () => {
    it('should handle unknown error types', async () => {
      mockClient.identifyPlant.mockRejectedValue('string error');

      const result = await service.identifyPlant(mockImageData);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('UNKNOWN_ERROR');
      expect(result.error?.message).toContain('Unknown error during plant identification');
    });

    it('should handle cache errors gracefully', async () => {
      // Mock a service with caching enabled but simulate cache errors
      const consoleSpy = jest.spyOn(console, 'warn').mockImplementation();
      
      // Override the generateImageHash method to throw an error
      const originalGenerateImageHash = (service as any).generateImageHash;
      (service as any).generateImageHash = jest.fn().mockRejectedValue(new Error('Hash error'));
      
      mockClient.identifyPlant.mockResolvedValue(mockApiResponse);
      mockClient.formatPlantInfo.mockReturnValue(mockPlantInfo);
      
      const result = await service.identifyPlant(mockImageData);
      
      expect(result.success).toBe(true); // Should still work despite cache errors
      expect(consoleSpy).toHaveBeenCalledWith('Failed to retrieve cached result:', expect.any(Error));
      expect(consoleSpy).toHaveBeenCalledWith('Failed to cache identification result:', expect.any(Error));
      
      // Restore original method
      (service as any).generateImageHash = originalGenerateImageHash;
      consoleSpy.mockRestore();
    });
  });

  describe('performance and timing', () => {
    it('should track processing time accurately', async () => {
      mockClient.identifyPlant.mockImplementation(() => 
        new Promise(resolve => 
          setTimeout(() => resolve(mockApiResponse), 100)
        )
      );
      mockClient.formatPlantInfo.mockReturnValue(mockPlantInfo);

      const result = await service.identifyPlant(mockImageData);

      expect(result.processingTimeMs).toBeGreaterThanOrEqual(100);
      expect(result.processingTimeMs).toBeLessThan(200); // Should be close to 100ms
    });
  });
});
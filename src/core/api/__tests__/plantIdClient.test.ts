/**
 * Tests for Plant.id API client
 * Covers authentication, API calls, error handling, and response formatting
 */

import { PlantIdClient, createPlantIdClient } from '../plantIdClient';
import {
  PlantIdentificationRequest,
  PlantIdentificationResponse,
  PlantIdApiConfig,
  IdentificationOptions,
} from '../../types/plantIdentification';
import { ImageData } from '../../types';

// Mock fetch globally
global.fetch = jest.fn();
global.FileReader = jest.fn(() => ({
  readAsDataURL: jest.fn(),
  onloadend: null,
  onerror: null,
  result: 'data:image/jpeg;base64,mockBase64Data',
})) as any;

const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

describe('PlantIdClient', () => {
  const mockConfig: PlantIdApiConfig = {
    apiKey: 'test-api-key',
    baseUrl: 'https://api.plant.id',
    timeout: 30000,
    retryAttempts: 3,
  };

  const mockImageData: ImageData = {
    uri: 'file://test-image.jpg',
    width: 800,
    height: 600,
    type: 'image/jpeg',
  };

  const mockApiResponse: PlantIdentificationResponse = {
    id: 'test-identification-id',
    suggestions: [
        {
          id: 1,
          plant_name: 'Rosa rubiginosa',
          plant_details: {
            common_names: ['Sweet Briar', 'Eglantine'],
            taxonomy: {
               kingdom: 'Plantae',
               phylum: 'Tracheophyta',
               class: 'Magnoliopsida',
               order: 'Rosales',
               family: 'Rosaceae',
               genus: 'Rosa',
             },
            wiki_description: {
             value: 'Rosa rubiginosa is a species of wild rose native to Europe.',
             citation: 'https://en.wikipedia.org/wiki/Rosa_rubiginosa',
             license_name: 'CC BY-SA',
             license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
           },
            image: {
               value: 'https://example.com/rosa-rubiginosa.jpg',
               citation: 'Test citation',
               license_name: 'CC BY-SA',
               license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
             },
            edible_parts: ['fruit'],
            watering: { min: 7, max: 14 },
            growth_rate: 'medium',
          },
          probability: 0.85,
          confirmed: false,
          similar_images: [],
        },
      ],
    modifiers: ['crops_fast', 'similar_images'],
    secret: 'test-secret',
    fail_cause: null,
    countable: true,
    feedback: null,
    is_plant_probability: 0.95,
  };

  let client: PlantIdClient;

  beforeEach(() => {
    client = new PlantIdClient(mockConfig);
    mockFetch.mockClear();
    jest.clearAllMocks();
  });

  describe('constructor', () => {
    it('should create client with valid configuration', () => {
      expect(client).toBeInstanceOf(PlantIdClient);
    });

    it('should set up correct headers', () => {
      // Access private property for testing
      const headers = (client as any).baseHeaders;
      expect(headers['Content-Type']).toBe('application/json');
      expect(headers['Api-Key']).toBe('test-api-key');
    });
  });

  describe('identifyPlant', () => {
    beforeEach(() => {
      // Mock successful fetch response
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ result: mockApiResponse }),
      } as Response);

      // Mock FileReader
      const mockFileReader = {
        readAsDataURL: jest.fn(),
        onloadend: null,
        onerror: null,
        result: 'data:image/jpeg;base64,mockBase64Data',
      };
      
      (global.FileReader as any).mockImplementation(() => mockFileReader);
      
      // Mock fetch for image conversion
      global.fetch = jest.fn().mockImplementation((url) => {
        if (url === mockImageData.uri) {
          return Promise.resolve({
            blob: () => Promise.resolve(new Blob(['mock image data'], { type: 'image/jpeg' })),
          });
        }
        return mockFetch(url);
      });
    });

    it('should identify plant successfully', async () => {
      const options: IdentificationOptions = {
        includeDetails: true,
        language: 'en',
      };

      const result = await client.identifyPlant(mockImageData, options);

      expect(result).toEqual(mockApiResponse);
      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.plant.id/v3/identification',
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
            'Api-Key': 'test-api-key',
          }),
        })
      );
    });

    it('should include location data when provided', async () => {
      const options: IdentificationOptions = {
        location: { latitude: 40.7128, longitude: -74.0060 },
      };

      await client.identifyPlant(mockImageData, options);

      const requestBody = JSON.parse(mockFetch.mock.calls[1][1]?.body as string);
      expect(requestBody.latitude).toBe(40.7128);
      expect(requestBody.longitude).toBe(-74.0060);
    });

    it('should handle API errors', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 400,
        statusText: 'Bad Request',
      } as Response);

      await expect(client.identifyPlant(mockImageData))
        .rejects
        .toThrow('HTTP 400: Bad Request');
    });

    it('should retry on network errors', async () => {
      mockFetch
        .mockRejectedValueOnce(new Error('Network error'))
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve({ result: mockApiResponse }),
        } as Response);

      const result = await client.identifyPlant(mockImageData);

      expect(result).toEqual(mockApiResponse);
      expect(mockFetch).toHaveBeenCalledTimes(4); // 1 for image + 3 for API (2 retries + 1 success)
    });

    it('should not retry on client errors', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 401,
        statusText: 'Unauthorized',
      } as Response);

      await expect(client.identifyPlant(mockImageData))
        .rejects
        .toThrow('HTTP 401: Unauthorized');

      expect(mockFetch).toHaveBeenCalledTimes(2); // 1 for image + 1 for API (no retries)
    });
  });

  describe('getPlantDetails', () => {
    const mockPlantDetails = {
      common_names: ['Test Plant'],
      taxonomy: { family: 'Testaceae' },
      wiki_description: { value: 'A test plant' },
    };

    beforeEach(() => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockPlantDetails),
      } as Response);
    });

    it('should get plant details successfully', async () => {
      const result = await client.getPlantDetails('Test plantus');

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.plant.id/v3/kb/plants/Test%20plantus',
        expect.objectContaining({
          headers: expect.objectContaining({
            'Api-Key': 'test-api-key',
          }),
        })
      );
      expect(result).toEqual(mockPlantDetails);
    });

    it('should handle URL encoding for plant names', async () => {
      await client.getPlantDetails('Rosa rubiginosa var. test');

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.plant.id/v3/kb/plants/Rosa%20rubiginosa%20var.%20test',
        expect.any(Object)
      );
    });
  });

  describe('formatPlantInfo', () => {
    it('should format plant info correctly', () => {
      const result = client.formatPlantInfo(mockApiResponse);

      expect(result).toEqual({
        scientificName: 'Rosa rubiginosa',
        commonNames: ['Sweet Briar', 'Eglantine'],
        family: 'Rosaceae',
        genus: 'Rosa',
        confidence: 0.85,
        description: 'Rosa rubiginosa is a species of wild rose native to Europe.',
        imageUrl: 'https://example.com/rosa-rubiginosa.jpg',
        careInfo: {
          watering: 'Every 7-14 days',
          growthRate: 'medium',
          edibleParts: ['fruit'],
        },
      });
    });

    it('should handle missing suggestions', () => {
      const emptyResponse = { ...mockApiResponse, suggestions: [] };

      expect(() => client.formatPlantInfo(emptyResponse))
        .toThrow('No plant suggestions found in response');
    });

    it('should handle missing optional fields', () => {
      const minimalResponse = {
        ...mockApiResponse,
        suggestions: [{
          plant_name: 'Test Plant',
          probability: 0.5,
          plant_details: {},
        }],
      };

      const result = client.formatPlantInfo(minimalResponse as any);

      expect(result.scientificName).toBe('Test Plant');
      expect(result.confidence).toBe(0.5);
      expect(result.commonNames).toEqual([]);
      expect(result.family).toBeUndefined();
    });
  });

  describe('validateConfig', () => {
    it('should validate valid configuration', () => {
      expect(() => PlantIdClient.validateConfig(mockConfig)).not.toThrow();
    });

    it('should throw error for missing API key', () => {
      const invalidConfig = { ...mockConfig, apiKey: '' };
      expect(() => PlantIdClient.validateConfig(invalidConfig))
        .toThrow('Plant.id API key is required');
    });

    it('should throw error for missing base URL', () => {
      const invalidConfig = { ...mockConfig, baseUrl: '' };
      expect(() => PlantIdClient.validateConfig(invalidConfig))
        .toThrow('Plant.id API base URL is required');
    });

    it('should throw error for invalid timeout', () => {
      const invalidConfig = { ...mockConfig, timeout: 0 };
      expect(() => PlantIdClient.validateConfig(invalidConfig))
        .toThrow('API timeout must be greater than 0');
    });

    it('should throw error for invalid retry attempts', () => {
      const invalidConfig = { ...mockConfig, retryAttempts: 0 };
      expect(() => PlantIdClient.validateConfig(invalidConfig))
        .toThrow('Retry attempts must be at least 1');
    });
  });

  describe('createPlantIdClient', () => {
    it('should create client with default configuration', () => {
      const client = createPlantIdClient('test-key');
      expect(client).toBeInstanceOf(PlantIdClient);
    });

    it('should create client with custom configuration', () => {
      const customOptions = {
        baseUrl: 'https://custom.api.url',
        timeout: 60000,
      };

      const client = createPlantIdClient('test-key', customOptions);
      expect(client).toBeInstanceOf(PlantIdClient);
    });

    it('should validate configuration on creation', () => {
      expect(() => createPlantIdClient(''))
        .toThrow('Plant.id API key is required');
    });
  });

  describe('error handling', () => {
    it('should handle network timeouts', async () => {
      mockFetch.mockImplementation(() => 
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), 100)
        )
      );

      await expect(client.identifyPlant(mockImageData))
        .rejects
        .toThrow();
    });

    it('should handle malformed JSON responses', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.reject(new Error('Invalid JSON')),
      } as Response);

      await expect(client.identifyPlant(mockImageData))
        .rejects
        .toThrow('Invalid JSON');
    });
  });

  describe('image conversion', () => {
    it('should handle image conversion errors', async () => {
      global.fetch = jest.fn().mockRejectedValue(new Error('Failed to fetch image'));

      await expect(client.identifyPlant(mockImageData))
        .rejects
        .toThrow('Failed to convert image to base64');
    });
  });
});
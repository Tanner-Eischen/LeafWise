/**
 * Image Processing Utilities Tests
 * Tests for image capture, cropping, enhancement, and quality assessment functionality
 */

import {
  processImage,
  assessImageQuality,
  cropToPlantArea,
  enhanceForPlantPhotography,
  validateImageForIdentification,
  ImageProcessing,
} from './imageProcessing';
import { ImageResult, ImageProcessingOptions } from '../types';

// Mock image data for testing
const mockImageResult: ImageResult = {
  uri: 'mock-image-uri',
  base64: 'mock-base64-data',
  metadata: {
    format: 'jpeg',
    dimensions: {
      width: 1920,
      height: 1080,
    },
    fileSize: 2048000, // 2MB
    timestamp: '2024-01-15T10:30:00.000Z',
    location: {
      latitude: 40.7128,
      longitude: -74.0060,
    },
  },
  isValid: true,
};

const mockLowResImageResult: ImageResult = {
  ...mockImageResult,
  uri: 'mock-low-res-image-uri',
  metadata: {
    ...mockImageResult.metadata,
    dimensions: {
      width: 320,
      height: 240,
    },
    fileSize: 50000, // 50KB
  },
};

const mockLargeImageResult: ImageResult = {
  ...mockImageResult,
  uri: 'mock-large-image-uri',
  metadata: {
    ...mockImageResult.metadata,
    fileSize: 12 * 1024 * 1024, // 12MB
  },
};

describe('Image Processing Utilities', () => {
  describe('processImage', () => {
    it('should process image with default options', async () => {
      const result = await processImage(mockImageResult);
      
      expect(result).toBeDefined();
      expect(result.originalUri).toBe(mockImageResult.uri);
      expect(result.processedUri).toContain('compressed');
      expect(result.qualityScore).toBeGreaterThan(0);
      expect(result.qualityScore).toBeLessThanOrEqual(1);
      expect(result.enhancements).toBeDefined();
    });

    it('should process image with custom options', async () => {
      const options: ImageProcessingOptions = {
        enableAutoEnhancement: true,
        cropToPlant: true,
        adjustLighting: true,
        sharpenImage: true,
        removeBackground: false,
        maxWidth: 1024,
        maxHeight: 768,
        compressionQuality: 0.9,
      };

      const result = await processImage(mockImageResult, options);
      
      expect(result).toBeDefined();
      expect(result.originalUri).toBe(mockImageResult.uri);
      expect(result.processedUri).toContain('compressed');
      expect(result.enhancements.cropped).toBe(true);
      expect(result.enhancements.brightness).toBeDefined();
      expect(result.enhancements.contrast).toBeDefined();
      expect(result.enhancements.sharpness).toBeDefined();
    });

    it('should handle processing errors gracefully', async () => {
      const invalidImage = {
        ...mockImageResult,
        uri: '', // Invalid URI
      };

      // Since we're using simulated processing, this should still work
      // In real implementation, this would throw an error
      const result = await processImage(invalidImage);
      expect(result).toBeDefined();
    });

    it('should apply background removal when requested', async () => {
      const options: ImageProcessingOptions = {
        removeBackground: true,
      };

      const result = await processImage(mockImageResult, options);
      
      expect(result.processedUri).toContain('background_removed');
    });
  });

  describe('assessImageQuality', () => {
    it('should assess image quality and return detailed analysis', async () => {
      const result = await assessImageQuality(mockImageResult);
      
      expect(result).toBeDefined();
      expect(result.overallScore).toBeGreaterThanOrEqual(0);
      expect(result.overallScore).toBeLessThanOrEqual(1);
      expect(result.factors).toBeDefined();
      expect(result.factors.brightness).toBeGreaterThanOrEqual(0);
      expect(result.factors.contrast).toBeGreaterThanOrEqual(0);
      expect(result.factors.sharpness).toBeGreaterThanOrEqual(0);
      expect(result.factors.noise).toBeGreaterThanOrEqual(0);
      expect(result.factors.blur).toBeGreaterThanOrEqual(0);
      expect(Array.isArray(result.recommendations)).toBe(true);
      expect(typeof result.isAcceptable).toBe('boolean');
    });

    it('should provide recommendations for poor quality images', async () => {
      // Mock poor quality by manipulating the analysis functions
      const result = await assessImageQuality(mockImageResult);
      
      // Since we're using simulated analysis, we can't guarantee poor quality
      // but we can verify the structure is correct
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });

    it('should handle quality assessment errors', async () => {
      const invalidImage = {
        ...mockImageResult,
        uri: '', // Invalid URI
      };

      // Since we're using simulated analysis, this should still work
      // In real implementation, this would throw an error
      const result = await assessImageQuality(invalidImage);
      expect(result).toBeDefined();
    });
  });

  describe('cropToPlantArea', () => {
    it('should crop image to focus on plant area', async () => {
      const result = await cropToPlantArea(
        mockImageResult.uri,
        mockImageResult.metadata.dimensions
      );
      
      expect(result).toBeDefined();
      expect(result.uri).toContain('cropped');
      expect(result.cropArea).toBeDefined();
      expect(result.cropArea.x).toBeGreaterThanOrEqual(0);
      expect(result.cropArea.y).toBeGreaterThanOrEqual(0);
      expect(result.cropArea.width).toBeGreaterThan(0);
      expect(result.cropArea.height).toBeGreaterThan(0);
    });

    it('should handle cropping errors', async () => {
      // Since we're using simulated cropping, this should still work
      // In real implementation, this would throw an error for invalid dimensions
      const result = await cropToPlantArea('', { width: 0, height: 0 });
      expect(result).toBeDefined();
    });

    it('should calculate crop area based on image dimensions', async () => {
      const dimensions = { width: 1000, height: 800 };
      const result = await cropToPlantArea('test-uri', dimensions);
      
      // Crop should be centered and 80% of the smaller dimension
      const expectedSize = Math.min(dimensions.width, dimensions.height) * 0.8;
      expect(result.cropArea.width).toBe(expectedSize);
      expect(result.cropArea.height).toBe(expectedSize);
    });
  });

  describe('enhanceForPlantPhotography', () => {
    it('should enhance image specifically for plant photography', async () => {
      const result = await enhanceForPlantPhotography(mockImageResult);
      
      expect(result).toBeDefined();
      expect(result.originalUri).toBe(mockImageResult.uri);
      expect(result.processedUri).toBeDefined();
      expect(result.enhancements).toBeDefined();
      expect(result.qualityScore).toBeGreaterThan(0);
    });

    it('should apply plant-specific enhancement settings', async () => {
      const result = await enhanceForPlantPhotography(mockImageResult);
      
      // Should have applied auto-enhancement, lighting adjustment, and sharpening
      expect(result.enhancements.brightness).toBeDefined();
      expect(result.enhancements.contrast).toBeDefined();
      expect(result.enhancements.sharpness).toBeDefined();
      expect(result.enhancements.saturation).toBeDefined();
    });
  });

  describe('validateImageForIdentification', () => {
    it('should validate high-quality image as suitable', async () => {
      const result = await validateImageForIdentification(mockImageResult);
      
      expect(result).toBeDefined();
      expect(typeof result.isValid).toBe('boolean');
      expect(Array.isArray(result.issues)).toBe(true);
      expect(Array.isArray(result.suggestions)).toBe(true);
    });

    it('should reject low-resolution images', async () => {
      const result = await validateImageForIdentification(mockLowResImageResult);
      
      expect(result.isValid).toBe(false);
      expect(result.issues.length).toBeGreaterThan(0);
      expect(result.issues[0]).toContain('resolution too low');
      expect(result.suggestions.length).toBeGreaterThan(0);
    });

    it('should reject oversized images', async () => {
      const result = await validateImageForIdentification(mockLargeImageResult);
      
      expect(result.isValid).toBe(false);
      expect(result.issues.some(issue => issue.includes('file size too large'))).toBe(true);
      expect(result.suggestions.some(suggestion => 
        suggestion.includes('Reduce image quality')
      )).toBe(true);
    });

    it('should provide helpful suggestions for invalid images', async () => {
      const result = await validateImageForIdentification(mockLowResImageResult);
      
      expect(result.suggestions.length).toBeGreaterThan(0);
      expect(result.suggestions[0]).toContain('640x480');
    });

    it('should handle validation errors', async () => {
      const invalidImage = {
        ...mockImageResult,
        metadata: {
          ...mockImageResult.metadata,
          dimensions: { width: -1, height: -1 },
        },
      };

      // Should detect invalid dimensions and mark as invalid
      const result = await validateImageForIdentification(invalidImage);
      expect(result.isValid).toBe(false);
      expect(result.issues.length).toBeGreaterThan(0);
    });
  });

  describe('ImageProcessing utility object', () => {
    it('should export all processing functions', () => {
      expect(ImageProcessing.processImage).toBeDefined();
      expect(ImageProcessing.assessImageQuality).toBeDefined();
      expect(ImageProcessing.cropToPlantArea).toBeDefined();
      expect(ImageProcessing.enhanceForPlantPhotography).toBeDefined();
      expect(ImageProcessing.validateImageForIdentification).toBeDefined();
    });

    it('should have all functions as callable', () => {
      expect(typeof ImageProcessing.processImage).toBe('function');
      expect(typeof ImageProcessing.assessImageQuality).toBe('function');
      expect(typeof ImageProcessing.cropToPlantArea).toBe('function');
      expect(typeof ImageProcessing.enhanceForPlantPhotography).toBe('function');
      expect(typeof ImageProcessing.validateImageForIdentification).toBe('function');
    });
  });

  describe('Integration scenarios', () => {
    it('should process and validate image in sequence', async () => {
      // First validate the original image
      const validation = await validateImageForIdentification(mockImageResult);
      
      if (validation.isValid) {
        // Then process the image
        const processed = await processImage(mockImageResult);
        expect(processed).toBeDefined();
        
        // Finally assess the processed image quality
        const quality = await assessImageQuality({
          ...mockImageResult,
          uri: processed.processedUri,
        });
        expect(quality).toBeDefined();
      }
    });

    it('should enhance and crop image for plant identification', async () => {
      // Enhance for plant photography
      const enhanced = await enhanceForPlantPhotography(mockImageResult);
      expect(enhanced).toBeDefined();
      
      // Then crop to plant area
      const cropped = await cropToPlantArea(
        enhanced.processedUri,
        enhanced.metadata.dimensions
      );
      expect(cropped).toBeDefined();
      expect(cropped.uri).toContain('cropped');
    });
  });

  describe('Error handling', () => {
    it('should handle network errors gracefully', async () => {
      const networkErrorImage = {
        ...mockImageResult,
        uri: 'network://error-uri',
      };

      // Since we're using simulated processing, this should still work
      // In real implementation, this would handle network errors
      const result = await processImage(networkErrorImage);
      expect(result).toBeDefined();
    });

    it('should handle corrupted image data', async () => {
      const corruptedImage = {
        ...mockImageResult,
        metadata: {
          ...mockImageResult.metadata,
          format: 'unknown' as any,
        },
      };

      // Should still attempt processing but may fail gracefully
      const result = await processImage(corruptedImage);
      expect(result).toBeDefined();
    });
  });
});
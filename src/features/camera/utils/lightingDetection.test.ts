/**
 * Tests for Lighting Detection Utilities
 * 
 * Comprehensive test suite covering all lighting detection functionality
 * including light level analysis, flash recommendations, guidance messages,
 * and monitoring capabilities.
 */

import {
  analyzeLightingConditions,
  detectLightLevel,
  analyzeImageBrightness,
  isSuitableForPlantIdentification,
  getColorTemperatureGuidance,
  createLightingMonitor,
  validateLightingConfig,
  type LightingCondition,
  type FlashRecommendation,
  type LightingAnalysis,
  type LightingDetectionConfig,
} from './lightingDetection';

// Mock setTimeout for testing
jest.useFakeTimers();

describe('Lighting Detection Utilities', () => {
  afterEach(() => {
    jest.clearAllTimers();
  });

  describe('analyzeLightingConditions', () => {
    it('should classify excellent lighting conditions', () => {
      const result = analyzeLightingConditions(90);
      
      expect(result.condition).toBe('excellent');
      expect(result.lightLevel).toBe(90);
      expect(result.flashRecommendation).toBe('none');
      expect(result.isSuitableForPhotography).toBe(true);
      expect(result.guidance).toContain('Perfect lighting');
    });

    it('should classify good lighting conditions', () => {
      const result = analyzeLightingConditions(75);
      
      expect(result.condition).toBe('good');
      expect(result.flashRecommendation).toBe('none');
      expect(result.isSuitableForPhotography).toBe(true);
      expect(result.guidance).toContain('Good lighting');
    });

    it('should classify fair lighting conditions', () => {
      const result = analyzeLightingConditions(50);
      
      expect(result.condition).toBe('fair');
      expect(result.flashRecommendation).toBe('auto');
      expect(result.isSuitableForPhotography).toBe(true);
      expect(result.guidance).toContain('Moderate lighting');
    });

    it('should classify poor lighting conditions', () => {
      const result = analyzeLightingConditions(30);
      
      expect(result.condition).toBe('poor');
      expect(result.flashRecommendation).toBe('on');
      expect(result.isSuitableForPhotography).toBe(true);
      expect(result.guidance).toContain('Low light detected');
    });

    it('should classify very poor lighting conditions', () => {
      const result = analyzeLightingConditions(10);
      
      expect(result.condition).toBe('very-poor');
      expect(result.flashRecommendation).toBe('torch');
      expect(result.isSuitableForPhotography).toBe(false);
      expect(result.guidance).toContain('Very low light');
    });

    it('should respect custom configuration', () => {
      const config: Partial<LightingDetectionConfig> = {
        minGoodLightLevel: 80,
        minFairLightLevel: 60,
        enableFlashRecommendations: false,
      };
      
      const result = analyzeLightingConditions(70, config);
      
      expect(result.condition).toBe('fair');
      expect(result.flashRecommendation).toBe('none');
    });

    it('should provide appropriate recommendations', () => {
      const excellentResult = analyzeLightingConditions(90);
      expect(excellentResult.recommendations).toContain('Conditions are optimal for photography');

      const poorResult = analyzeLightingConditions(25);
      expect(poorResult.recommendations).toContain('Enable flash for clearer photos');
      expect(poorResult.recommendations).toContain('Move to a brighter location if possible');

      const veryPoorResult = analyzeLightingConditions(10);
      expect(veryPoorResult.recommendations).toContain('Move to a well-lit area');
      expect(veryPoorResult.recommendations).toContain('Use torch mode for continuous lighting');
    });

    it('should add specific recommendations for very low light levels', () => {
      const result = analyzeLightingConditions(12);
      
      expect(result.recommendations).toContain(
        'Current lighting may result in blurry or dark photos'
      );
      expect(result.recommendations).toContain(
        'Consider waiting for better lighting conditions'
      );
    });
  });

  describe('detectLightLevel', () => {
    it('should return a light level between 0 and 100', async () => {
      const lightLevel = await detectLightLevel();
      
      expect(lightLevel).toBeGreaterThanOrEqual(0);
      expect(lightLevel).toBeLessThanOrEqual(100);
      expect(Number.isInteger(lightLevel)).toBe(true);
    });

    it('should resolve within reasonable time', async () => {
      const startTime = Date.now();
      await detectLightLevel();
      const endTime = Date.now();
      
      expect(endTime - startTime).toBeLessThan(200);
    });
  });

  describe('analyzeImageBrightness', () => {
    it('should return 0 for empty image data', () => {
      const brightness = analyzeImageBrightness(new Uint8Array());
      expect(brightness).toBe(0);
    });

    it('should return 0 for completely black image', () => {
      const blackImage = new Uint8Array(400).fill(0); // 100 pixels, RGBA
      const brightness = analyzeImageBrightness(blackImage);
      expect(brightness).toBe(0);
    });

    it('should return 100 for completely white image', () => {
      const whiteImage = new Uint8Array(400).fill(255); // 100 pixels, RGBA
      const brightness = analyzeImageBrightness(whiteImage);
      expect(brightness).toBe(100);
    });

    it('should calculate correct brightness for mixed image', () => {
      const mixedImage = new Uint8Array(8); // 2 pixels, RGBA
      // First pixel: black (0, 0, 0, 255)
      mixedImage[0] = 0;
      mixedImage[1] = 0;
      mixedImage[2] = 0;
      mixedImage[3] = 255;
      // Second pixel: white (255, 255, 255, 255)
      mixedImage[4] = 255;
      mixedImage[5] = 255;
      mixedImage[6] = 255;
      mixedImage[7] = 255;
      
      const brightness = analyzeImageBrightness(mixedImage);
      expect(brightness).toBe(50); // Average of 0 and 100
    });

    it('should use correct luminance formula', () => {
      const colorImage = new Uint8Array(4); // 1 pixel, RGBA
      // Red pixel (255, 0, 0, 255)
      colorImage[0] = 255;
      colorImage[1] = 0;
      colorImage[2] = 0;
      colorImage[3] = 255;
      
      const brightness = analyzeImageBrightness(colorImage);
      // Expected: (0.299 * 255 + 0.587 * 0 + 0.114 * 0) / 255 * 100 ≈ 30
      expect(brightness).toBeCloseTo(30, 0);
    });
  });

  describe('isSuitableForPlantIdentification', () => {
    it('should return true for adequate lighting', () => {
      expect(isSuitableForPlantIdentification(30)).toBe(true);
      expect(isSuitableForPlantIdentification(50)).toBe(true);
      expect(isSuitableForPlantIdentification(80)).toBe(true);
    });

    it('should return false for inadequate lighting', () => {
      expect(isSuitableForPlantIdentification(20)).toBe(false);
      expect(isSuitableForPlantIdentification(10)).toBe(false);
      expect(isSuitableForPlantIdentification(0)).toBe(false);
    });

    it('should handle boundary condition', () => {
      expect(isSuitableForPlantIdentification(25)).toBe(true);
      expect(isSuitableForPlantIdentification(24)).toBe(false);
    });
  });

  describe('getColorTemperatureGuidance', () => {
    it('should provide appropriate guidance for each condition', () => {
      expect(getColorTemperatureGuidance('excellent')).toContain('Natural lighting');
      expect(getColorTemperatureGuidance('good')).toContain('accurate colors');
      expect(getColorTemperatureGuidance('fair')).toContain('slightly warm or cool');
      expect(getColorTemperatureGuidance('poor')).toContain('Flash will help');
      expect(getColorTemperatureGuidance('very-poor')).toContain('Artificial lighting');
    });
  });

  describe('createLightingMonitor', () => {
    it('should call callback with lighting analysis', async () => {
      const callback = jest.fn();
      const stopMonitor = createLightingMonitor(callback);
      
      // Fast-forward time to trigger monitoring
      jest.advanceTimersByTime(600);
      await Promise.resolve(); // Allow async operations to complete
      
      expect(callback).toHaveBeenCalled();
      expect(callback.mock.calls[0][0]).toHaveProperty('condition');
      expect(callback.mock.calls[0][0]).toHaveProperty('lightLevel');
      expect(callback.mock.calls[0][0]).toHaveProperty('flashRecommendation');
      
      stopMonitor();
    });

    it('should respect custom update interval', async () => {
      const callback = jest.fn();
      const config = { updateInterval: 1000 };
      const stopMonitor = createLightingMonitor(callback, config);
      
      // Should not call callback before interval
      jest.advanceTimersByTime(500);
      await Promise.resolve();
      expect(callback).not.toHaveBeenCalled();
      
      // Should call callback after interval
      jest.advanceTimersByTime(600);
      await Promise.resolve();
      expect(callback).toHaveBeenCalled();
      
      stopMonitor();
    });

    it('should stop monitoring when stop function is called', async () => {
      const callback = jest.fn();
      const stopMonitor = createLightingMonitor(callback);
      
      // Let it run once
      jest.advanceTimersByTime(600);
      await Promise.resolve();
      const initialCallCount = callback.mock.calls.length;
      
      // Stop monitoring
      stopMonitor();
      
      // Advance time and verify no more calls
      jest.advanceTimersByTime(1000);
      await Promise.resolve();
      expect(callback.mock.calls.length).toBe(initialCallCount);
    });

    it('should handle errors gracefully', async () => {
      const callback = jest.fn();
      const consoleSpy = jest.spyOn(console, 'warn').mockImplementation();
      
      // Mock detectLightLevel to throw an error
      const originalDetectLightLevel = require('./lightingDetection').detectLightLevel;
      require('./lightingDetection').detectLightLevel = jest.fn().mockRejectedValue(
        new Error('Detection failed')
      );
      
      const stopMonitor = createLightingMonitor(callback);
      
      jest.advanceTimersByTime(600);
      await Promise.resolve();
      
      expect(consoleSpy).toHaveBeenCalledWith(
        'Lighting monitoring error:',
        expect.any(Error)
      );
      
      // Restore original function
      require('./lightingDetection').detectLightLevel = originalDetectLightLevel;
      consoleSpy.mockRestore();
      stopMonitor();
    });
  });

  describe('validateLightingConfig', () => {
    it('should validate correct configuration', () => {
      const config: Partial<LightingDetectionConfig> = {
        minGoodLightLevel: 70,
        minFairLightLevel: 40,
        enableFlashRecommendations: true,
        updateInterval: 500,
      };
      
      const result = validateLightingConfig(config);
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject invalid light level ranges', () => {
      const config = {
        minGoodLightLevel: 150,
        minFairLightLevel: -10,
      };
      
      const result = validateLightingConfig(config);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('minGoodLightLevel must be between 0 and 100');
      expect(result.errors).toContain('minFairLightLevel must be between 0 and 100');
    });

    it('should reject invalid update interval', () => {
      const config = {
        updateInterval: 50,
      };
      
      const result = validateLightingConfig(config);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('updateInterval must be at least 100ms');
    });

    it('should reject invalid light level relationship', () => {
      const config = {
        minGoodLightLevel: 40,
        minFairLightLevel: 70,
      };
      
      const result = validateLightingConfig(config);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain(
        'minGoodLightLevel must be greater than minFairLightLevel'
      );
    });

    it('should handle empty configuration', () => {
      const result = validateLightingConfig({});
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });
  });

  describe('Edge Cases and Error Handling', () => {
    it('should handle extreme light levels', () => {
      const veryLowResult = analyzeLightingConditions(-5);
      expect(veryLowResult.condition).toBe('very-poor');
      
      const veryHighResult = analyzeLightingConditions(150);
      expect(veryHighResult.condition).toBe('excellent');
    });

    it('should handle boundary light levels correctly', () => {
      expect(analyzeLightingConditions(85).condition).toBe('excellent');
      expect(analyzeLightingConditions(84).condition).toBe('good');
      expect(analyzeLightingConditions(70).condition).toBe('good');
      expect(analyzeLightingConditions(69).condition).toBe('fair');
      expect(analyzeLightingConditions(40).condition).toBe('fair');
      expect(analyzeLightingConditions(39).condition).toBe('poor');
      expect(analyzeLightingConditions(20).condition).toBe('poor');
      expect(analyzeLightingConditions(19).condition).toBe('very-poor');
    });

    it('should provide consistent results for same input', () => {
      const result1 = analyzeLightingConditions(60);
      const result2 = analyzeLightingConditions(60);
      
      expect(result1).toEqual(result2);
    });
  });

  describe('Integration Tests', () => {
    it('should work with real-world lighting scenarios', () => {
      // Bright outdoor daylight
      const outdoorResult = analyzeLightingConditions(95);
      expect(outdoorResult.condition).toBe('excellent');
      expect(outdoorResult.flashRecommendation).toBe('none');
      expect(outdoorResult.isSuitableForPhotography).toBe(true);
      
      // Indoor office lighting
      const indoorResult = analyzeLightingConditions(65);
      expect(indoorResult.condition).toBe('fair');
      expect(indoorResult.flashRecommendation).toBe('auto');
      expect(indoorResult.isSuitableForPhotography).toBe(true);
      
      // Evening/dim lighting
      const eveningResult = analyzeLightingConditions(25);
      expect(eveningResult.condition).toBe('poor');
      expect(eveningResult.flashRecommendation).toBe('on');
      expect(eveningResult.isSuitableForPhotography).toBe(true);
      
      // Night/very dark
      const nightResult = analyzeLightingConditions(8);
      expect(nightResult.condition).toBe('very-poor');
      expect(nightResult.flashRecommendation).toBe('torch');
      expect(nightResult.isSuitableForPhotography).toBe(false);
    });
  });
});
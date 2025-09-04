/**
 * Lighting Detection Utilities
 * 
 * This module provides utilities for detecting lighting conditions and providing
 * guidance to users for optimal plant photography. It includes light level detection,
 * flash recommendations, and UI guidance for suboptimal conditions.
 * 
 * Features:
 * - Light level detection from camera preview
 * - Flash recommendation logic
 * - Lighting guidance messages
 * - Optimal lighting condition assessment
 * - Real-time lighting analysis
 */

// CameraDevice import removed - not needed for lighting detection utilities

/**
 * Represents different lighting conditions
 */
export type LightingCondition = 
  | 'excellent'
  | 'good'
  | 'fair'
  | 'poor'
  | 'very-poor';

/**
 * Represents flash recommendation types
 */
export type FlashRecommendation = 
  | 'none'
  | 'auto'
  | 'on'
  | 'torch';

/**
 * Lighting analysis result
 */
export interface LightingAnalysis {
  /** Current lighting condition */
  condition: LightingCondition;
  /** Light level score (0-100) */
  lightLevel: number;
  /** Flash recommendation */
  flashRecommendation: FlashRecommendation;
  /** User guidance message */
  guidance: string;
  /** Whether conditions are suitable for photography */
  isSuitableForPhotography: boolean;
  /** Specific recommendations for improvement */
  recommendations: string[];
}

/**
 * Configuration for lighting detection
 */
export interface LightingDetectionConfig {
  /** Minimum light level for good photography (0-100) */
  minGoodLightLevel: number;
  /** Minimum light level for fair photography (0-100) */
  minFairLightLevel: number;
  /** Enable automatic flash recommendations */
  enableFlashRecommendations: boolean;
  /** Update interval for continuous monitoring (ms) */
  updateInterval: number;
}

/**
 * Default configuration for lighting detection
 */
const DEFAULT_CONFIG: LightingDetectionConfig = {
  minGoodLightLevel: 70,
  minFairLightLevel: 40,
  enableFlashRecommendations: true,
  updateInterval: 500,
};

/**
 * Analyzes current lighting conditions and provides recommendations
 * 
 * @param lightLevel - Current light level (0-100)
 * @param config - Configuration options
 * @returns Lighting analysis with recommendations
 */
export function analyzeLightingConditions(
  lightLevel: number,
  config: Partial<LightingDetectionConfig> = {}
): LightingAnalysis {
  const finalConfig = { ...DEFAULT_CONFIG, ...config };
  
  const condition = determineLightingCondition(lightLevel, finalConfig);
  const flashRecommendation = getFlashRecommendation(condition, finalConfig);
  const guidance = getGuidanceMessage(condition);
  const isSuitableForPhotography = condition !== 'very-poor';
  const recommendations = getRecommendations(condition, lightLevel);

  return {
    condition,
    lightLevel,
    flashRecommendation,
    guidance,
    isSuitableForPhotography,
    recommendations,
  };
}

/**
 * Determines lighting condition based on light level
 * 
 * @param lightLevel - Current light level (0-100)
 * @param config - Configuration options
 * @returns Lighting condition category
 */
function determineLightingCondition(
  lightLevel: number,
  config: LightingDetectionConfig
): LightingCondition {
  if (lightLevel >= 85) return 'excellent';
  if (lightLevel >= config.minGoodLightLevel) return 'good';
  if (lightLevel >= config.minFairLightLevel) return 'fair';
  if (lightLevel >= 20) return 'poor';
  return 'very-poor';
}

/**
 * Gets flash recommendation based on lighting condition
 * 
 * @param condition - Current lighting condition
 * @param config - Configuration options
 * @returns Flash recommendation
 */
function getFlashRecommendation(
  condition: LightingCondition,
  config: LightingDetectionConfig
): FlashRecommendation {
  if (!config.enableFlashRecommendations) return 'none';

  switch (condition) {
    case 'excellent':
    case 'good':
      return 'none';
    case 'fair':
      return 'auto';
    case 'poor':
      return 'on';
    case 'very-poor':
      return 'torch';
    default:
      return 'auto';
  }
}

/**
 * Gets user guidance message based on lighting condition
 * 
 * @param condition - Current lighting condition
 * @returns Guidance message for the user
 */
function getGuidanceMessage(condition: LightingCondition): string {
  switch (condition) {
    case 'excellent':
      return 'Perfect lighting! Great conditions for plant photography.';
    case 'good':
      return 'Good lighting conditions. You should get clear photos.';
    case 'fair':
      return 'Moderate lighting. Consider using flash for better results.';
    case 'poor':
      return 'Low light detected. Flash recommended for clear photos.';
    case 'very-poor':
      return 'Very low light. Move to a brighter area or use torch mode.';
    default:
      return 'Analyzing lighting conditions...';
  }
}

/**
 * Gets specific recommendations for improving photo quality
 * 
 * @param condition - Current lighting condition
 * @param lightLevel - Current light level
 * @returns Array of specific recommendations
 */
function getRecommendations(
  condition: LightingCondition,
  lightLevel: number
): string[] {
  const recommendations: string[] = [];

  switch (condition) {
    case 'excellent':
      recommendations.push('Conditions are optimal for photography');
      break;
    case 'good':
      recommendations.push('Good natural lighting available');
      break;
    case 'fair':
      recommendations.push('Consider enabling flash for better detail');
      recommendations.push('Try moving closer to a window or light source');
      break;
    case 'poor':
      recommendations.push('Enable flash for clearer photos');
      recommendations.push('Move to a brighter location if possible');
      recommendations.push('Avoid shadows on the plant');
      break;
    case 'very-poor':
      recommendations.push('Move to a well-lit area');
      recommendations.push('Use torch mode for continuous lighting');
      recommendations.push('Consider photographing near a window during daylight');
      recommendations.push('Avoid taking photos in dark environments');
      break;
  }

  // Add specific recommendations based on light level
  if (lightLevel < 30) {
    recommendations.push('Current lighting may result in blurry or dark photos');
  }
  if (lightLevel < 15) {
    recommendations.push('Consider waiting for better lighting conditions');
  }

  return recommendations;
}

/**
 * Simulates light level detection from camera preview
 * In a real implementation, this would analyze actual camera frames
 * 
 * @param device - Camera device (for future implementation)
 * @returns Promise resolving to light level (0-100)
 */
export async function detectLightLevel(
  device?: object
): Promise<number> {
  // Simulate light level detection
  // In a real implementation, this would:
  // 1. Capture a frame from the camera preview
  // 2. Analyze pixel brightness values
  // 3. Calculate average luminance
  // 4. Convert to a 0-100 scale
  
  return new Promise((resolve) => {
    setTimeout(() => {
      // Simulate varying light conditions
      const simulatedLightLevel = Math.random() * 100;
      resolve(Math.round(simulatedLightLevel));
    }, 100);
  });
}

/**
 * Analyzes image brightness from pixel data
 * 
 * @param imageData - Image pixel data
 * @returns Brightness level (0-100)
 */
export function analyzeImageBrightness(imageData: Uint8Array): number {
  if (imageData.length === 0) return 0;

  let totalBrightness = 0;
  const pixelCount = imageData.length / 4; // RGBA format

  for (let i = 0; i < imageData.length; i += 4) {
    const r = imageData[i];
    const g = imageData[i + 1];
    const b = imageData[i + 2];
    
    // Calculate luminance using standard formula
    const luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    totalBrightness += luminance;
  }

  const averageBrightness = totalBrightness / pixelCount;
  return Math.round((averageBrightness / 255) * 100);
}

/**
 * Checks if current lighting is suitable for plant identification
 * 
 * @param lightLevel - Current light level (0-100)
 * @returns Whether lighting is suitable
 */
export function isSuitableForPlantIdentification(lightLevel: number): boolean {
  return lightLevel >= 25; // Minimum threshold for plant identification
}

/**
 * Gets color temperature recommendation based on lighting
 * 
 * @param condition - Current lighting condition
 * @returns Color temperature guidance
 */
export function getColorTemperatureGuidance(condition: LightingCondition): string {
  switch (condition) {
    case 'excellent':
    case 'good':
      return 'Natural lighting provides accurate colors';
    case 'fair':
      return 'Colors may appear slightly warm or cool';
    case 'poor':
      return 'Flash will help maintain color accuracy';
    case 'very-poor':
      return 'Artificial lighting may affect color representation';
    default:
      return 'Color accuracy depends on lighting quality';
  }
}

/**
 * Creates a continuous lighting monitor
 * 
 * @param callback - Function called with lighting updates
 * @param config - Configuration options
 * @returns Function to stop monitoring
 */
export function createLightingMonitor(
  callback: (analysis: LightingAnalysis) => void,
  config: Partial<LightingDetectionConfig> = {}
): () => void {
  const finalConfig = { ...DEFAULT_CONFIG, ...config };
  let isMonitoring = true;

  const monitor = async () => {
    while (isMonitoring) {
      try {
        const lightLevel = await detectLightLevel();
        const analysis = analyzeLightingConditions(lightLevel, finalConfig);
        callback(analysis);
        
        await new Promise(resolve => 
          setTimeout(resolve, finalConfig.updateInterval)
        );
      } catch (error) {
        console.warn('Lighting monitoring error:', error);
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  };

  monitor();

  return () => {
    isMonitoring = false;
  };
}

/**
 * Validates lighting detection configuration
 * 
 * @param config - Configuration to validate
 * @returns Validation result with any errors
 */
export function validateLightingConfig(
  config: Partial<LightingDetectionConfig>
): { isValid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (config.minGoodLightLevel !== undefined) {
    if (config.minGoodLightLevel < 0 || config.minGoodLightLevel > 100) {
      errors.push('minGoodLightLevel must be between 0 and 100');
    }
  }

  if (config.minFairLightLevel !== undefined) {
    if (config.minFairLightLevel < 0 || config.minFairLightLevel > 100) {
      errors.push('minFairLightLevel must be between 0 and 100');
    }
  }

  if (config.updateInterval !== undefined) {
    if (config.updateInterval < 100) {
      errors.push('updateInterval must be at least 100ms');
    }
  }

  if (
    config.minGoodLightLevel !== undefined &&
    config.minFairLightLevel !== undefined &&
    config.minGoodLightLevel <= config.minFairLightLevel
  ) {
    errors.push('minGoodLightLevel must be greater than minFairLightLevel');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}
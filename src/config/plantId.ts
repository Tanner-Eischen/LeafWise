/**
 * Plant.id API configuration
 * Manages API keys, endpoints, and service settings
 */

import { PlantIdApiConfig } from '../core/types/plantIdentification';

/**
 * Environment-specific Plant.id configuration
 */
interface PlantIdEnvironmentConfig {
  apiKey: string;
  baseUrl: string;
  timeout: number;
  retryAttempts: number;
  enableCaching: boolean;
  cacheExpiryHours: number;
  minConfidenceThreshold: number;
  maxSuggestions: number;
}

/**
 * Default Plant.id configuration values
 */
const DEFAULT_CONFIG: Omit<PlantIdEnvironmentConfig, 'apiKey'> = {
  baseUrl: 'https://api.plant.id',
  timeout: 30000, // 30 seconds
  retryAttempts: 3,
  enableCaching: true,
  cacheExpiryHours: 24,
  minConfidenceThreshold: 0.1, // 10%
  maxSuggestions: 5,
};

/**
 * Development configuration
 */
const DEVELOPMENT_CONFIG: Partial<PlantIdEnvironmentConfig> = {
  timeout: 45000, // Longer timeout for development
  retryAttempts: 2,
  enableCaching: true,
  minConfidenceThreshold: 0.05, // Lower threshold for testing
  maxSuggestions: 10,
};

/**
 * Production configuration
 */
const PRODUCTION_CONFIG: Partial<PlantIdEnvironmentConfig> = {
  timeout: 25000, // Shorter timeout for production
  retryAttempts: 3,
  enableCaching: true,
  minConfidenceThreshold: 0.15, // Higher threshold for production
  maxSuggestions: 5,
};

/**
 * Gets the current environment (development, production, or test)
 * 
 * @returns Current environment string
 */
function getCurrentEnvironment(): string {
  // In React Native, we can use __DEV__ global
  if (typeof __DEV__ !== 'undefined') {
    return __DEV__ ? 'development' : 'production';
  }
  
  // Fallback to NODE_ENV if available
  if (typeof process !== 'undefined' && process.env) {
    return process.env.NODE_ENV || 'development';
  }
  
  return 'development';
}

/**
 * Gets environment-specific configuration overrides
 * 
 * @param environment - Target environment
 * @returns Configuration overrides for the environment
 */
function getEnvironmentConfig(environment: string): Partial<PlantIdEnvironmentConfig> {
  switch (environment) {
    case 'production':
      return PRODUCTION_CONFIG;
    case 'development':
      return DEVELOPMENT_CONFIG;
    case 'test':
      return {
        timeout: 10000,
        retryAttempts: 1,
        enableCaching: false,
        minConfidenceThreshold: 0.01,
        maxSuggestions: 3,
      };
    default:
      return DEVELOPMENT_CONFIG;
  }
}

/**
 * Retrieves Plant.id API key from environment variables
 * 
 * @returns API key string or throws error if not found
 */
function getApiKey(): string {
  // Try different possible environment variable names
  const possibleKeys = [
    'PLANT_ID_API_KEY',
    'PLANTID_API_KEY',
    'REACT_NATIVE_PLANT_ID_API_KEY',
  ];
  
  for (const keyName of possibleKeys) {
    if (typeof process !== 'undefined' && process.env && process.env[keyName]) {
      return process.env[keyName];
    }
  }
  
  // In development, allow a fallback or throw a helpful error
  const environment = getCurrentEnvironment();
  if (environment === 'development') {
    console.warn(
      'Plant.id API key not found in environment variables. ' +
      'Please set PLANT_ID_API_KEY in your .env file or environment.'
    );
    // Return a placeholder for development (will cause API calls to fail gracefully)
    return 'development-placeholder-key';
  }
  
  throw new Error(
    'Plant.id API key is required. Please set PLANT_ID_API_KEY environment variable.'
  );
}

/**
 * Creates Plant.id API configuration for the current environment
 * 
 * @param overrides - Optional configuration overrides
 * @returns Complete Plant.id API configuration
 */
export function createPlantIdConfig(
  overrides: Partial<PlantIdEnvironmentConfig> = {}
): PlantIdApiConfig {
  const environment = getCurrentEnvironment();
  const environmentConfig = getEnvironmentConfig(environment);
  
  const config: PlantIdEnvironmentConfig = {
    ...DEFAULT_CONFIG,
    ...environmentConfig,
    apiKey: getApiKey(),
    ...overrides,
  };
  
  return {
    apiKey: config.apiKey,
    baseUrl: config.baseUrl,
    timeout: config.timeout,
    retryAttempts: config.retryAttempts,
  };
}

/**
 * Creates Plant.id service configuration for the current environment
 * 
 * @param overrides - Optional configuration overrides
 * @returns Complete service configuration
 */
export function createPlantIdServiceConfig(
  overrides: Partial<PlantIdEnvironmentConfig> = {}
) {
  const environment = getCurrentEnvironment();
  const environmentConfig = getEnvironmentConfig(environment);
  
  const config: PlantIdEnvironmentConfig = {
    ...DEFAULT_CONFIG,
    ...environmentConfig,
    apiKey: getApiKey(),
    ...overrides,
  };
  
  return {
    apiKey: config.apiKey,
    enableCaching: config.enableCaching,
    cacheExpiryMs: config.cacheExpiryHours * 60 * 60 * 1000,
    minConfidenceThreshold: config.minConfidenceThreshold,
    maxSuggestions: config.maxSuggestions,
  };
}

/**
 * Validates Plant.id configuration
 * 
 * @param config - Configuration to validate
 * @throws Error if configuration is invalid
 */
export function validatePlantIdConfig(config: PlantIdApiConfig): void {
  if (!config.apiKey || config.apiKey === 'development-placeholder-key') {
    throw new Error(
      'Valid Plant.id API key is required. Please obtain an API key from https://plant.id/'
    );
  }
  
  if (!config.baseUrl || !config.baseUrl.startsWith('https://')) {
    throw new Error('Plant.id API base URL must be a valid HTTPS URL');
  }
  
  if (config.timeout <= 0 || config.timeout > 120000) {
    throw new Error('API timeout must be between 1ms and 120 seconds');
  }
  
  if (config.retryAttempts < 1 || config.retryAttempts > 10) {
    throw new Error('Retry attempts must be between 1 and 10');
  }
}

/**
 * Gets configuration information for debugging
 * 
 * @returns Configuration info (without sensitive data)
 */
export function getConfigInfo() {
  const environment = getCurrentEnvironment();
  const hasApiKey = !!getApiKey() && getApiKey() !== 'development-placeholder-key';
  
  return {
    environment,
    hasValidApiKey: hasApiKey,
    baseUrl: DEFAULT_CONFIG.baseUrl,
    timeout: DEFAULT_CONFIG.timeout,
    retryAttempts: DEFAULT_CONFIG.retryAttempts,
  };
}

/**
 * Default Plant.id configuration for the current environment
 */
export const PLANT_ID_CONFIG = createPlantIdConfig();

/**
 * Default Plant.id service configuration for the current environment
 */
export const PLANT_ID_SERVICE_CONFIG = createPlantIdServiceConfig();
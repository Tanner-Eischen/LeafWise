/**
 * Environment Configuration Manager for LeafWise
 * Manages environment-specific settings and API endpoints
 * Supports development, staging, and production environments
 */

export type Environment = 'development' | 'staging' | 'production';

export interface EnvironmentConfig {
  name: Environment;
  apiBaseUrl: string;
  plantIdentificationApiUrl: string;
  firebaseConfig: {
    apiKey: string;
    authDomain: string;
    projectId: string;
    storageBucket: string;
    messagingSenderId: string;
    appId: string;
  };
  features: {
    enableAnalytics: boolean;
    enableCrashReporting: boolean;
    enableDebugMode: boolean;
    enableMockData: boolean;
  };
  logging: {
    level: 'debug' | 'info' | 'warn' | 'error';
    enableConsoleLogging: boolean;
    enableRemoteLogging: boolean;
  };
  performance: {
    enablePerformanceMonitoring: boolean;
    apiTimeoutMs: number;
    imageUploadTimeoutMs: number;
  };
}

/**
 * Gets the current environment from process.env or defaults to development
 * @returns Current environment string
 */
function getCurrentEnvironment(): Environment {
  const env = process.env.NODE_ENV || process.env.EXPO_PUBLIC_ENV || 'development';
  
  if (env === 'production' || env === 'staging' || env === 'development') {
    return env as Environment;
  }
  
  return 'development';
}

/**
 * Gets environment-specific configuration
 * @param environment - Target environment
 * @returns Environment configuration object
 */
function getEnvironmentConfig(environment: Environment): EnvironmentConfig {
  const configs: Record<Environment, EnvironmentConfig> = {
    development: {
      name: 'development',
      apiBaseUrl: 'http://localhost:3000/api',
      plantIdentificationApiUrl: 'https://api.plant.id/v2',
      firebaseConfig: {
        apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY_DEV || '',
        authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN_DEV || '',
        projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID_DEV || '',
        storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET_DEV || '',
        messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID_DEV || '',
        appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID_DEV || '',
      },
      features: {
        enableAnalytics: false,
        enableCrashReporting: false,
        enableDebugMode: true,
        enableMockData: true,
      },
      logging: {
        level: 'debug',
        enableConsoleLogging: true,
        enableRemoteLogging: false,
      },
      performance: {
        enablePerformanceMonitoring: false,
        apiTimeoutMs: 10000,
        imageUploadTimeoutMs: 30000,
      },
    },
    staging: {
      name: 'staging',
      apiBaseUrl: 'https://staging-api.LeafWise.com/api',
      plantIdentificationApiUrl: 'https://api.plant.id/v2',
      firebaseConfig: {
        apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY_STAGING || '',
        authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN_STAGING || '',
        projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID_STAGING || '',
        storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET_STAGING || '',
        messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID_STAGING || '',
        appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID_STAGING || '',
      },
      features: {
        enableAnalytics: true,
        enableCrashReporting: true,
        enableDebugMode: false,
        enableMockData: false,
      },
      logging: {
        level: 'info',
        enableConsoleLogging: true,
        enableRemoteLogging: true,
      },
      performance: {
        enablePerformanceMonitoring: true,
        apiTimeoutMs: 8000,
        imageUploadTimeoutMs: 25000,
      },
    },
    production: {
      name: 'production',
      apiBaseUrl: 'https://api.LeafWise.com/api',
      plantIdentificationApiUrl: 'https://api.plant.id/v2',
      firebaseConfig: {
        apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY_PROD || '',
        authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN_PROD || '',
        projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID_PROD || '',
        storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET_PROD || '',
        messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID_PROD || '',
        appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID_PROD || '',
      },
      features: {
        enableAnalytics: true,
        enableCrashReporting: true,
        enableDebugMode: false,
        enableMockData: false,
      },
      logging: {
        level: 'error',
        enableConsoleLogging: false,
        enableRemoteLogging: true,
      },
      performance: {
        enablePerformanceMonitoring: true,
        apiTimeoutMs: 5000,
        imageUploadTimeoutMs: 20000,
      },
    },
  };
  
  return configs[environment];
}

// Export current environment configuration
export const currentEnvironment = getCurrentEnvironment();
export const config = getEnvironmentConfig(currentEnvironment);

// Export utility functions
export { getCurrentEnvironment, getEnvironmentConfig };
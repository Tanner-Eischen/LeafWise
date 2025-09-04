/**
 * Build Configuration for LeafWise
 * Manages build settings and environment-specific configurations
 * Supports different build targets and optimization levels
 */

import { Environment } from './environment';

export interface BuildConfig {
  environment: Environment;
  bundleIdentifier: string;
  appName: string;
  version: string;
  buildNumber: string;
  optimization: {
    minify: boolean;
    treeshake: boolean;
    sourceMaps: boolean;
    bundleAnalyzer: boolean;
  };
  expo: {
    slug: string;
    scheme: string;
    orientation: 'portrait' | 'landscape' | 'default';
    platforms: ('ios' | 'android' | 'web')[];
    updates: {
      enabled: boolean;
      checkAutomatically: 'ON_ERROR_RECOVERY' | 'ON_LOAD' | 'NEVER';
      fallbackToCacheTimeout: number;
    };
  };
  assets: {
    icon: string;
    splash: {
      image: string;
      resizeMode: 'contain' | 'cover' | 'native';
      backgroundColor: string;
    };
  };
  permissions: string[];
}

/**
 * Gets build configuration for specified environment
 * @param environment - Target environment
 * @returns Build configuration object
 */
function getBuildConfig(environment: Environment): BuildConfig {
  const baseConfig = {
    version: '1.0.0',
    buildNumber: process.env.BUILD_NUMBER || '1',
    expo: {
      orientation: 'portrait' as const,
      platforms: ['ios', 'android'] as ('ios' | 'android' | 'web')[],
      assets: {
        icon: './assets/icon.png',
        splash: {
          image: './assets/splash-icon.png',
          resizeMode: 'contain' as const,
          backgroundColor: '#ffffff',
        },
      },
      permissions: [
        'CAMERA',
        'CAMERA_ROLL',
        'LOCATION',
        'NOTIFICATIONS',
        'INTERNET',
        'ACCESS_NETWORK_STATE',
      ],
    },
  };

  const configs: Record<Environment, BuildConfig> = {
    development: {
      ...baseConfig,
      environment: 'development',
      bundleIdentifier: 'com.LeafWise.dev',
      appName: 'LeafWise Dev',
      optimization: {
        minify: false,
        treeshake: false,
        sourceMaps: true,
        bundleAnalyzer: true,
      },
      expo: {
        ...baseConfig.expo,
        slug: 'LeafWise-dev',
        scheme: 'LeafWise-dev',
        updates: {
          enabled: false,
          checkAutomatically: 'NEVER',
          fallbackToCacheTimeout: 0,
        },
      },
      assets: baseConfig.expo.assets,
      permissions: baseConfig.expo.permissions,
    },
    staging: {
      ...baseConfig,
      environment: 'staging',
      bundleIdentifier: 'com.LeafWise.staging',
      appName: 'LeafWise Staging',
      optimization: {
        minify: true,
        treeshake: true,
        sourceMaps: true,
        bundleAnalyzer: false,
      },
      expo: {
        ...baseConfig.expo,
        slug: 'LeafWise-staging',
        scheme: 'LeafWise-staging',
        updates: {
          enabled: true,
          checkAutomatically: 'ON_LOAD',
          fallbackToCacheTimeout: 5000,
        },
      },
      assets: baseConfig.expo.assets,
      permissions: baseConfig.expo.permissions,
    },
    production: {
      ...baseConfig,
      environment: 'production',
      bundleIdentifier: 'com.LeafWise.app',
      appName: 'LeafWise',
      optimization: {
        minify: true,
        treeshake: true,
        sourceMaps: false,
        bundleAnalyzer: false,
      },
      expo: {
        ...baseConfig.expo,
        slug: 'LeafWise',
        scheme: 'LeafWise',
        updates: {
          enabled: true,
          checkAutomatically: 'ON_ERROR_RECOVERY',
          fallbackToCacheTimeout: 10000,
        },
      },
      assets: baseConfig.expo.assets,
      permissions: baseConfig.expo.permissions,
    },
  };

  return configs[environment];
}

/**
 * Gets the current build configuration based on environment
 * @returns Current build configuration
 */
function getCurrentBuildConfig(): BuildConfig {
  const environment = (process.env.EXPO_PUBLIC_ENV || 'development') as Environment;
  return getBuildConfig(environment);
}

export { getBuildConfig, getCurrentBuildConfig };
export const buildConfig = getCurrentBuildConfig();
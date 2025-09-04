/**
 * Camera Permission Utilities for LeafWise
 * Handles camera permission requests and checks using React Native permissions
 * Implements Camera Integration (AC1) requirements for proper permission handling
 */

import { Alert, Linking, Platform } from 'react-native';
import {
  CameraPermissionStatus,
  CameraPermissionResult,
  CameraPermissionOptions,
} from '../types';

/**
 * Maps React Native permission status to our custom status type
 * @param status - React Native permission status
 * @returns Mapped camera permission status
 */
function mapPermissionStatus(status: string): CameraPermissionStatus {
  switch (status) {
    case 'granted':
      return 'granted';
    case 'denied':
      return 'denied';
    case 'restricted':
      return 'restricted';
    case 'undetermined':
    case 'never_ask_again':
    default:
      return 'undetermined';
  }
}

/**
 * Checks current camera permission status without requesting
 * @returns Promise resolving to current permission status
 */
export async function checkCameraPermission(): Promise<CameraPermissionResult> {
  try {
    // For React Native, we'll use expo-camera's permission methods
    const { Camera } = await import('expo-camera');
    const permission = await Camera.getCameraPermissionsAsync();
    
    return {
      status: mapPermissionStatus(permission.status),
      canAskAgain: permission.canAskAgain ?? true,
      expires: permission.expires ?? 'never',
    };
  } catch (error) {
    // Permission check failed, return undetermined status
    return {
      status: 'undetermined',
      canAskAgain: true,
      expires: 'never',
    };
  }
}

/**
 * Requests camera permission from the user
 * @param options - Optional configuration for permission request
 * @returns Promise resolving to permission request result
 */
export async function requestCameraPermission(
  options: CameraPermissionOptions = {}
): Promise<CameraPermissionResult> {
  try {
    // Check current status first
    const currentStatus = await checkCameraPermission();
    
    // If already granted, return immediately
    if (currentStatus.status === 'granted') {
      return currentStatus;
    }
    
    // If permission was denied and can't ask again, show settings prompt
    if (currentStatus.status === 'denied' && !currentStatus.canAskAgain) {
      if (options.showRationale) {
        showPermissionDeniedAlert(options);
      }
      return currentStatus;
    }
    
    // Show rationale if requested and this is not the first request
    if (options.showRationale && currentStatus.status === 'denied') {
      await showPermissionRationale(options);
    }
    
    // Request permission
    const { Camera } = await import('expo-camera');
    const permission = await Camera.requestCameraPermissionsAsync();
    
    const result: CameraPermissionResult = {
      status: mapPermissionStatus(permission.status),
      canAskAgain: permission.canAskAgain ?? true,
      expires: permission.expires ?? 'never',
    };
    
    // Handle post-request scenarios
    if (result.status === 'denied' && !result.canAskAgain) {
      showPermissionDeniedAlert(options);
    }
    
    return result;
  } catch (error) {
    // Permission request failed, return denied status
    return {
      status: 'denied',
      canAskAgain: false,
      expires: 'never',
    };
  }
}

/**
 * Shows rationale dialog explaining why camera permission is needed
 * @param options - Permission options containing rationale text
 * @returns Promise that resolves when user acknowledges the rationale
 */
function showPermissionRationale(
  options: CameraPermissionOptions
): Promise<void> {
  return new Promise((resolve) => {
    const title = options.rationaleTitle || 'Camera Access Required';
    const message = options.rationaleMessage || 
      'LeafWise needs access to your camera to take photos of plants for identification. ' +
      'This allows you to capture high-quality images that improve identification accuracy.';
    
    Alert.alert(
      title,
      message,
      [
        {
          text: 'Cancel',
          style: 'cancel',
          onPress: () => resolve(),
        },
        {
          text: 'Continue',
          onPress: () => resolve(),
        },
      ],
      { cancelable: false }
    );
  });
}

/**
 * Shows alert when permission is permanently denied
 * @param options - Permission options for customizing the alert
 */
function showPermissionDeniedAlert(_options: CameraPermissionOptions): void {
  const title = 'Camera Access Denied';
  const message = 
    'Camera access is required to take photos for plant identification. ' +
    'Please enable camera access in your device settings to use this feature.';
  
  Alert.alert(
    title,
    message,
    [
      {
        text: 'Cancel',
        style: 'cancel',
      },
      {
        text: 'Open Settings',
        onPress: openAppSettings,
      },
    ],
    { cancelable: true }
  );
}

/**
 * Opens the app settings page where user can manually enable permissions
 */
export async function openAppSettings(): Promise<void> {
  try {
    if (Platform.OS === 'ios') {
      await Linking.openURL('app-settings:');
    } else {
      await Linking.openURL('package:com.LeafWise');
    }
  } catch (error) {
    // Failed to open app-specific settings, try fallback
    // Fallback to general settings
    try {
      await Linking.openURL('app-settings:');
    } catch (fallbackError) {
      // Both attempts to open settings failed
    }
  }
}

/**
 * Checks if camera permission is granted
 * @returns Promise resolving to boolean indicating if permission is granted
 */
export async function hasCameraPermission(): Promise<boolean> {
  const result = await checkCameraPermission();
  return result.status === 'granted';
}

/**
 * Ensures camera permission is granted, requesting if necessary
 * @param options - Optional configuration for permission request
 * @returns Promise resolving to boolean indicating if permission was granted
 */
export async function ensureCameraPermission(
  options: CameraPermissionOptions = {}
): Promise<boolean> {
  const result = await requestCameraPermission(options);
  return result.status === 'granted';
}

/**
 * Gets detailed camera permission information
 * @returns Promise resolving to detailed permission information
 */
export async function getCameraPermissionInfo(): Promise<{
  hasPermission: boolean;
  canRequest: boolean;
  status: CameraPermissionStatus;
  shouldShowRationale: boolean;
}> {
  const result = await checkCameraPermission();
  
  return {
    hasPermission: result.status === 'granted',
    canRequest: result.canAskAgain && result.status !== 'granted',
    status: result.status,
    shouldShowRationale: result.status === 'denied' && result.canAskAgain,
  };
}

/**
 * Permission utility for handling camera access with user-friendly messaging
 * Provides comprehensive permission management for camera functionality
 */
export const CameraPermissions = {
  check: checkCameraPermission,
  request: requestCameraPermission,
  hasPermission: hasCameraPermission,
  ensure: ensureCameraPermission,
  getInfo: getCameraPermissionInfo,
  openSettings: openAppSettings,
} as const;
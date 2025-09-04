/**
 * Camera Permission Utilities Tests
 * Comprehensive tests for camera permission handling functionality
 */

import { Alert, Linking, Platform } from 'react-native';
import {
  checkCameraPermission,
  requestCameraPermission,
  hasCameraPermission,
  ensureCameraPermission,
  getCameraPermissionInfo,
  openAppSettings,
  CameraPermissions,
} from './permissions';
import { CameraPermissionResult } from '../types';

// Mock React Native modules
jest.mock('react-native', () => ({
  Alert: {
    alert: jest.fn(),
  },
  Linking: {
    openURL: jest.fn(),
  },
  Platform: {
    OS: 'ios',
  },
}));

// Mock expo-camera
const mockGetCameraPermissionsAsync = jest.fn();
const mockRequestCameraPermissionsAsync = jest.fn();

jest.mock('expo-camera', () => ({
  Camera: {
    getCameraPermissionsAsync: mockGetCameraPermissionsAsync,
    requestCameraPermissionsAsync: mockRequestCameraPermissionsAsync,
  },
}));

describe('Camera Permission Utilities', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (Platform as any).OS = 'ios';
  });

  describe('checkCameraPermission', () => {
    it('should return granted status when permission is granted', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await checkCameraPermission();

      expect(result).toEqual({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });
    });

    it('should return denied status when permission is denied', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });

      const result = await checkCameraPermission();

      expect(result).toEqual({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });
    });

    it('should handle errors gracefully', async () => {
      mockGetCameraPermissionsAsync.mockRejectedValue(new Error('Permission check failed'));

      const result = await checkCameraPermission();

      expect(result).toEqual({
        status: 'undetermined',
        canAskAgain: true,
        expires: 'never',
      });
    });

    it('should map unknown status to undetermined', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'unknown_status',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await checkCameraPermission();

      expect(result.status).toBe('undetermined');
    });
  });

  describe('requestCameraPermission', () => {
    it('should return immediately if permission is already granted', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await requestCameraPermission();

      expect(result.status).toBe('granted');
      expect(mockRequestCameraPermissionsAsync).not.toHaveBeenCalled();
    });

    it('should request permission when not granted', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'undetermined',
        canAskAgain: true,
        expires: 'never',
      });

      mockRequestCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await requestCameraPermission();

      expect(mockRequestCameraPermissionsAsync).toHaveBeenCalled();
      expect(result.status).toBe('granted');
    });

    it('should show rationale when requested and permission was denied', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: true,
        expires: 'never',
      });

      mockRequestCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation((title, message, buttons) => {
        // Simulate user pressing "Continue"
        if (buttons && buttons[1] && buttons[1].onPress) {
          buttons[1].onPress();
        }
      });

      await requestCameraPermission({
        showRationale: true,
        rationaleTitle: 'Custom Title',
        rationaleMessage: 'Custom message',
      });

      expect(alertSpy).toHaveBeenCalledWith(
        'Custom Title',
        'Custom message',
        expect.any(Array),
        { cancelable: false }
      );
    });

    it('should show settings alert when permission is permanently denied', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });

      const alertSpy = jest.spyOn(Alert, 'alert');

      await requestCameraPermission({ showRationale: true });

      expect(alertSpy).toHaveBeenCalledWith(
        'Camera Access Denied',
        expect.stringContaining('Please enable camera access'),
        expect.any(Array),
        { cancelable: true }
      );
    });

    it('should handle request errors gracefully', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'undetermined',
        canAskAgain: true,
        expires: 'never',
      });

      mockRequestCameraPermissionsAsync.mockRejectedValue(new Error('Request failed'));

      const result = await requestCameraPermission();

      expect(result).toEqual({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });
    });
  });

  describe('openAppSettings', () => {
    it('should open iOS app settings', async () => {
      (Platform as any).OS = 'ios';
      const linkingSpy = jest.spyOn(Linking, 'openURL').mockResolvedValue(true);
      
      await openAppSettings();
      
      expect(linkingSpy).toHaveBeenCalledWith('app-settings:');
    });

    it('should open Android app settings', async () => {
      (Platform as any).OS = 'android';
      const linkingSpy = jest.spyOn(Linking, 'openURL').mockResolvedValue(true);
      
      await openAppSettings();
      
      expect(linkingSpy).toHaveBeenCalledWith('package:com.LeafWise');
    });

    it('should fallback to general settings on error', async () => {
      (Platform as any).OS = 'android';
      const linkingSpy = jest.spyOn(Linking, 'openURL')
        .mockRejectedValueOnce(new Error('Failed to open package settings'))
        .mockResolvedValueOnce(true);
      
      await openAppSettings();
      
      expect(linkingSpy).toHaveBeenCalledTimes(2);
      expect(linkingSpy).toHaveBeenLastCalledWith('app-settings:');
    });
  });

  describe('hasCameraPermission', () => {
    it('should return true when permission is granted', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await hasCameraPermission();
      expect(result).toBe(true);
    });

    it('should return false when permission is not granted', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await hasCameraPermission();
      expect(result).toBe(false);
    });
  });

  describe('ensureCameraPermission', () => {
    it('should return true when permission is granted after request', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'undetermined',
        canAskAgain: true,
        expires: 'never',
      });

      mockRequestCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await ensureCameraPermission();
      expect(result).toBe(true);
    });

    it('should return false when permission is denied', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'undetermined',
        canAskAgain: true,
        expires: 'never',
      });

      mockRequestCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });

      const result = await ensureCameraPermission();
      expect(result).toBe(false);
    });
  });

  describe('getCameraPermissionInfo', () => {
    it('should return correct info for granted permission', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'granted',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await getCameraPermissionInfo();

      expect(result).toEqual({
        hasPermission: true,
        canRequest: false,
        status: 'granted',
        shouldShowRationale: false,
      });
    });

    it('should return correct info for denied permission that can be requested', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: true,
        expires: 'never',
      });

      const result = await getCameraPermissionInfo();

      expect(result).toEqual({
        hasPermission: false,
        canRequest: true,
        status: 'denied',
        shouldShowRationale: true,
      });
    });

    it('should return correct info for permanently denied permission', async () => {
      mockGetCameraPermissionsAsync.mockResolvedValue({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });

      const result = await getCameraPermissionInfo();

      expect(result).toEqual({
        hasPermission: false,
        canRequest: false,
        status: 'denied',
        shouldShowRationale: false,
      });
    });
  });

  describe('CameraPermissions object', () => {
    it('should export all permission utilities', () => {
      expect(CameraPermissions.check).toBe(checkCameraPermission);
      expect(CameraPermissions.request).toBe(requestCameraPermission);
      expect(CameraPermissions.hasPermission).toBe(hasCameraPermission);
      expect(CameraPermissions.ensure).toBe(ensureCameraPermission);
      expect(CameraPermissions.getInfo).toBe(getCameraPermissionInfo);
      expect(CameraPermissions.openSettings).toBe(openAppSettings);
    });
  });
});
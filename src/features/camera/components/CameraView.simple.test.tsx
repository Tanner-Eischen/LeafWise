/**
 * Simple CameraView Component Tests
 * Basic tests to verify component functionality
 */

import React from 'react';
import { render, screen } from '@testing-library/react-native';
import CameraView from './CameraView';

// Mock expo-camera
jest.mock('expo-camera', () => ({
  CameraView: 'CameraView',
  useCameraPermissions: () => [{ granted: true }, jest.fn()],
}));

// Mock expo-image-picker
jest.mock('expo-image-picker', () => ({
  requestMediaLibraryPermissionsAsync: jest.fn(() => 
    Promise.resolve({ status: 'granted' })
  ),
  launchImageLibraryAsync: jest.fn(() => 
    Promise.resolve({
      cancelled: false,
      assets: [{
        uri: 'mock-image-uri',
        width: 100,
        height: 100,
      }],
    })
  ),
}));

// Mock permissions utility
jest.mock('../utils/permissions', () => ({
  requestCameraPermission: jest.fn(() => 
    Promise.resolve({
      status: 'granted',
      canAskAgain: true,
      expires: 'never',
    })
  ),
  checkCameraPermission: jest.fn(() => 
    Promise.resolve({
      status: 'granted',
      canAskAgain: true,
      expires: 'never',
    })
  ),
}));

describe('CameraView Simple Tests', () => {
  const mockOnCapture = jest.fn();
  const mockOnClose = jest.fn();
  const mockOnError = jest.fn();

  const defaultProps = {
    onCapture: mockOnCapture,
    onClose: mockOnClose,
    onError: mockOnError,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders without crashing', () => {
    render(<CameraView {...defaultProps} />);
    expect(screen.getByText('Initializing camera...')).toBeTruthy();
  });

  it('shows loading indicator initially', () => {
    render(<CameraView {...defaultProps} />);
    expect(screen.getByTestId('loading-indicator')).toBeTruthy();
  });
});
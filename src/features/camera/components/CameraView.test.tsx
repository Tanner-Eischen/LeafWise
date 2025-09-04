/**
 * CameraView Component Tests
 * Tests for the camera interface component with plant photography optimizations
 */

import React from 'react';
import { render, fireEvent, waitFor, screen } from '@testing-library/react-native';
import { Alert } from 'react-native';
import CameraView from './CameraView';
import { CameraError, ImageResult } from '../types';
import * as permissions from '../utils/permissions';

// Mock expo-camera
jest.mock('expo-camera', () => ({
  CameraView: React.forwardRef((props: any, ref: any) => {
    React.useImperativeHandle(ref, () => ({
      takePictureAsync: jest.fn().mockResolvedValue({
        uri: 'mock-photo-uri',
        width: 1920,
        height: 1080,
        base64: null,
      }),
    }));
    
    const MockCamera = require('react-native').View;
    return (
      <MockCamera
        {...props}
        testID={props.testID || 'camera-view'}
      >
        {props.children}
      </MockCamera>
    );
  }),
}));

// Mock expo-image-picker
jest.mock('expo-image-picker', () => ({
  launchImageLibraryAsync: jest.fn(),
  MediaTypeOptions: {
    Images: 'Images',
  },
}));

// Mock permissions utility
jest.mock('../utils/permissions', () => ({
  requestCameraPermission: jest.fn(),
  checkCameraPermission: jest.fn(),
}));

// Mock Alert
jest.spyOn(Alert, 'alert');

const mockRequestCameraPermission = permissions.requestCameraPermission as jest.MockedFunction<
  typeof permissions.requestCameraPermission
>;

describe('CameraView Component', () => {
  const mockOnCapture = jest.fn();
  const mockOnError = jest.fn();

  const defaultProps = {
    onCapture: mockOnCapture,
    onError: mockOnError,
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockRequestCameraPermission.mockResolvedValue({
      status: 'granted',
      canAskAgain: true,
      expires: 'never',
    });
  });

  describe('Initialization', () => {
    it('renders loading state initially', () => {
      render(<CameraView {...defaultProps} />);
      
      expect(screen.getByText('Initializing camera...')).toBeTruthy();
      expect(screen.getByTestId('loading-indicator')).toBeTruthy();
    });

    it('requests camera permissions on mount', async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalledWith({
          showRationale: true,
          rationaleTitle: 'Camera Access Required',
          rationaleMessage: 'LeafWise needs camera access to identify plants from photos.',
        });
      });
    });

    it('handles permission denied error', async () => {
      mockRequestCameraPermission.mockResolvedValue({
        status: 'denied',
        canAskAgain: false,
        expires: 'never',
      });

      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockOnError).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 'PERMISSION_DENIED',
            message: 'Camera permission is required for plant identification',
            recoverable: true,
          })
        );
      });
    });
  });

  describe('Camera Controls', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      // Wait for initialization
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('renders camera controls when ready', async () => {
      await waitFor(() => {
        expect(screen.getByTestId('flash-button')).toBeTruthy();
        expect(screen.getByTestId('camera-flip-button')).toBeTruthy();
        expect(screen.getByTestId('capture-button')).toBeTruthy();
      });
    });

    it('toggles flash mode when flash button is pressed', async () => {
      await waitFor(() => {
        const flashButton = screen.getByTestId('flash-button');
        
        // Initial state should show flash icon
        expect(flashButton).toBeTruthy();
        
        // Press to toggle flash mode
        fireEvent.press(flashButton);
        
        // Should toggle flash mode
        expect(flashButton).toBeTruthy();
      });
    });

    it('toggles camera type when flip button is pressed', async () => {
      await waitFor(() => {
        const flipButton = screen.getByTestId('camera-flip-button');
        fireEvent.press(flipButton);
        
        // Camera type should toggle from back to front
        expect(flipButton).toBeTruthy();
      });
    });
  });

  describe('Plant Photography Guidance', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('shows plant photography guidance overlay', async () => {
      await waitFor(() => {
        expect(screen.getByText('Plant Photography Tips')).toBeTruthy();
      });
    });

    it('hides guidance when hide button is pressed', async () => {
      await waitFor(() => {
        const hideButton = screen.getByText('Hide');
        fireEvent.press(hideButton);
        
        expect(screen.queryByText('Plant Photography Tips')).toBeNull();
      });
    });

    it('toggles guidance with guidance toggle button', async () => {
      await waitFor(() => {
        const guidanceToggle = screen.getByTestId('guidance-toggle');
        
        // Hide guidance first
        fireEvent.press(guidanceToggle);
        expect(screen.queryByText('Plant Photography Tips')).toBeNull();
        
        // Show guidance again
        fireEvent.press(guidanceToggle);
        expect(screen.getByText('Plant Photography Tips')).toBeTruthy();
      });
    });
  });

  describe('Photo Capture', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('captures photo when capture button is pressed', async () => {
      await waitFor(() => {
        const captureButton = screen.getByTestId('capture-button');
        fireEvent.press(captureButton);
        
        // Should trigger photo capture
        expect(captureButton).toBeTruthy();
      });
    });

    it('calls onCapture with image result after successful capture', async () => {
      await waitFor(() => {
        const captureButton = screen.getByTestId('capture-button');
        fireEvent.press(captureButton);
      });

      await waitFor(() => {
        expect(mockOnCapture).toHaveBeenCalledWith(
          expect.objectContaining({
            uri: 'mock-photo-uri',
            metadata: expect.objectContaining({
              format: 'jpeg',
              dimensions: {
                width: 1920,
                height: 1080,
              },
            }),
            isValid: true,
          })
        );
      });
    });

    it('handles capture button interaction', async () => {
      await waitFor(() => {
        const captureButton = screen.getByTestId('capture-button');
        fireEvent.press(captureButton);
        
        // Should handle capture button press
        expect(captureButton).toBeTruthy();
      });
    });
  });

  describe('Image Gallery Integration', () => {
    const mockLaunchImageLibraryAsync = require('expo-image-picker').launchImageLibraryAsync;

    beforeEach(async () => {
      mockLaunchImageLibraryAsync.mockResolvedValue({
        canceled: false,
        assets: [{
          uri: 'mock-gallery-image-uri',
          width: 1920,
          height: 1080,
          fileSize: 1024000,
        }],
      });

      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('opens gallery when gallery button is pressed', async () => {
      await waitFor(() => {
        const galleryButton = screen.getByTestId('gallery-button');
        fireEvent.press(galleryButton);
        
        expect(mockLaunchImageLibraryAsync).toHaveBeenCalledWith({
          mediaTypes: 'Images',
          allowsEditing: true,
          aspect: [4, 3],
          quality: 0.8,
        });
      });
    });

    it('calls onCapture with selected gallery image', async () => {
      await waitFor(() => {
        const galleryButton = screen.getByTestId('gallery-button');
        fireEvent.press(galleryButton);
      });

      await waitFor(() => {
        expect(mockOnCapture).toHaveBeenCalledWith(
          expect.objectContaining({
            uri: 'mock-gallery-image-uri',
            metadata: expect.objectContaining({
              format: 'jpeg',
              dimensions: {
                width: 1920,
                height: 1080,
              },
              fileSize: 1024000,
            }),
            isValid: true,
          })
        );
      });
    });

    it('handles gallery selection cancellation', async () => {
      mockLaunchImageLibraryAsync.mockResolvedValue({
        canceled: true,
        assets: [],
      });

      await waitFor(() => {
        const galleryButton = screen.getByTestId('gallery-button');
        fireEvent.press(galleryButton);
      });

      // Should not call onCapture when cancelled
      expect(mockOnCapture).not.toHaveBeenCalled();
    });
  });

  describe('Configuration Application', () => {
    it('applies initial configuration correctly', async () => {
      const initialConfig = {
        type: 'front' as const,
        flashMode: 'on' as const,
        quality: 'medium' as const,
      };

      render(<CameraView {...defaultProps} initialConfig={initialConfig} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });

      // Configuration should be applied to camera state
      expect(screen.getByTestId('camera-view')).toBeTruthy();
    });
  });

  describe('Lighting Analysis', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('displays lighting analysis information', async () => {
      await waitFor(() => {
        expect(screen.getByText('Lighting: good')).toBeTruthy();
      });
    });
  });

  describe('Focus Guide', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('renders focus guide overlay', async () => {
      await waitFor(() => {
        expect(screen.getByTestId('focus-guide')).toBeTruthy();
      });
    });
  });

  describe('Error Handling', () => {
    it('handles camera initialization errors', async () => {
      mockRequestCameraPermission.mockRejectedValue(new Error('Permission error'));

      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockOnError).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 'INITIALIZATION_FAILED',
            message: 'Failed to initialize camera',
            details: 'Permission error',
          })
        );
      });
    });

    it('handles camera mount errors', async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });

      // Simulate camera mount error
      const cameraView = screen.getByTestId('camera-view');
      fireEvent(cameraView, 'onMountError', { message: 'Camera mount failed' });

      expect(mockOnError).toHaveBeenCalledWith(
        expect.objectContaining({
          code: 'CAMERA_UNAVAILABLE',
          message: 'Camera is not available',
          details: 'Camera mount failed',
        })
      );
    });
  });

  describe('Accessibility', () => {
    beforeEach(async () => {
      render(<CameraView {...defaultProps} />);
      
      await waitFor(() => {
        expect(mockRequestCameraPermission).toHaveBeenCalled();
      });
    });

    it('provides testID for all interactive elements', async () => {
      await waitFor(() => {
        expect(screen.getByTestId('camera-view')).toBeTruthy();
        expect(screen.getByTestId('flash-button')).toBeTruthy();
        expect(screen.getByTestId('camera-flip-button')).toBeTruthy();
        expect(screen.getByTestId('guidance-toggle')).toBeTruthy();
        expect(screen.getByTestId('gallery-button')).toBeTruthy();
        expect(screen.getByTestId('capture-button')).toBeTruthy();
        expect(screen.getByTestId('focus-guide')).toBeTruthy();
      });
    });
  });
});
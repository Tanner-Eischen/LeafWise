/**
 * Tests for LightingGuidance Component
 * 
 * This file contains comprehensive tests for the LightingGuidance component,
 * including rendering, user interactions, lighting monitoring, and animations.
 */

import React from 'react';
import { render, fireEvent, waitFor, act } from '@testing-library/react-native';
import { Alert, Animated } from 'react-native';
import { LightingGuidance } from './LightingGuidance';
import * as lightingDetection from '../utils/lightingDetection';

// Mock the lighting detection utilities
jest.mock('../utils/lightingDetection', () => ({
  analyzeLightingConditions: jest.fn(),
  createLightingMonitor: jest.fn(),
}));

// Mock React Native components
jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  return {
    ...RN,
    Alert: {
      alert: jest.fn(),
    },
    Animated: {
      ...RN.Animated,
      Value: jest.fn(() => ({
        setValue: jest.fn(),
        addListener: jest.fn(),
        removeListener: jest.fn(),
        removeAllListeners: jest.fn(),
      })),
      timing: jest.fn(() => ({
        start: jest.fn((callback) => callback && callback()),
      })),
      sequence: jest.fn(() => ({
        start: jest.fn((callback) => callback && callback()),
      })),
      View: RN.View,
    },
  };
});

const mockLightingDetection = lightingDetection as jest.Mocked<typeof lightingDetection>;

describe('LightingGuidance', () => {
  let mockStopMonitor: jest.Mock;
  let mockOnFlashRecommendationChange: jest.Mock;
  let mockOnSuitabilityChange: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockStopMonitor = jest.fn();
    mockOnFlashRecommendationChange = jest.fn();
    mockOnSuitabilityChange = jest.fn();
    
    mockLightingDetection.createLightingMonitor.mockReturnValue(mockStopMonitor);
    
    // Mock Animated.Value
    (Animated.Value as jest.Mock).mockImplementation(() => ({
      setValue: jest.fn(),
      addListener: jest.fn(),
      removeListener: jest.fn(),
      removeAllListeners: jest.fn(),
    }));
    
    // Mock Animated.timing
    (Animated.timing as jest.Mock).mockReturnValue({
      start: jest.fn((callback) => callback && callback()),
    });
    
    // Mock Animated.sequence
    (Animated.sequence as jest.Mock).mockReturnValue({
      start: jest.fn((callback) => callback && callback()),
    });
  });

  afterEach(() => {
    jest.clearAllTimers();
  });

  describe('Rendering', () => {
    it('should not render when not visible', () => {
      const { queryByTestId } = render(
        <LightingGuidance visible={false} />
      );
      
      expect(queryByTestId('lighting-guidance')).toBeNull();
    });

    it('should not render initially when no lighting analysis is available', () => {
      const { queryByTestId } = render(
        <LightingGuidance visible={true} />
      );
      
      expect(queryByTestId('lighting-guidance')).toBeNull();
    });

    it('should render with excellent lighting conditions', async () => {
      const mockAnalysis = {
        condition: 'excellent' as const,
        lightLevel: 85,
        flashRecommendation: 'none' as const,
        guidance: 'Perfect lighting for plant photography!',
        isSuitableForPhotography: true,
        recommendations: ['Great natural lighting', 'No flash needed'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId, getByText } = render(
        <LightingGuidance visible={true} />
      );

      await waitFor(() => {
        expect(getByTestId('lighting-guidance')).toBeTruthy();
        expect(getByText('Excellent')).toBeTruthy();
        expect(getByText('85%')).toBeTruthy();
        expect(getByText('Perfect lighting for plant photography!')).toBeTruthy();
      });
    });

    it('should render with poor lighting conditions and warnings', async () => {
      const mockAnalysis = {
        condition: 'poor' as const,
        lightLevel: 25,
        flashRecommendation: 'recommended' as const,
        guidance: 'Low light detected. Consider using flash.',
        isSuitableForPhotography: false,
        recommendations: ['Use flash', 'Move to brighter area'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId, getByText } = render(
        <LightingGuidance visible={true} />
      );

      await waitFor(() => {
        expect(getByTestId('lighting-guidance')).toBeTruthy();
        expect(getByText('Poor')).toBeTruthy();
        expect(getByText('25%')).toBeTruthy();
        expect(getByText('💡 Flash: Recommended')).toBeTruthy();
        expect(getByText('⚠️ Lighting may affect photo quality')).toBeTruthy();
      });
    });
  });

  describe('Monitoring', () => {
    it('should start monitoring when visible', () => {
      render(<LightingGuidance visible={true} />);
      
      expect(mockLightingDetection.createLightingMonitor).toHaveBeenCalledWith(
        expect.any(Function),
        undefined
      );
    });

    it('should stop monitoring when not visible', async () => {
      const { rerender } = render(<LightingGuidance visible={true} />);
      
      expect(mockLightingDetection.createLightingMonitor).toHaveBeenCalled();
      
      rerender(<LightingGuidance visible={false} />);
      
      await waitFor(() => {
        expect(mockStopMonitor).toHaveBeenCalled();
      });
    });

    it('should use custom config when provided', () => {
      const customConfig = {
        updateInterval: 2000,
        smoothingFactor: 0.3,
      };
      
      render(
        <LightingGuidance 
          visible={true} 
          config={customConfig}
        />
      );
      
      expect(mockLightingDetection.createLightingMonitor).toHaveBeenCalledWith(
        expect.any(Function),
        customConfig
      );
    });

    it('should cleanup monitoring on unmount', () => {
      const { unmount } = render(<LightingGuidance visible={true} />);
      
      unmount();
      
      expect(mockStopMonitor).toHaveBeenCalled();
    });
  });

  describe('Callbacks', () => {
    it('should call onFlashRecommendationChange when flash recommendation changes', async () => {
      const mockAnalysis = {
        condition: 'fair' as const,
        lightLevel: 45,
        flashRecommendation: 'recommended' as const,
        guidance: 'Consider using flash',
        isSuitableForPhotography: true,
        recommendations: ['Use flash for better results'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      render(
        <LightingGuidance 
          visible={true}
          onFlashRecommendationChange={mockOnFlashRecommendationChange}
        />
      );

      await waitFor(() => {
        expect(mockOnFlashRecommendationChange).toHaveBeenCalledWith('recommended');
      });
    });

    it('should call onSuitabilityChange when suitability changes', async () => {
      const mockAnalysis = {
        condition: 'very-poor' as const,
        lightLevel: 10,
        flashRecommendation: 'required' as const,
        guidance: 'Very low light. Flash required.',
        isSuitableForPhotography: false,
        recommendations: ['Use flash', 'Find better lighting'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      render(
        <LightingGuidance 
          visible={true}
          onSuitabilityChange={mockOnSuitabilityChange}
        />
      );

      await waitFor(() => {
        expect(mockOnSuitabilityChange).toHaveBeenCalledWith(false);
      });
    });
  });

  describe('User Interactions', () => {
    it('should show detailed guidance when main indicator is pressed', async () => {
      const mockAnalysis = {
        condition: 'good' as const,
        lightLevel: 70,
        flashRecommendation: 'none' as const,
        guidance: 'Good lighting conditions',
        isSuitableForPhotography: true,
        recommendations: ['Natural lighting is sufficient', 'No flash needed'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId } = render(
        <LightingGuidance visible={true} />
      );

      await waitFor(() => {
        expect(getByTestId('lighting-guidance-main-indicator')).toBeTruthy();
      });

      fireEvent.press(getByTestId('lighting-guidance-main-indicator'));

      expect(Alert.alert).toHaveBeenCalledWith(
        '🌤️ Good Lighting',
        'Natural lighting is sufficient\n\nNo flash needed',
        [{ text: 'OK' }]
      );
    });

    it('should toggle recommendations when header is pressed', async () => {
      const mockAnalysis = {
        condition: 'fair' as const,
        lightLevel: 50,
        flashRecommendation: 'optional' as const,
        guidance: 'Adequate lighting',
        isSuitableForPhotography: true,
        recommendations: ['Flash optional', 'Good for most plants'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId, queryByTestId } = render(
        <LightingGuidance 
          visible={true}
          showDetailedRecommendations={true}
        />
      );

      await waitFor(() => {
        expect(getByTestId('lighting-guidance-recommendations-toggle')).toBeTruthy();
      });

      // Initially recommendations should not be shown
      expect(queryByTestId('lighting-guidance-recommendations-list')).toBeNull();

      // Press to show recommendations
      fireEvent.press(getByTestId('lighting-guidance-recommendations-toggle'));

      await waitFor(() => {
        expect(getByTestId('lighting-guidance-recommendations-list')).toBeTruthy();
      });

      // Press again to hide recommendations
      fireEvent.press(getByTestId('lighting-guidance-recommendations-toggle'));

      await waitFor(() => {
        expect(queryByTestId('lighting-guidance-recommendations-list')).toBeNull();
      });
    });
  });

  describe('Animations', () => {
    it('should trigger pulse animation for poor lighting conditions', async () => {
      const mockAnalysis = {
        condition: 'poor' as const,
        lightLevel: 20,
        flashRecommendation: 'recommended' as const,
        guidance: 'Poor lighting detected',
        isSuitableForPhotography: false,
        recommendations: ['Use flash', 'Move to brighter location'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      render(<LightingGuidance visible={true} />);

      await waitFor(() => {
        expect(Animated.sequence).toHaveBeenCalled();
      });
    });

    it('should trigger pulse animation for very poor lighting conditions', async () => {
      const mockAnalysis = {
        condition: 'very-poor' as const,
        lightLevel: 5,
        flashRecommendation: 'required' as const,
        guidance: 'Very poor lighting',
        isSuitableForPhotography: false,
        recommendations: ['Flash required', 'Find better lighting'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      render(<LightingGuidance visible={true} />);

      await waitFor(() => {
        expect(Animated.sequence).toHaveBeenCalled();
      });
    });

    it('should trigger fade in animation when becoming visible', () => {
      render(<LightingGuidance visible={true} />);
      
      expect(Animated.timing).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        })
      );
    });

    it('should trigger fade out animation when becoming invisible', async () => {
      const { rerender } = render(<LightingGuidance visible={true} />);
      
      // Clear previous calls
      (Animated.timing as jest.Mock).mockClear();
      
      rerender(<LightingGuidance visible={false} />);
      
      await waitFor(() => {
        expect(Animated.timing).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            toValue: 0,
            duration: 300,
            useNativeDriver: true,
          })
        );
      });
    });
  });

  describe('Custom Styling', () => {
    it('should apply custom styles', async () => {
      const customStyle = { marginTop: 50 };
      const mockAnalysis = {
        condition: 'excellent' as const,
        lightLevel: 90,
        flashRecommendation: 'none' as const,
        guidance: 'Perfect lighting',
        isSuitableForPhotography: true,
        recommendations: ['Excellent conditions'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId } = render(
        <LightingGuidance 
          visible={true}
          style={customStyle}
        />
      );

      await waitFor(() => {
        const component = getByTestId('lighting-guidance');
        expect(component.props.style).toEqual(
          expect.arrayContaining([
            expect.objectContaining(customStyle)
          ])
        );
      });
    });

    it('should use custom testID', async () => {
      const customTestID = 'custom-lighting-guidance';
      const mockAnalysis = {
        condition: 'good' as const,
        lightLevel: 75,
        flashRecommendation: 'none' as const,
        guidance: 'Good lighting',
        isSuitableForPhotography: true,
        recommendations: ['Good conditions'],
      };

      mockLightingDetection.createLightingMonitor.mockImplementation((callback) => {
        setTimeout(() => callback(mockAnalysis), 0);
        return mockStopMonitor;
      });

      const { getByTestId } = render(
        <LightingGuidance 
          visible={true}
          testID={customTestID}
        />
      );

      await waitFor(() => {
        expect(getByTestId(customTestID)).toBeTruthy();
        expect(getByTestId(`${customTestID}-main-indicator`)).toBeTruthy();
        expect(getByTestId(`${customTestID}-guidance`)).toBeTruthy();
      });
    });
  });

  describe('Edge Cases', () => {
    it('should handle multiple rapid visibility changes', async () => {
      const { rerender } = render(<LightingGuidance visible={false} />);
      
      // Rapidly toggle visibility
      rerender(<LightingGuidance visible={true} />);
      rerender(<LightingGuidance visible={false} />);
      rerender(<LightingGuidance visible={true} />);
      
      await waitFor(() => {
        expect(mockLightingDetection.createLightingMonitor).toHaveBeenCalled();
      });
    });

    it('should handle missing lighting analysis gracefully', () => {
      mockLightingDetection.createLightingMonitor.mockImplementation(() => {
        // Don't call the callback, simulating no analysis
        return mockStopMonitor;
      });

      const { queryByTestId } = render(
        <LightingGuidance visible={true} />
      );

      // Should not render without analysis
      expect(queryByTestId('lighting-guidance')).toBeNull();
    });

    it('should handle monitor creation failure', () => {
      mockLightingDetection.createLightingMonitor.mockImplementation(() => {
        throw new Error('Monitor creation failed');
      });

      // Should not crash
      expect(() => {
        render(<LightingGuidance visible={true} />);
      }).not.toThrow();
    });
  });
});
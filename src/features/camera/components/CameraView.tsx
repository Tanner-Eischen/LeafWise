/**
 * CameraView Component for LeafWise
 * Camera interface optimized for plant photography with flash control,
 * focus adjustment, capture button, and guidance overlay
 * Implements Camera Integration (AC2) requirements
 */

import React, {
  useState,
  useRef,
  useCallback,
  useEffect,
} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Dimensions,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { CameraView as ExpoCamera } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import {
  CameraConfig,
  CameraState,
  ImageResult,
  LightingAnalysis,
  PlantPhotographyGuidance,
  CameraError,
  CameraViewProps,
} from '../types';
import { requestCameraPermission } from '../utils/permissions';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

/**
 * CameraView component providing optimized plant photography interface
 * @param props - Component props
 * @returns JSX element for camera interface
 */
function CameraView({
  onCapture,
  onError,
  initialConfig,
  style,
}: CameraViewProps): React.JSX.Element {
  // Camera state management
  const [cameraState, setCameraState] = useState<CameraState>({
    status: 'initializing',
    isInitialized: false,
    hasPermission: false,
    config: {
      type: 'back',
      flashMode: 'auto',
      focusMode: 'auto',
      quality: 'high',
      enableZoom: true,
      aspectRatio: '4:3',
      ...initialConfig,
    },
    isCapturing: false,
    isProcessing: false,
  });

  const [lightingAnalysis, setLightingAnalysis] = useState<LightingAnalysis | null>(null);
  const [plantGuidance, setPlantGuidance] = useState<PlantPhotographyGuidance | null>(null);
  const [showGuidance, setShowGuidance] = useState(true);
  const [zoomLevel, setZoomLevel] = useState(0);
  
  const cameraRef = useRef<ExpoCamera>(null);
  const guidanceTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  /**
   * Initialize camera permissions and setup
   */
  const initializeCamera = useCallback(async () => {
    try {
      setCameraState(prev => ({ ...prev, status: 'initializing' }));
      
      const permissionResult = await requestCameraPermission({
        showRationale: true,
        rationaleTitle: 'Camera Access Required',
        rationaleMessage: 'LeafWise needs camera access to identify plants from photos.',
      });

      if (permissionResult.status !== 'granted') {
        const error: CameraError = {
          code: 'PERMISSION_DENIED',
          message: 'Camera permission is required for plant identification',
          timestamp: new Date().toISOString(),
          recoverable: true,
          retryAction: initializeCamera,
        };
        onError(error);
        return;
      }

      setCameraState(prev => ({
        ...prev,
        status: 'ready',
        isInitialized: true,
        hasPermission: true,
      }));
    } catch (error) {
      const cameraError: CameraError = {
        code: 'INITIALIZATION_FAILED',
        message: 'Failed to initialize camera',
        details: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        recoverable: true,
        retryAction: initializeCamera,
      };
      onError(cameraError);
    }
  }, [onError]);

  /**
   * Analyze lighting conditions for optimal plant photography
   */
  const analyzeLighting = useCallback(async () => {
    // Simulated lighting analysis - in real implementation, this would
    // analyze camera feed or use device sensors
    const mockAnalysis: LightingAnalysis = {
      condition: 'good',
      brightness: 0.7,
      contrast: 0.8,
      shadowIntensity: 0.3,
      recommendations: {
        useFlash: false,
        adjustPosition: false,
        waitForBetterLight: false,
        suggestions: ['Lighting conditions are good for plant photography'],
      },
    };
    
    setLightingAnalysis(mockAnalysis);
  }, []);

  /**
   * Analyze plant photography guidance
   */
  const analyzeGuidance = useCallback(async () => {
    // Simulated guidance analysis - in real implementation, this would
    // use computer vision to analyze the camera feed
    const mockGuidance: PlantPhotographyGuidance = {
      isOptimalDistance: true,
      isGoodLighting: true,
      isStableHold: true,
      isPlantCentered: false,
      suggestions: ['Center the plant in the frame', 'Hold steady for best results'],
      confidence: 0.85,
    };
    
    setPlantGuidance(mockGuidance);
  }, []);

  /**
   * Toggle camera flash mode
   */
  const toggleFlash = useCallback(() => {
    setCameraState(prev => ({
      ...prev,
      config: {
        ...prev.config,
        flashMode: prev.config.flashMode === 'off' ? 'on' : 'off'
      }
    }));
  }, []);

  /**
   * Toggle camera type (front/back)
   */
  const toggleCameraType = useCallback(() => {
    setCameraState(prev => ({
      ...prev,
      config: {
        ...prev.config,
        type: prev.config.type === 'back' ? 'front' : 'back',
      },
    }));
  }, []);

  /**
   * Handle zoom gesture
   */
  const handleZoom = useCallback((delta: number) => {
    if (!cameraState.config.enableZoom) return;
    
    setZoomLevel(prev => {
      const maxZoom = cameraState.config.maxZoom || 10;
      const newZoom = Math.max(0, Math.min(maxZoom, prev + delta));
      return newZoom;
    });
  }, [cameraState.config.enableZoom, cameraState.config.maxZoom]);

  /**
   * Capture photo with plant photography optimizations
   */
  const capturePhoto = useCallback(async () => {
    if (!cameraRef.current || cameraState.isCapturing) return;

    try {
      setCameraState(prev => ({ ...prev, isCapturing: true, status: 'capturing' }));

      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
      });

      if (photo) {
        const imageResult: ImageResult = {
          uri: photo.uri,
          base64: photo.base64,
          metadata: {
            format: 'jpeg',
            dimensions: {
              width: photo.width || 0,
              height: photo.height || 0,
            },
            fileSize: 0,
            timestamp: new Date().toISOString(),
          },
          isValid: true,
        };

        onCapture(imageResult);
      } else {
        throw new Error('Failed to capture photo');
      }
    } catch (error) {
      const cameraError: CameraError = {
        code: 'CAPTURE_FAILED',
        message: 'Failed to capture photo',
        details: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        recoverable: true,
        retryAction: capturePhoto,
      };
      onError(cameraError);
    } finally {
      setCameraState(prev => ({ ...prev, isCapturing: false, status: 'ready' }));
    }
  }, [cameraState.isCapturing, onCapture, onError]);

  /**
   * Select image from gallery
   */
  const selectFromGallery = useCallback(async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        const asset = result.assets[0];
        const imageResult: ImageResult = {
          uri: asset.uri,
          metadata: {
            format: 'jpeg',
            dimensions: {
              width: asset.width || 0,
              height: asset.height || 0,
            },
            fileSize: asset.fileSize || 0,
            timestamp: new Date().toISOString(),
          },
          isValid: true,
        };

        onCapture(imageResult);
      }
    } catch (error) {
      const cameraError: CameraError = {
        code: 'CAPTURE_FAILED',
        message: 'Failed to select image from gallery',
        details: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        recoverable: true,
      };
      onError(cameraError);
    }
  }, [onCapture, onError]);

  /**
   * Handle camera ready event
   */
  const handleCameraReady = useCallback(() => {
    analyzeLighting();
    analyzeGuidance();
  }, [analyzeLighting, analyzeGuidance]);

  /**
   * Handle camera error
   */
  const handleCameraError = useCallback((error: any) => {
    const cameraError: CameraError = {
      code: 'CAMERA_UNAVAILABLE',
      message: 'Camera is not available',
      details: error?.message || 'Unknown camera error',
      timestamp: new Date().toISOString(),
      recoverable: true,
      retryAction: initializeCamera,
    };
    onError(cameraError);
  }, [onError, initializeCamera]);

  // Initialize camera on mount
  useEffect(() => {
    initializeCamera();
    
    return () => {
      if (guidanceTimeoutRef.current) {
        clearTimeout(guidanceTimeoutRef.current);
      }
    };
  }, [initializeCamera]);

  // Auto-hide guidance after 5 seconds
  useEffect(() => {
    if (showGuidance && plantGuidance) {
      guidanceTimeoutRef.current = setTimeout(() => {
        setShowGuidance(false);
      }, 5000);
    }
    
    return () => {
      if (guidanceTimeoutRef.current) {
        clearTimeout(guidanceTimeoutRef.current);
      }
    };
  }, [showGuidance, plantGuidance]);

  // Render loading state
  if (cameraState.status === 'initializing' || !cameraState.hasPermission) {
    return (
      <View style={[styles.container, style]}>
        <StatusBar barStyle="light-content" backgroundColor="#000" />
        <View style={styles.loadingContainer} testID="loading-indicator">
          <ActivityIndicator size="large" color="#4CAF50" />
          <Text style={styles.loadingText}>Initializing camera...</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.container, style]}>
      <StatusBar barStyle="light-content" backgroundColor="#000" />
      
      {/* Camera View */}
      <ExpoCamera
        ref={cameraRef}
        style={styles.camera}
        facing={cameraState.config.type}
        flash={cameraState.config.flashMode}
        zoom={zoomLevel / 10}
        onCameraReady={handleCameraReady}
        onMountError={handleCameraError}
        testID="camera-view"
      >
        {/* Focus Guide */}
        <View style={styles.focusGuide} testID="focus-guide">
          <View style={styles.focusCorner} />
          <View style={[styles.focusCorner, styles.focusCornerTopRight]} />
          <View style={[styles.focusCorner, styles.focusCornerBottomLeft]} />
          <View style={[styles.focusCorner, styles.focusCornerBottomRight]} />
        </View>

        {/* Plant Photography Guidance Overlay */}
        {showGuidance && plantGuidance && (
          <View style={styles.guidanceOverlay}>
            <View style={styles.guidanceContainer}>
              <Text style={styles.guidanceTitle}>Plant Photography Tips</Text>
              {plantGuidance.suggestions.map((suggestion, index) => (
                <Text key={index} style={styles.guidanceText}>
                  • {suggestion}
                </Text>
              ))}
              <TouchableOpacity
                style={styles.hideGuidanceButton}
                onPress={() => setShowGuidance(false)}
              >
                <Text style={styles.hideGuidanceText}>Hide</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

        {/* Lighting Analysis Display */}
        {lightingAnalysis && (
          <View style={styles.lightingInfo}>
            <Text style={styles.lightingText}>
              Lighting: {lightingAnalysis.condition}
            </Text>
          </View>
        )}

        {/* Camera Controls */}
        <View style={styles.controlsContainer}>
          {/* Flash Control */}
          <TouchableOpacity style={styles.controlButton} onPress={toggleFlash} testID="flash-button">
            <Text style={styles.controlButtonText}>
              {cameraState.config.flashMode === 'off' ? '⚡' :
               cameraState.config.flashMode === 'auto' ? '⚡A' :
               cameraState.config.flashMode === 'on' ? '⚡ON' : '🔦'}
            </Text>
          </TouchableOpacity>

          {/* Camera Type Toggle */}
          <TouchableOpacity style={styles.controlButton} onPress={toggleCameraType} testID="camera-flip-button">
            <Text style={styles.controlButtonText}>🔄</Text>
          </TouchableOpacity>

          {/* Guidance Toggle */}
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => setShowGuidance(!showGuidance)}
            testID="guidance-toggle"
          >
            <Text style={styles.controlButtonText}>💡</Text>
          </TouchableOpacity>
        </View>

        {/* Bottom Controls */}
        <View style={styles.bottomControls}>
          {/* Gallery Button */}
          <TouchableOpacity
            style={styles.galleryButton}
            onPress={selectFromGallery}
            testID="gallery-button"
          >
            <Text style={styles.galleryButtonText}>📷</Text>
          </TouchableOpacity>

          {/* Capture Button */}
          <TouchableOpacity
            style={[
              styles.captureButton,
              cameraState.isCapturing && styles.captureButtonDisabled
            ]}
            onPress={capturePhoto}
            disabled={cameraState.isCapturing}
            testID="capture-button"
          >
            {cameraState.isCapturing ? (
              <ActivityIndicator size="small" color="#fff" />
            ) : (
              <View style={styles.captureButtonInner} />
            )}
          </TouchableOpacity>

          {/* Zoom Control */}
          <View style={styles.zoomContainer}>
            <Text style={styles.zoomText}>{zoomLevel.toFixed(1)}x</Text>
          </View>
        </View>
      </ExpoCamera>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
  },
  loadingText: {
    color: '#fff',
    fontSize: 16,
    marginTop: 16,
  },
  camera: {
    flex: 1,
  },
  focusGuide: {
    position: 'absolute',
    top: '40%',
    left: '30%',
    width: '40%',
    height: '20%',
  },
  focusCorner: {
    position: 'absolute',
    width: 20,
    height: 20,
    borderTopWidth: 2,
    borderLeftWidth: 2,
    borderColor: '#4CAF50',
    top: 0,
    left: 0,
  },
  focusCornerTopRight: {
    top: 0,
    right: 0,
    left: 'auto',
    borderTopWidth: 2,
    borderRightWidth: 2,
    borderLeftWidth: 0,
  },
  focusCornerBottomLeft: {
    bottom: 0,
    left: 0,
    top: 'auto',
    borderBottomWidth: 2,
    borderLeftWidth: 2,
    borderTopWidth: 0,
  },
  focusCornerBottomRight: {
    bottom: 0,
    right: 0,
    top: 'auto',
    left: 'auto',
    borderBottomWidth: 2,
    borderRightWidth: 2,
    borderTopWidth: 0,
    borderLeftWidth: 0,
  },
  guidanceOverlay: {
    position: 'absolute',
    top: 50,
    left: 20,
    right: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    borderRadius: 8,
    padding: 16,
  },
  guidanceContainer: {
    alignItems: 'flex-start',
  },
  guidanceTitle: {
    color: '#4CAF50',
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  guidanceText: {
    color: '#fff',
    fontSize: 14,
    marginBottom: 4,
  },
  hideGuidanceButton: {
    marginTop: 8,
    paddingHorizontal: 12,
    paddingVertical: 6,
    backgroundColor: '#4CAF50',
    borderRadius: 4,
  },
  hideGuidanceText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  lightingInfo: {
    position: 'absolute',
    top: 20,
    right: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 4,
  },
  lightingText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  controlsContainer: {
    position: 'absolute',
    top: 60,
    left: 20,
    flexDirection: 'column',
  },
  controlButton: {
    width: 50,
    height: 50,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  controlButtonText: {
    color: '#fff',
    fontSize: 20,
  },
  bottomControls: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 40,
  },
  galleryButton: {
    width: 60,
    height: 60,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  galleryButtonText: {
    fontSize: 24,
  },
  captureButton: {
    width: 80,
    height: 80,
    backgroundColor: '#fff',
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 4,
    borderColor: '#4CAF50',
  },
  captureButtonDisabled: {
    opacity: 0.6,
  },
  captureButtonInner: {
    width: 60,
    height: 60,
    backgroundColor: '#4CAF50',
    borderRadius: 30,
  },
  zoomContainer: {
    width: 60,
    height: 60,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  zoomText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
});

export default CameraView;
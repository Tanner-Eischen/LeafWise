/**
 * Camera Module Type Definitions for LeafWise
 * Defines TypeScript interfaces for camera functionality including
 * permission handling, image capture, and processing types
 * Ensures type safety for camera implementation
 */

// ============================================================================
// Permission Types
// ============================================================================

/**
 * Camera permission status enumeration
 */
export type CameraPermissionStatus = 
  | 'granted'
  | 'denied'
  | 'restricted'
  | 'undetermined';

/**
 * Camera permission request result
 */
export interface CameraPermissionResult {
  status: CameraPermissionStatus;
  canAskAgain: boolean;
  expires: 'never' | number;
}

/**
 * Camera permission request options
 */
export interface CameraPermissionOptions {
  showRationale?: boolean;
  rationaleTitle?: string;
  rationaleMessage?: string;
}

// ============================================================================
// Camera Configuration Types
// ============================================================================

/**
 * Camera type enumeration
 */
export type CameraType = 'back' | 'front';

/**
 * Camera flash mode enumeration
 */
export type CameraFlashMode = 'on' | 'off' | 'auto';

/**
 * Camera focus mode enumeration
 */
export type CameraFocusMode = 'auto' | 'manual' | 'continuous';

/**
 * Camera quality settings
 */
export type CameraQuality = 'low' | 'medium' | 'high' | 'ultra';

/**
 * Camera configuration interface
 */
export interface CameraConfig {
  type: CameraType;
  flashMode: CameraFlashMode;
  focusMode: CameraFocusMode;
  quality: CameraQuality;
  enableZoom: boolean;
  maxZoom?: number;
  aspectRatio?: '4:3' | '16:9' | '1:1';
}

// ============================================================================
// Image Types
// ============================================================================

/**
 * Image format enumeration
 */
export type ImageFormat = 'jpeg' | 'png' | 'webp';

/**
 * Image dimensions interface
 */
export interface ImageDimensions {
  width: number;
  height: number;
}

/**
 * Image metadata interface
 */
export interface ImageMetadata {
  format: ImageFormat;
  dimensions: ImageDimensions;
  fileSize: number;
  timestamp: string;
  location?: {
    latitude: number;
    longitude: number;
    altitude?: number;
  };
  exif?: Record<string, unknown>;
}

/**
 * Raw image result from camera capture
 */
export interface ImageResult {
  uri: string;
  base64?: string;
  metadata: ImageMetadata;
  isValid: boolean;
}

/**
 * Processed image with enhancements
 */
export interface ProcessedImage {
  originalUri: string;
  processedUri: string;
  base64?: string;
  metadata: ImageMetadata;
  enhancements: {
    brightness?: number;
    contrast?: number;
    saturation?: number;
    sharpness?: number;
    cropped?: boolean;
    rotated?: number;
  };
  qualityScore: number;
}

// ============================================================================
// Image Processing Types
// ============================================================================

/**
 * Image processing options
 */
export interface ImageProcessingOptions {
  enableAutoEnhancement?: boolean;
  cropToPlant?: boolean;
  adjustLighting?: boolean;
  sharpenImage?: boolean;
  removeBackground?: boolean;
  maxWidth?: number;
  maxHeight?: number;
  compressionQuality?: number;
}

/**
 * Image quality assessment result
 */
export interface ImageQualityAssessment {
  overallScore: number;
  factors: {
    brightness: number;
    contrast: number;
    sharpness: number;
    noise: number;
    blur: number;
  };
  recommendations: string[];
  isAcceptable: boolean;
}

/**
 * Crop area definition
 */
export interface CropArea {
  x: number;
  y: number;
  width: number;
  height: number;
}

// ============================================================================
// Lighting Detection Types
// ============================================================================

/**
 * Lighting condition enumeration
 */
export type LightingCondition = 
  | 'excellent'
  | 'good'
  | 'fair'
  | 'poor'
  | 'very-poor';

/**
 * Lighting analysis result
 */
export interface LightingAnalysis {
  condition: LightingCondition;
  brightness: number;
  contrast: number;
  shadowIntensity: number;
  recommendations: {
    useFlash: boolean;
    adjustPosition: boolean;
    waitForBetterLight: boolean;
    suggestions: string[];
  };
}

// ============================================================================
// Camera State Types
// ============================================================================

/**
 * Camera initialization status
 */
export type CameraStatus = 
  | 'initializing'
  | 'ready'
  | 'capturing'
  | 'processing'
  | 'error'
  | 'unavailable';

/**
 * Camera state interface
 */
export interface CameraState {
  status: CameraStatus;
  isInitialized: boolean;
  hasPermission: boolean;
  config: CameraConfig;
  isCapturing: boolean;
  isProcessing: boolean;
  lastError?: CameraError;
}

// ============================================================================
// Error Types
// ============================================================================

/**
 * Camera error codes
 */
export type CameraErrorCode = 
  | 'PERMISSION_DENIED'
  | 'CAMERA_UNAVAILABLE'
  | 'INITIALIZATION_FAILED'
  | 'CAPTURE_FAILED'
  | 'PROCESSING_FAILED'
  | 'INVALID_CONFIG'
  | 'STORAGE_ERROR'
  | 'NETWORK_ERROR'
  | 'UNKNOWN_ERROR';

/**
 * Camera error interface
 */
export interface CameraError {
  code: CameraErrorCode;
  message: string;
  details?: string;
  timestamp: string;
  recoverable: boolean;
  retryAction?: () => Promise<void>;
}

// ============================================================================
// Camera Service Interface
// ============================================================================

/**
 * Camera capture options
 */
export interface CameraCaptureOptions {
  quality?: CameraQuality;
  includeBase64?: boolean;
  includeExif?: boolean;
  skipProcessing?: boolean;
  processingOptions?: ImageProcessingOptions;
}

/**
 * Camera service interface defining the contract for camera operations
 */
export interface ICameraService {
  /**
   * Initialize the camera service
   */
  initialize(_config?: Partial<CameraConfig>): Promise<void>;

  /**
   * Request camera permissions
   */
  requestPermissions(_options?: CameraPermissionOptions): Promise<CameraPermissionResult>;

  /**
   * Check current camera permissions
   */
  checkPermissions(): Promise<CameraPermissionResult>;

  /**
   * Open camera interface
   */
  openCamera(): Promise<void>;

  /**
   * Captures a photo with the current camera configuration
   * @param options - Optional capture options
   * @returns Promise resolving to captured image data
   */
  capturePhoto(_options?: CameraCaptureOptions): Promise<ImageResult>;

  /**
   * Processes a captured image with specified options
   * @param image - The image to process
   * @param options - Processing options
   * @returns Promise resolving to processed image
   */
  processImage(_image: ImageResult, _options?: ImageProcessingOptions): Promise<ProcessedImage>;

  /**
   * Assess image quality
   */
  assessImageQuality(_image: ImageResult): Promise<ImageQualityAssessment>;

  /**
   * Analyzes lighting conditions for optimal capture
   * @returns Promise resolving to lighting analysis
   */
  analyzeLighting(): Promise<LightingAnalysis>;

  /**
   * Updates camera configuration
   * @param config - New configuration settings
   * @returns Promise resolving when configuration is applied
   */
  updateConfig(_config: Partial<CameraConfig>): Promise<void>;

  /**
   * Get current camera state
   */
  getState(): CameraState;

  /**
   * Cleanup camera resources
   */
  cleanup(): Promise<void>;
}

// ============================================================================
// Event Types
// ============================================================================

/**
 * Camera event types
 */
export type CameraEventType = 
  | 'initialized'
  | 'permission-changed'
  | 'config-updated'
  | 'capture-started'
  | 'capture-completed'
  | 'processing-started'
  | 'processing-completed'
  | 'error-occurred'
  | 'cleanup-completed';

/**
 * Camera event interface
 */
export interface CameraEvent {
  type: CameraEventType;
  timestamp: string;
  data?: unknown;
  error?: CameraError;
}

/**
 * Camera event listener function type
 */
export type CameraEventListener = (_event: CameraEvent) => void;

// ============================================================================
// Utility Types
// ============================================================================

/**
 * Camera capability check result
 */
export interface CameraCapabilities {
  hasCamera: boolean;
  hasFrontCamera: boolean;
  hasBackCamera: boolean;
  hasFlash: boolean;
  hasAutoFocus: boolean;
  hasZoom: boolean;
  supportedFormats: ImageFormat[];
  supportedQualities: CameraQuality[];
  maxResolution: ImageDimensions;
}

/**
 * Plant photography guidance interface
 */
export interface PlantPhotographyGuidance {
  isOptimalDistance: boolean;
  isGoodLighting: boolean;
  isStableHold: boolean;
  isPlantCentered: boolean;
  suggestions: string[];
  confidence: number;
}

// ============================================================================
// Component Props Types
// ============================================================================

/**
 * Camera view component props
 */
export interface CameraViewProps {
  onCapture: (image: ImageResult) => void;
  onError: (error: CameraError) => void;
  initialConfig?: Partial<CameraConfig>;
  style?: object;
}
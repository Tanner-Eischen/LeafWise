"""Image Processing Service for plant analysis using computer vision.

This service provides functionality for processing plant images, segmenting plants
from backgrounds, and extracting measurements using computer vision techniques.
"""

import cv2
import numpy as np
import logging
from typing import Tuple, Optional, Dict, Any, List
from app.schemas.timelapse import PlantMeasurements

logger = logging.getLogger(__name__)


class ImageProcessingService:
    """Service for processing plant images using computer vision."""
    
    def __init__(self):
        """Initialize image processor with OpenCV configurations."""
        self.contour_min_area = 1000  # Minimum contour area for plant detection
        self.blur_kernel_size = 5
        self.canny_lower = 50
        self.canny_upper = 150
    
    def preprocess_image(self, image_path: str) -> Tuple[np.ndarray, np.ndarray]:
        """
        Preprocess image for plant analysis.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Tuple of (original_image, processed_image)
        """
        try:
            # Load image
            image = cv2.imread(image_path)
            if image is None:
                raise ValueError(f"Could not load image from {image_path}")
            
            original = image.copy()
            
            # Convert to RGB for processing
            rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Apply Gaussian blur to reduce noise
            blurred = cv2.GaussianBlur(rgb_image, (self.blur_kernel_size, self.blur_kernel_size), 0)
            
            # Convert to HSV for better plant segmentation
            hsv = cv2.cvtColor(blurred, cv2.COLOR_RGB2HSV)
            
            return original, hsv
            
        except Exception as e:
            logger.error(f"Error preprocessing image {image_path}: {str(e)}")
            raise
    
    def segment_plant(self, hsv_image: np.ndarray) -> np.ndarray:
        """
        Segment plant from background using color-based segmentation.
        
        Args:
            hsv_image: HSV image array
            
        Returns:
            Binary mask of plant regions
        """
        try:
            # Define HSV range for green plants (adjustable)
            lower_green = np.array([35, 40, 40])
            upper_green = np.array([85, 255, 255])
            
            # Create mask for green regions
            green_mask = cv2.inRange(hsv_image, lower_green, upper_green)
            
            # Apply morphological operations to clean up mask
            kernel = np.ones((5, 5), np.uint8)
            green_mask = cv2.morphologyEx(green_mask, cv2.MORPH_CLOSE, kernel)
            green_mask = cv2.morphologyEx(green_mask, cv2.MORPH_OPEN, kernel)
            
            # Fill holes in the mask
            contours, _ = cv2.findContours(green_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            for contour in contours:
                cv2.fillPoly(green_mask, [contour], 255)
            
            return green_mask
            
        except Exception as e:
            logger.error(f"Error segmenting plant: {str(e)}")
            raise
    
    def extract_measurements(self, original_image: np.ndarray, plant_mask: np.ndarray) -> PlantMeasurements:
        """
        Extract plant measurements from segmented image.
        
        Args:
            original_image: Original image array
            plant_mask: Binary mask of plant regions
            
        Returns:
            PlantMeasurements object with extracted data
        """
        try:
            # Find contours of plant regions
            contours, _ = cv2.findContours(plant_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            if not contours:
                logger.warning("No plant contours found in image")
                return PlantMeasurements()
            
            # Get the largest contour (main plant)
            main_contour = max(contours, key=cv2.contourArea)
            
            # Calculate bounding rectangle
            x, y, w, h = cv2.boundingRect(main_contour)
            
            # Calculate measurements (assuming pixel-to-cm conversion factor)
            # This would need calibration in a real implementation
            pixel_to_cm = 0.1  # Placeholder conversion factor
            
            height_cm = h * pixel_to_cm
            width_cm = w * pixel_to_cm
            
            # Calculate area
            contour_area = cv2.contourArea(main_contour)
            leaf_area_cm2 = contour_area * (pixel_to_cm ** 2)
            
            # Estimate leaf count using contour analysis
            leaf_count = self._estimate_leaf_count(original_image, plant_mask)
            
            # Calculate health score based on color analysis
            health_score = self._calculate_health_score(original_image, plant_mask)
            
            return PlantMeasurements(
                height_cm=height_cm,
                width_cm=width_cm,
                leaf_count=leaf_count,
                leaf_area_cm2=leaf_area_cm2,
                health_score=health_score
            )
            
        except Exception as e:
            logger.error(f"Error extracting measurements: {str(e)}")
            return PlantMeasurements()
    
    def _estimate_leaf_count(self, image: np.ndarray, mask: np.ndarray) -> Optional[int]:
        """
        Estimate leaf count using contour analysis.
        
        Args:
            image: Original image array
            mask: Binary mask of plant regions
            
        Returns:
            Estimated leaf count or None if estimation fails
        """
        try:
            # Apply mask to image
            masked_image = cv2.bitwise_and(image, image, mask=mask)
            
            # Convert to grayscale
            gray = cv2.cvtColor(masked_image, cv2.COLOR_BGR2GRAY)
            
            # Apply edge detection
            edges = cv2.Canny(gray, self.canny_lower, self.canny_upper)
            
            # Find contours that might represent leaves
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            # Filter contours by area to get potential leaves
            leaf_contours = [c for c in contours if cv2.contourArea(c) > self.contour_min_area]
            
            return len(leaf_contours)
            
        except Exception as e:
            logger.error(f"Error estimating leaf count: {str(e)}")
            return None
    
    def _calculate_health_score(self, image: np.ndarray, mask: np.ndarray) -> Optional[float]:
        """
        Calculate plant health score based on color analysis.
        
        Args:
            image: Original image array
            mask: Binary mask of plant regions
            
        Returns:
            Health score between 0.0 and 1.0, or None if calculation fails
        """
        try:
            # Apply mask to image
            masked_image = cv2.bitwise_and(image, image, mask=mask)
            
            # Convert to HSV for color analysis
            hsv = cv2.cvtColor(masked_image, cv2.COLOR_BGR2HSV)
            
            # Extract hue values from plant regions
            plant_pixels = hsv[mask > 0]
            
            if len(plant_pixels) == 0:
                return None
            
            # Calculate mean hue and saturation
            mean_hue = np.mean(plant_pixels[:, 0])
            mean_saturation = np.mean(plant_pixels[:, 1])
            mean_value = np.mean(plant_pixels[:, 2])
            
            # Health score based on green color intensity and saturation
            # Healthy plants typically have hue around 60 (green) with good saturation
            hue_score = 1.0 - abs(mean_hue - 60) / 60.0
            saturation_score = mean_saturation / 255.0
            brightness_score = mean_value / 255.0
            
            # Combine scores with weights
            health_score = (hue_score * 0.4 + saturation_score * 0.4 + brightness_score * 0.2)
            
            return max(0.0, min(1.0, health_score))
            
        except Exception as e:
            logger.error(f"Error calculating health score: {str(e)}")
            return None
    
    def detect_plant_features(self, image_path: str) -> Dict[str, Any]:
        """
        Detect plant features from an image.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Dictionary of detected features
        """
        try:
            # Preprocess image
            original, hsv = self.preprocess_image(image_path)
            
            # Segment plant
            plant_mask = self.segment_plant(hsv)
            
            # Extract measurements
            measurements = self.extract_measurements(original, plant_mask)
            
            # Additional feature detection
            features = {
                "measurements": measurements,
                "has_flowers": self._detect_flowers(original, plant_mask),
                "has_fruits": self._detect_fruits(original, plant_mask),
                "has_disease_signs": self._detect_disease_signs(original, plant_mask)
            }
            
            return features
            
        except Exception as e:
            logger.error(f"Error detecting plant features: {str(e)}")
            return {"error": str(e)}
    
    def _detect_flowers(self, image: np.ndarray, mask: np.ndarray) -> bool:
        """
        Detect presence of flowers in plant image.
        
        Args:
            image: Original image array
            mask: Binary mask of plant regions
            
        Returns:
            True if flowers are detected, False otherwise
        """
        try:
            # Convert to HSV
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Define HSV ranges for common flower colors
            color_ranges = [
                # Red flowers
                (np.array([0, 100, 100]), np.array([10, 255, 255])),
                (np.array([160, 100, 100]), np.array([180, 255, 255])),
                # Yellow flowers
                (np.array([20, 100, 100]), np.array([30, 255, 255])),
                # Purple/pink flowers
                (np.array([130, 50, 50]), np.array([170, 255, 255])),
                # White flowers (high value, low saturation)
                (np.array([0, 0, 200]), np.array([180, 30, 255]))
            ]
            
            # Check for each color range
            for lower, upper in color_ranges:
                color_mask = cv2.inRange(hsv, lower, upper)
                color_mask = cv2.bitwise_and(color_mask, mask)
                
                # If significant area of this color is found, likely has flowers
                if np.sum(color_mask) > 5000:
                    return True
            
            return False
            
        except Exception as e:
            logger.error(f"Error detecting flowers: {str(e)}")
            return False
    
    def _detect_fruits(self, image: np.ndarray, mask: np.ndarray) -> bool:
        """
        Detect presence of fruits in plant image.
        
        Args:
            image: Original image array
            mask: Binary mask of plant regions
            
        Returns:
            True if fruits are detected, False otherwise
        """
        # Similar implementation to flower detection but with fruit colors
        # This is a simplified placeholder implementation
        return False
    
    def _detect_disease_signs(self, image: np.ndarray, mask: np.ndarray) -> bool:
        """
        Detect signs of disease in plant image.
        
        Args:
            image: Original image array
            mask: Binary mask of plant regions
            
        Returns:
            True if disease signs are detected, False otherwise
        """
        try:
            # Apply mask to image
            masked_image = cv2.bitwise_and(image, image, mask=mask)
            
            # Convert to HSV for color analysis
            hsv = cv2.cvtColor(masked_image, cv2.COLOR_BGR2HSV)
            
            # Define HSV ranges for common disease indicators
            # Yellow/brown spots
            lower_yellow = np.array([20, 100, 100])
            upper_yellow = np.array([30, 255, 255])
            yellow_mask = cv2.inRange(hsv, lower_yellow, upper_yellow)
            
            # Brown/dead areas
            lower_brown = np.array([10, 50, 50])
            upper_brown = np.array([20, 255, 150])
            brown_mask = cv2.inRange(hsv, lower_brown, upper_brown)
            
            # Combine masks
            disease_mask = cv2.bitwise_or(yellow_mask, brown_mask)
            
            # Calculate percentage of potentially diseased area
            plant_area = np.sum(mask > 0)
            if plant_area == 0:
                return False
                
            disease_area = np.sum(disease_mask > 0)
            disease_percentage = disease_area / plant_area
            
            # If more than 5% of the plant shows disease indicators
            return disease_percentage > 0.05
            
        except Exception as e:
            logger.error(f"Error detecting disease signs: {str(e)}")
            return False
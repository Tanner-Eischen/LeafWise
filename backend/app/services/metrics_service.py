"""Metrics Service for extracting measurements from plant photos.

This service provides functionality for extracting metrics from plant photos,
including leaf area, plant height, and other growth-related measurements.
It leverages computer vision techniques to analyze plant images and extract
quantitative data for growth tracking and analysis.
"""

import logging
from typing import Dict, Any, Optional, List, Tuple
from uuid import UUID
import os
import numpy as np

from app.services.image_processing_service import ImageProcessingService
from app.schemas.timelapse import PlantMeasurements

logger = logging.getLogger(__name__)


class MetricsService:
    """Service for extracting metrics from plant photos."""
    
    def __init__(self):
        """Initialize the metrics service with image processing capabilities."""
        self.image_processor = ImageProcessingService()
    
    def extract_metrics(self, image_path: str) -> PlantMeasurements:
        """Extract metrics from a plant photo.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            PlantMeasurements object containing extracted metrics
        """
        try:
            # Use the image processing service to detect plant features
            features = self.image_processor.detect_plant_features(image_path)
            
            # Extract measurements from features
            measurements = features.get("measurements", PlantMeasurements())
            
            return measurements
        except Exception as e:
            logger.error(f"Error extracting metrics from image {image_path}: {str(e)}")
            return PlantMeasurements()
    
    def calculate_growth_rate(self, 
                             current_metrics: PlantMeasurements, 
                             previous_metrics: PlantMeasurements, 
                             days_between: float) -> Dict[str, float]:
        """Calculate growth rate between two sets of measurements.
        
        Args:
            current_metrics: Current plant measurements
            previous_metrics: Previous plant measurements
            days_between: Number of days between measurements
            
        Returns:
            Dictionary of growth rates for different metrics
        """
        growth_rates = {}
        
        # Calculate height growth rate (cm/day)
        if current_metrics.height_cm is not None and previous_metrics.height_cm is not None:
            height_change = current_metrics.height_cm - previous_metrics.height_cm
            growth_rates["height_cm_per_day"] = height_change / days_between
        
        # Calculate leaf area growth rate (cm²/day)
        if current_metrics.leaf_area_cm2 is not None and previous_metrics.leaf_area_cm2 is not None:
            area_change = current_metrics.leaf_area_cm2 - previous_metrics.leaf_area_cm2
            growth_rates["leaf_area_cm2_per_day"] = area_change / days_between
        
        # Calculate leaf count growth rate (leaves/day)
        if current_metrics.leaf_count is not None and previous_metrics.leaf_count is not None:
            leaf_change = current_metrics.leaf_count - previous_metrics.leaf_count
            growth_rates["leaf_count_per_day"] = leaf_change / days_between
        
        return growth_rates
    
    def detect_growth_milestones(self, 
                               current_metrics: PlantMeasurements, 
                               previous_metrics: PlantMeasurements) -> List[str]:
        """Detect significant growth milestones between measurements.
        
        Args:
            current_metrics: Current plant measurements
            previous_metrics: Previous plant measurements
            
        Returns:
            List of detected milestone descriptions
        """
        milestones = []
        
        # Height milestone (>10% increase)
        if (current_metrics.height_cm is not None and 
            previous_metrics.height_cm is not None and 
            previous_metrics.height_cm > 0):
            height_percent = (current_metrics.height_cm - previous_metrics.height_cm) / previous_metrics.height_cm * 100
            if height_percent >= 10:
                milestones.append(f"Height increased by {height_percent:.1f}%")
        
        # Leaf area milestone (>15% increase)
        if (current_metrics.leaf_area_cm2 is not None and 
            previous_metrics.leaf_area_cm2 is not None and 
            previous_metrics.leaf_area_cm2 > 0):
            area_percent = (current_metrics.leaf_area_cm2 - previous_metrics.leaf_area_cm2) / previous_metrics.leaf_area_cm2 * 100
            if area_percent >= 15:
                milestones.append(f"Leaf area increased by {area_percent:.1f}%")
        
        # New leaves milestone
        if (current_metrics.leaf_count is not None and 
            previous_metrics.leaf_count is not None):
            new_leaves = current_metrics.leaf_count - previous_metrics.leaf_count
            if new_leaves >= 1:
                leaf_text = "leaf" if new_leaves == 1 else "leaves"
                milestones.append(f"Gained {new_leaves} new {leaf_text}")
        
        # Health improvement milestone
        if (current_metrics.health_score is not None and 
            previous_metrics.health_score is not None):
            health_change = current_metrics.health_score - previous_metrics.health_score
            if health_change >= 0.15:  # 15% health improvement
                milestones.append(f"Health improved by {health_change*100:.1f}%")
        
        return milestones
    
    def normalize_metrics(self, metrics: PlantMeasurements, 
                         reference_width: Optional[int] = None, 
                         reference_height: Optional[int] = None) -> PlantMeasurements:
        """Normalize metrics based on reference dimensions.
        
        This is useful when comparing photos taken at different distances or angles.
        
        Args:
            metrics: Plant measurements to normalize
            reference_width: Reference image width (pixels)
            reference_height: Reference image height (pixels)
            
        Returns:
            Normalized plant measurements
        """
        # If no reference dimensions provided, return original metrics
        if reference_width is None or reference_height is None:
            return metrics
        
        # Create a copy of the metrics
        normalized = PlantMeasurements(
            height_cm=metrics.height_cm,
            width_cm=metrics.width_cm,
            leaf_count=metrics.leaf_count,
            branch_count=metrics.branch_count,
            flower_count=metrics.flower_count,
            fruit_count=metrics.fruit_count,
            health_score=metrics.health_score,
            leaf_area_cm2=metrics.leaf_area_cm2,
            stem_thickness_mm=metrics.stem_thickness_mm
        )
        
        # TODO: Implement normalization logic based on reference dimensions
        # This would adjust measurements based on the ratio between the current
        # image dimensions and the reference dimensions
        
        return normalized
    
    def batch_process_images(self, image_paths: List[str]) -> Dict[str, PlantMeasurements]:
        """Process multiple images and extract metrics.
        
        Args:
            image_paths: List of paths to image files
            
        Returns:
            Dictionary mapping image paths to their extracted measurements
        """
        results = {}
        
        for image_path in image_paths:
            try:
                metrics = self.extract_metrics(image_path)
                results[image_path] = metrics
            except Exception as e:
                logger.error(f"Error processing image {image_path}: {str(e)}")
                results[image_path] = PlantMeasurements()
        
        return results
    
    def get_metrics_summary(self, metrics_list: List[PlantMeasurements]) -> Dict[str, Any]:
        """Generate a summary of metrics from multiple measurements.
        
        Args:
            metrics_list: List of plant measurements
            
        Returns:
            Dictionary with summary statistics
        """
        if not metrics_list:
            return {}
        
        summary = {}
        
        # Height statistics
        heights = [m.height_cm for m in metrics_list if m.height_cm is not None]
        if heights:
            summary["height_cm"] = {
                "min": min(heights),
                "max": max(heights),
                "avg": sum(heights) / len(heights),
                "growth": max(heights) - min(heights) if len(heights) > 1 else 0
            }
        
        # Leaf area statistics
        areas = [m.leaf_area_cm2 for m in metrics_list if m.leaf_area_cm2 is not None]
        if areas:
            summary["leaf_area_cm2"] = {
                "min": min(areas),
                "max": max(areas),
                "avg": sum(areas) / len(areas),
                "growth": max(areas) - min(areas) if len(areas) > 1 else 0
            }
        
        # Leaf count statistics
        leaf_counts = [m.leaf_count for m in metrics_list if m.leaf_count is not None]
        if leaf_counts:
            summary["leaf_count"] = {
                "min": min(leaf_counts),
                "max": max(leaf_counts),
                "avg": sum(leaf_counts) / len(leaf_counts),
                "growth": max(leaf_counts) - min(leaf_counts) if len(leaf_counts) > 1 else 0
            }
        
        # Health score statistics
        health_scores = [m.health_score for m in metrics_list if m.health_score is not None]
        if health_scores:
            summary["health_score"] = {
                "min": min(health_scores),
                "max": max(health_scores),
                "avg": sum(health_scores) / len(health_scores),
                "trend": health_scores[-1] - health_scores[0] if len(health_scores) > 1 else 0
            }
        
        return summary
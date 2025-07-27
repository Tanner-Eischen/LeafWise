"""Video Generation Service for creating timelapse videos from plant growth images.

This service provides functionality for generating timelapse videos from
sequences of plant growth images with optional annotations and effects.
"""

import logging
import cv2
import numpy as np
import tempfile
import os
import shutil
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime
from pathlib import Path
import json

logger = logging.getLogger(__name__)


class VideoGenerationService:
    """Service for generating timelapse videos from plant growth images."""
    
    def __init__(self):
        """Initialize video generator with default settings."""
        self.default_fps = 5
        self.default_resolution = (1280, 720)
        self.font = cv2.FONT_HERSHEY_SIMPLEX
        self.font_scale = 0.7
        self.font_color = (255, 255, 255)  # White
        self.line_thickness = 2
    
    def create_timelapse_video(
        self,
        image_paths: List[str],
        output_path: str,
        fps: int = None,
        add_timestamps: bool = True,
        add_measurements: bool = False,
        measurements_data: Optional[List[Dict[str, Any]]] = None
    ) -> bool:
        """
        Create timelapse video from sequence of images.
        
        Args:
            image_paths: List of paths to images
            output_path: Path to save the output video
            fps: Frames per second (default: self.default_fps)
            add_timestamps: Whether to add timestamps to frames
            add_measurements: Whether to add measurement data to frames
            measurements_data: List of measurement data for each frame
            
        Returns:
            True if video creation was successful, False otherwise
        """
        if not image_paths:
            logger.error("No images provided for timelapse video")
            return False
        
        if fps is None:
            fps = self.default_fps
        
        try:
            # Create temporary directory for processed frames
            with tempfile.TemporaryDirectory() as temp_dir:
                processed_frames = []
                
                # Process each image
                for i, img_path in enumerate(image_paths):
                    if not os.path.exists(img_path):
                        logger.warning(f"Image not found: {img_path}")
                        continue
                    
                    # Read image
                    img = cv2.imread(img_path)
                    if img is None:
                        logger.warning(f"Failed to read image: {img_path}")
                        continue
                    
                    # Resize image to standard resolution if needed
                    if img.shape[1] != self.default_resolution[0] or img.shape[0] != self.default_resolution[1]:
                        img = cv2.resize(img, self.default_resolution)
                    
                    # Add annotations
                    timestamp = self._extract_timestamp_from_path(img_path)
                    measurement = measurements_data[i] if measurements_data and i < len(measurements_data) else None
                    
                    if add_timestamps or (add_measurements and measurement):
                        img = self.add_visual_annotations(img, timestamp, measurement if add_measurements else None)
                    
                    # Save processed frame
                    frame_path = os.path.join(temp_dir, f"frame_{i:04d}.jpg")
                    cv2.imwrite(frame_path, img)
                    processed_frames.append(frame_path)
                
                if not processed_frames:
                    logger.error("No valid frames to create video")
                    return False
                
                # Create video from processed frames
                return self._create_video_from_frames(processed_frames, output_path, fps)
                
        except Exception as e:
            logger.error(f"Error creating timelapse video: {str(e)}")
            return False
    
    def add_visual_annotations(
        self,
        image: np.ndarray,
        timestamp: str,
        measurements: Optional[Dict[str, Any]] = None
    ) -> np.ndarray:
        """
        Add timestamp and measurement annotations to image.
        
        Args:
            image: Image array
            timestamp: Timestamp string
            measurements: Optional measurement data
            
        Returns:
            Annotated image
        """
        try:
            # Create a copy of the image
            annotated = image.copy()
            
            # Add semi-transparent overlay at the bottom for better text visibility
            h, w = annotated.shape[:2]
            overlay = annotated.copy()
            cv2.rectangle(overlay, (0, h - 120), (w, h), (0, 0, 0), -1)
            cv2.addWeighted(overlay, 0.5, annotated, 0.5, 0, annotated)
            
            # Add timestamp
            if timestamp:
                cv2.putText(
                    annotated,
                    f"Date: {timestamp}",
                    (20, h - 90),
                    self.font,
                    self.font_scale,
                    self.font_color,
                    self.line_thickness
                )
            
            # Add measurements if provided
            if measurements:
                y_pos = h - 60
                
                # Add height
                if measurements.get('height_cm') is not None:
                    cv2.putText(
                        annotated,
                        f"Height: {measurements['height_cm']:.1f} cm",
                        (20, y_pos),
                        self.font,
                        self.font_scale,
                        self.font_color,
                        self.line_thickness
                    )
                    y_pos += 30
                
                # Add leaf count
                if measurements.get('leaf_count') is not None:
                    cv2.putText(
                        annotated,
                        f"Leaves: {measurements['leaf_count']}",
                        (20, y_pos),
                        self.font,
                        self.font_scale,
                        self.font_color,
                        self.line_thickness
                    )
                    y_pos += 30
                
                # Add health score
                if measurements.get('health_score') is not None:
                    health_score = measurements['health_score']
                    health_text = f"Health: {health_score:.2f}"
                    
                    # Color-code health score
                    if health_score >= 0.8:
                        health_color = (0, 255, 0)  # Green for good health
                    elif health_score >= 0.6:
                        health_color = (0, 255, 255)  # Yellow for moderate health
                    else:
                        health_color = (0, 0, 255)  # Red for poor health
                    
                    cv2.putText(
                        annotated,
                        health_text,
                        (20, y_pos),
                        self.font,
                        self.font_scale,
                        health_color,
                        self.line_thickness
                    )
            
            return annotated
            
        except Exception as e:
            logger.error(f"Error adding visual annotations: {str(e)}")
            return image
    
    def _extract_timestamp_from_path(self, image_path: str) -> str:
        """
        Extract timestamp from image path or file metadata.
        
        Args:
            image_path: Path to image file
            
        Returns:
            Timestamp string
        """
        try:
            # Try to extract date from filename (assuming format like YYYY-MM-DD_HH-MM-SS)
            filename = os.path.basename(image_path)
            
            # Look for date pattern in filename
            import re
            date_match = re.search(r'(\d{4}-\d{2}-\d{2})', filename)
            if date_match:
                return date_match.group(1)
            
            # If not found in filename, use file creation date
            file_time = os.path.getctime(image_path)
            return datetime.fromtimestamp(file_time).strftime('%Y-%m-%d')
            
        except Exception as e:
            logger.error(f"Error extracting timestamp: {str(e)}")
            return "Unknown Date"
    
    def _create_video_from_frames(
        self,
        frame_paths: List[str],
        output_path: str,
        fps: int
    ) -> bool:
        """
        Create video from a list of frame image paths.
        
        Args:
            frame_paths: List of paths to frame images
            output_path: Path to save the output video
            fps: Frames per second
            
        Returns:
            True if video creation was successful, False otherwise
        """
        try:
            # Ensure output directory exists
            os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
            
            # Get frame dimensions from first frame
            first_frame = cv2.imread(frame_paths[0])
            if first_frame is None:
                logger.error(f"Failed to read first frame: {frame_paths[0]}")
                return False
                
            h, w = first_frame.shape[:2]
            
            # Initialize video writer
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # MP4 codec
            video_writer = cv2.VideoWriter(output_path, fourcc, fps, (w, h))
            
            if not video_writer.isOpened():
                logger.error(f"Failed to open video writer for {output_path}")
                return False
            
            # Add frames to video
            for frame_path in frame_paths:
                frame = cv2.imread(frame_path)
                if frame is not None:
                    video_writer.write(frame)
            
            # Release video writer
            video_writer.release()
            
            logger.info(f"Timelapse video created successfully: {output_path}")
            return True
            
        except Exception as e:
            logger.error(f"Error creating video from frames: {str(e)}")
            return False
    
    def create_enhanced_timelapse(
        self,
        image_paths: List[str],
        output_path: str,
        measurements_data: Optional[List[Dict[str, Any]]] = None,
        transition_effect: str = "fade",
        add_intro: bool = True,
        add_outro: bool = True,
        title: str = "Plant Growth Timelapse"
    ) -> bool:
        """
        Create enhanced timelapse video with effects and transitions.
        
        Args:
            image_paths: List of paths to images
            output_path: Path to save the output video
            measurements_data: List of measurement data for each frame
            transition_effect: Type of transition effect between frames
            add_intro: Whether to add intro slide
            add_outro: Whether to add outro slide
            title: Title for the timelapse video
            
        Returns:
            True if video creation was successful, False otherwise
        """
        if not image_paths:
            logger.error("No images provided for timelapse video")
            return False
        
        try:
            # Create temporary directory for processed frames
            with tempfile.TemporaryDirectory() as temp_dir:
                processed_frames = []
                frame_index = 0
                
                # Add intro slide if requested
                if add_intro:
                    intro_frames = self._create_intro_frames(title, 30)  # 30 frames for intro
                    for i, frame in enumerate(intro_frames):
                        frame_path = os.path.join(temp_dir, f"frame_{frame_index:04d}.jpg")
                        cv2.imwrite(frame_path, frame)
                        processed_frames.append(frame_path)
                        frame_index += 1
                
                # Process each image
                for i, img_path in enumerate(image_paths):
                    if not os.path.exists(img_path):
                        logger.warning(f"Image not found: {img_path}")
                        continue
                    
                    # Read image
                    img = cv2.imread(img_path)
                    if img is None:
                        logger.warning(f"Failed to read image: {img_path}")
                        continue
                    
                    # Resize image to standard resolution if needed
                    if img.shape[1] != self.default_resolution[0] or img.shape[0] != self.default_resolution[1]:
                        img = cv2.resize(img, self.default_resolution)
                    
                    # Add annotations
                    timestamp = self._extract_timestamp_from_path(img_path)
                    measurement = measurements_data[i] if measurements_data and i < len(measurements_data) else None
                    img = self.add_visual_annotations(img, timestamp, measurement)
                    
                    # Add transition frames if not the first image
                    if i > 0 and transition_effect == "fade" and len(processed_frames) > 0:
                        prev_img = cv2.imread(processed_frames[-1])
                        transition_frames = self._create_fade_transition(prev_img, img, 5)  # 5 frames for transition
                        
                        for j, frame in enumerate(transition_frames):
                            frame_path = os.path.join(temp_dir, f"frame_{frame_index:04d}.jpg")
                            cv2.imwrite(frame_path, frame)
                            processed_frames.append(frame_path)
                            frame_index += 1
                    
                    # Save processed frame
                    frame_path = os.path.join(temp_dir, f"frame_{frame_index:04d}.jpg")
                    cv2.imwrite(frame_path, img)
                    processed_frames.append(frame_path)
                    frame_index += 1
                
                # Add outro slide if requested
                if add_outro:
                    outro_frames = self._create_outro_frames(30)  # 30 frames for outro
                    for i, frame in enumerate(outro_frames):
                        frame_path = os.path.join(temp_dir, f"frame_{frame_index:04d}.jpg")
                        cv2.imwrite(frame_path, frame)
                        processed_frames.append(frame_path)
                        frame_index += 1
                
                if not processed_frames:
                    logger.error("No valid frames to create video")
                    return False
                
                # Create video from processed frames
                return self._create_video_from_frames(processed_frames, output_path, self.default_fps)
                
        except Exception as e:
            logger.error(f"Error creating enhanced timelapse: {str(e)}")
            return False
    
    def _create_intro_frames(self, title: str, num_frames: int) -> List[np.ndarray]:
        """
        Create intro frames with title animation.
        
        Args:
            title: Title text
            num_frames: Number of frames to generate
            
        Returns:
            List of frame images
        """
        frames = []
        
        try:
            for i in range(num_frames):
                # Create blank frame
                frame = np.zeros((self.default_resolution[1], self.default_resolution[0], 3), dtype=np.uint8)
                
                # Calculate fade-in opacity
                opacity = min(1.0, i / (num_frames * 0.5))
                
                # Add title with fade-in effect
                font_scale = 1.5
                text_size = cv2.getTextSize(title, self.font, font_scale, 2)[0]
                text_x = (frame.shape[1] - text_size[0]) // 2
                text_y = (frame.shape[0] + text_size[1]) // 2
                
                # Draw text with opacity
                cv2.putText(
                    frame,
                    title,
                    (text_x, text_y),
                    self.font,
                    font_scale,
                    (int(255 * opacity), int(255 * opacity), int(255 * opacity)),
                    2
                )
                
                frames.append(frame)
                
            return frames
            
        except Exception as e:
            logger.error(f"Error creating intro frames: {str(e)}")
            return [np.zeros((self.default_resolution[1], self.default_resolution[0], 3), dtype=np.uint8)]
    
    def _create_outro_frames(self, num_frames: int) -> List[np.ndarray]:
        """
        Create outro frames with fade-out effect.
        
        Args:
            num_frames: Number of frames to generate
            
        Returns:
            List of frame images
        """
        frames = []
        
        try:
            for i in range(num_frames):
                # Create blank frame
                frame = np.zeros((self.default_resolution[1], self.default_resolution[0], 3), dtype=np.uint8)
                
                # Calculate fade-out opacity
                opacity = 1.0 - min(1.0, i / (num_frames * 0.8))
                
                # Add text with fade-out effect
                text = "End of Timelapse"
                font_scale = 1.2
                text_size = cv2.getTextSize(text, self.font, font_scale, 2)[0]
                text_x = (frame.shape[1] - text_size[0]) // 2
                text_y = (frame.shape[0] + text_size[1]) // 2
                
                # Draw text with opacity
                cv2.putText(
                    frame,
                    text,
                    (text_x, text_y),
                    self.font,
                    font_scale,
                    (int(255 * opacity), int(255 * opacity), int(255 * opacity)),
                    2
                )
                
                frames.append(frame)
                
            return frames
            
        except Exception as e:
            logger.error(f"Error creating outro frames: {str(e)}")
            return [np.zeros((self.default_resolution[1], self.default_resolution[0], 3), dtype=np.uint8)]
    
    def _create_fade_transition(
        self,
        from_frame: np.ndarray,
        to_frame: np.ndarray,
        num_frames: int
    ) -> List[np.ndarray]:
        """
        Create fade transition between two frames.
        
        Args:
            from_frame: Starting frame
            to_frame: Ending frame
            num_frames: Number of transition frames
            
        Returns:
            List of transition frames
        """
        frames = []
        
        try:
            for i in range(num_frames):
                # Calculate blend factor
                alpha = (i + 1) / (num_frames + 1)
                
                # Blend frames
                blended = cv2.addWeighted(from_frame, 1 - alpha, to_frame, alpha, 0)
                frames.append(blended)
                
            return frames
            
        except Exception as e:
            logger.error(f"Error creating fade transition: {str(e)}")
            return []
"""Time-lapse Growth Tracking Service.

This service implements automated photo capture scheduling, growth analysis,
and timelapse video generation using specialized services for image processing,
growth analysis, and video generation.
"""

import logging
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple, Union
from uuid import UUID, uuid4
from pathlib import Path
import aiofiles
import json
import os
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant
from app.schemas.timelapse import (
    TimelapseSessionCreate,
    TimelapseSessionUpdate,
    TimelapseSessionResponse,
    GrowthPhotoCreate,
    GrowthPhotoResponse,
    GrowthAnalysis,
    PlantMeasurements,
    HealthIndicators,
    GrowthChanges,
    AnomalyFlag,
    TrackingConfig,
    PhotoSchedule,
    ProcessingStatus,
    TrackingStatus,
    MilestoneType,
    DetectionMethod
)
from app.services.file_service import FileService
from app.services.image_processing_service import ImageProcessingService
from app.services.growth_analysis_service import GrowthAnalysisService
from app.services.video_generation_service import VideoGenerationService

logger = logging.getLogger(__name__)


class TimelapseService:
    """Service for managing time-lapse growth tracking sessions."""
    
    def __init__(self, file_service: FileService):
        """Initialize timelapse service."""
        self.file_service = file_service
        self.image_processor = ImageProcessingService()
        self.growth_analyzer = GrowthAnalysisService()
        self.video_generator = VideoGenerationService()
    
    async def initialize_tracking(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_data: TimelapseSessionCreate
    ) -> TimelapseSessionResponse:
        """
        Initialize a new time-lapse tracking session.
        
        Args:
            db: Database session
            user_id: ID of the user creating the session
            session_data: Session configuration data
            
        Returns:
            Created session response
        """
        try:
            # Verify plant ownership
            plant_query = select(UserPlant).where(
                and_(UserPlant.id == session_data.plant_id, UserPlant.user_id == user_id)
            )
            plant_result = await db.execute(plant_query)
            plant = plant_result.scalar_one_or_none()
            
            if not plant:
                raise ValueError("Plant not found or not owned by user")
            
            # Create tracking session
            tracking_session = TimelapseSession(
                id=uuid4(),
                user_id=user_id,
                plant_id=session_data.plant_id,
                name=session_data.name,
                description=session_data.description,
                start_date=datetime.utcnow(),
                status=TrackingStatus.active,
                config=session_data.config.dict() if session_data.config else {},
                photo_schedule=session_data.photo_schedule.dict() if session_data.photo_schedule else {}
            )
            
            db.add(tracking_session)
            await db.commit()
            await db.refresh(tracking_session)
            
            # Create response
            return TimelapseSessionResponse(
                id=str(tracking_session.id),
                user_id=str(tracking_session.user_id),
                plant_id=str(tracking_session.plant_id),
                name=tracking_session.name,
                description=tracking_session.description,
                start_date=tracking_session.start_date,
                end_date=tracking_session.end_date,
                status=tracking_session.status,
                config=TrackingConfig(**tracking_session.config) if tracking_session.config else None,
                photo_schedule=PhotoSchedule(**tracking_session.photo_schedule) if tracking_session.photo_schedule else None,
                photo_count=0,
                last_photo_date=None,
                created_at=tracking_session.created_at,
                updated_at=tracking_session.updated_at
            )
            
        except Exception as e:
            logger.error(f"Error initializing tracking session: {str(e)}")
            await db.rollback()
            raise
    
    async def add_growth_photo(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_id: UUID,
        photo_data: GrowthPhotoCreate
    ) -> GrowthPhotoResponse:
        """
        Add a new growth photo to a tracking session.
        
        Args:
            db: Database session
            user_id: ID of the user adding the photo
            session_id: ID of the tracking session
            photo_data: Photo data
            
        Returns:
            Created photo response
        """
        try:
            # Verify session ownership
            session_query = select(TimelapseSession).where(
                and_(TimelapseSession.id == session_id, TimelapseSession.user_id == user_id)
            )
            session_result = await db.execute(session_query)
            session = session_result.scalar_one_or_none()
            
            if not session:
                raise ValueError("Tracking session not found or not owned by user")
            
            # Process the photo and extract measurements
            photo_path = photo_data.photo_path
            
            # Use image processing service to extract measurements
            measurements = await self._process_photo_measurements(photo_path)
            
            # Create growth photo record
            growth_photo = GrowthPhoto(
                id=uuid4(),
                session_id=session_id,
                photo_path=photo_path,
                capture_date=photo_data.capture_date or datetime.utcnow(),
                notes=photo_data.notes,
                measurements=measurements.dict(),
                processing_status=ProcessingStatus.completed
            )
            
            db.add(growth_photo)
            
            # Update session last photo date
            session.last_photo_date = growth_photo.capture_date
            session.updated_at = datetime.utcnow()
            
            await db.commit()
            await db.refresh(growth_photo)
            
            # Analyze growth and detect milestones
            await self._analyze_growth_and_detect_milestones(db, session, growth_photo)
            
            # Create response
            return GrowthPhotoResponse(
                id=str(growth_photo.id),
                session_id=str(growth_photo.session_id),
                photo_path=growth_photo.photo_path,
                capture_date=growth_photo.capture_date,
                notes=growth_photo.notes,
                measurements=PlantMeasurements(**growth_photo.measurements) if growth_photo.measurements else None,
                processing_status=growth_photo.processing_status,
                created_at=growth_photo.created_at,
                updated_at=growth_photo.updated_at
            )
            
        except Exception as e:
            logger.error(f"Error adding growth photo: {str(e)}")
            await db.rollback()
            raise
    
    async def _process_photo_measurements(self, photo_path: str) -> PlantMeasurements:
        """
        Process photo and extract plant measurements.
        
        Args:
            photo_path: Path to the photo file
            
        Returns:
            Extracted plant measurements
        """
        try:
            # Check if file exists
            if not os.path.exists(photo_path):
                logger.error(f"Photo file not found: {photo_path}")
                return PlantMeasurements()
            
            # Use image processing service to extract measurements
            original, hsv = self.image_processor.preprocess_image(photo_path)
            plant_mask = self.image_processor.segment_plant(hsv)
            measurements = self.image_processor.extract_measurements(original, plant_mask)
            
            return measurements
            
        except Exception as e:
            logger.error(f"Error processing photo measurements: {str(e)}")
            return PlantMeasurements()
    
    async def _analyze_growth_and_detect_milestones(
        self,
        db: AsyncSession,
        session: TimelapseSession,
        current_photo: GrowthPhoto
    ) -> None:
        """
        Analyze growth and detect milestones.
        
        Args:
            db: Database session
            session: Tracking session
            current_photo: Current growth photo
        """
        try:
            # Get previous photos for comparison
            photos_query = select(GrowthPhoto).where(
                and_(
                    GrowthPhoto.session_id == session.id,
                    GrowthPhoto.id != current_photo.id
                )
            ).order_by(desc(GrowthPhoto.capture_date))
            
            photos_result = await db.execute(photos_query)
            previous_photos = photos_result.scalars().all()
            
            if not previous_photos:
                # First photo, no comparison needed
                return
            
            # Get previous measurements
            previous_photo = previous_photos[0]
            previous_measurements = PlantMeasurements(**previous_photo.measurements) if previous_photo.measurements else None
            current_measurements = PlantMeasurements(**current_photo.measurements) if current_photo.measurements else None
            
            if not previous_measurements or not current_measurements:
                return
            
            # Get all measurements history
            measurements_history = [
                {**photo.measurements, "capture_date": photo.capture_date.isoformat()}
                for photo in [current_photo] + previous_photos
                if photo.measurements
            ]
            
            # Use growth analyzer to detect milestones
            milestone_targets = session.config.get("milestone_targets", []) if session.config else []
            
            detected_milestones = self.growth_analyzer.detect_milestones(
                current_measurements,
                previous_measurements,
                measurements_history,
                milestone_targets
            )
            
            # Save detected milestones
            for milestone_data in detected_milestones:
                milestone = GrowthMilestone(
                    id=uuid4(),
                    session_id=session.id,
                    photo_id=current_photo.id,
                    milestone_type=milestone_data.get("milestone_type", "custom"),
                    name=milestone_data.get("milestone_name", "Milestone"),
                    description=milestone_data.get("description", ""),
                    achievement_date=datetime.fromisoformat(milestone_data.get("achievement_date")) 
                        if milestone_data.get("achievement_date") else datetime.utcnow(),
                    detection_method=milestone_data.get("detection_method", "automatic"),
                    confidence_score=milestone_data.get("confidence_score", 0.5),
                    metadata=milestone_data
                )
                
                db.add(milestone)
            
            # Detect anomalies
            anomalies = self.growth_analyzer.detect_anomalies(current_measurements, previous_measurements)
            
            # Save anomalies as metadata in the current photo
            if anomalies:
                current_photo.metadata = current_photo.metadata or {}
                current_photo.metadata["anomalies"] = [anomaly.dict() for anomaly in anomalies]
                current_photo.updated_at = datetime.utcnow()
            
            await db.commit()
            
        except Exception as e:
            logger.error(f"Error analyzing growth and detecting milestones: {str(e)}")
    
    async def get_growth_analysis(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_id: UUID
    ) -> GrowthAnalysis:
        """
        Get growth analysis for a tracking session.
        
        Args:
            db: Database session
            user_id: ID of the user
            session_id: ID of the tracking session
            
        Returns:
            Growth analysis data
        """
        try:
            # Verify session ownership
            session_query = select(TimelapseSession).where(
                and_(TimelapseSession.id == session_id, TimelapseSession.user_id == user_id)
            )
            session_result = await db.execute(session_query)
            session = session_result.scalar_one_or_none()
            
            if not session:
                raise ValueError("Tracking session not found or not owned by user")
            
            # Get photos for analysis
            photos_query = select(GrowthPhoto).where(
                GrowthPhoto.session_id == session_id
            ).order_by(GrowthPhoto.capture_date)
            
            photos_result = await db.execute(photos_query)
            photos = photos_result.scalars().all()
            
            if not photos:
                return GrowthAnalysis(
                    session_id=str(session_id),
                    plant_id=str(session.plant_id),
                    analysis_date=datetime.utcnow(),
                    growth_rates={},
                    health_indicators=HealthIndicators(),
                    growth_changes=GrowthChanges(),
                    anomalies=[],
                    confidence_score=0.0
                )
            
            # Extract measurements history
            measurements_history = [
                {**photo.measurements, "capture_date": photo.capture_date.isoformat()}
                for photo in photos
                if photo.measurements
            ]
            
            if not measurements_history:
                return GrowthAnalysis(
                    session_id=str(session_id),
                    plant_id=str(session.plant_id),
                    analysis_date=datetime.utcnow(),
                    growth_rates={},
                    health_indicators=HealthIndicators(),
                    growth_changes=GrowthChanges(),
                    anomalies=[],
                    confidence_score=0.0
                )
            
            # Calculate growth rates
            growth_rates = self.growth_analyzer.calculate_growth_rate(measurements_history)
            
            # Detect growth patterns
            growth_patterns = self.growth_analyzer.detect_growth_patterns(measurements_history)
            
            # Extract health indicators
            health_indicators = HealthIndicators(
                current_health_score=measurements_history[0].get("health_score", 0.0),
                health_trend=growth_patterns.get("health_trend", {}).get("trend", "stable"),
                health_trend_confidence=growth_patterns.get("health_trend", {}).get("confidence", "low")
            )
            
            # Extract growth changes
            first_measurement = measurements_history[-1]  # Oldest
            latest_measurement = measurements_history[0]  # Newest
            
            height_change = latest_measurement.get("height_cm", 0) - first_measurement.get("height_cm", 0)
            width_change = latest_measurement.get("width_cm", 0) - first_measurement.get("width_cm", 0)
            leaf_count_change = latest_measurement.get("leaf_count", 0) - first_measurement.get("leaf_count", 0)
            
            growth_changes = GrowthChanges(
                height_change_cm=height_change,
                width_change_cm=width_change,
                leaf_count_change=leaf_count_change,
                growth_phase=growth_patterns.get("growth_phase", "unknown"),
                growth_consistency=growth_patterns.get("growth_consistency", 0.0)
            )
            
            # Get anomalies
            anomalies = []
            for photo in photos:
                if photo.metadata and photo.metadata.get("anomalies"):
                    for anomaly_data in photo.metadata["anomalies"]:
                        anomalies.append(AnomalyFlag(**anomaly_data))
            
            # Calculate confidence score
            confidence_score = 0.5  # Base confidence
            if len(measurements_history) >= 5:
                confidence_score += 0.2  # More data points increase confidence
            if growth_patterns.get("growth_consistency", 0.0) > 0.7:
                confidence_score += 0.2  # Consistent growth increases confidence
            
            return GrowthAnalysis(
                session_id=str(session_id),
                plant_id=str(session.plant_id),
                analysis_date=datetime.utcnow(),
                growth_rates=growth_rates,
                health_indicators=health_indicators,
                growth_changes=growth_changes,
                anomalies=anomalies,
                confidence_score=min(0.95, confidence_score)
            )
            
        except Exception as e:
            logger.error(f"Error getting growth analysis: {str(e)}")
            raise
    
    async def generate_timelapse_video(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_id: UUID,
        output_path: Optional[str] = None,
        fps: int = 5,
        add_measurements: bool = True
    ) -> str:
        """
        Generate timelapse video from tracking session photos.
        
        Args:
            db: Database session
            user_id: ID of the user
            session_id: ID of the tracking session
            output_path: Path to save the output video (optional)
            fps: Frames per second
            add_measurements: Whether to add measurement data to frames
            
        Returns:
            Path to the generated video
        """
        try:
            # Verify session ownership
            session_query = select(TimelapseSession).where(
                and_(TimelapseSession.id == session_id, TimelapseSession.user_id == user_id)
            )
            session_result = await db.execute(session_query)
            session = session_result.scalar_one_or_none()
            
            if not session:
                raise ValueError("Tracking session not found or not owned by user")
            
            # Get photos for video
            photos_query = select(GrowthPhoto).where(
                GrowthPhoto.session_id == session_id
            ).order_by(GrowthPhoto.capture_date)
            
            photos_result = await db.execute(photos_query)
            photos = photos_result.scalars().all()
            
            if not photos:
                raise ValueError("No photos found for timelapse video")
            
            # Prepare output path
            if not output_path:
                videos_dir = Path("data/videos")
                videos_dir.mkdir(parents=True, exist_ok=True)
                output_path = str(videos_dir / f"timelapse_{session_id}_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.mp4")
            
            # Prepare image paths and measurements
            image_paths = [photo.photo_path for photo in photos]
            measurements_data = [photo.measurements for photo in photos] if add_measurements else None
            
            # Generate video using video generation service
            success = self.video_generator.create_timelapse_video(
                image_paths=image_paths,
                output_path=output_path,
                fps=fps,
                add_timestamps=True,
                add_measurements=add_measurements,
                measurements_data=measurements_data
            )
            
            if not success:
                raise ValueError("Failed to generate timelapse video")
            
            # Update session with video path
            session.metadata = session.metadata or {}
            session.metadata["timelapse_videos"] = session.metadata.get("timelapse_videos", []) + [
                {
                    "path": output_path,
                    "created_at": datetime.utcnow().isoformat(),
                    "fps": fps,
                    "photo_count": len(photos)
                }
            ]
            session.updated_at = datetime.utcnow()
            
            await db.commit()
            
            return output_path
            
        except Exception as e:
            logger.error(f"Error generating timelapse video: {str(e)}")
            raise
    
    async def get_session_milestones(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_id: UUID
    ) -> List[Dict[str, Any]]:
        """
        Get milestones for a tracking session.
        
        Args:
            db: Database session
            user_id: ID of the user
            session_id: ID of the tracking session
            
        Returns:
            List of milestone data
        """
        try:
            # Verify session ownership
            session_query = select(TimelapseSession).where(
                and_(TimelapseSession.id == session_id, TimelapseSession.user_id == user_id)
            )
            session_result = await db.execute(session_query)
            session = session_result.scalar_one_or_none()
            
            if not session:
                raise ValueError("Tracking session not found or not owned by user")
            
            # Get milestones
            milestones_query = select(GrowthMilestone).where(
                GrowthMilestone.session_id == session_id
            ).order_by(desc(GrowthMilestone.achievement_date))
            
            milestones_result = await db.execute(milestones_query)
            milestones = milestones_result.scalars().all()
            
            # Format milestone data
            milestone_data = []
            for milestone in milestones:
                data = {
                    "id": str(milestone.id),
                    "session_id": str(milestone.session_id),
                    "photo_id": str(milestone.photo_id) if milestone.photo_id else None,
                    "milestone_type": milestone.milestone_type,
                    "name": milestone.name,
                    "description": milestone.description,
                    "achievement_date": milestone.achievement_date.isoformat(),
                    "detection_method": milestone.detection_method,
                    "confidence_score": milestone.confidence_score,
                    "created_at": milestone.created_at.isoformat()
                }
                
                if milestone.metadata:
                    data.update(milestone.metadata)
                
                milestone_data.append(data)
            
            return milestone_data
            
        except Exception as e:
            logger.error(f"Error getting session milestones: {str(e)}")
            raise
    
    async def predict_future_growth(
        self,
        db: AsyncSession,
        user_id: UUID,
        session_id: UUID,
        prediction_days: int = 30
    ) -> Dict[str, Any]:
        """
        Predict future growth based on historical measurements.
        
        Args:
            db: Database session
            user_id: ID of the user
            session_id: ID of the tracking session
            prediction_days: Number of days to predict into the future
            
        Returns:
            Dictionary with growth predictions
        """
        try:
            # Verify session ownership
            session_query = select(TimelapseSession).where(
                and_(TimelapseSession.id == session_id, TimelapseSession.user_id == user_id)
            )
            session_result = await db.execute(session_query)
            session = session_result.scalar_one_or_none()
            
            if not session:
                raise ValueError("Tracking session not found or not owned by user")
            
            # Get photos for analysis
            photos_query = select(GrowthPhoto).where(
                GrowthPhoto.session_id == session_id
            ).order_by(GrowthPhoto.capture_date)
            
            photos_result = await db.execute(photos_query)
            photos = photos_result.scalars().all()
            
            if len(photos) < 3:
                return {
                    "status": "insufficient_data",
                    "message": "At least 3 photos are required for growth prediction"
                }
            
            # Extract measurements history
            measurements_history = [
                {**photo.measurements, "capture_date": photo.capture_date.isoformat()}
                for photo in photos
                if photo.measurements
            ]
            
            if len(measurements_history) < 3:
                return {
                    "status": "insufficient_data",
                    "message": "At least 3 measurements are required for growth prediction"
                }
            
            # Use growth analyzer to predict future growth
            prediction_result = self.growth_analyzer.predict_future_growth(
                measurements_history,
                prediction_days
            )
            
            return prediction_result
            
        except Exception as e:
            logger.error(f"Error predicting future growth: {str(e)}")
            return {"status": "error", "message": str(e)}
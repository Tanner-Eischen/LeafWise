"""Telemetry API endpoints for sensor data collection.

This module provides endpoints for collecting and retrieving sensor telemetry data
including light readings and growth photos."""

from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
from uuid import UUID, uuid4
import json

from fastapi import APIRouter, Depends, HTTPException, status, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import desc, and_, select

from app.models.user_plant import UserPlant

from app.core.database import get_db
from app.models.light_reading import LightReading, LightSource
from app.models.growth_photo import GrowthPhoto
from app.schemas.telemetry import (
    LightReadingCreate, 
    LightReadingResponse, 
    BatchLightReadingRequest, 
    GrowthPhotoCreate, 
    GrowthPhotoResponse,
    TelemetryBatchRequest,
    TelemetryBatchResponse,
    TelemetrySyncStatus
)
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.services.file_service import upload_media_file
from app.services.image_processing_service import ImageProcessingService
from app.services.telemetry_service import TelemetryService
from app.services.metrics_service import MetricsService
from app.schemas.timelapse import PlantMeasurements

router = APIRouter()

@router.get("/telemetry-summary", response_model=Dict[str, Any])
async def get_telemetry_summary(
    plant_id: UUID,
    days: int = Query(30, ge=1, le=90, description="Number of days to include in summary"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get a comprehensive telemetry summary for a plant.
    
    This endpoint combines light readings and growth photo data to provide
    a complete picture of the plant's growth and environment over time.
    
    Args:
        plant_id: Plant ID to get summary for
        days: Number of days to include in summary
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Dictionary with combined telemetry data including light statistics,
        growth metrics, and trend analysis
        
    Raises:
        HTTPException: If plant not found or not owned by user
    """
    # Check if plant exists and belongs to user
    plant_query = select(UserPlant).where(
        and_(
            UserPlant.id == plant_id,
            UserPlant.user_id == current_user.id
        )
    )
    result = await db.execute(plant_query)
    plant = result.scalars().first()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found"
        )
    
    # Use the telemetry service to get the combined summary
    telemetry_service = TelemetryService(db)
    summary = await telemetry_service.get_telemetry_summary(
        user_id=current_user.id,
        plant_id=plant_id,
        days=days
    )
    
    return summary





@router.get("/sync-status", response_model=List[TelemetrySyncStatus])
async def get_sync_status(
    session_id: Optional[UUID] = Query(None, description="Filter by session ID"),
    item_type: Optional[str] = Query(None, description="Filter by item type (light_reading, growth_photo, batch)"),
    sync_status: Optional[str] = Query(None, description="Filter by sync status (pending, synced, failed, conflict)"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get synchronization status for telemetry items.
    
    This endpoint allows clients to track the synchronization state of their
    telemetry data, particularly useful for offline synchronization scenarios.
    
    Args:
        session_id: Optional session ID to filter results
        item_type: Optional item type filter (light_reading, growth_photo, batch)
        sync_status: Optional sync status filter (pending, synced, failed, conflict)
        skip: Number of records to skip (pagination)
        limit: Maximum number of records to return (pagination)
        db: Database session
        current_user: Authenticated user
        
    Returns:
        List of sync status records matching the filters
        
    Raises:
        HTTPException: If validation fails
    """
    # Validate item_type if provided
    if item_type and item_type not in {"light_reading", "growth_photo", "batch"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="item_type must be one of: light_reading, growth_photo, batch"
        )
    
    # Validate sync_status if provided
    if sync_status and sync_status not in {"pending", "in_progress", "synced", "failed", "conflict", "cancelled"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sync_status must be one of: pending, in_progress, synced, failed, conflict, cancelled"
        )
    
    # Use the telemetry service to get sync statuses
    telemetry_service = TelemetryService(db)
    
    try:
        # Build query filters
        filters = {"user_id": current_user.id}
        if session_id:
            filters["session_id"] = session_id
        if item_type:
            filters["item_type"] = item_type
        if sync_status:
            filters["sync_status"] = sync_status
        
        # Get sync statuses (assuming the service has this method)
        sync_statuses = await telemetry_service.get_sync_statuses(
            filters=filters,
            skip=skip,
            limit=limit
        )
        
        return sync_statuses
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve sync status: {str(e)}"
        )


@router.post("/resolve-conflicts", response_model=Dict[str, Any])
async def resolve_conflicts(
    conflict_resolutions: List[Dict[str, Any]],
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Resolve synchronization conflicts for telemetry items.
    
    This endpoint handles conflict resolution when offline data conflicts
    with server data during synchronization.
    
    Args:
        conflict_resolutions: List of conflict resolution decisions
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Dictionary with resolution results
        
    Raises:
        HTTPException: If validation fails or resolution encounters errors
    """
    if not conflict_resolutions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one conflict resolution must be provided"
        )
    
    # Initialize response data
    resolution_results = {
        "total_conflicts": len(conflict_resolutions),
        "resolved_conflicts": 0,
        "failed_resolutions": 0,
        "resolved_items": [],
        "errors": []
    }
    
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    
    try:
        for idx, resolution in enumerate(conflict_resolutions):
            try:
                # Validate required fields
                required_fields = ["item_id", "item_type", "resolution_strategy"]
                for field in required_fields:
                    if field not in resolution:
                        raise ValueError(f"Missing required field: {field}")
                
                item_id = UUID(resolution["item_id"])
                item_type = resolution["item_type"]
                strategy = resolution["resolution_strategy"]
                
                # Validate item_type
                if item_type not in {"light_reading", "growth_photo"}:
                    raise ValueError("item_type must be light_reading or growth_photo")
                
                # Validate resolution strategy
                if strategy not in {"keep_server", "keep_client", "merge"}:
                    raise ValueError("resolution_strategy must be keep_server, keep_client, or merge")
                
                # Apply conflict resolution based on strategy
                if strategy == "keep_server":
                    # Mark client version as resolved, keep server version
                    await telemetry_service.resolve_conflict_keep_server(
                        item_id=item_id,
                        item_type=item_type,
                        user_id=current_user.id
                    )
                elif strategy == "keep_client":
                    # Update server with client data
                    client_data = resolution.get("client_data", {})
                    await telemetry_service.resolve_conflict_keep_client(
                        item_id=item_id,
                        item_type=item_type,
                        client_data=client_data,
                        user_id=current_user.id
                    )
                elif strategy == "merge":
                    # Merge client and server data
                    merge_data = resolution.get("merge_data", {})
                    await telemetry_service.resolve_conflict_merge(
                        item_id=item_id,
                        item_type=item_type,
                        merge_data=merge_data,
                        user_id=current_user.id
                    )
                
                resolution_results["resolved_conflicts"] += 1
                resolution_results["resolved_items"].append({
                    "item_id": str(item_id),
                    "item_type": item_type,
                    "strategy": strategy,
                    "resolved_at": datetime.utcnow().isoformat()
                })
                
            except Exception as e:
                resolution_results["failed_resolutions"] += 1
                resolution_results["errors"].append({
                    "conflict_index": idx,
                    "error": str(e),
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # If all resolutions failed, return 400 status
        if resolution_results["failed_resolutions"] == resolution_results["total_conflicts"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="All conflict resolutions failed to process"
            )
        
        return resolution_results
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Handle unexpected errors
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Conflict resolution failed: {str(e)}"
        )


@router.get("/growth-metrics/{plant_id}", response_model=Dict[str, Any])
async def get_growth_metrics(
    plant_id: UUID,
    from_date: Optional[datetime] = Query(None, description="Start date for analysis"),
    to_date: Optional[datetime] = Query(None, description="End date for analysis"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get growth metrics analysis for a plant based on photos.
    
    Args:
        plant_id: Plant ID to analyze
        from_date: Start date for analysis
        to_date: End date for analysis
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Growth metrics analysis including measurements, rates, and milestones
        
    Raises:
        HTTPException: If plant not found or analysis fails
    """
    # Verify plant ownership
    plant_query = select(UserPlant).where(
        and_(UserPlant.id == plant_id, UserPlant.user_id == current_user.id)
    )
    result = await db.execute(plant_query)
    plant = result.scalar_one_or_none()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found"
        )
    
    # Use the telemetry service to get growth photos
    telemetry_service = TelemetryService(db)
    photos = await telemetry_service.get_growth_photos(
        user_id=current_user.id,
        plant_id=plant_id,
        start_date=from_date,
        end_date=to_date
    )
    
    if not photos:
        return {"message": "No growth photos found for this plant"}
    
    # Extract metrics from photos
    metrics_service = MetricsService()
    metrics_list = []
    for photo in photos:
        if photo.is_processed:
            # Create measurements object from photo metrics
            measurements = metrics_service.create_measurements(
                height_cm=photo.plant_height_cm,
                leaf_area_cm2=photo.leaf_area_cm2,
                health_score=photo.health_score
            )
            metrics_list.append(measurements)
    
    # Generate metrics summary
    metrics_summary = metrics_service.get_metrics_summary(metrics_list)
    
    # Calculate growth rates if we have at least two measurements
    growth_rates = {}
    if len(metrics_list) >= 2:
        # Calculate days between first and last photo
        first_photo = photos[-1]  # Assuming photos are ordered by date descending
        last_photo = photos[0]
        days_between = (last_photo.captured_at - first_photo.captured_at).days
        if days_between > 0:
            growth_rates = metrics_service.calculate_growth_rate(
                metrics_list[0],  # Latest metrics
                metrics_list[-1],  # Earliest metrics
                days_between
            )
    
    # Detect milestones if we have at least two measurements
    milestones = []
    if len(metrics_list) >= 2:
        # Compare latest with earliest
        milestones = metrics_service.detect_growth_milestones(
            metrics_list[0],  # Latest metrics
            metrics_list[-1]   # Earliest metrics
        )
    
    # Compile the complete analysis
    analysis = {
        "plant_id": str(plant_id),
        "photo_count": len(photos),
        "date_range": {
            "from": photos[-1].captured_at if photos else None,
            "to": photos[0].captured_at if photos else None,
        },
        "metrics_summary": metrics_summary,
        "growth_rates": growth_rates,
        "milestones": milestones
    }
    
    return analysis

@router.post("/growth-photos", response_model=GrowthPhotoResponse, status_code=status.HTTP_201_CREATED)
async def upload_growth_photo(
    plant_id: UUID = Form(...),
    photo_file: UploadFile = File(...),
    notes: Optional[str] = Form(None),
    location_name: Optional[str] = Form(None),
    ambient_light_lux: Optional[float] = Form(None),
    camera_settings: Optional[str] = Form(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Upload a new growth photo for a plant.
    
    Args:
        plant_id: ID of the plant
        photo_file: Uploaded image file
        notes: Optional notes about the photo
        location_name: Optional location name
        ambient_light_lux: Optional ambient light in lux
        camera_settings: Optional camera settings as JSON string
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Created growth photo record
        
    Raises:
        HTTPException: If file upload fails or plant doesn't exist
    """
    # Validate file type
    if not photo_file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )
    
    # Upload the file to storage
    media_url, file_size, _ = await upload_media_file(photo_file)
    
    # Parse camera settings if provided
    camera_settings_dict = None
    if camera_settings:
        try:
            import json
            camera_settings_dict = json.loads(camera_settings)
        except json.JSONDecodeError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid camera settings JSON format"
            )
    
    # Use the telemetry service to create the photo
    telemetry_service = TelemetryService(db)
    db_growth_photo = await telemetry_service.create_growth_photo(
        user_id=current_user.id,
        plant_id=plant_id,
        file_path=media_url,
        file_size=file_size,
        notes=notes,
        location_name=location_name,
        ambient_light_lux=ambient_light_lux,
        camera_settings=camera_settings_dict,
        is_processed=False,
        captured_at=datetime.utcnow()
    )
    
    return db_growth_photo

@router.get("/growth-photos", response_model=List[GrowthPhotoResponse])
async def get_growth_photos(
    plant_id: Optional[UUID] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = Query(None, description="End date for filtering photos"),
    is_processed: Optional[bool] = None,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get growth photos with filtering and pagination.
    
    Args:
        plant_id: Filter by plant ID
        start_date: Filter by start date
        end_date: Filter by end date
        is_processed: Filter by processing status
        skip: Number of records to skip (pagination)
        limit: Maximum number of records to return (pagination)
        db: Database session
        current_user: Authenticated user
        
    Returns:
        List of growth photos matching the filters
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    photos = await telemetry_service.get_growth_photos(
        user_id=current_user.id,
        plant_id=plant_id,
        start_date=start_date,
        end_date=end_date,
        is_processed=is_processed,
        skip=skip,
        limit=limit
    )
    
    return photos

@router.get("/growth-photos/{photo_id}", response_model=GrowthPhotoResponse)
async def get_growth_photo(
    photo_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get a specific growth photo by ID.
    
    Args:
        photo_id: Growth photo ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Growth photo if found
        
    Raises:
        HTTPException: If photo not found or not owned by user
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    photo = await telemetry_service.get_growth_photo_by_id(
        photo_id=photo_id,
        user_id=current_user.id
    )
    
    if not photo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Growth photo not found"
        )
    
    return photo

@router.post("/growth-photos/{photo_id}/complete", response_model=GrowthPhotoResponse)
async def complete_growth_photo(
    photo_id: UUID,
    auto_process: bool = Query(True, description="Automatically process image for measurements"),
    leaf_area_cm2: Optional[float] = Query(None, description="Measured leaf area in cm²"),
    plant_height_cm: Optional[float] = Query(None, description="Measured plant height in cm"),
    health_score: Optional[float] = Query(None, ge=0.0, le=1.0, description="Plant health score between 0-1"),
    chlorophyll_index: Optional[float] = Query(None, description="Chlorophyll index measurement"),
    processing_version: Optional[str] = Query(None, description="Version of processing algorithm used"),
    confidence_score: Optional[float] = Query(None, ge=0.0, le=1.0, description="Confidence score of measurements"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Mark a growth photo as processed and update with measurements.
    
    Args:
        photo_id: Growth photo ID
        auto_process: Whether to automatically process the image
        leaf_area_cm2: Optional measured leaf area
        plant_height_cm: Optional measured plant height
        health_score: Optional plant health score
        chlorophyll_index: Optional chlorophyll index
        processing_version: Optional processing algorithm version
        confidence_score: Optional confidence score
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Updated growth photo record
        
    Raises:
        HTTPException: If photo not found, already processed, or not owned by user
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    
    # Get the photo first to check if it exists and belongs to the user
    photo = await telemetry_service.get_growth_photo_by_id(
        photo_id=photo_id,
        user_id=current_user.id
    )
    
    if not photo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Growth photo not found"
        )
    
    # Check if already processed
    if photo.is_processed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Growth photo already processed"
        )
    
    # Process the image if auto_process is enabled
    if auto_process:
        try:
            # Initialize metrics service
            metrics_service = MetricsService()
            
            # Process the image to extract measurements
            measurements = metrics_service.extract_metrics(photo.file_path)
            
            # Use detected values if not manually provided
            if leaf_area_cm2 is None and hasattr(measurements, 'leaf_area_cm2'):
                leaf_area_cm2 = measurements.leaf_area_cm2
            
            if plant_height_cm is None and hasattr(measurements, 'height_cm'):
                plant_height_cm = measurements.height_cm
            
            if health_score is None and hasattr(measurements, 'health_score'):
                health_score = measurements.health_score
            
            # Set processing version if not provided
            if processing_version is None:
                processing_version = "v1.0"
                
            # Set default confidence score if not provided
            if confidence_score is None:
                confidence_score = 0.85
                
        except Exception as e:
            # Log the error but continue with manual values if provided
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error processing growth photo {photo_id}: {str(e)}")
    
    # Update the photo with the telemetry service
    updated_photo = await telemetry_service.analyze_growth_photo(
        photo_id=photo_id,
        user_id=current_user.id,
        leaf_area_cm2=leaf_area_cm2,
        plant_height_cm=plant_height_cm,
        health_score=health_score,
        chlorophyll_index=chlorophyll_index,
        processing_version=processing_version,
        confidence_score=confidence_score
    )
    
    return updated_photo

@router.get("/light-readings", response_model=List[LightReadingResponse])
async def get_light_readings(
    plant_id: Optional[UUID] = None,
    source: Optional[LightSource] = None,
    location_name: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = Query(None, description="End date for filtering readings"),
    min_lux: Optional[float] = Query(None, description="Minimum lux value"),
    max_lux: Optional[float] = Query(None, description="Maximum lux value"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get light readings with filtering and pagination.
    
    Args:
        plant_id: Filter by plant ID
        source: Filter by light source type
        location_name: Filter by location name
        start_date: Filter by start date
        end_date: Filter by end date
        min_lux: Filter by minimum lux value
        max_lux: Filter by maximum lux value
        skip: Number of records to skip (pagination)
        limit: Maximum number of records to return (pagination)
        db: Database session
        current_user: Authenticated user
        
    Returns:
        List of light readings matching the filters
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    readings = await telemetry_service.get_light_readings(
        user_id=current_user.id,
        plant_id=plant_id,
        source=source,
        location_name=location_name,
        start_date=start_date,
        end_date=end_date,
        min_lux=min_lux,
        max_lux=max_lux,
        skip=skip,
        limit=limit
    )
    
    return readings

@router.get("/light-readings/{reading_id}", response_model=LightReadingResponse)
async def get_light_reading(
    reading_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get a specific light reading by ID.
    
    Args:
        reading_id: Light reading ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Light reading if found
        
    Raises:
        HTTPException: If reading not found or not owned by user
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    reading = await telemetry_service.get_light_reading_by_id(
        reading_id=reading_id,
        user_id=current_user.id
    )
    
    if not reading:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Light reading not found"
        )
    
    return reading

@router.post("/light-readings", response_model=LightReadingResponse, status_code=status.HTTP_201_CREATED)
async def create_light_reading(
    light_reading: LightReadingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Create a new light reading measurement.
    
    Args:
        light_reading: Light reading data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Created light reading
        
    Raises:
        HTTPException: If calibration profile or plant doesn't exist
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    db_light_reading = await telemetry_service.create_light_reading(
        user_id=current_user.id,
        light_reading=light_reading
    )
    
    return db_light_reading

@router.post("/light-readings/batch", response_model=List[LightReadingResponse], status_code=status.HTTP_201_CREATED)
async def create_batch_light_readings(
    batch_request: BatchLightReadingRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Create multiple light readings in a single request.
    
    Args:
        batch_request: Batch of light readings
        db: Database session
        current_user: Authenticated user
        
    Returns:
        List of created light readings
        
    Raises:
        HTTPException: If validation fails
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    created_readings = await telemetry_service.create_batch_light_readings(
        user_id=current_user.id,
        readings=batch_request.readings
    )
    
    return created_readings


@router.get("/light-readings/statistics", response_model=Dict[str, Any])
async def get_light_statistics(
    plant_id: Optional[UUID] = None,
    days: int = Query(7, ge=1, le=90, description="Number of days to include in statistics"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get light reading statistics for a user or plant.
    
    Args:
        plant_id: Optional plant ID to filter statistics
        days: Number of days to include in statistics
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Dictionary with light statistics including averages, min/max values,
        reading counts, and source distribution
    """
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    statistics = await telemetry_service.get_light_statistics(
        user_id=current_user.id,
        plant_id=plant_id,
        days=days
    )
    
    return statistics


@router.post("/batch", response_model=TelemetryBatchResponse, status_code=status.HTTP_201_CREATED)
async def create_telemetry_batch(
    batch_request: TelemetryBatchRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Create multiple telemetry items (light readings and growth photos) in a single batch.
    
    This endpoint supports batch processing of telemetry data with proper validation,
    error handling, and sync status tracking for offline synchronization.
    
    Args:
        batch_request: Batch request containing light readings and growth photos
        db: Database session
        current_user: Authenticated user
        
    Returns:
        TelemetryBatchResponse with processing results and sync statuses
        
    Raises:
        HTTPException: If validation fails or batch processing encounters errors
    """
    start_time = datetime.utcnow()
    
    # Initialize response data
    batch_response = TelemetryBatchResponse(
        batch_id=uuid4(),
        session_id=batch_request.session_id,
        total_items=len(batch_request.light_readings) + len(batch_request.growth_photos),
        successful_items=0,
        failed_items=0,
        light_readings_created=[],
        growth_photos_created=[],
        sync_statuses=[],
        errors=[]
    )
    
    # Validate batch is not empty
    if batch_response.total_items == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Batch must contain at least one light reading or growth photo"
        )
    
    # Use the telemetry service
    telemetry_service = TelemetryService(db)
    
    try:
        # Process light readings
        for idx, light_reading in enumerate(batch_request.light_readings):
            try:
                # Create the light reading
                db_light_reading = await telemetry_service.create_light_reading(
                    user_id=current_user.id,
                    light_reading=light_reading
                )
                
                batch_response.light_readings_created.append(db_light_reading.id)
                batch_response.successful_items += 1
                
                # Create sync status for the light reading
                sync_status = TelemetrySyncStatus(
                    item_id=db_light_reading.id,
                    item_type="light_reading",
                    session_id=batch_request.session_id,
                    sync_status="synced" if not batch_request.offline_mode else "pending",
                    retry_count=0,
                    last_sync_attempt=datetime.utcnow() if not batch_request.offline_mode else None,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                batch_response.sync_statuses.append(sync_status)
                
            except Exception as e:
                batch_response.failed_items += 1
                batch_response.errors.append({
                    "item_type": "light_reading",
                    "item_index": idx,
                    "error": str(e),
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Process growth photos
        for idx, growth_photo in enumerate(batch_request.growth_photos):
            try:
                # Create the growth photo
                db_growth_photo = await telemetry_service.create_growth_photo(
                    user_id=current_user.id,
                    plant_id=growth_photo.plant_id,
                    file_path=growth_photo.file_path,
                    file_size=growth_photo.file_size,
                    notes=growth_photo.notes,
                    location_name=growth_photo.location_name,
                    ambient_light_lux=growth_photo.ambient_light_lux,
                    camera_settings=growth_photo.camera_settings,
                    is_processed=False,
                    captured_at=growth_photo.captured_at
                )
                
                batch_response.growth_photos_created.append(db_growth_photo.id)
                batch_response.successful_items += 1
                
                # Create sync status for the growth photo
                sync_status = TelemetrySyncStatus(
                    item_id=db_growth_photo.id,
                    item_type="growth_photo",
                    session_id=batch_request.session_id,
                    sync_status="synced" if not batch_request.offline_mode else "pending",
                    retry_count=0,
                    last_sync_attempt=datetime.utcnow() if not batch_request.offline_mode else None,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                batch_response.sync_statuses.append(sync_status)
                
            except Exception as e:
                batch_response.failed_items += 1
                batch_response.errors.append({
                    "item_type": "growth_photo",
                    "item_index": idx,
                    "error": str(e),
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Calculate processing duration
        end_time = datetime.utcnow()
        batch_response.processing_duration_ms = int((end_time - start_time).total_seconds() * 1000)
        batch_response.created_at = end_time
        
        # If all items failed, return 400 status
        if batch_response.failed_items == batch_response.total_items:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="All items in batch failed to process",
                headers={"X-Batch-ID": str(batch_response.batch_id)}
            )
        
        return batch_response
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Handle unexpected errors
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Batch processing failed: {str(e)}",
            headers={"X-Batch-ID": str(batch_response.batch_id)}
        )
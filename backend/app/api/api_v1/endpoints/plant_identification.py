"""Plant identification API endpoints.

This module provides REST API endpoints for AI-powered plant identification.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.plant_identification import (
    PlantIdentificationCreate,
    PlantIdentificationUpdate,
    PlantIdentificationResponse,
    PlantIdentificationListResponse,
    PlantIdentificationResultResponse
)
from app.services.plant_identification_service import (
    PlantIdentificationService,
    create_identification,
    get_identification_by_id,
    get_user_identifications,
    update_identification,
    delete_identification,
    verify_identification,
    get_pending_verifications,
    get_identification_statistics
)
from app.services.auth_service import AuthService

router = APIRouter()

# Initialize the plant identification service
plant_id_service = PlantIdentificationService()


@router.post(
    "/",
    response_model=PlantIdentificationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create plant identification",
    description="Submit a plant image for AI identification."
)
async def create_plant_identification(
    identification_data: PlantIdentificationCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResponse:
    """Create a new plant identification request."""
    try:
        identification = await create_identification(db, current_user.id, identification_data)
        return PlantIdentificationResponse.from_orm(identification)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create identification"
        )


@router.post(
    "/upload",
    response_model=PlantIdentificationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload and identify plant",
    description="Upload a plant image and get AI identification results."
)
async def upload_and_identify(
    file: UploadFile = File(..., description="Plant image file"),
    location: Optional[str] = Query(None, description="Location where photo was taken"),
    notes: Optional[str] = Query(None, description="Additional notes about the plant"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResponse:
    """Upload image and create identification request with AI analysis."""
    # Validate file type
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )
    
    # Validate file size (max 10MB)
    max_size = 10 * 1024 * 1024  # 10MB
    if file.size and file.size > max_size:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size too large. Maximum size is 10MB"
        )
    
    try:
        # Read image data
        image_data = await file.read()
        
        if not image_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty file uploaded"
            )
        
        # Process image with AI identification
        identification = await plant_id_service.process_plant_image(
            image_data=image_data,
            filename=file.filename or "unknown.jpg",
            user_id=current_user.id,
            db=db,
            location=location,
            notes=notes
        )
        
        return PlantIdentificationResponse.from_orm(identification)
        
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process identification: {str(e)}"
        )


@router.post(
    "/analyze",
    response_model=PlantIdentificationResultResponse,
    summary="Analyze plant image",
    description="Analyze a plant image without saving the identification."
)
async def analyze_plant_image(
    file: UploadFile = File(..., description="Plant image file"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResultResponse:
    """Analyze plant image and return identification results without saving."""
    # Validate file type
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )
    
    # Validate file size (max 10MB)
    max_size = 10 * 1024 * 1024  # 10MB
    if file.size and file.size > max_size:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size too large. Maximum size is 10MB"
        )
    
    try:
        # Read image data
        image_data = await file.read()
        
        if not image_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty file uploaded"
            )
        
        # Perform AI identification without saving
        identification_result = await plant_id_service._identify_plant_with_ai(
            image_path=None,  # We don't save the image for analysis-only
            image_data=image_data
        )
        
        # Find species suggestions from database
        species_suggestions = []
        if identification_result.get("suggestions"):
            for suggestion in identification_result["suggestions"][:3]:  # Top 3 suggestions
                species_match = await plant_id_service._find_species_match(
                    db,
                    suggestion.get("name", ""),
                    [suggestion]
                )
                if species_match:
                    # Get the full species data
                    from app.models.plant_species import PlantSpecies
                    result = await db.execute(
                        select(PlantSpecies).where(PlantSpecies.id == species_match["species_id"])
                    )
                    species = result.scalar_one_or_none()
                    if species:
                        from app.schemas.plant_species import PlantSpeciesResponse
                        species_suggestions.append(PlantSpeciesResponse.from_orm(species))
        
        # Format care recommendations
        care_recommendations = ""
        if identification_result.get("care_recommendations"):
            care_data = identification_result["care_recommendations"]
            care_recommendations = f"""
Light: {care_data.get('light_requirements', 'Unknown')}
Water: {care_data.get('water_requirements', 'Unknown')}
Soil: {care_data.get('soil_type', 'Unknown')}
Difficulty: {care_data.get('difficulty_level', 'Unknown')}
            """.strip()
        
        return PlantIdentificationResultResponse(
            identified_name=identification_result["identified_name"],
            confidence_score=identification_result["confidence_score"],
            species_suggestions=species_suggestions,
            care_recommendations=care_recommendations
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to analyze image: {str(e)}"
        )


@router.get(
    "/",
    response_model=PlantIdentificationListResponse,
    summary="Get user's identifications",
    description="Get all plant identifications for the current user."
)
async def get_my_identifications(
    status_filter: Optional[str] = Query(None, description="Filter by status (pending, completed, failed)"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationListResponse:
    """Get user's plant identifications."""
    try:
        identifications, total = await get_user_identifications(
            db, current_user.id, status_filter, skip, limit
        )
        
        return PlantIdentificationListResponse(
            identifications=[PlantIdentificationResponse.from_orm(ident) for ident in identifications],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get identifications"
        )


@router.get(
    "/pending",
    response_model=PlantIdentificationListResponse,
    summary="Get pending verifications",
    description="Get plant identifications pending expert verification (admin only)."
)
async def get_pending_identification_verifications(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationListResponse:
    """Get pending identifications for verification (admin only)."""
    # Verify admin permission for accessing pending verifications
    AuthService.check_admin_permission(current_user, "plant_verification")
    
    try:
        identifications, total = await get_pending_verifications(db, skip, limit)
        
        return PlantIdentificationListResponse(
            identifications=[PlantIdentificationResponse.from_orm(ident) for ident in identifications],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get pending verifications"
        )


@router.get(
    "/stats",
    summary="Get identification statistics",
    description="Get statistics about plant identifications."
)
async def get_identification_statistics(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get identification statistics for the current user."""
    try:
        stats = await get_identification_statistics(db, current_user.id)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get identification statistics"
        )


@router.get(
    "/{identification_id}",
    response_model=PlantIdentificationResponse,
    summary="Get identification details",
    description="Get details of a specific plant identification."
)
async def get_identification(
    identification_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResponse:
    """Get identification by ID."""
    identification = await get_identification_by_id(db, identification_id, current_user.id)
    if not identification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Identification not found"
        )
    return PlantIdentificationResponse.from_orm(identification)


@router.get(
    "/{identification_id}/ai-details",
    summary="Get AI identification details",
    description="Get detailed AI analysis for a specific identification."
)
async def get_ai_identification_details(
    identification_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get detailed AI analysis for an identification."""
    try:
        ai_details = await plant_id_service.get_identification_with_ai_details(
            db=db,
            identification_id=identification_id,
            user_id=current_user.id
        )
        
        if not ai_details:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Identification not found"
            )
        
        return ai_details
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get AI details: {str(e)}"
        )


@router.put(
    "/{identification_id}",
    response_model=PlantIdentificationResponse,
    summary="Update identification",
    description="Update plant identification information."
)
async def update_plant_identification(
    identification_id: UUID,
    identification_data: PlantIdentificationUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResponse:
    """Update plant identification."""
    try:
        identification = await update_identification(
            db, identification_id, current_user.id, identification_data
        )
        if not identification:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Identification not found"
            )
        return PlantIdentificationResponse.from_orm(identification)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update identification"
        )


@router.post(
    "/{identification_id}/verify",
    response_model=PlantIdentificationResponse,
    summary="Verify identification",
    description="Verify or correct a plant identification (expert/admin only)."
)
async def verify_plant_identification(
    identification_id: UUID,
    verified_species_id: Optional[UUID] = Query(None, description="Correct species ID if different from AI suggestion"),
    verification_notes: Optional[str] = Query(None, description="Verification notes"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantIdentificationResponse:
    """Verify plant identification (expert/admin only)."""
    # Verify expert or admin permission for plant identification verification
    AuthService.check_expert_permission(current_user, "plant_identification")
    
    try:
        identification = await verify_identification(
            db, identification_id, current_user.id, verified_species_id, verification_notes
        )
        if not identification:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Identification not found"
            )
        return PlantIdentificationResponse.from_orm(identification)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to verify identification"
        )


@router.delete(
    "/{identification_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete identification",
    description="Delete a plant identification."
)
async def delete_plant_identification(
    identification_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete plant identification."""
    try:
        success = await delete_identification(db, identification_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Identification not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete identification"
        )
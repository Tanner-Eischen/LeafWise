"""Plant species API endpoints.

This module provides REST API endpoints for managing plant species data.
"""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.plant_species import (
    PlantSpeciesCreate,
    PlantSpeciesUpdate,
    PlantSpeciesResponse,
    PlantSpeciesListResponse
)
from app.services.plant_species_service import (
    create_species,
    get_species_by_id,
    get_species_by_scientific_name,
    search_species,
    update_species,
    delete_species,
    get_popular_species
)

router = APIRouter()


@router.post(
    "/",
    response_model=PlantSpeciesResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create plant species",
    description="Create a new plant species. Requires authentication."
)
async def create_plant_species(
    species_data: PlantSpeciesCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantSpeciesResponse:
    """Create a new plant species."""
    try:
        species = await create_species(db, species_data)
        return PlantSpeciesResponse.from_orm(species)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create plant species"
        )


@router.get(
    "/search",
    response_model=PlantSpeciesListResponse,
    summary="Search plant species",
    description="Search plant species by name, care requirements, or other criteria."
)
async def search_plant_species(
    query: Optional[str] = Query(None, description="Search query for species name"),
    care_level: Optional[str] = Query(None, description="Filter by care level"),
    light_requirements: Optional[str] = Query(None, description="Filter by light requirements"),
    water_frequency_days: Optional[int] = Query(None, description="Filter by watering frequency"),
    is_toxic: Optional[bool] = Query(None, description="Filter by toxicity"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db)
) -> PlantSpeciesListResponse:
    """Search plant species with filters."""
    try:
        filters = {}
        if care_level:
            filters["care_level"] = care_level
        if light_requirements:
            filters["light_requirements"] = light_requirements
        if water_frequency_days:
            filters["water_frequency_days"] = water_frequency_days
        if is_toxic is not None:
            filters["is_toxic"] = is_toxic
        
        species_list, total = await search_species(db, query, filters, skip, limit)
        
        return PlantSpeciesListResponse(
            species=[PlantSpeciesResponse.from_orm(species) for species in species_list],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to search plant species"
        )


@router.get(
    "/popular",
    response_model=PlantSpeciesListResponse,
    summary="Get popular plant species",
    description="Get the most popular plant species based on user plants."
)
async def get_popular_plant_species(
    limit: int = Query(10, ge=1, le=50, description="Maximum number of species to return"),
    db: AsyncSession = Depends(get_db)
) -> PlantSpeciesListResponse:
    """Get popular plant species."""
    try:
        species_list = await get_popular_species(db, limit)
        
        return PlantSpeciesListResponse(
            species=[PlantSpeciesResponse.from_orm(species) for species in species_list],
            total=len(species_list),
            skip=0,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get popular plant species"
        )


@router.get(
    "/scientific-name/{scientific_name}",
    response_model=PlantSpeciesResponse,
    summary="Get species by scientific name",
    description="Get plant species by scientific name."
)
async def get_species_by_scientific_name_endpoint(
    scientific_name: str,
    db: AsyncSession = Depends(get_db)
) -> PlantSpeciesResponse:
    """Get plant species by scientific name."""
    species = await get_species_by_scientific_name(db, scientific_name)
    if not species:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant species not found"
        )
    return PlantSpeciesResponse.from_orm(species)


@router.get(
    "/{species_id}",
    response_model=PlantSpeciesResponse,
    summary="Get plant species by ID",
    description="Get plant species details by ID."
)
async def get_plant_species(
    species_id: UUID,
    db: AsyncSession = Depends(get_db)
) -> PlantSpeciesResponse:
    """Get plant species by ID."""
    species = await get_species_by_id(db, species_id)
    if not species:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant species not found"
        )
    return PlantSpeciesResponse.from_orm(species)


@router.put(
    "/{species_id}",
    response_model=PlantSpeciesResponse,
    summary="Update plant species",
    description="Update plant species information. Requires authentication."
)
async def update_plant_species(
    species_id: UUID,
    species_data: PlantSpeciesUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantSpeciesResponse:
    """Update plant species."""
    try:
        species = await update_species(db, species_id, species_data)
        if not species:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant species not found"
            )
        return PlantSpeciesResponse.from_orm(species)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update plant species"
        )


@router.delete(
    "/{species_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete plant species",
    description="Delete plant species. Requires authentication."
)
async def delete_plant_species(
    species_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete plant species."""
    try:
        success = await delete_species(db, species_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant species not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete plant species"
        )
"""Plant trades API endpoints.

This module provides REST API endpoints for the plant trading marketplace.
"""

from typing import List, Optional
from uuid import UUID
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.plant_trade import (
    PlantTradeCreate,
    PlantTradeUpdate,
    PlantTradeResponse,
    PlantTradeListResponse,
    PlantTradeSearchRequest,
    PlantTradeInterestRequest
)
from app.services.plant_trade_service import (
    create_trade,
    get_trade_by_id,
    search_trades,
    get_user_trades,
    update_trade,
    express_interest,
    accept_trade,
    cancel_trade,
    delete_trade,
    get_trade_stats,
    get_popular_trade_species
)

router = APIRouter()


@router.post(
    "/",
    response_model=PlantTradeResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create trade listing",
    description="Create a new plant trade listing."
)
async def create_trade_listing(
    trade_data: PlantTradeCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantTradeResponse:
    """Create a new plant trade listing."""
    try:
        trade = await create_trade(db, current_user.id, trade_data)
        return PlantTradeResponse.from_orm(trade)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create trade listing"
        )


@router.get(
    "/",
    response_model=PlantTradeListResponse,
    summary="Search trade listings",
    description="Search and browse plant trade listings."
)
async def search_trade_listings(
    trade_type: Optional[str] = Query(None, description="Filter by trade type (sell, trade, giveaway)"),
    species_id: Optional[UUID] = Query(None, description="Filter by plant species"),
    location: Optional[str] = Query(None, description="Filter by location"),
    min_price: Optional[Decimal] = Query(None, description="Minimum price filter"),
    max_price: Optional[Decimal] = Query(None, description="Maximum price filter"),
    is_available: Optional[bool] = Query(True, description="Filter by availability"),
    sort_by: Optional[str] = Query("created_at", description="Sort by field (created_at, price, title)"),
    sort_order: Optional[str] = Query("desc", description="Sort order (asc, desc)"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db)
) -> PlantTradeListResponse:
    """Search plant trade listings."""
    try:
        search_request = PlantTradeSearchRequest(
            trade_type=trade_type,
            species_id=species_id,
            location=location,
            min_price=min_price,
            max_price=max_price,
            is_available=is_available,
            sort_by=sort_by,
            sort_order=sort_order
        )
        
        trades, total = await search_trades(db, search_request, skip, limit)
        
        return PlantTradeListResponse(
            trades=[PlantTradeResponse.from_orm(trade) for trade in trades],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to search trade listings"
        )


@router.get(
    "/my-trades",
    response_model=PlantTradeListResponse,
    summary="Get user's trade listings",
    description="Get all trade listings created by the current user."
)
async def get_my_trades(
    is_available: Optional[bool] = Query(None, description="Filter by availability"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantTradeListResponse:
    """Get user's trade listings."""
    try:
        trades, total = await get_user_trades(db, current_user.id, is_available, skip, limit)
        
        return PlantTradeListResponse(
            trades=[PlantTradeResponse.from_orm(trade) for trade in trades],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get user trades"
        )


@router.get(
    "/stats",
    summary="Get trade statistics",
    description="Get marketplace statistics."
)
async def get_marketplace_stats(
    db: AsyncSession = Depends(get_db)
) -> dict:
    """Get marketplace statistics."""
    try:
        stats = await get_trade_stats(db)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get trade statistics"
        )


@router.get(
    "/popular-species",
    summary="Get popular trade species",
    description="Get most popular plant species in trades."
)
async def get_popular_species(
    limit: int = Query(10, ge=1, le=50, description="Maximum number of species to return"),
    db: AsyncSession = Depends(get_db)
) -> List[dict]:
    """Get popular species in trades."""
    try:
        popular_species = await get_popular_trade_species(db, limit)
        return popular_species
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get popular species"
        )


@router.get(
    "/{trade_id}",
    response_model=PlantTradeResponse,
    summary="Get trade details",
    description="Get details of a specific trade listing."
)
async def get_trade_listing(
    trade_id: UUID,
    db: AsyncSession = Depends(get_db)
) -> PlantTradeResponse:
    """Get trade listing by ID."""
    trade = await get_trade_by_id(db, trade_id)
    if not trade:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trade listing not found"
        )
    return PlantTradeResponse.from_orm(trade)


@router.put(
    "/{trade_id}",
    response_model=PlantTradeResponse,
    summary="Update trade listing",
    description="Update a trade listing (owner only)."
)
async def update_trade_listing(
    trade_id: UUID,
    trade_data: PlantTradeUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantTradeResponse:
    """Update trade listing."""
    try:
        trade = await update_trade(db, trade_id, current_user.id, trade_data)
        if not trade:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trade listing not found or access denied"
            )
        return PlantTradeResponse.from_orm(trade)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update trade listing"
        )


@router.post(
    "/{trade_id}/interest",
    summary="Express interest",
    description="Express interest in a trade listing."
)
async def express_trade_interest(
    trade_id: UUID,
    interest_data: PlantTradeInterestRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Express interest in a trade listing."""
    try:
        success = await express_interest(
            db, trade_id, current_user.id, interest_data.message, interest_data.offered_plant_id
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trade listing not found or not available"
            )
        
        return {
            "message": "Interest expressed successfully",
            "trade_id": trade_id,
            "user_id": current_user.id
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to express interest"
        )


@router.post(
    "/{trade_id}/accept",
    summary="Accept trade",
    description="Accept a trade offer (owner only)."
)
async def accept_trade_offer(
    trade_id: UUID,
    interested_user_id: UUID = Query(..., description="ID of the user whose offer to accept"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Accept a trade offer."""
    try:
        success = await accept_trade(db, trade_id, current_user.id, interested_user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trade listing not found or access denied"
            )
        
        return {
            "message": "Trade accepted successfully",
            "trade_id": trade_id,
            "accepted_user_id": interested_user_id
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to accept trade"
        )


@router.post(
    "/{trade_id}/cancel",
    summary="Cancel trade",
    description="Cancel a trade listing (owner only)."
)
async def cancel_trade_listing(
    trade_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Cancel trade listing."""
    try:
        success = await cancel_trade(db, trade_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trade listing not found or access denied"
            )
        
        return {
            "message": "Trade cancelled successfully",
            "trade_id": trade_id
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to cancel trade"
        )


@router.delete(
    "/{trade_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete trade listing",
    description="Delete a trade listing (owner only)."
)
async def delete_trade_listing(
    trade_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete trade listing."""
    try:
        success = await delete_trade(db, trade_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trade listing not found or access denied"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete trade listing"
        )
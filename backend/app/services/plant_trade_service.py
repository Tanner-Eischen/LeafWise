"""Plant trade service.

This module provides business logic for the plant trading marketplace,
including CRUD operations, search, and trade management.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

from sqlalchemy import and_, or_, func, desc, asc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_trade import PlantTrade, TradeStatus, TradeType
from app.models.plant_species import PlantSpecies
from app.schemas.plant_trade import PlantTradeCreate, PlantTradeUpdate, PlantTradeSearchRequest


class PlantTradeService:
    """Service for managing plant trades."""
    
    @staticmethod
    async def create_trade(
        db: AsyncSession,
        user_id: UUID,
        trade_data: PlantTradeCreate
    ) -> PlantTrade:
        """Create a new plant trade listing.
        
        Args:
            db: Database session
            user_id: Owner user ID
            trade_data: Trade creation data
            
        Returns:
            Created trade listing
        """
        trade = PlantTrade(
            owner_id=user_id,
            **trade_data.dict()
        )
        db.add(trade)
        await db.commit()
        await db.refresh(trade)
        return trade
    
    @staticmethod
    async def get_trade_by_id(
        db: AsyncSession,
        trade_id: UUID,
        include_inactive: bool = False
    ) -> Optional[PlantTrade]:
        """Get trade by ID.
        
        Args:
            db: Database session
            trade_id: Trade ID
            include_inactive: Whether to include inactive trades
            
        Returns:
            Trade if found, None otherwise
        """
        query = select(PlantTrade).options(
            selectinload(PlantTrade.owner),
            selectinload(PlantTrade.species),
            selectinload(PlantTrade.interested_user)
        ).where(PlantTrade.id == trade_id)
        
        if not include_inactive:
            query = query.where(PlantTrade.is_active == True)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_user_trades(
        db: AsyncSession,
        user_id: UUID,
        status: Optional[TradeStatus] = None,
        trade_type: Optional[TradeType] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantTrade], int]:
        """Get trades owned by a user.
        
        Args:
            db: Database session
            user_id: User ID
            status: Optional status filter
            trade_type: Optional trade type filter
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (trades list, total count)
        """
        # Build base query
        base_query = select(PlantTrade).options(
            selectinload(PlantTrade.species),
            selectinload(PlantTrade.interested_user)
        ).where(
            and_(
                PlantTrade.owner_id == user_id,
                PlantTrade.is_active == True
            )
        )
        
        count_query = select(func.count(PlantTrade.id)).where(
            and_(
                PlantTrade.owner_id == user_id,
                PlantTrade.is_active == True
            )
        )
        
        # Apply filters
        if status:
            base_query = base_query.where(PlantTrade.status == status)
            count_query = count_query.where(PlantTrade.status == status)
        
        if trade_type:
            base_query = base_query.where(PlantTrade.trade_type == trade_type)
            count_query = count_query.where(PlantTrade.trade_type == trade_type)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(desc(PlantTrade.created_at))
            .offset(skip)
            .limit(limit)
        )
        trades = result.scalars().all()
        
        return list(trades), total
    
    @staticmethod
    async def search_trades(
        db: AsyncSession,
        search_params: PlantTradeSearchRequest,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantTrade], int]:
        """Search plant trades with filters.
        
        Args:
            db: Database session
            search_params: Search parameters
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (trades list, total count)
        """
        # Build base query
        base_query = select(PlantTrade).options(
            selectinload(PlantTrade.owner),
            selectinload(PlantTrade.species)
        ).where(
            and_(
                PlantTrade.is_active == True,
                PlantTrade.status == TradeStatus.AVAILABLE
            )
        )
        
        count_query = select(func.count(PlantTrade.id)).where(
            and_(
                PlantTrade.is_active == True,
                PlantTrade.status == TradeStatus.AVAILABLE
            )
        )
        
        # Apply search filters
        if search_params.query:
            search_filter = or_(
                PlantTrade.title.ilike(f"%{search_params.query}%"),
                PlantTrade.description.ilike(f"%{search_params.query}%")
            )
            base_query = base_query.where(search_filter)
            count_query = count_query.where(search_filter)
        
        if search_params.trade_type:
            base_query = base_query.where(PlantTrade.trade_type == search_params.trade_type)
            count_query = count_query.where(PlantTrade.trade_type == search_params.trade_type)
        
        if search_params.species_id:
            base_query = base_query.where(PlantTrade.species_id == search_params.species_id)
            count_query = count_query.where(PlantTrade.species_id == search_params.species_id)
        
        if search_params.location:
            base_query = base_query.where(
                PlantTrade.location.ilike(f"%{search_params.location}%")
            )
            count_query = count_query.where(
                PlantTrade.location.ilike(f"%{search_params.location}%")
            )
        
        if search_params.max_price is not None:
            base_query = base_query.where(
                or_(
                    PlantTrade.price <= search_params.max_price,
                    PlantTrade.price.is_(None)  # Include free items
                )
            )
            count_query = count_query.where(
                or_(
                    PlantTrade.price <= search_params.max_price,
                    PlantTrade.price.is_(None)
                )
            )
        
        # Apply sorting
        if search_params.sort_by == "price_low":
            base_query = base_query.order_by(asc(PlantTrade.price.nulls_first()))
        elif search_params.sort_by == "price_high":
            base_query = base_query.order_by(desc(PlantTrade.price.nulls_last()))
        elif search_params.sort_by == "newest":
            base_query = base_query.order_by(desc(PlantTrade.created_at))
        else:  # Default to newest
            base_query = base_query.order_by(desc(PlantTrade.created_at))
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.offset(skip).limit(limit)
        )
        trades = result.scalars().all()
        
        return list(trades), total
    
    @staticmethod
    async def update_trade(
        db: AsyncSession,
        trade_id: UUID,
        user_id: UUID,
        trade_data: PlantTradeUpdate
    ) -> Optional[PlantTrade]:
        """Update trade listing.
        
        Args:
            db: Database session
            trade_id: Trade ID
            user_id: Owner user ID
            trade_data: Update data
            
        Returns:
            Updated trade if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(PlantTrade).where(
                and_(
                    PlantTrade.id == trade_id,
                    PlantTrade.owner_id == user_id
                )
            )
        )
        trade = result.scalar_one_or_none()
        
        if not trade:
            return None
        
        # Update fields
        update_data = trade_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(trade, field, value)
        
        trade.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(trade)
        return trade
    
    @staticmethod
    async def express_interest(
        db: AsyncSession,
        trade_id: UUID,
        user_id: UUID
    ) -> Optional[PlantTrade]:
        """Express interest in a trade.
        
        Args:
            db: Database session
            trade_id: Trade ID
            user_id: Interested user ID
            
        Returns:
            Updated trade if successful, None otherwise
        """
        result = await db.execute(
            select(PlantTrade).where(
                and_(
                    PlantTrade.id == trade_id,
                    PlantTrade.status == TradeStatus.AVAILABLE,
                    PlantTrade.is_active == True,
                    PlantTrade.owner_id != user_id  # Can't be interested in own trade
                )
            )
        )
        trade = result.scalar_one_or_none()
        
        if not trade:
            return None
        
        # Update trade status and interested user
        trade.status = TradeStatus.PENDING
        trade.interested_user_id = user_id
        trade.updated_at = datetime.utcnow()
        
        await db.commit()
        await db.refresh(trade)
        return trade
    
    @staticmethod
    async def accept_trade(
        db: AsyncSession,
        trade_id: UUID,
        owner_id: UUID
    ) -> Optional[PlantTrade]:
        """Accept a trade (mark as completed).
        
        Args:
            db: Database session
            trade_id: Trade ID
            owner_id: Owner user ID
            
        Returns:
            Updated trade if successful, None otherwise
        """
        result = await db.execute(
            select(PlantTrade).where(
                and_(
                    PlantTrade.id == trade_id,
                    PlantTrade.owner_id == owner_id,
                    PlantTrade.status == TradeStatus.PENDING
                )
            )
        )
        trade = result.scalar_one_or_none()
        
        if not trade:
            return None
        
        # Mark trade as completed
        trade.status = TradeStatus.COMPLETED
        trade.updated_at = datetime.utcnow()
        
        await db.commit()
        await db.refresh(trade)
        return trade
    
    @staticmethod
    async def cancel_trade(
        db: AsyncSession,
        trade_id: UUID,
        user_id: UUID
    ) -> Optional[PlantTrade]:
        """Cancel a trade (owner can cancel, interested user can withdraw).
        
        Args:
            db: Database session
            trade_id: Trade ID
            user_id: User ID (owner or interested user)
            
        Returns:
            Updated trade if successful, None otherwise
        """
        result = await db.execute(
            select(PlantTrade).where(
                and_(
                    PlantTrade.id == trade_id,
                    or_(
                        PlantTrade.owner_id == user_id,
                        PlantTrade.interested_user_id == user_id
                    )
                )
            )
        )
        trade = result.scalar_one_or_none()
        
        if not trade:
            return None
        
        # If owner cancels, mark as cancelled
        # If interested user withdraws, reset to available
        if trade.owner_id == user_id:
            trade.status = TradeStatus.CANCELLED
        else:
            trade.status = TradeStatus.AVAILABLE
            trade.interested_user_id = None
        
        trade.updated_at = datetime.utcnow()
        
        await db.commit()
        await db.refresh(trade)
        return trade
    
    @staticmethod
    async def delete_trade(
        db: AsyncSession,
        trade_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete trade listing (soft delete).
        
        Args:
            db: Database session
            trade_id: Trade ID
            user_id: Owner user ID
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(PlantTrade).where(
                and_(
                    PlantTrade.id == trade_id,
                    PlantTrade.owner_id == user_id
                )
            )
        )
        trade = result.scalar_one_or_none()
        
        if not trade:
            return False
        
        trade.is_active = False
        trade.updated_at = datetime.utcnow()
        await db.commit()
        return True
    
    @staticmethod
    async def get_trade_statistics(
        db: AsyncSession,
        user_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Get trade statistics.
        
        Args:
            db: Database session
            user_id: Optional user ID for user-specific stats
            
        Returns:
            Dictionary with trade statistics
        """
        base_filter = PlantTrade.is_active == True
        if user_id:
            base_filter = and_(base_filter, PlantTrade.owner_id == user_id)
        
        # Total active trades
        total_result = await db.execute(
            select(func.count(PlantTrade.id)).where(base_filter)
        )
        total_trades = total_result.scalar()
        
        # Trades by status
        status_result = await db.execute(
            select(
                PlantTrade.status,
                func.count(PlantTrade.id)
            ).where(base_filter)
            .group_by(PlantTrade.status)
        )
        status_stats = {status.value: count for status, count in status_result.all()}
        
        # Trades by type
        type_result = await db.execute(
            select(
                PlantTrade.trade_type,
                func.count(PlantTrade.id)
            ).where(base_filter)
            .group_by(PlantTrade.trade_type)
        )
        type_stats = {trade_type.value: count for trade_type, count in type_result.all()}
        
        # Average price for sell trades
        avg_price_result = await db.execute(
            select(func.avg(PlantTrade.price)).where(
                and_(
                    base_filter,
                    PlantTrade.trade_type == TradeType.SELL,
                    PlantTrade.price.is_not(None)
                )
            )
        )
        avg_price = avg_price_result.scalar() or 0.0
        
        return {
            "total_trades": total_trades,
            "status_breakdown": status_stats,
            "type_breakdown": type_stats,
            "available_trades": status_stats.get(TradeStatus.AVAILABLE.value, 0),
            "completed_trades": status_stats.get(TradeStatus.COMPLETED.value, 0),
            "average_sell_price": round(float(avg_price), 2) if avg_price else 0.0
        }
    
    @staticmethod
    async def get_popular_species(
        db: AsyncSession,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get most popular species in trades.
        
        Args:
            db: Database session
            limit: Maximum number of species to return
            
        Returns:
            List of popular species with trade counts
        """
        result = await db.execute(
            select(
                PlantTrade.species_id,
                func.count(PlantTrade.id).label('trade_count')
            ).join(PlantSpecies)
            .where(
                and_(
                    PlantTrade.is_active == True,
                    PlantTrade.status == TradeStatus.AVAILABLE
                )
            )
            .group_by(PlantTrade.species_id)
            .order_by(desc('trade_count'))
            .limit(limit)
        )
        
        popular_species = []
        for species_id, count in result.all():
            # Get species details
            species_result = await db.execute(
                select(PlantSpecies).where(PlantSpecies.id == species_id)
            )
            species = species_result.scalar_one_or_none()
            
            if species:
                popular_species.append({
                    "species_id": species_id,
                    "scientific_name": species.scientific_name,
                    "common_names": species.common_names,
                    "trade_count": count
                })
        
        return popular_species
    
    @staticmethod
    async def get_popular_species_in_trades(
        db: AsyncSession,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get most popular species in trades (alias for get_popular_species).
        
        Args:
            db: Database session
            limit: Maximum number of species to return
            
        Returns:
            List of popular species with trade counts
        """
        return await PlantTradeService.get_popular_species(db, limit)


# Convenience functions for dependency injection
async def create_trade(
    db: AsyncSession,
    user_id: UUID,
    trade_data: PlantTradeCreate
) -> PlantTrade:
    """Create a new plant trade listing."""
    return await PlantTradeService.create_trade(db, user_id, trade_data)


async def get_trade_by_id(
    db: AsyncSession,
    trade_id: UUID,
    include_inactive: bool = False
) -> Optional[PlantTrade]:
    """Get trade by ID."""
    return await PlantTradeService.get_trade_by_id(db, trade_id, include_inactive)


async def search_trades(
    db: AsyncSession,
    search_params: PlantTradeSearchRequest,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantTrade], int]:
    """Search plant trades."""
    return await PlantTradeService.search_trades(db, search_params, skip, limit)


async def express_interest(
    db: AsyncSession,
    trade_id: UUID,
    user_id: UUID
) -> Optional[PlantTrade]:
    """Express interest in a trade."""
    return await PlantTradeService.express_interest(db, trade_id, user_id)


async def get_trade_statistics(
    db: AsyncSession,
    user_id: Optional[UUID] = None
) -> Dict[str, Any]:
    """Get trade statistics."""
    return await PlantTradeService.get_trade_statistics(db, user_id)


async def get_user_trades(
    db: AsyncSession,
    user_id: UUID,
    status: Optional[TradeStatus] = None,
    trade_type: Optional[TradeType] = None,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantTrade], int]:
    """Get trades owned by a user."""
    return await PlantTradeService.get_user_trades(
        db, user_id, status, trade_type, skip, limit
    )


async def update_trade(
    db: AsyncSession,
    trade_id: UUID,
    user_id: UUID,
    trade_data: PlantTradeUpdate
) -> Optional[PlantTrade]:
    """Update trade listing."""
    return await PlantTradeService.update_trade(db, trade_id, user_id, trade_data)


async def accept_trade(
    db: AsyncSession,
    trade_id: UUID,
    user_id: UUID
) -> Optional[PlantTrade]:
    """Accept a trade offer."""
    return await PlantTradeService.accept_trade(db, trade_id, user_id)


async def cancel_trade(
    db: AsyncSession,
    trade_id: UUID,
    user_id: UUID
) -> Optional[PlantTrade]:
    """Cancel a trade."""
    return await PlantTradeService.cancel_trade(db, trade_id, user_id)


async def delete_trade(db: AsyncSession, trade_id: UUID, user_id: UUID) -> bool:
    """Delete trade listing (soft delete)."""
    return await PlantTradeService.delete_trade(db, trade_id, user_id)


async def get_popular_species_in_trades(
    db: AsyncSession,
    limit: int = 10
) -> List[Dict[str, Any]]:
    """Get popular species in trades."""
    return await PlantTradeService.get_popular_species_in_trades(db, limit)


async def get_trade_stats(
    db: AsyncSession,
    user_id: Optional[UUID] = None
) -> Dict[str, Any]:
    """Get trade statistics."""
    return await PlantTradeService.get_trade_statistics(db, user_id)


async def get_popular_trade_species(
    db: AsyncSession,
    limit: int = 10
) -> List[Dict[str, Any]]:
    """Get popular species in trades."""
    return await PlantTradeService.get_popular_species(db, limit)
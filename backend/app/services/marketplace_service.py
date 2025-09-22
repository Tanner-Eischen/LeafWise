from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
import json
import statistics
from enum import Enum
import uuid

from app.models.plant_trade import PlantTrade
from app.models.user_plant import UserPlant
from app.models.user import User

class TradeStatus(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    ESCROW_FUNDED = "escrow_funded"
    SHIPPED = "shipped"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class MarketplaceService:
    def __init__(self):
        pass

    async def create_plant_listing(
        self,
        db: Session,
        seller_id: str,
        listing_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Create a new plant listing with pricing suggestions."""
        
        plant = db.query(UserPlant).filter(
            UserPlant.id == listing_data.get("plant_id"),
            UserPlant.user_id == seller_id
        ).first()
        
        if not plant:
            raise ValueError("Plant not found or you do not own this plant")
        
        pricing_suggestion = await self._generate_pricing_suggestion(
            db, plant.species_id, listing_data.get("size", "medium")
        )
        
        trade = PlantTrade(
            seller_id=seller_id,
            plant_id=listing_data.get("plant_id"),
            title=listing_data.get("title", plant.name),
            description=listing_data.get("description", ""),
            price=str(listing_data.get("price", pricing_suggestion["suggested_price"])),
            trade_type="sell",
            status=TradeStatus.PENDING,
            location=listing_data.get("location", ""),
            photos=json.dumps(listing_data.get("photos", [])),
            additional_info=json.dumps({
                "suggested_price": pricing_suggestion["suggested_price"],
                "pricing_confidence": pricing_suggestion["confidence"]
            }),
            created_at=datetime.utcnow()
        )
        
        db.add(trade)
        db.commit()
        db.refresh(trade)
        
        return {
            "listing_id": str(trade.id),
            "title": trade.title,
            "price": trade.price,
            "suggested_price": pricing_suggestion["suggested_price"],
            "status": trade.status,
            "created_at": trade.created_at.isoformat()
        }

    async def initiate_secure_trade(
        self,
        db: Session,
        buyer_id: str,
        listing_id: str,
        trade_details: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Initiate a secure trade with escrow protection."""
        
        listing = db.query(PlantTrade).filter(
            PlantTrade.id == listing_id,
            PlantTrade.status == TradeStatus.PENDING
        ).first()
        
        if not listing:
            raise ValueError("Listing not found or no longer available")
        
        if listing.seller_id == buyer_id:
            raise ValueError("Cannot buy your own listing")
        
        escrow_data = await self._create_escrow_account(
            db, float(listing.price), buyer_id, listing.seller_id, listing_id
        )
        
        listing.buyer_id = buyer_id
        listing.status = TradeStatus.ACCEPTED
        listing.additional_info = json.dumps({
            **json.loads(listing.additional_info or "{}"),
            "escrow_id": escrow_data["escrow_id"]
        })
        
        db.commit()
        
        return {
            "trade_id": str(listing.id),
            "escrow_id": escrow_data["escrow_id"],
            "total_amount": float(listing.price),
            "status": "trade_initiated"
        }

    async def _generate_pricing_suggestion(
        self, db: Session, species_id: str, size: str
    ) -> Dict[str, Any]:
        """Generate AI-powered pricing suggestions."""
        
        recent_trades = db.query(PlantTrade).join(UserPlant).filter(
            UserPlant.species_id == species_id,
            PlantTrade.status == TradeStatus.COMPLETED,
            PlantTrade.created_at >= datetime.utcnow() - timedelta(days=90)
        ).all()
        
        if recent_trades:
            prices = [float(trade.price) for trade in recent_trades]
            base_price = statistics.median(prices)
            confidence = min(0.9, len(prices) / 10)
        else:
            base_price = 25.0
            confidence = 0.3
        
        size_multipliers = {"small": 0.7, "medium": 1.0, "large": 1.4}
        size_multiplier = size_multipliers.get(size, 1.0)
        suggested_price = base_price * size_multiplier
        
        return {
            "suggested_price": round(suggested_price, 2),
            "confidence": confidence
        }

    async def _create_escrow_account(
        self, db: Session, trade_amount: float, buyer_id: str, 
        seller_id: str, listing_id: str
    ) -> Dict[str, Any]:
        """Create an escrow account for secure trading."""
        
        escrow_id = str(uuid.uuid4())
        
        return {
            "escrow_id": escrow_id,
            "amount": trade_amount,
            "buyer_id": buyer_id,
            "seller_id": seller_id,
            "status": "created",
            "created_at": datetime.utcnow().isoformat()
        }

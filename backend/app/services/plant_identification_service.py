"""Plant identification service.

This module provides business logic for AI-powered plant identification,
including image processing, species matching, and verification.
"""

import os
import base64
import logging
from datetime import datetime
from typing import List, Optional, Dict, Any, Tuple
from uuid import UUID
from io import BytesIO
from pathlib import Path

import aiofiles
from openai import AsyncOpenAI
from PIL import Image
from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.models.plant_identification import PlantIdentification
from app.models.plant_species import PlantSpecies
from app.schemas.plant_identification import PlantIdentificationCreate, PlantIdentificationUpdate

logger = logging.getLogger(__name__)


class PlantIdentificationService:
    """Service for managing plant identification."""
    
    def __init__(self):
        """Initialize the plant identification service."""
        self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY) if settings.OPENAI_API_KEY else None
        self.upload_dir = Path("uploads/plant_images")
        self.upload_dir.mkdir(parents=True, exist_ok=True)
    
    async def process_plant_image(
        self,
        image_data: bytes,
        filename: str,
        user_id: UUID,
        db: AsyncSession,
        location: Optional[str] = None,
        notes: Optional[str] = None
    ) -> PlantIdentification:
        """Process uploaded plant image and perform AI identification.
        
        Args:
            image_data: Binary image data
            filename: Original filename
            user_id: User ID
            db: Database session
            location: Optional location where photo was taken
            notes: Optional user notes
            
        Returns:
            PlantIdentification with AI results
        """
        try:
            # Save image file
            image_path = await self._save_image(image_data, filename, user_id)
            
            # Perform AI identification
            identification_result = await self._identify_plant_with_ai(image_path, image_data)
            
            # Find matching species in database
            species_match = await self._find_species_match(
                db, 
                identification_result["identified_name"],
                identification_result["suggestions"]
            )
            
            # Create identification record
            identification_data = PlantIdentificationCreate(
                image_path=str(image_path)
            )
            
            identification = PlantIdentification(
                user_id=user_id,
                image_path=str(image_path),
                confidence_score=identification_result["confidence_score"],
                identified_name=identification_result["identified_name"],
                species_id=species_match["species_id"] if species_match else None,
                is_verified=False
            )
            
            db.add(identification)
            await db.commit()
            await db.refresh(identification)
            
            logger.info(f"Plant identification completed for user {user_id}: {identification_result['identified_name']}")
            return identification
            
        except Exception as e:
            logger.error(f"Error processing plant image: {str(e)}")
            raise
    
    async def _save_image(self, image_data: bytes, filename: str, user_id: UUID) -> Path:
        """Save uploaded image to filesystem.
        
        Args:
            image_data: Binary image data
            filename: Original filename
            user_id: User ID
            
        Returns:
            Path to saved image
        """
        try:
            # Process and resize image
            image = Image.open(BytesIO(image_data))
            
            # Convert to RGB if necessary
            if image.mode in ('RGBA', 'LA', 'P'):
                image = image.convert('RGB')
            
            # Resize if too large (max 1920x1920)
            max_size = (1920, 1920)
            if image.size[0] > max_size[0] or image.size[1] > max_size[1]:
                image.thumbnail(max_size, Image.Resampling.LANCZOS)
            
            # Generate unique filename
            timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
            file_extension = Path(filename).suffix.lower()
            if not file_extension:
                file_extension = '.jpg'
            
            new_filename = f"{user_id}_{timestamp}{file_extension}"
            image_path = self.upload_dir / new_filename
            
            # Save image
            image.save(image_path, 'JPEG', quality=85, optimize=True)
            
            logger.info(f"Image saved: {image_path}")
            return image_path
            
        except Exception as e:
            logger.error(f"Error saving image: {str(e)}")
            raise
    
    async def _identify_plant_with_ai(self, image_path: Path, image_data: bytes) -> Dict[str, Any]:
        """Identify plant using OpenAI Vision API.
        
        Args:
            image_path: Path to saved image
            image_data: Binary image data
            
        Returns:
            Dictionary with identification results
        """
        if not self.openai_client:
            logger.warning("OpenAI API key not configured, returning mock identification")
            return self._get_mock_identification()
        
        try:
            # Encode image to base64
            base64_image = base64.b64encode(image_data).decode('utf-8')
            
            # Prepare the prompt for plant identification
            prompt = """
            You are an expert botanist. Analyze this plant image and provide identification information.
            
            Please respond with a JSON object containing:
            {
                "identified_name": "Most likely plant name (common name)",
                "scientific_name": "Scientific name if confident",
                "confidence_score": 0.0-1.0,
                "suggestions": [
                    {
                        "name": "Alternative plant name",
                        "scientific_name": "Scientific name",
                        "confidence": 0.0-1.0,
                        "reasoning": "Why this could be the plant"
                    }
                ],
                "plant_characteristics": {
                    "leaf_shape": "Description",
                    "leaf_arrangement": "Description", 
                    "flower_color": "Color if visible",
                    "growth_habit": "Description"
                },
                "care_recommendations": {
                    "light_requirements": "Light needs",
                    "water_requirements": "Watering needs",
                    "soil_type": "Soil preferences",
                    "difficulty_level": "beginner/intermediate/advanced"
                },
                "additional_notes": "Any other relevant information"
            }
            
            Focus on accuracy and provide multiple suggestions if uncertain. 
            If you cannot identify the plant confidently, indicate this in the confidence score and suggestions.
            """
            
            # Make API call to OpenAI Vision
            response = await self.openai_client.chat.completions.create(
                model="gpt-4-vision-preview",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": prompt},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{base64_image}",
                                    "detail": "high"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=1000,
                temperature=0.1
            )
            
            # Parse the response
            ai_response = response.choices[0].message.content
            
            # Try to extract JSON from response
            try:
                import json
                # Find JSON in the response (it might be wrapped in markdown)
                json_start = ai_response.find('{')
                json_end = ai_response.rfind('}') + 1
                if json_start != -1 and json_end > json_start:
                    json_str = ai_response[json_start:json_end]
                    identification_data = json.loads(json_str)
                else:
                    raise ValueError("No JSON found in response")
            except (json.JSONDecodeError, ValueError):
                # Fallback: parse the response manually
                identification_data = self._parse_ai_response_fallback(ai_response)
            
            # Validate and clean the data
            result = {
                "identified_name": identification_data.get("identified_name", "Unknown Plant"),
                "scientific_name": identification_data.get("scientific_name", ""),
                "confidence_score": float(identification_data.get("confidence_score", 0.5)),
                "suggestions": identification_data.get("suggestions", []),
                "plant_characteristics": identification_data.get("plant_characteristics", {}),
                "care_recommendations": identification_data.get("care_recommendations", {}),
                "additional_notes": identification_data.get("additional_notes", "")
            }
            
            logger.info(f"AI identification completed: {result['identified_name']} (confidence: {result['confidence_score']})")
            return result
            
        except Exception as e:
            logger.error(f"Error in AI identification: {str(e)}")
            # Return fallback identification
            return {
                "identified_name": "Plant identification unavailable",
                "scientific_name": "",
                "confidence_score": 0.0,
                "suggestions": [],
                "plant_characteristics": {},
                "care_recommendations": {},
                "additional_notes": f"AI identification failed: {str(e)}"
            }
    
    def _parse_ai_response_fallback(self, response: str) -> Dict[str, Any]:
        """Fallback parser for AI response when JSON parsing fails.
        
        Args:
            response: AI response text
            
        Returns:
            Parsed identification data
        """
        # Simple text parsing fallback
        lines = response.split('\n')
        
        identified_name = "Unknown Plant"
        confidence_score = 0.5
        
        for line in lines:
            line = line.strip()
            if 'identified' in line.lower() or 'plant' in line.lower():
                # Try to extract plant name
                if ':' in line:
                    identified_name = line.split(':', 1)[1].strip()
                    break
        
        return {
            "identified_name": identified_name,
            "scientific_name": "",
            "confidence_score": confidence_score,
            "suggestions": [],
            "plant_characteristics": {},
            "care_recommendations": {},
            "additional_notes": "Parsed from text response"
        }
    
    def _get_mock_identification(self) -> Dict[str, Any]:
        """Get mock identification data when AI service is unavailable.
        
        Returns:
            Mock identification data
        """
        return {
            "identified_name": "Pothos",
            "scientific_name": "Epipremnum aureum",
            "confidence_score": 0.75,
            "suggestions": [
                {
                    "name": "Golden Pothos",
                    "scientific_name": "Epipremnum aureum",
                    "confidence": 0.75,
                    "reasoning": "Heart-shaped leaves with variegation pattern"
                },
                {
                    "name": "Philodendron",
                    "scientific_name": "Philodendron hederaceum",
                    "confidence": 0.60,
                    "reasoning": "Similar leaf shape and growth pattern"
                }
            ],
            "plant_characteristics": {
                "leaf_shape": "Heart-shaped",
                "leaf_arrangement": "Alternate",
                "growth_habit": "Trailing vine"
            },
            "care_recommendations": {
                "light_requirements": "Bright, indirect light",
                "water_requirements": "Water when soil is dry",
                "soil_type": "Well-draining potting mix",
                "difficulty_level": "beginner"
            },
            "additional_notes": "Mock identification - OpenAI API not configured"
        }
    
    async def _find_species_match(
        self, 
        db: AsyncSession, 
        identified_name: str, 
        suggestions: List[Dict[str, Any]]
    ) -> Optional[Dict[str, Any]]:
        """Find matching plant species in database.
        
        Args:
            db: Database session
            identified_name: Primary identified name
            suggestions: List of alternative suggestions
            
        Returns:
            Dictionary with species match info or None
        """
        try:
            # Search for exact matches first
            search_names = [identified_name]
            
            # Add scientific names from suggestions
            for suggestion in suggestions:
                if suggestion.get("scientific_name"):
                    search_names.append(suggestion["scientific_name"])
                if suggestion.get("name"):
                    search_names.append(suggestion["name"])
            
            # Query database for matches
            for name in search_names:
                # Try exact match on scientific name
                result = await db.execute(
                    select(PlantSpecies).where(
                        func.lower(PlantSpecies.scientific_name) == name.lower()
                    )
                )
                species = result.scalar_one_or_none()
                
                if species:
                    return {
                        "species_id": species.id,
                        "match_type": "scientific_name",
                        "match_confidence": 0.9
                    }
                
                # Try exact match on common name
                result = await db.execute(
                    select(PlantSpecies).where(
                        func.lower(PlantSpecies.common_name) == name.lower()
                    )
                )
                species = result.scalar_one_or_none()
                
                if species:
                    return {
                        "species_id": species.id,
                        "match_type": "common_name", 
                        "match_confidence": 0.8
                    }
            
            # Try fuzzy matching (simplified)
            for name in search_names[:3]:  # Limit to top 3 names
                result = await db.execute(
                    select(PlantSpecies).where(
                        func.lower(PlantSpecies.scientific_name).contains(name.lower().split()[0])
                    ).limit(1)
                )
                species = result.scalar_one_or_none()
                
                if species:
                    return {
                        "species_id": species.id,
                        "match_type": "fuzzy",
                        "match_confidence": 0.6
                    }
            
            return None
            
        except Exception as e:
            logger.error(f"Error finding species match: {str(e)}")
            return None
    
    async def get_identification_with_ai_details(
        self,
        db: AsyncSession,
        identification_id: UUID,
        user_id: Optional[UUID] = None
    ) -> Optional[Dict[str, Any]]:
        """Get identification with detailed AI analysis.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: Optional user ID for ownership check
            
        Returns:
            Identification with AI details or None
        """
        try:
            identification = await self.get_identification_by_id(db, identification_id, user_id)
            
            if not identification:
                return None
            
            # If we have the image, we could re-analyze it for more details
            # For now, return the stored identification with enhanced info
            result = {
                "identification": identification,
                "ai_analysis": {
                    "confidence_score": identification.confidence_score,
                    "identified_name": identification.identified_name,
                    "analysis_date": identification.created_at,
                    "model_version": "gpt-4-vision-preview"
                }
            }
            
            return result
            
        except Exception as e:
            logger.error(f"Error getting identification with AI details: {str(e)}")
            return None
    
    @staticmethod
    async def create_identification(
        db: AsyncSession,
        user_id: UUID,
        identification_data: PlantIdentificationCreate
    ) -> PlantIdentification:
        """Create a new plant identification record.
        
        Args:
            db: Database session
            user_id: User ID
            identification_data: Identification creation data
            
        Returns:
            Created identification record
        """
        identification = PlantIdentification(
            user_id=user_id,
            **identification_data.dict()
        )
        db.add(identification)
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def get_identification_by_id(
        db: AsyncSession,
        identification_id: UUID,
        user_id: Optional[UUID] = None
    ) -> Optional[PlantIdentification]:
        """Get identification by ID.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: Optional user ID for ownership check
            
        Returns:
            Identification if found and accessible, None otherwise
        """
        query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species),
            selectinload(PlantIdentification.user)
        ).where(PlantIdentification.id == identification_id)
        
        if user_id:
            query = query.where(PlantIdentification.user_id == user_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_user_identifications(
        db: AsyncSession,
        user_id: UUID,
        verified_only: Optional[bool] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantIdentification], int]:
        """Get identifications by user.
        
        Args:
            db: Database session
            user_id: User ID
            verified_only: Filter by verification status
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (identifications list, total count)
        """
        # Build base query
        base_query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species)
        ).where(PlantIdentification.user_id == user_id)
        
        count_query = select(func.count(PlantIdentification.id)).where(
            PlantIdentification.user_id == user_id
        )
        
        if verified_only is not None:
            base_query = base_query.where(PlantIdentification.is_verified == verified_only)
            count_query = count_query.where(PlantIdentification.is_verified == verified_only)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(desc(PlantIdentification.created_at))
            .offset(skip)
            .limit(limit)
        )
        identifications = result.scalars().all()
        
        return list(identifications), total
    
    @staticmethod
    async def update_identification(
        db: AsyncSession,
        identification_id: UUID,
        user_id: UUID,
        identification_data: PlantIdentificationUpdate
    ) -> Optional[PlantIdentification]:
        """Update identification record.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: User ID (for ownership verification)
            identification_data: Update data
            
        Returns:
            Updated identification if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(PlantIdentification).where(
                and_(
                    PlantIdentification.id == identification_id,
                    PlantIdentification.user_id == user_id
                )
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return None
        
        # Update fields
        update_data = identification_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(identification, field, value)
        
        identification.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def verify_identification(
        db: AsyncSession,
        identification_id: UUID,
        verified_by_user_id: UUID,
        is_correct: bool,
        correct_species_id: Optional[UUID] = None
    ) -> Optional[PlantIdentification]:
        """Verify an identification (community verification).
        
        Args:
            db: Database session
            identification_id: Identification ID
            verified_by_user_id: User ID of verifier
            is_correct: Whether the identification is correct
            correct_species_id: Correct species ID if identification was wrong
            
        Returns:
            Updated identification if found, None otherwise
        """
        result = await db.execute(
            select(PlantIdentification).where(
                PlantIdentification.id == identification_id
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return None
        
        # Update verification status
        identification.is_verified = True
        identification.verified_at = datetime.utcnow()
        identification.verified_by_user_id = verified_by_user_id
        
        # If identification was incorrect, update with correct species
        if not is_correct and correct_species_id:
            identification.species_id = correct_species_id
            identification.confidence_score = 1.0  # Human verification is 100% confident
        
        identification.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def delete_identification(
        db: AsyncSession,
        identification_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete identification record.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: User ID (for ownership verification)
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(PlantIdentification).where(
                and_(
                    PlantIdentification.id == identification_id,
                    PlantIdentification.user_id == user_id
                )
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return False
        
        # Delete image file if it exists
        if identification.image_path and os.path.exists(identification.image_path):
            try:
                os.remove(identification.image_path)
            except OSError:
                pass  # File might already be deleted
        
        await db.delete(identification)
        await db.commit()
        return True
    
    @staticmethod
    async def get_pending_verifications(
        db: AsyncSession,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantIdentification], int]:
        """Get identifications pending verification.
        
        Args:
            db: Database session
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (identifications list, total count)
        """
        # Build query for unverified identifications
        base_query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species),
            selectinload(PlantIdentification.user)
        ).where(PlantIdentification.is_verified == False)
        
        count_query = select(func.count(PlantIdentification.id)).where(
            PlantIdentification.is_verified == False
        )
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results, ordered by confidence score (lowest first for review)
        result = await db.execute(
            base_query.order_by(PlantIdentification.confidence_score.asc())
            .offset(skip)
            .limit(limit)
        )
        identifications = result.scalars().all()
        
        return list(identifications), total
    
    @staticmethod
    async def get_identification_statistics(
        db: AsyncSession,
        user_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Get identification statistics.
        
        Args:
            db: Database session
            user_id: Optional user ID for user-specific stats
            
        Returns:
            Dictionary with identification statistics
        """
        base_query = select(PlantIdentification)
        
        if user_id:
            base_query = base_query.where(PlantIdentification.user_id == user_id)
        
        # Total identifications
        total_result = await db.execute(
            select(func.count(PlantIdentification.id)).where(
                PlantIdentification.user_id == user_id if user_id else True
            )
        )
        total_identifications = total_result.scalar()
        
        # Verified identifications
        verified_result = await db.execute(
            select(func.count(PlantIdentification.id)).where(
                and_(
                    PlantIdentification.is_verified == True,
                    PlantIdentification.user_id == user_id if user_id else True
                )
            )
        )
        verified_identifications = verified_result.scalar()
        
        # Average confidence score
        avg_confidence_result = await db.execute(
            select(func.avg(PlantIdentification.confidence_score)).where(
                PlantIdentification.user_id == user_id if user_id else True
            )
        )
        avg_confidence = avg_confidence_result.scalar() or 0.0
        
        # Most identified species
        species_result = await db.execute(
            select(
                PlantIdentification.species_id,
                func.count(PlantIdentification.id).label('count')
            ).where(
                PlantIdentification.user_id == user_id if user_id else True
            ).group_by(PlantIdentification.species_id)
            .order_by(desc('count'))
            .limit(5)
        )
        top_species = species_result.all()
        
        # Get species names for top species
        top_species_with_names = []
        for species_id, count in top_species:
            if species_id:
                species_result = await db.execute(
                    select(PlantSpecies).where(PlantSpecies.id == species_id)
                )
                species = species_result.scalar_one_or_none()
                if species:
                    top_species_with_names.append({
                        "species_id": species_id,
                        "scientific_name": species.scientific_name,
                        "common_names": species.common_names,
                        "count": count
                    })
        
        return {
            "total_identifications": total_identifications,
            "verified_identifications": verified_identifications,
            "pending_verification": total_identifications - verified_identifications,
            "verification_rate": round(
                (verified_identifications / total_identifications * 100) if total_identifications > 0 else 0, 2
            ),
            "average_confidence_score": round(float(avg_confidence), 3),
            "top_identified_species": top_species_with_names
        }
    
    @staticmethod
    async def search_similar_identifications(
        db: AsyncSession,
        species_id: UUID,
        confidence_threshold: float = 0.8,
        limit: int = 10
    ) -> List[PlantIdentification]:
        """Search for similar identifications of the same species.
        
        Args:
            db: Database session
            species_id: Species ID to search for
            confidence_threshold: Minimum confidence score
            limit: Maximum number of results
            
        Returns:
            List of similar identifications
        """
        result = await db.execute(
            select(PlantIdentification).options(
                selectinload(PlantIdentification.user)
            ).where(
                and_(
                    PlantIdentification.species_id == species_id,
                    PlantIdentification.confidence_score >= confidence_threshold,
                    PlantIdentification.is_verified == True
                )
            ).order_by(desc(PlantIdentification.confidence_score))
            .limit(limit)
        )
        
        return list(result.scalars().all())


# Convenience functions for dependency injection
async def create_identification(
    db: AsyncSession,
    user_id: UUID,
    identification_data: PlantIdentificationCreate
) -> PlantIdentification:
    """Create a new plant identification record."""
    return await PlantIdentificationService.create_identification(
        db, user_id, identification_data
    )


async def get_identification_by_id(
    db: AsyncSession,
    identification_id: UUID,
    user_id: Optional[UUID] = None
) -> Optional[PlantIdentification]:
    """Get identification by ID."""
    return await PlantIdentificationService.get_identification_by_id(
        db, identification_id, user_id
    )


async def get_user_identifications(
    db: AsyncSession,
    user_id: UUID,
    verified_only: Optional[bool] = None,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantIdentification], int]:
    """Get identifications by user."""
    return await PlantIdentificationService.get_user_identifications(
        db, user_id, verified_only, skip, limit
    )


async def verify_identification(
    db: AsyncSession,
    identification_id: UUID,
    verified_by_user_id: UUID,
    is_correct: bool,
    correct_species_id: Optional[UUID] = None
) -> Optional[PlantIdentification]:
    """Verify an identification."""
    return await PlantIdentificationService.verify_identification(
        db, identification_id, verified_by_user_id, is_correct, correct_species_id
    )


async def get_pending_verifications(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantIdentification], int]:
    """Get identifications pending verification."""
    return await PlantIdentificationService.get_pending_verifications(db, skip, limit)


async def get_identification_statistics(
    db: AsyncSession,
    user_id: Optional[UUID] = None
) -> Dict[str, Any]:
    """Get identification statistics."""
    return await PlantIdentificationService.get_identification_statistics(db, user_id)


async def update_identification(
    db: AsyncSession,
    identification_id: UUID,
    user_id: UUID,
    identification_data: PlantIdentificationUpdate
) -> Optional[PlantIdentification]:
    """Update identification record."""
    return await PlantIdentificationService.update_identification(
        db, identification_id, user_id, identification_data
    )


async def delete_identification(
    db: AsyncSession,
    identification_id: UUID,
    user_id: UUID
) -> bool:
    """Delete identification record."""
    return await PlantIdentificationService.delete_identification(
        db, identification_id, user_id
    )
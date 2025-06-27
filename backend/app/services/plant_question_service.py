"""Plant question service.

This module provides business logic for the plant Q&A community,
including questions, answers, voting, and moderation.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

from sqlalchemy import and_, or_, func, desc, asc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.plant_species import PlantSpecies
from app.schemas.plant_question import (
    PlantQuestionCreate, PlantQuestionUpdate,
    PlantAnswerCreate, PlantAnswerUpdate,
    PlantQuestionSearchRequest
)


class PlantQuestionService:
    """Service for managing plant questions."""
    
    @staticmethod
    async def create_question(
        db: AsyncSession,
        user_id: UUID,
        question_data: PlantQuestionCreate
    ) -> PlantQuestion:
        """Create a new plant question.
        
        Args:
            db: Database session
            user_id: Author user ID
            question_data: Question creation data
            
        Returns:
            Created question
        """
        question = PlantQuestion(
            author_id=user_id,
            **question_data.dict()
        )
        db.add(question)
        await db.commit()
        await db.refresh(question)
        return question
    
    @staticmethod
    async def get_question_by_id(
        db: AsyncSession,
        question_id: UUID,
        include_answers: bool = True
    ) -> Optional[PlantQuestion]:
        """Get question by ID.
        
        Args:
            db: Database session
            question_id: Question ID
            include_answers: Whether to include answers
            
        Returns:
            Question if found, None otherwise
        """
        query = select(PlantQuestion).options(
            selectinload(PlantQuestion.author),
            selectinload(PlantQuestion.species)
        )
        
        if include_answers:
            query = query.options(
                selectinload(PlantQuestion.answers).selectinload(PlantAnswer.author)
            )
        
        query = query.where(PlantQuestion.id == question_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def search_questions(
        db: AsyncSession,
        search_params: PlantQuestionSearchRequest,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantQuestion], int]:
        """Search plant questions with filters.
        
        Args:
            db: Database session
            search_params: Search parameters
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (questions list, total count)
        """
        # Build base query
        base_query = select(PlantQuestion).options(
            selectinload(PlantQuestion.author),
            selectinload(PlantQuestion.species)
        )
        
        count_query = select(func.count(PlantQuestion.id))
        
        # Apply search filters
        filters = []
        
        if search_params.query:
            search_filter = or_(
                PlantQuestion.title.ilike(f"%{search_params.query}%"),
                PlantQuestion.content.ilike(f"%{search_params.query}%")
            )
            filters.append(search_filter)
        
        if search_params.species_id:
            filters.append(PlantQuestion.species_id == search_params.species_id)
        
        if search_params.tags:
            # Search for questions that have any of the specified tags
            tag_filters = []
            for tag in search_params.tags:
                tag_filters.append(PlantQuestion.tags.contains([tag]))
            if tag_filters:
                filters.append(or_(*tag_filters))
        
        if search_params.is_solved is not None:
            filters.append(PlantQuestion.is_solved == search_params.is_solved)
        
        if search_params.author_id:
            filters.append(PlantQuestion.author_id == search_params.author_id)
        
        # Apply filters to queries
        if filters:
            filter_condition = and_(*filters)
            base_query = base_query.where(filter_condition)
            count_query = count_query.where(filter_condition)
        
        # Apply sorting
        if search_params.sort_by == "newest":
            base_query = base_query.order_by(desc(PlantQuestion.created_at))
        elif search_params.sort_by == "oldest":
            base_query = base_query.order_by(asc(PlantQuestion.created_at))
        elif search_params.sort_by == "most_answers":
            # Count answers for each question
            base_query = base_query.outerjoin(PlantAnswer).group_by(PlantQuestion.id)
            base_query = base_query.order_by(desc(func.count(PlantAnswer.id)))
        elif search_params.sort_by == "unsolved":
            base_query = base_query.where(PlantQuestion.is_solved == False)
            base_query = base_query.order_by(desc(PlantQuestion.created_at))
        else:  # Default to newest
            base_query = base_query.order_by(desc(PlantQuestion.created_at))
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.offset(skip).limit(limit)
        )
        questions = result.scalars().all()
        
        return list(questions), total
    
    @staticmethod
    async def update_question(
        db: AsyncSession,
        question_id: UUID,
        user_id: UUID,
        question_data: PlantQuestionUpdate
    ) -> Optional[PlantQuestion]:
        """Update question.
        
        Args:
            db: Database session
            question_id: Question ID
            user_id: Author user ID
            question_data: Update data
            
        Returns:
            Updated question if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(PlantQuestion).where(
                and_(
                    PlantQuestion.id == question_id,
                    PlantQuestion.author_id == user_id
                )
            )
        )
        question = result.scalar_one_or_none()
        
        if not question:
            return None
        
        # Update fields
        update_data = question_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(question, field, value)
        
        question.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(question)
        return question
    
    @staticmethod
    async def mark_question_solved(
        db: AsyncSession,
        question_id: UUID,
        user_id: UUID,
        accepted_answer_id: Optional[UUID] = None
    ) -> Optional[PlantQuestion]:
        """Mark question as solved.
        
        Args:
            db: Database session
            question_id: Question ID
            user_id: Author user ID
            accepted_answer_id: Optional accepted answer ID
            
        Returns:
            Updated question if successful, None otherwise
        """
        result = await db.execute(
            select(PlantQuestion).where(
                and_(
                    PlantQuestion.id == question_id,
                    PlantQuestion.author_id == user_id
                )
            )
        )
        question = result.scalar_one_or_none()
        
        if not question:
            return None
        
        # Mark as solved
        question.is_solved = True
        question.solved_at = datetime.utcnow()
        question.updated_at = datetime.utcnow()
        
        # Mark accepted answer if provided
        if accepted_answer_id:
            answer_result = await db.execute(
                select(PlantAnswer).where(
                    and_(
                        PlantAnswer.id == accepted_answer_id,
                        PlantAnswer.question_id == question_id
                    )
                )
            )
            answer = answer_result.scalar_one_or_none()
            if answer:
                answer.is_accepted = True
                answer.updated_at = datetime.utcnow()
        
        await db.commit()
        await db.refresh(question)
        return question
    
    @staticmethod
    async def delete_question(
        db: AsyncSession,
        question_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete question.
        
        Args:
            db: Database session
            question_id: Question ID
            user_id: Author user ID
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(PlantQuestion).where(
                and_(
                    PlantQuestion.id == question_id,
                    PlantQuestion.author_id == user_id
                )
            )
        )
        question = result.scalar_one_or_none()
        
        if not question:
            return False
        
        # Delete associated answers first
        await db.execute(
            select(PlantAnswer).where(PlantAnswer.question_id == question_id)
        )
        
        await db.delete(question)
        await db.commit()
        return True


class PlantAnswerService:
    """Service for managing plant answers."""
    
    @staticmethod
    async def create_answer(
        db: AsyncSession,
        user_id: UUID,
        answer_data: PlantAnswerCreate
    ) -> Optional[PlantAnswer]:
        """Create a new answer.
        
        Args:
            db: Database session
            user_id: Author user ID
            answer_data: Answer creation data
            
        Returns:
            Created answer if question exists, None otherwise
        """
        # Verify question exists
        question_result = await db.execute(
            select(PlantQuestion).where(PlantQuestion.id == answer_data.question_id)
        )
        question = question_result.scalar_one_or_none()
        
        if not question:
            return None
        
        answer = PlantAnswer(
            author_id=user_id,
            **answer_data.dict()
        )
        db.add(answer)
        await db.commit()
        await db.refresh(answer)
        return answer
    
    @staticmethod
    async def get_answer_by_id(
        db: AsyncSession,
        answer_id: UUID
    ) -> Optional[PlantAnswer]:
        """Get answer by ID.
        
        Args:
            db: Database session
            answer_id: Answer ID
            
        Returns:
            Answer if found, None otherwise
        """
        result = await db.execute(
            select(PlantAnswer).options(
                selectinload(PlantAnswer.author),
                selectinload(PlantAnswer.question)
            ).where(PlantAnswer.id == answer_id)
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_question_answers(
        db: AsyncSession,
        question_id: UUID,
        skip: int = 0,
        limit: int = 50
    ) -> tuple[List[PlantAnswer], int]:
        """Get answers for a question.
        
        Args:
            db: Database session
            question_id: Question ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (answers list, total count)
        """
        # Build base query
        base_query = select(PlantAnswer).options(
            selectinload(PlantAnswer.author)
        ).where(PlantAnswer.question_id == question_id)
        
        count_query = select(func.count(PlantAnswer.id)).where(
            PlantAnswer.question_id == question_id
        )
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results, ordered by accepted first, then by votes
        result = await db.execute(
            base_query.order_by(
                desc(PlantAnswer.is_accepted),
                desc(PlantAnswer.upvotes - PlantAnswer.downvotes),
                asc(PlantAnswer.created_at)
            ).offset(skip).limit(limit)
        )
        answers = result.scalars().all()
        
        return list(answers), total
    
    @staticmethod
    async def update_answer(
        db: AsyncSession,
        answer_id: UUID,
        user_id: UUID,
        answer_data: PlantAnswerUpdate
    ) -> Optional[PlantAnswer]:
        """Update answer.
        
        Args:
            db: Database session
            answer_id: Answer ID
            user_id: Author user ID
            answer_data: Update data
            
        Returns:
            Updated answer if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(PlantAnswer).where(
                and_(
                    PlantAnswer.id == answer_id,
                    PlantAnswer.author_id == user_id
                )
            )
        )
        answer = result.scalar_one_or_none()
        
        if not answer:
            return None
        
        # Update fields
        update_data = answer_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(answer, field, value)
        
        answer.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(answer)
        return answer
    
    @staticmethod
    async def vote_answer(
        db: AsyncSession,
        answer_id: UUID,
        user_id: UUID,
        is_upvote: bool
    ) -> Optional[PlantAnswer]:
        """Vote on an answer.
        
        Args:
            db: Database session
            answer_id: Answer ID
            user_id: Voter user ID
            is_upvote: True for upvote, False for downvote
            
        Returns:
            Updated answer if found, None otherwise
        """
        result = await db.execute(
            select(PlantAnswer).where(
                and_(
                    PlantAnswer.id == answer_id,
                    PlantAnswer.author_id != user_id  # Can't vote on own answer
                )
            )
        )
        answer = result.scalar_one_or_none()
        
        if not answer:
            return None
        
        # Update vote counts
        if is_upvote:
            answer.upvotes += 1
        else:
            answer.downvotes += 1
        
        answer.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(answer)
        return answer
    
    @staticmethod
    async def delete_answer(
        db: AsyncSession,
        answer_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete answer.
        
        Args:
            db: Database session
            answer_id: Answer ID
            user_id: Author user ID
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(PlantAnswer).where(
                and_(
                    PlantAnswer.id == answer_id,
                    PlantAnswer.author_id == user_id
                )
            )
        )
        answer = result.scalar_one_or_none()
        
        if not answer:
            return False
        
        await db.delete(answer)
        await db.commit()
        return True


# Convenience functions for dependency injection
async def create_question(
    db: AsyncSession,
    user_id: UUID,
    question_data: PlantQuestionCreate
) -> PlantQuestion:
    """Create a new plant question."""
    return await PlantQuestionService.create_question(db, user_id, question_data)


async def get_question_by_id(
    db: AsyncSession,
    question_id: UUID,
    include_answers: bool = True
) -> Optional[PlantQuestion]:
    """Get question by ID."""
    return await PlantQuestionService.get_question_by_id(db, question_id, include_answers)


async def search_questions(
    db: AsyncSession,
    search_params: PlantQuestionSearchRequest,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantQuestion], int]:
    """Search plant questions."""
    return await PlantQuestionService.search_questions(db, search_params, skip, limit)


async def create_answer(
    db: AsyncSession,
    user_id: UUID,
    answer_data: PlantAnswerCreate
) -> Optional[PlantAnswer]:
    """Create a new answer."""
    return await PlantAnswerService.create_answer(db, user_id, answer_data)


async def vote_answer(
    db: AsyncSession,
    answer_id: UUID,
    user_id: UUID,
    is_upvote: bool
) -> Optional[PlantAnswer]:
    """Vote on an answer."""
    return await PlantAnswerService.vote_answer(db, answer_id, user_id, is_upvote)


async def mark_question_solved(
    db: AsyncSession,
    question_id: UUID,
    user_id: UUID,
    accepted_answer_id: Optional[UUID] = None
) -> Optional[PlantQuestion]:
    """Mark question as solved."""
    return await PlantQuestionService.mark_question_solved(
        db, question_id, user_id, accepted_answer_id
    )


def get_plant_question_service() -> PlantQuestionService:
    """Get plant question service instance."""
    return PlantQuestionService()


def get_plant_answer_service() -> PlantAnswerService:
    """Get plant answer service instance."""
    return PlantAnswerService()
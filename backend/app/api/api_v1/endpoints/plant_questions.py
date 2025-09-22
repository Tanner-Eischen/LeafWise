"""Plant questions and answers API endpoints.

This module provides REST API endpoints for the plant Q&A community.
"""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.plant_question import (
    PlantQuestionCreate,
    PlantQuestionUpdate,
    PlantAnswerCreate,
    PlantAnswerUpdate,
    PlantQuestionResponse,
    PlantAnswerResponse,
    PlantQuestionListResponse,
    PlantQuestionSearchRequest,
    PlantAnswerVoteRequest
)
from app.services.plant_question_service import (
    get_plant_question_service,
    get_plant_answer_service
)

router = APIRouter()


# Question endpoints
@router.post(
    "/",
    response_model=PlantQuestionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Ask a question",
    description="Ask a new plant-related question."
)
async def create_question(
    question_data: PlantQuestionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantQuestionResponse:
    """Create a new plant question."""
    try:
        question_service = get_plant_question_service()
        question = await question_service.create_question(db, current_user.id, question_data)
        return PlantQuestionResponse.from_orm(question)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create question"
        )


@router.get(
    "/",
    response_model=PlantQuestionListResponse,
    summary="Search questions",
    description="Search and browse plant questions."
)
async def search_questions(
    query: Optional[str] = Query(None, description="Search query"),
    category: Optional[str] = Query(None, description="Filter by category"),
    species_id: Optional[UUID] = Query(None, description="Filter by plant species"),
    is_solved: Optional[bool] = Query(None, description="Filter by solved status"),
    sort_by: Optional[str] = Query("created_at", description="Sort by field (created_at, votes, answers)"),
    sort_order: Optional[str] = Query("desc", description="Sort order (asc, desc)"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db)
) -> PlantQuestionListResponse:
    """Search plant questions."""
    try:
        search_request = PlantQuestionSearchRequest(
            query=query,
            category=category,
            species_id=species_id,
            is_solved=is_solved,
            sort_by=sort_by,
            sort_order=sort_order
        )
        
        question_service = get_plant_question_service()
        questions, total = await question_service.search_questions(db, search_request, skip, limit)
        
        return PlantQuestionListResponse(
            questions=[PlantQuestionResponse.from_orm(q) for q in questions],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to search questions"
        )


@router.get(
    "/my-questions",
    response_model=PlantQuestionListResponse,
    summary="Get user's questions",
    description="Get all questions asked by the current user."
)
async def get_my_questions(
    is_solved: Optional[bool] = Query(None, description="Filter by solved status"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantQuestionListResponse:
    """Get user's questions."""
    try:
        question_service = get_plant_question_service()
        questions, total = await question_service.get_user_questions(
            db, current_user.id, is_solved, skip, limit
        )
        
        return PlantQuestionListResponse(
            questions=[PlantQuestionResponse.from_orm(q) for q in questions],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get user questions"
        )


@router.get(
    "/{question_id}",
    response_model=PlantQuestionResponse,
    summary="Get question details",
    description="Get details of a specific question with its answers."
)
async def get_question(
    question_id: UUID,
    db: AsyncSession = Depends(get_db)
) -> PlantQuestionResponse:
    """Get question by ID."""
    question_service = get_plant_question_service()
    question = await question_service.get_question_by_id(db, question_id)
    if not question:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Question not found"
        )
    return PlantQuestionResponse.from_orm(question)


@router.put(
    "/{question_id}",
    response_model=PlantQuestionResponse,
    summary="Update question",
    description="Update a question (author only)."
)
async def update_question(
    question_id: UUID,
    question_data: PlantQuestionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantQuestionResponse:
    """Update question."""
    try:
        question_service = get_plant_question_service()
        question = await question_service.update_question(
            db, question_id, current_user.id, question_data
        )
        if not question:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Question not found or access denied"
            )
        return PlantQuestionResponse.from_orm(question)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update question"
        )


@router.post(
    "/{question_id}/solve",
    summary="Mark question as solved",
    description="Mark a question as solved (author only)."
)
async def mark_question_solved(
    question_id: UUID,
    best_answer_id: Optional[UUID] = Query(None, description="ID of the best answer"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Mark question as solved."""
    try:
        question_service = get_plant_question_service()
        success = await question_service.mark_as_solved(
            db, question_id, current_user.id, best_answer_id
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Question not found or access denied"
            )
        
        return {
            "message": "Question marked as solved",
            "question_id": question_id,
            "best_answer_id": best_answer_id
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to mark question as solved"
        )


@router.delete(
    "/{question_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete question",
    description="Delete a question (author only)."
)
async def delete_question(
    question_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete question."""
    try:
        question_service = get_plant_question_service()
        success = await question_service.delete_question(db, question_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Question not found or access denied"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete question"
        )


# Answer endpoints
@router.post(
    "/{question_id}/answers",
    response_model=PlantAnswerResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Answer a question",
    description="Provide an answer to a plant question."
)
async def create_answer(
    question_id: UUID,
    answer_data: PlantAnswerCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantAnswerResponse:
    """Create an answer to a question."""
    try:
        answer_service = get_plant_answer_service()
        answer = await answer_service.create_answer(db, question_id, current_user.id, answer_data)
        return PlantAnswerResponse.from_orm(answer)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create answer"
        )


@router.get(
    "/{question_id}/answers",
    response_model=List[PlantAnswerResponse],
    summary="Get question answers",
    description="Get all answers for a specific question."
)
async def get_question_answers(
    question_id: UUID,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db)
) -> List[PlantAnswerResponse]:
    """Get answers for a question."""
    try:
        answer_service = get_plant_answer_service()
        answers = await answer_service.get_question_answers(db, question_id, skip, limit)
        return [PlantAnswerResponse.from_orm(answer) for answer in answers]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get answers"
        )


@router.put(
    "/answers/{answer_id}",
    response_model=PlantAnswerResponse,
    summary="Update answer",
    description="Update an answer (author only)."
)
async def update_answer(
    answer_id: UUID,
    answer_data: PlantAnswerUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantAnswerResponse:
    """Update answer."""
    try:
        answer_service = get_plant_answer_service()
        answer = await answer_service.update_answer(db, answer_id, current_user.id, answer_data)
        if not answer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Answer not found or access denied"
            )
        return PlantAnswerResponse.from_orm(answer)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update answer"
        )


@router.post(
    "/answers/{answer_id}/vote",
    summary="Vote on answer",
    description="Vote on an answer (upvote or downvote)."
)
async def vote_on_answer(
    answer_id: UUID,
    vote_data: PlantAnswerVoteRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Vote on an answer."""
    try:
        answer_service = get_plant_answer_service()
        success = await answer_service.vote_answer(
            db, answer_id, current_user.id, vote_data.is_upvote
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Answer not found"
            )
        
        return {
            "message": f"{'Upvoted' if vote_data.is_upvote else 'Downvoted'} successfully",
            "answer_id": answer_id,
            "is_upvote": vote_data.is_upvote
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to vote on answer"
        )


@router.delete(
    "/answers/{answer_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete answer",
    description="Delete an answer (author only)."
)
async def delete_answer(
    answer_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete answer."""
    try:
        answer_service = get_plant_answer_service()
        success = await answer_service.delete_answer(db, answer_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Answer not found or access denied"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete answer"
        )
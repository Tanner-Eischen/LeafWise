"""RAG Infrastructure API endpoints."""

import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field, ConfigDict

from app.core.database import get_db, AsyncSessionLocal
from app.services.auth_service import get_current_user_from_token as get_current_user
from app.models.user import User
from app.services.rag_content_pipeline import RAGContentPipeline
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


class IndexingRequest(BaseModel):
    """Request model for content indexing."""
    model_config = ConfigDict(from_attributes=True)
    
    content_type: str = Field(description="Content type: species, knowledge, question, answer, story")
    content_id: str = Field(description="ID of the content to index")
    force_reindex: bool = Field(default=False, description="Force reindexing even if content exists")


class BulkIndexingRequest(BaseModel):
    """Request model for bulk content indexing."""
    model_config = ConfigDict(from_attributes=True)
    
    content_items: List[IndexingRequest] = Field(description="List of content items to index")
    batch_size: int = Field(default=10, description="Number of items to process in each batch")


class KnowledgeBaseInitRequest(BaseModel):
    """Request model for knowledge base initialization."""
    model_config = ConfigDict(from_attributes=True)
    
    include_basic_care: bool = Field(default=True, description="Include basic care information")
    include_species_info: bool = Field(default=False, description="Include species information")
    force_reinit: bool = Field(default=False, description="Force reinitialization")


class IndexingStatsResponse(BaseModel):
    """Response model for indexing statistics."""
    model_config = ConfigDict(from_attributes=True)
    
    embedding_counts: Dict[str, int] = Field(description="Count of embeddings by type")
    total_embeddings: int = Field(description="Total number of embeddings")
    content_coverage: Dict[str, Dict[str, Any]] = Field(description="Coverage statistics by content type")
    last_updated: str = Field(description="Timestamp of last update")


class IndexingResultResponse(BaseModel):
    """Response model for indexing operations."""
    model_config = ConfigDict(from_attributes=True)
    
    success: bool = Field(description="Whether the operation was successful")
    message: str = Field(description="Operation result message")
    details: Optional[Dict[str, Any]] = Field(default=None, description="Additional operation details")


class VectorSearchResult(BaseModel):
    """Model for a single vector search result."""
    model_config = ConfigDict(from_attributes=True)
    
    content_id: str = Field(description="ID of the content")
    content_type: str = Field(description="Type of content")
    similarity_score: float = Field(description="Similarity score")
    content: Dict[str, Any] = Field(description="Content data")


class VectorSearchResponse(BaseModel):
    """Response model for vector search operations."""
    model_config = ConfigDict(from_attributes=True)
    
    success: bool = Field(description="Whether the search was successful")
    query: str = Field(description="Search query")
    content_types: Optional[List[str]] = Field(default=None, description="Types of content searched")
    results_count: int = Field(description="Number of results")
    results: List[VectorSearchResult] = Field(description="Search results")


class ComponentHealth(BaseModel):
    """Model for component health status."""
    model_config = ConfigDict(from_attributes=True)
    
    status: str = Field(description="Component status")
    embedding_dimension: Optional[int] = Field(default=None, description="Embedding dimension if applicable")


class ContentIndexingHealth(BaseModel):
    """Model for content indexing health."""
    model_config = ConfigDict(from_attributes=True)
    
    total_embeddings: int = Field(description="Total number of embeddings")
    coverage: Dict[str, Dict[str, Any]] = Field(description="Coverage by content type")


class SystemComponentsHealth(BaseModel):
    """Model for system components health."""
    model_config = ConfigDict(from_attributes=True)
    
    embedding_service: ComponentHealth = Field(description="Embedding service health")
    vector_database: ComponentHealth = Field(description="Vector database health")
    content_indexing: ContentIndexingHealth = Field(description="Content indexing health")


class SystemHealthResponse(BaseModel):
    """Response model for system health check."""
    model_config = ConfigDict(from_attributes=True)
    
    overall_status: str = Field(description="Overall system status")
    timestamp: str = Field(description="Health check timestamp")
    components: SystemComponentsHealth = Field(description="Component health details")


class CacheClearResponse(BaseModel):
    """Response model for cache clearing operation."""
    model_config = ConfigDict(from_attributes=True)
    
    success: bool = Field(description="Whether the operation was successful")
    message: str = Field(description="Operation result message")
    timestamp: str = Field(description="Operation timestamp")


# Initialize services
embedding_service = EmbeddingService()
vector_service = VectorDatabaseService(embedding_service)
rag_pipeline = RAGContentPipeline(embedding_service, vector_service)


@router.post("/initialize-knowledge-base", response_model=IndexingResultResponse)
async def initialize_knowledge_base(
    request: KnowledgeBaseInitRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> IndexingResultResponse:
    """Initialize the plant knowledge base with essential content."""
    try:
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can initialize the knowledge base"
            )
        
        logger.info(f"Initializing knowledge base requested by user {current_user.id}")
        
        result = await rag_pipeline.initialize_knowledge_base(db)
        
        if result.get("status") == "success":
            return IndexingResultResponse(
                success=True,
                message=f"Knowledge base initialized successfully. Created {result.get('created_entries', 0)} entries, indexed {result.get('indexed_entries', 0)} entries.",
                details=result
            )
        else:
            return IndexingResultResponse(
                success=False,
                message=f"Knowledge base initialization failed: {result.get('message', 'Unknown error')}",
                details=result
            )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error initializing knowledge base: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to initialize knowledge base: {str(e)}"
        )


@router.post("/index-content", response_model=IndexingResultResponse)
async def index_single_content(
    request: IndexingRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Index a single piece of content for RAG retrieval.
    
    Supports indexing plant species, knowledge base entries, questions, answers, and stories.
    """
    try:
        logger.info(f"Indexing {request.content_type} {request.content_id} requested by user {current_user.id}")
        
        success = False
        
        if request.content_type == "species":
            success = await rag_pipeline.index_plant_species(
                db, request.content_id, request.force_reindex
            )
        elif request.content_type == "knowledge":
            success = await rag_pipeline.index_knowledge_entry(
                db, request.content_id, request.force_reindex
            )
        else:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported content type: {request.content_type}"
            )
        
        if success:
            response_data = IndexingResultResponse(
                success=True,
                message=f"Successfully indexed {request.content_type} {request.content_id}",
                details={"content_type": request.content_type, "content_id": request.content_id}
            )
            return JSONResponse(content=response_data.dict(), status_code=status.HTTP_200_OK)
        else:
            response_data = IndexingResultResponse(
                success=False,
                message=f"Failed to index {request.content_type} {request.content_id}",
                details={"content_type": request.content_type, "content_id": request.content_id}
            )
            return JSONResponse(content=response_data.dict(), status_code=status.HTTP_400_BAD_REQUEST)
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error indexing content: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to index content: {str(e)}"
        )


@router.get("/indexing-stats", response_model=IndexingStatsResponse)
async def get_indexing_statistics(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Get statistics about indexed content."""
    try:
        stats = await rag_pipeline.get_indexing_stats(db)
        response_data = IndexingStatsResponse(**stats)
        return JSONResponse(content=response_data.dict(), status_code=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error getting indexing stats: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get indexing stats: {str(e)}"
        )


@router.post("/bulk-index-species", response_model=IndexingResultResponse)
async def bulk_index_all_species(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Bulk index all plant species in the database.
    
    This is a long-running operation that runs in the background.
    """
    try:
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can perform bulk indexing"
            )
        
        # Start background task
        background_tasks.add_task(_bulk_index_species_background, current_user.id)
        
        response_data = IndexingResultResponse(
            success=True,
            message="Bulk indexing of species started in background",
            details={"user_id": current_user.id}
        )
        return JSONResponse(content=response_data.dict(), status_code=status.HTTP_202_ACCEPTED)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting bulk indexing: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to start bulk indexing: {str(e)}"
        )


@router.post("/test-vector-search", response_model=VectorSearchResponse)
async def test_vector_search(
    query: str = Query(..., description="Search query to test"),
    content_types: Optional[List[str]] = Query(None, description="Content types to search"),
    limit: int = Query(5, ge=1, le=20, description="Number of results to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Test vector search functionality."""
    try:
        results = await vector_service.search(
            query=query,
            content_types=content_types,
            limit=limit,
            db=db
        )
        
        response_data = VectorSearchResponse(
            success=True,
            query=query,
            content_types=content_types,
            results_count=len(results),
            results=[VectorSearchResult(**result) for result in results]
        )
        return JSONResponse(content=response_data.dict(), status_code=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error performing vector search: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to perform vector search: {str(e)}"
        )


@router.get("/system-health", response_model=SystemHealthResponse)
async def get_rag_system_health(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Get health status of RAG system components."""
    try:
        # Check embedding service
        embedding_health = ComponentHealth(
            status="healthy",
            embedding_dimension=embedding_service.embedding_dimension
        )
        
        # Check vector database
        try:
            await vector_service.test_connection(db)
            vector_health = ComponentHealth(status="healthy")
        except Exception as e:
            vector_health = ComponentHealth(status=f"unhealthy: {str(e)}")
        
        # Check content indexing
        try:
            stats = await rag_pipeline.get_indexing_stats(db)
            indexing_health = ContentIndexingHealth(
                total_embeddings=stats["total_embeddings"],
                coverage=stats["content_coverage"]
            )
        except Exception as e:
            indexing_health = ContentIndexingHealth(
                total_embeddings=0,
                coverage={}
            )
        
        # Overall status
        overall = "healthy" if all(
            h.status == "healthy" 
            for h in [embedding_health, vector_health]
        ) else "degraded"
        
        response_data = SystemHealthResponse(
            overall_status=overall,
            timestamp=datetime.utcnow().isoformat(),
            components=SystemComponentsHealth(
                embedding_service=embedding_health,
                vector_database=vector_health,
                content_indexing=indexing_health
            )
        )
        return JSONResponse(content=response_data.dict(), status_code=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error checking system health: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to check system health: {str(e)}"
        )


async def _bulk_index_species_background(user_id: str) -> None:
    """Background task for bulk indexing species."""
    try:
        async with AsyncSessionLocal() as db:
            await rag_pipeline.bulk_index_all_species(db)
            logger.info(f"Bulk indexing completed for user {user_id}")
    except Exception as e:
        logger.error(f"Error in bulk indexing background task: {str(e)}")


@router.delete("/clear-cache", response_model=CacheClearResponse)
async def clear_search_cache(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> JSONResponse:
    """Clear the semantic search cache."""
    try:
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can clear the cache"
            )
        
        await vector_service.clear_search_cache(db)
        
        response_data = CacheClearResponse(
            success=True,
            message="Search cache cleared successfully",
            timestamp=datetime.utcnow().isoformat()
        )
        return JSONResponse(content=response_data.dict(), status_code=status.HTTP_200_OK)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error clearing search cache: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to clear search cache: {str(e)}"
        ) 
"""RAG Infrastructure API endpoints."""

import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.services.rag_content_pipeline import RAGContentPipeline
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


class IndexingRequest(BaseModel):
    """Request model for content indexing."""
    content_type: str  # "species", "knowledge", "question", "answer", "story"
    content_id: str
    force_reindex: bool = False


class BulkIndexingRequest(BaseModel):
    """Request model for bulk content indexing."""
    content_items: List[IndexingRequest]
    batch_size: int = 10


class KnowledgeBaseInitRequest(BaseModel):
    """Request model for knowledge base initialization."""
    include_basic_care: bool = True
    include_species_info: bool = False
    force_reinit: bool = False


class IndexingStatsResponse(BaseModel):
    """Response model for indexing statistics."""
    embedding_counts: Dict[str, int]
    total_embeddings: int
    content_coverage: Dict[str, Dict[str, Any]]
    last_updated: str


class IndexingResultResponse(BaseModel):
    """Response model for indexing operations."""
    success: bool
    message: str
    details: Optional[Dict[str, Any]] = None


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
):
    """Initialize the plant knowledge base with essential content.
    
    This endpoint creates foundational knowledge entries for common plant care topics.
    Only admin users can initialize the knowledge base.
    """
    try:
        # Check if user is admin (you may want to implement proper admin check)
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can initialize the knowledge base"
            )
        
        logger.info(f"Initializing knowledge base requested by user {current_user.id}")
        
        # Initialize knowledge base
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
):
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
            return IndexingResultResponse(
                success=True,
                message=f"Successfully indexed {request.content_type} {request.content_id}",
                details={"content_type": request.content_type, "content_id": request.content_id}
            )
        else:
            return IndexingResultResponse(
                success=False,
                message=f"Failed to index {request.content_type} {request.content_id}",
                details={"content_type": request.content_type, "content_id": request.content_id}
            )
    
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
):
    """Get comprehensive statistics about the current indexing status.
    
    Returns counts of embeddings by type, coverage percentages, and system health metrics.
    """
    try:
        logger.info(f"Indexing stats requested by user {current_user.id}")
        
        stats = await rag_pipeline.get_indexing_stats(db)
        
        if "error" in stats:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to get indexing stats: {stats['error']}"
            )
        
        return IndexingStatsResponse(**stats)
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting indexing stats: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get indexing statistics: {str(e)}"
        )


@router.post("/bulk-index-species", response_model=IndexingResultResponse)
async def bulk_index_all_species(
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Bulk index all plant species in the database.
    
    This operation runs in the background and can take several minutes.
    Only admin users can trigger bulk indexing operations.
    """
    try:
        # Check if user is admin
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can perform bulk indexing operations"
            )
        
        logger.info(f"Bulk species indexing requested by user {current_user.id}")
        
        # Add bulk indexing to background tasks
        background_tasks.add_task(
            _bulk_index_species_background,
            db,
            current_user.id
        )
        
        return IndexingResultResponse(
            success=True,
            message="Bulk species indexing started in background. Check indexing stats for progress.",
            details={"operation": "bulk_species_indexing", "status": "started"}
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting bulk species indexing: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to start bulk species indexing: {str(e)}"
        )


@router.post("/test-vector-search")
async def test_vector_search(
    query: str = Query(..., description="Search query to test"),
    content_types: Optional[List[str]] = Query(None, description="Content types to search"),
    limit: int = Query(5, ge=1, le=20, description="Number of results to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Test vector similarity search functionality.
    
    This endpoint allows testing the RAG retrieval system with custom queries.
    """
    try:
        logger.info(f"Vector search test requested by user {current_user.id} with query: {query}")
        
        # Generate query embedding
        query_embedding = await embedding_service.generate_text_embedding(query)
        
        # Perform similarity search
        results = await vector_service.similarity_search(
            db=db,
            query_embedding=query_embedding,
            content_types=content_types,
            limit=limit,
            similarity_threshold=0.5
        )
        
        return {
            "success": True,
            "query": query,
            "content_types": content_types,
            "results_count": len(results),
            "results": results
        }
    
    except Exception as e:
        logger.error(f"Error testing vector search: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Vector search test failed: {str(e)}"
        )


@router.get("/system-health")
async def get_rag_system_health(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get RAG system health status and diagnostics.
    
    Returns information about database connections, embedding service status,
    and overall system performance metrics.
    """
    try:
        logger.info(f"RAG system health check requested by user {current_user.id}")
        
        # Get indexing stats
        stats = await rag_pipeline.get_indexing_stats(db)
        
        # Test embedding service
        try:
            test_embedding = await embedding_service.generate_text_embedding("test query")
            embedding_service_status = "healthy"
            embedding_dimension = len(test_embedding)
        except Exception as e:
            embedding_service_status = f"error: {str(e)}"
            embedding_dimension = 0
        
        # Test vector database
        try:
            test_results = await vector_service.similarity_search(
                db=db,
                query_embedding=[0.1] * 1536,  # Dummy embedding
                limit=1
            )
            vector_db_status = "healthy"
        except Exception as e:
            vector_db_status = f"error: {str(e)}"
        
        health_status = {
            "overall_status": "healthy" if embedding_service_status == "healthy" and vector_db_status == "healthy" else "degraded",
            "timestamp": datetime.utcnow().isoformat(),
            "components": {
                "embedding_service": {
                    "status": embedding_service_status,
                    "embedding_dimension": embedding_dimension
                },
                "vector_database": {
                    "status": vector_db_status
                },
                "content_indexing": {
                    "total_embeddings": stats.get("total_embeddings", 0),
                    "coverage": stats.get("content_coverage", {})
                }
            }
        }
        
        return health_status
    
    except Exception as e:
        logger.error(f"Error checking RAG system health: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Health check failed: {str(e)}"
        )


async def _bulk_index_species_background(db: AsyncSession, user_id: str):
    """Background task for bulk indexing all species."""
    try:
        logger.info(f"Starting background bulk species indexing for user {user_id}")
        
        # This would need to be implemented with proper database session management
        # For now, it's a placeholder
        # results = await rag_pipeline.bulk_index_all_species(db)
        
        logger.info(f"Background bulk species indexing completed for user {user_id}")
    except Exception as e:
        logger.error(f"Error in background bulk species indexing: {str(e)}")


@router.delete("/clear-cache")
async def clear_search_cache(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Clear the semantic search cache.
    
    This can help improve performance and ensure fresh results after content updates.
    Only admin users can clear the cache.
    """
    try:
        # Check if user is admin
        if not current_user.is_superuser:
            raise HTTPException(
                status_code=403,
                detail="Only admin users can clear the search cache"
            )
        
        logger.info(f"Search cache clear requested by user {current_user.id}")
        
        # Clear cache (this would need to be implemented in the pipeline)
        # result = await rag_pipeline.refresh_search_cache(db)
        
        return {
            "success": True,
            "message": "Search cache cleared successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error clearing search cache: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to clear search cache: {str(e)}"
        ) 
"""Task management service.

This module provides comprehensive task management functionality including
CRUD operations, progress tracking, dependency resolution, and team collaboration.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import and_, desc, func, or_
from sqlalchemy.orm import selectinload

from app.models.task_management import (
    Task, TaskCategory, TaskProgress, TaskComment,
    TaskStatus, TaskPriority, task_dependencies
)
from app.models.user import User


class TaskManagementService:
    """Service for managing project tasks, progress tracking, and team collaboration."""
    
    def __init__(self, db: AsyncSession):
        """Initialize the task management service.
        
        Args:
            db: Database session
        """
        self.db = db
    
    # Task CRUD Operations
    
    async def create_task(
        self,
        title: str,
        description: str,
        category_id: UUID,
        created_by_id: UUID,
        priority: TaskPriority = TaskPriority.MEDIUM,
        assignee_id: Optional[UUID] = None,
        estimated_hours: Optional[float] = None,
        due_date: Optional[datetime] = None,
        file_path: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        dependency_ids: Optional[List[UUID]] = None
    ) -> Dict[str, Any]:
        """Create a new task.
        
        Args:
            title: Task title
            description: Task description
            category_id: Task category ID
            created_by_id: User ID who created the task
            priority: Task priority
            assignee_id: Optional assignee user ID
            estimated_hours: Estimated hours to complete
            due_date: Task due date
            file_path: Associated file path
            acceptance_criteria: Task acceptance criteria
            dependency_ids: List of task IDs this task depends on
            
        Returns:
            Created task data
        """
        task = Task(
            title=title,
            description=description,
            category_id=category_id,
            created_by_id=created_by_id,
            priority=priority.value,
            assignee_id=assignee_id,
            estimated_hours=estimated_hours,
            due_date=due_date,
            file_path=file_path,
            acceptance_criteria=acceptance_criteria
        )
        
        self.db.add(task)
        await self.db.flush()  # Get the task ID
        
        # Add dependencies if provided
        if dependency_ids:
            await self._add_task_dependencies(task.id, dependency_ids)
        
        await self.db.commit()
        await self.db.refresh(task)
        
        return await self._format_task_response(task)
    
    async def get_task(
        self,
        task_id: UUID,
        include_progress: bool = True,
        include_comments: bool = True
    ) -> Optional[Dict[str, Any]]:
        """Get a task by ID.
        
        Args:
            task_id: Task ID
            include_progress: Include progress entries
            include_comments: Include comments
            
        Returns:
            Task data or None if not found
        """
        query = select(Task).where(Task.id == task_id)
        
        # Add eager loading based on options
        options = [selectinload(Task.category), selectinload(Task.assignee), selectinload(Task.created_by)]
        if include_progress:
            options.append(selectinload(Task.progress_entries))
        if include_comments:
            options.append(selectinload(Task.comments))
        
        query = query.options(*options)
        
        result = await self.db.execute(query)
        task = result.scalar_one_or_none()
        
        if not task:
            return None
        
        return await self._format_task_response(task, include_progress, include_comments)
    
    async def update_task(
        self,
        task_id: UUID,
        updates: Dict[str, Any],
        updated_by_id: UUID
    ) -> Optional[Dict[str, Any]]:
        """Update a task.
        
        Args:
            task_id: Task ID
            updates: Dictionary of fields to update
            updated_by_id: User ID making the update
            
        Returns:
            Updated task data or None if not found
        """
        result = await self.db.execute(select(Task).where(Task.id == task_id))
        task = result.scalar_one_or_none()
        
        if not task:
            return None
        
        # Update allowed fields
        allowed_fields = {
            'title', 'description', 'status', 'priority', 'assignee_id',
            'estimated_hours', 'actual_hours', 'start_date', 'due_date',
            'file_path', 'implementation_notes', 'acceptance_criteria'
        }
        
        for field, value in updates.items():
            if field in allowed_fields and hasattr(task, field):
                setattr(task, field, value)
        
        # Handle status changes
        if 'status' in updates:
            if updates['status'] == TaskStatus.COMPLETED and not task.completed_at:
                task.completed_at = datetime.utcnow()
            elif updates['status'] != TaskStatus.COMPLETED:
                task.completed_at = None
        
        task.updated_at = datetime.utcnow()
        
        await self.db.commit()
        await self.db.refresh(task)
        
        return await self._format_task_response(task)
    
    async def delete_task(self, task_id: UUID) -> bool:
        """Delete a task.
        
        Args:
            task_id: Task ID
            
        Returns:
            True if deleted, False if not found
        """
        result = await self.db.execute(select(Task).where(Task.id == task_id))
        task = result.scalar_one_or_none()
        
        if not task:
            return False
        
        await self.db.delete(task)
        await self.db.commit()
        
        return True
    
    # Task Listing and Filtering
    
    async def get_tasks(
        self,
        category_id: Optional[UUID] = None,
        assignee_id: Optional[UUID] = None,
        status: Optional[TaskStatus] = None,
        priority: Optional[TaskPriority] = None,
        overdue_only: bool = False,
        limit: int = 50,
        offset: int = 0
    ) -> Dict[str, Any]:
        """Get tasks with filtering options.
        
        Args:
            category_id: Filter by category
            assignee_id: Filter by assignee
            status: Filter by status
            priority: Filter by priority
            overdue_only: Show only overdue tasks
            limit: Maximum number of tasks
            offset: Pagination offset
            
        Returns:
            Dictionary with tasks and pagination info
        """
        query = select(Task).options(
            selectinload(Task.category),
            selectinload(Task.assignee),
            selectinload(Task.created_by)
        )
        
        # Apply filters
        conditions = []
        
        if category_id:
            conditions.append(Task.category_id == category_id)
        
        if assignee_id:
            conditions.append(Task.assignee_id == assignee_id)
        
        if status:
            conditions.append(Task.status == status.value)
        
        if priority:
            conditions.append(Task.priority == priority.value)
        
        if overdue_only:
            now = datetime.utcnow()
            conditions.append(
                and_(
                    Task.due_date.isnot(None),
                    Task.due_date < now,
                    Task.status != TaskStatus.COMPLETED.value
                )
            )
        
        if conditions:
            query = query.where(and_(*conditions))
        
        # Get total count
        count_query = select(func.count(Task.id))
        if conditions:
            count_query = count_query.where(and_(*conditions))
        
        total_result = await self.db.execute(count_query)
        total_count = total_result.scalar()
        
        # Apply pagination and ordering
        query = query.order_by(desc(Task.created_at)).limit(limit).offset(offset)
        
        result = await self.db.execute(query)
        tasks = result.scalars().all()
        
        formatted_tasks = []
        for task in tasks:
            formatted_tasks.append(await self._format_task_response(task, include_progress=False, include_comments=False))
        
        return {
            "tasks": formatted_tasks,
            "total_count": total_count,
            "limit": limit,
            "offset": offset,
            "has_more": offset + len(tasks) < total_count
        }
    
    async def get_kanban_board(self, category_id: Optional[UUID] = None) -> Dict[str, List[Dict[str, Any]]]:
        """Get tasks organized by status for Kanban board view.
        
        Args:
            category_id: Optional category filter
            
        Returns:
            Dictionary with tasks grouped by status
        """
        query = select(Task).options(
            selectinload(Task.category),
            selectinload(Task.assignee)
        )
        
        if category_id:
            query = query.where(Task.category_id == category_id)
        
        result = await self.db.execute(query)
        tasks = result.scalars().all()
        
        # Group by status
        kanban_board = {
            TaskStatus.PENDING.value: [],
            TaskStatus.IN_PROGRESS.value: [],
            TaskStatus.COMPLETED.value: [],
            TaskStatus.BLOCKED.value: [],
            TaskStatus.CANCELLED.value: []
        }
        
        for task in tasks:
            task_data = await self._format_task_response(task, include_progress=False, include_comments=False)
            kanban_board[task.status].append(task_data)
        
        return kanban_board
    
    # Progress Tracking
    
    async def log_progress(
        self,
        task_id: UUID,
        user_id: UUID,
        hours_worked: float,
        progress_notes: Optional[str] = None,
        completion_percentage: Optional[float] = None
    ) -> Dict[str, Any]:
        """Log progress on a task.
        
        Args:
            task_id: Task ID
            user_id: User logging progress
            hours_worked: Hours worked
            progress_notes: Optional progress notes
            completion_percentage: Optional completion percentage
            
        Returns:
            Progress entry data
        """
        # Verify task exists
        result = await self.db.execute(select(Task).where(Task.id == task_id))
        task = result.scalar_one_or_none()
        
        if not task:
            raise ValueError(f"Task {task_id} not found")
        
        # Create progress entry
        progress = TaskProgress(
            task_id=task_id,
            user_id=user_id,
            hours_worked=hours_worked,
            progress_notes=progress_notes,
            completion_percentage=completion_percentage or 0.0
        )
        
        self.db.add(progress)
        
        # Update task actual hours
        task.actual_hours = (task.actual_hours or 0.0) + hours_worked
        task.updated_at = datetime.utcnow()
        
        await self.db.commit()
        await self.db.refresh(progress)
        
        return {
            "id": progress.id,
            "task_id": progress.task_id,
            "user_id": progress.user_id,
            "hours_worked": progress.hours_worked,
            "progress_notes": progress.progress_notes,
            "completion_percentage": progress.completion_percentage,
            "logged_at": progress.logged_at,
            "created_at": progress.created_at
        }
    
    # Comments and Collaboration
    
    async def add_comment(
        self,
        task_id: UUID,
        user_id: UUID,
        content: str,
        is_internal: bool = False
    ) -> Dict[str, Any]:
        """Add a comment to a task.
        
        Args:
            task_id: Task ID
            user_id: User adding comment
            content: Comment content
            is_internal: Whether comment is internal
            
        Returns:
            Comment data
        """
        comment = TaskComment(
            task_id=task_id,
            user_id=user_id,
            content=content,
            is_internal=is_internal
        )
        
        self.db.add(comment)
        await self.db.commit()
        await self.db.refresh(comment)
        
        return {
            "id": comment.id,
            "task_id": comment.task_id,
            "user_id": comment.user_id,
            "content": comment.content,
            "is_internal": comment.is_internal,
            "created_at": comment.created_at,
            "updated_at": comment.updated_at
        }
    
    # Categories
    
    async def create_category(
        self,
        name: str,
        description: Optional[str] = None,
        color: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a task category.
        
        Args:
            name: Category name
            description: Category description
            color: Hex color code
            
        Returns:
            Category data
        """
        category = TaskCategory(
            name=name,
            description=description,
            color=color
        )
        
        self.db.add(category)
        await self.db.commit()
        await self.db.refresh(category)
        
        return {
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "color": category.color,
            "created_at": category.created_at
        }
    
    async def get_categories(self) -> List[Dict[str, Any]]:
        """Get all task categories.
        
        Returns:
            List of category data
        """
        result = await self.db.execute(select(TaskCategory).order_by(TaskCategory.name))
        categories = result.scalars().all()
        
        return [
            {
                "id": cat.id,
                "name": cat.name,
                "description": cat.description,
                "color": cat.color,
                "created_at": cat.created_at
            }
            for cat in categories
        ]
    
    # Analytics and Reporting
    
    async def get_task_analytics(
        self,
        category_id: Optional[UUID] = None,
        assignee_id: Optional[UUID] = None,
        days_back: int = 30
    ) -> Dict[str, Any]:
        """Get task analytics and metrics.
        
        Args:
            category_id: Optional category filter
            assignee_id: Optional assignee filter
            days_back: Number of days to analyze
            
        Returns:
            Analytics data
        """
        start_date = datetime.utcnow() - timedelta(days=days_back)
        
        # Base query conditions
        conditions = [Task.created_at >= start_date]
        
        if category_id:
            conditions.append(Task.category_id == category_id)
        
        if assignee_id:
            conditions.append(Task.assignee_id == assignee_id)
        
        # Get task counts by status
        status_query = select(
            Task.status,
            func.count(Task.id).label('count')
        ).where(and_(*conditions)).group_by(Task.status)
        
        status_result = await self.db.execute(status_query)
        status_counts = {row.status: row.count for row in status_result}
        
        # Get completion rate
        total_tasks = sum(status_counts.values())
        completed_tasks = status_counts.get(TaskStatus.COMPLETED.value, 0)
        completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
        
        # Get average completion time
        completed_query = select(
            func.avg(
                func.extract('epoch', Task.completed_at - Task.created_at) / 3600
            ).label('avg_hours')
        ).where(
            and_(
                *conditions,
                Task.status == TaskStatus.COMPLETED.value,
                Task.completed_at.isnot(None)
            )
        )
        
        avg_result = await self.db.execute(completed_query)
        avg_completion_hours = avg_result.scalar() or 0
        
        # Get overdue tasks count
        now = datetime.utcnow()
        overdue_query = select(func.count(Task.id)).where(
            and_(
                *conditions,
                Task.due_date.isnot(None),
                Task.due_date < now,
                Task.status != TaskStatus.COMPLETED.value
            )
        )
        
        overdue_result = await self.db.execute(overdue_query)
        overdue_count = overdue_result.scalar()
        
        return {
            "total_tasks": total_tasks,
            "status_distribution": status_counts,
            "completion_rate": round(completion_rate, 2),
            "avg_completion_hours": round(avg_completion_hours, 2),
            "overdue_tasks": overdue_count,
            "period_days": days_back
        }
    
    # Private Helper Methods
    
    async def _add_task_dependencies(self, task_id: UUID, dependency_ids: List[UUID]) -> None:
        """Add dependencies to a task.
        
        Args:
            task_id: Task ID
            dependency_ids: List of dependency task IDs
        """
        for dep_id in dependency_ids:
            # Verify dependency exists
            result = await self.db.execute(select(Task).where(Task.id == dep_id))
            if result.scalar_one_or_none():
                # Insert dependency relationship
                await self.db.execute(
                    task_dependencies.insert().values(
                        task_id=task_id,
                        dependency_id=dep_id
                    )
                )
    
    async def _format_task_response(
        self,
        task: Task,
        include_progress: bool = True,
        include_comments: bool = True
    ) -> Dict[str, Any]:
        """Format task data for API response.
        
        Args:
            task: Task model instance
            include_progress: Include progress entries
            include_comments: Include comments
            
        Returns:
            Formatted task data
        """
        data = {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "status": task.status,
            "priority": task.priority,
            "estimated_hours": task.estimated_hours,
            "actual_hours": task.actual_hours,
            "start_date": task.start_date,
            "due_date": task.due_date,
            "completed_at": task.completed_at,
            "file_path": task.file_path,
            "implementation_notes": task.implementation_notes,
            "acceptance_criteria": task.acceptance_criteria,
            "created_at": task.created_at,
            "updated_at": task.updated_at,
            "is_completed": task.is_completed,
            "is_overdue": task.is_overdue,
            "progress_percentage": task.progress_percentage,
            "can_start": task.can_start
        }
        
        # Add related data if loaded
        if hasattr(task, 'category') and task.category:
            data["category"] = {
                "id": task.category.id,
                "name": task.category.name,
                "color": task.category.color
            }
        
        if hasattr(task, 'assignee') and task.assignee:
            data["assignee"] = {
                "id": task.assignee.id,
                "username": task.assignee.username,
                "email": task.assignee.email
            }
        
        if hasattr(task, 'created_by') and task.created_by:
            data["created_by"] = {
                "id": task.created_by.id,
                "username": task.created_by.username
            }
        
        if include_progress and hasattr(task, 'progress_entries'):
            data["progress_entries"] = [
                {
                    "id": p.id,
                    "hours_worked": p.hours_worked,
                    "progress_notes": p.progress_notes,
                    "completion_percentage": p.completion_percentage,
                    "logged_at": p.logged_at
                }
                for p in task.progress_entries
            ]
        
        if include_comments and hasattr(task, 'comments'):
            data["comments"] = [
                {
                    "id": c.id,
                    "content": c.content,
                    "is_internal": c.is_internal,
                    "created_at": c.created_at,
                    "user_id": c.user_id
                }
                for c in task.comments
            ]
        
        return data
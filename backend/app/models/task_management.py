"""Task management database models.

This module defines models for tracking project tasks, progress, and team collaboration
for the Sensor & Photo Telemetry feature implementation.
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, Text, Float, Boolean, Index
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship
from sqlalchemy.schema import UniqueConstraint

from app.core.database import Base


class TaskStatus(str, Enum):
    """Task status enumeration."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    BLOCKED = "blocked"
    CANCELLED = "cancelled"


class TaskPriority(str, Enum):
    """Task priority enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class TaskCategory(Base):
    """Task category model for organizing tasks by type.
    
    Categories include Backend, Frontend, Documentation, Analytics, etc.
    """
    
    __tablename__ = "task_categories"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    name = Column(String(100), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    color = Column(String(7), nullable=True)  # Hex color code
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    tasks = relationship("Task", back_populates="category")
    
    # Indexes
    __table_args__ = (
        Index('ix_task_categories_name', 'name'),
    )
    
    def __repr__(self) -> str:
        return f"<TaskCategory(id={self.id}, name={self.name})>"


class Task(Base):
    """Task model for tracking implementation tasks.
    
    This model stores tasks with status, priority, dependencies, and progress tracking.
    """
    
    __tablename__ = "tasks"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(20), nullable=False, default=TaskStatus.PENDING)
    priority = Column(String(20), nullable=False, default=TaskPriority.MEDIUM)
    
    # Task metadata
    category_id = Column(PostgresUUID(as_uuid=True), ForeignKey("task_categories.id"), nullable=False)
    assignee_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    created_by_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Time tracking
    estimated_hours = Column(Float, nullable=True)
    actual_hours = Column(Float, nullable=True, default=0.0)
    start_date = Column(DateTime, nullable=True)
    due_date = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    
    # Task details
    file_path = Column(String(500), nullable=True)  # Associated file path
    implementation_notes = Column(Text, nullable=True)
    acceptance_criteria = Column(Text, nullable=True)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    category = relationship("TaskCategory", back_populates="tasks")
    assignee = relationship("User", foreign_keys=[assignee_id])
    created_by = relationship("User", foreign_keys=[created_by_id])
    progress_entries = relationship("TaskProgress", back_populates="task", cascade="all, delete-orphan")
    comments = relationship("TaskComment", back_populates="task", cascade="all, delete-orphan")
    
    # Dependencies (self-referential many-to-many)
    dependencies = relationship(
        "Task",
        secondary="task_dependencies",
        primaryjoin="Task.id==task_dependencies.c.task_id",
        secondaryjoin="Task.id==task_dependencies.c.dependency_id",
        back_populates="dependents"
    )
    dependents = relationship(
        "Task",
        secondary="task_dependencies",
        primaryjoin="Task.id==task_dependencies.c.dependency_id",
        secondaryjoin="Task.id==task_dependencies.c.task_id",
        back_populates="dependencies"
    )
    
    # Constraints and indexes
    __table_args__ = (
        Index('ix_tasks_status', 'status'),
        Index('ix_tasks_priority', 'priority'),
        Index('ix_tasks_category_id', 'category_id'),
        Index('ix_tasks_assignee_id', 'assignee_id'),
        Index('ix_tasks_due_date', 'due_date'),
        Index('ix_tasks_created_at', 'created_at'),
    )
    
    def __repr__(self) -> str:
        return f"<Task(id={self.id}, title={self.title}, status={self.status})>"
    
    @property
    def is_completed(self) -> bool:
        """Check if task is completed.
        
        Returns:
            bool: True if task status is completed
        """
        return self.status == TaskStatus.COMPLETED
    
    @property
    def is_overdue(self) -> bool:
        """Check if task is overdue.
        
        Returns:
            bool: True if task has due date and is past due
        """
        if not self.due_date or self.is_completed:
            return False
        return datetime.utcnow() > self.due_date
    
    @property
    def progress_percentage(self) -> float:
        """Calculate task progress percentage.
        
        Returns:
            float: Progress percentage (0-100)
        """
        if self.is_completed:
            return 100.0
        
        if self.estimated_hours and self.actual_hours:
            return min(100.0, (self.actual_hours / self.estimated_hours) * 100)
        
        return 0.0
    
    @property
    def can_start(self) -> bool:
        """Check if task can be started based on dependencies.
        
        Returns:
            bool: True if all dependencies are completed
        """
        return all(dep.is_completed for dep in self.dependencies)


class TaskProgress(Base):
    """Task progress tracking model.
    
    This model stores progress updates and time entries for tasks.
    """
    
    __tablename__ = "task_progress"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    task_id = Column(PostgresUUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Progress details
    hours_worked = Column(Float, nullable=False, default=0.0)
    progress_notes = Column(Text, nullable=True)
    completion_percentage = Column(Float, nullable=False, default=0.0)
    
    # Metadata
    logged_at = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    task = relationship("Task", back_populates="progress_entries")
    user = relationship("User")
    
    # Indexes
    __table_args__ = (
        Index('ix_task_progress_task_id', 'task_id'),
        Index('ix_task_progress_user_id', 'user_id'),
        Index('ix_task_progress_logged_at', 'logged_at'),
    )
    
    def __repr__(self) -> str:
        return f"<TaskProgress(id={self.id}, task_id={self.task_id}, hours={self.hours_worked})>"


class TaskComment(Base):
    """Task comment model for team collaboration.
    
    This model stores comments and discussions on tasks.
    """
    
    __tablename__ = "task_comments"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    task_id = Column(PostgresUUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Comment content
    content = Column(Text, nullable=False)
    is_internal = Column(Boolean, default=False)  # Internal team notes vs public updates
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    task = relationship("Task", back_populates="comments")
    user = relationship("User")
    
    # Indexes
    __table_args__ = (
        Index('ix_task_comments_task_id', 'task_id'),
        Index('ix_task_comments_user_id', 'user_id'),
        Index('ix_task_comments_created_at', 'created_at'),
    )
    
    def __repr__(self) -> str:
        return f"<TaskComment(id={self.id}, task_id={self.task_id}, user_id={self.user_id})>"


# Task dependencies association table
from sqlalchemy import Table

task_dependencies = Table(
    'task_dependencies',
    Base.metadata,
    Column('task_id', PostgresUUID(as_uuid=True), ForeignKey('tasks.id'), primary_key=True),
    Column('dependency_id', PostgresUUID(as_uuid=True), ForeignKey('tasks.id'), primary_key=True),
    Column('created_at', DateTime, default=datetime.utcnow)
)
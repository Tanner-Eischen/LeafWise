"""Enhance stories for seasonal AI and time-lapse features

Revision ID: enhance_stories_seasonal
Revises: f9a8b7c6d5e4
Create Date: 2025-01-22 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'enhance_stories_seasonal'
down_revision = 'f9a8b7c6d5e4'
branch_labels = None
depends_on = None


def upgrade():
    """Add enhanced fields to stories table for seasonal AI and time-lapse integration."""
    # Add new columns to stories table
    op.add_column('stories', sa.Column('plant_tags', sa.String(500), nullable=True))
    op.add_column('stories', sa.Column('location', sa.String(200), nullable=True))
    op.add_column('stories', sa.Column('metadata', sa.Text(), nullable=True))
    op.add_column('stories', sa.Column('updated_at', sa.DateTime(), nullable=True, default=sa.func.now()))
    
    # Update existing records to have updated_at timestamp
    op.execute("UPDATE stories SET updated_at = created_at WHERE updated_at IS NULL")
    
    # Create indexes for better query performance
    op.create_index('ix_stories_plant_tags', 'stories', ['plant_tags'])
    op.create_index('ix_stories_location', 'stories', ['location'])
    op.create_index('ix_stories_content_type', 'stories', ['content_type'])
    op.create_index('ix_stories_updated_at', 'stories', ['updated_at'])


def downgrade():
    """Remove enhanced fields from stories table."""
    # Drop indexes
    op.drop_index('ix_stories_updated_at', table_name='stories')
    op.drop_index('ix_stories_content_type', table_name='stories')
    op.drop_index('ix_stories_location', table_name='stories')
    op.drop_index('ix_stories_plant_tags', table_name='stories')
    
    # Drop columns
    op.drop_column('stories', 'updated_at')
    op.drop_column('stories', 'metadata')
    op.drop_column('stories', 'location')
    op.drop_column('stories', 'plant_tags')
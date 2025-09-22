"""add_telemetry_fields_and_growth_photos

Revision ID: 5dd46745c263
Revises: ccbad7945308
Create Date: 2025-09-19 23:28:14.029415

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '5dd46745c263'
down_revision = 'ccbad7945308'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Upgrade database schema."""
    # Add telemetry fields to light_readings table
    op.add_column('light_readings', sa.Column('telemetry_session_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column('light_readings', sa.Column('sync_status', sa.String(length=20), nullable=False, server_default='pending'))
    op.add_column('light_readings', sa.Column('offline_created', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('light_readings', sa.Column('conflict_resolution_data', postgresql.JSONB(astext_type=sa.Text()), nullable=True))
    op.add_column('light_readings', sa.Column('client_timestamp', sa.DateTime(), nullable=True))
    op.add_column('light_readings', sa.Column('retry_count', sa.Integer(), nullable=False, server_default='0'))
    
    # Create growth_photos table
    op.create_table('growth_photos',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('plant_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('file_path', sa.String(length=500), nullable=False),
        sa.Column('file_size', sa.Integer(), nullable=True),
        sa.Column('image_width', sa.Integer(), nullable=True),
        sa.Column('image_height', sa.Integer(), nullable=True),
        sa.Column('leaf_area_cm2', sa.Float(), nullable=True),
        sa.Column('plant_height_cm', sa.Float(), nullable=True),
        sa.Column('leaf_count', sa.Integer(), nullable=True),
        sa.Column('stem_width_mm', sa.Float(), nullable=True),
        sa.Column('health_score', sa.Float(), nullable=True),
        sa.Column('chlorophyll_index', sa.Float(), nullable=True),
        sa.Column('disease_indicators', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('processing_version', sa.String(length=20), nullable=True),
        sa.Column('confidence_scores', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('analysis_duration_ms', sa.Integer(), nullable=True),
        sa.Column('location_name', sa.String(length=100), nullable=True),
        sa.Column('ambient_light_lux', sa.Float(), nullable=True),
        sa.Column('camera_settings', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('is_processed', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('processing_error', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.Column('captured_at', sa.DateTime(), nullable=False),
        sa.Column('processed_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['plant_id'], ['user_plants.id'], name=op.f('fk_growth_photos_plant_id_user_plants')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], name=op.f('fk_growth_photos_user_id_users')),
        sa.PrimaryKeyConstraint('id', name=op.f('pk_growth_photos'))
    )
    
    # Create indexes for light_readings telemetry fields
    op.create_index('idx_light_readings_telemetry_session_id', 'light_readings', ['telemetry_session_id'], unique=False)
    op.create_index('idx_light_readings_sync_status', 'light_readings', ['sync_status'], unique=False)
    op.create_index('idx_light_readings_client_timestamp', 'light_readings', ['client_timestamp'], unique=False)
    
    # Create indexes for growth_photos table
    op.create_index('idx_growth_photos_user_id', 'growth_photos', ['user_id'], unique=False)
    op.create_index('idx_growth_photos_plant_id', 'growth_photos', ['plant_id'], unique=False)
    op.create_index('idx_growth_photos_captured_at', 'growth_photos', ['captured_at'], unique=False)
    op.create_index('idx_growth_photos_is_processed', 'growth_photos', ['is_processed'], unique=False)
    op.create_index('idx_growth_photos_plant_captured', 'growth_photos', ['plant_id', 'captured_at'], unique=False)
    
    # Add relationship column to light_readings for growth_photos
    op.add_column('light_readings', sa.Column('growth_photo_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.create_foreign_key('fk_light_readings_growth_photo_id_growth_photos', 'light_readings', 'growth_photos', ['growth_photo_id'], ['id'])


def downgrade() -> None:
    """Downgrade database schema."""
    # Drop foreign key and column for growth_photos relationship
    op.drop_constraint('fk_light_readings_growth_photo_id_growth_photos', 'light_readings', type_='foreignkey')
    op.drop_column('light_readings', 'growth_photo_id')
    
    # Drop growth_photos indexes
    op.drop_index('idx_growth_photos_plant_captured', table_name='growth_photos')
    op.drop_index('idx_growth_photos_is_processed', table_name='growth_photos')
    op.drop_index('idx_growth_photos_captured_at', table_name='growth_photos')
    op.drop_index('idx_growth_photos_plant_id', table_name='growth_photos')
    op.drop_index('idx_growth_photos_user_id', table_name='growth_photos')
    
    # Drop light_readings telemetry indexes
    op.drop_index('idx_light_readings_client_timestamp', table_name='light_readings')
    op.drop_index('idx_light_readings_sync_status', table_name='light_readings')
    op.drop_index('idx_light_readings_telemetry_session_id', table_name='light_readings')
    
    # Drop growth_photos table
    op.drop_table('growth_photos')
    
    # Remove telemetry fields from light_readings table
    op.drop_column('light_readings', 'retry_count')
    op.drop_column('light_readings', 'client_timestamp')
    op.drop_column('light_readings', 'conflict_resolution_data')
    op.drop_column('light_readings', 'offline_created')
    op.drop_column('light_readings', 'sync_status')
    op.drop_column('light_readings', 'telemetry_session_id')
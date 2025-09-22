-- Create growth_photos table for storing plant growth tracking photos
-- This migration implements the database schema for the GrowthPhoto model

CREATE TABLE growth_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  plant_id UUID NOT NULL REFERENCES user_plants(id),
  
  -- Photo metadata
  file_path TEXT NOT NULL,
  file_size INTEGER,
  image_width INTEGER,
  image_height INTEGER,
  
  -- Growth metrics (extracted by ML)
  leaf_area_cm2 REAL,
  plant_height_cm REAL,
  leaf_count INTEGER,
  stem_width_mm REAL,
  
  -- Health indicators
  health_score REAL,
  chlorophyll_index REAL,
  disease_indicators JSONB,
  
  -- Analysis metadata
  processing_version VARCHAR(20),
  confidence_scores JSONB,
  analysis_duration_ms INTEGER,
  
  -- Location and lighting context
  location_name VARCHAR(100),
  ambient_light_lux REAL,
  
  -- Camera settings
  camera_settings JSONB,
  
  -- Metadata
  notes TEXT,
  is_processed BOOLEAN DEFAULT FALSE,
  processing_error TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  captured_at TIMESTAMPTZ NOT NULL,
  processed_at TIMESTAMPTZ
);

-- Create indexes for efficient querying
CREATE INDEX idx_growth_photos_user_id ON growth_photos(user_id);
CREATE INDEX idx_growth_photos_plant_id ON growth_photos(plant_id);
CREATE INDEX idx_growth_photos_captured_at ON growth_photos(captured_at);
CREATE INDEX idx_growth_photos_is_processed ON growth_photos(is_processed);
CREATE INDEX idx_growth_photos_plant_captured ON growth_photos(plant_id, captured_at);

-- Add comment
COMMENT ON TABLE growth_photos IS 'Stores plant growth photos with extracted metrics for tracking development over time';
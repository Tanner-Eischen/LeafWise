-- Migration: Create light_readings table
-- Description: Creates the light_readings table for storing sensor measurements

CREATE TABLE light_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  plant_id UUID REFERENCES user_plants(id),
  
  -- Light measurement data
  lux_value FLOAT NOT NULL,
  ppfd_value FLOAT,
  source VARCHAR(20) NOT NULL CHECK (source IN ('als', 'camera', 'ble', 'manual')),
  
  -- Location and context
  location_name VARCHAR(100),
  gps_latitude FLOAT,
  gps_longitude FLOAT,
  altitude FLOAT,
  
  -- Environmental context
  temperature FLOAT,
  humidity FLOAT,
  
  -- Calibration and accuracy
  calibration_profile_id UUID REFERENCES calibration_profiles(id),
  accuracy_estimate FLOAT,
  confidence_score FLOAT,
  
  -- Device information
  device_id VARCHAR(100),
  ble_device_id UUID REFERENCES ble_devices(id),
  
  -- Metadata
  raw_data JSONB,
  processing_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  measured_at TIMESTAMPTZ NOT NULL,
  
  -- Light source profile for PPFD conversion
  light_source_profile VARCHAR(20) CHECK (light_source_profile IN ('sun', 'white_led', 'other'))
);

-- Create indexes for performance
CREATE INDEX idx_light_readings_user_id ON light_readings(user_id);
CREATE INDEX idx_light_readings_plant_id ON light_readings(plant_id);
CREATE INDEX idx_light_readings_measured_at ON light_readings(measured_at);
CREATE INDEX idx_light_readings_source ON light_readings(source);
CREATE INDEX idx_light_readings_location ON light_readings(location_name);
CREATE INDEX idx_light_readings_user_measured ON light_readings(user_id, measured_at);

-- Add comment
COMMENT ON TABLE light_readings IS 'Stores light measurements from various sources with location and calibration data';
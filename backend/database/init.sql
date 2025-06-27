-- Database initialization script for Plant Social platform
-- This script sets up the database with necessary extensions

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgvector extension for future RAG features
CREATE EXTENSION IF NOT EXISTS vector;

-- Create indexes for better performance (will be created by Alembic migrations)
-- This file serves as documentation for manual setup if needed

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE plant_social_db TO postgres;

-- Set timezone
SET timezone = 'UTC';

-- Create custom types that might be needed
DO $$
BEGIN
    -- Create enum types if they don't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'friendship_status') THEN
        CREATE TYPE friendship_status AS ENUM ('pending', 'accepted', 'declined', 'blocked');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message_type') THEN
        CREATE TYPE message_type AS ENUM ('text', 'image', 'video', 'audio', 'plant_id', 'plant_care', 'location');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message_status') THEN
        CREATE TYPE message_status AS ENUM ('sent', 'delivered', 'read', 'deleted', 'expired');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'story_type') THEN
        CREATE TYPE story_type AS ENUM ('image', 'video', 'plant_showcase', 'plant_timelapse', 'garden_tour');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'story_privacy_level') THEN
        CREATE TYPE story_privacy_level AS ENUM ('public', 'friends', 'close_friends', 'plant_community');
    END IF;
END$$;
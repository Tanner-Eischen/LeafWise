-- Enable pgvector extension for vector similarity search
-- This script should be run by a database administrator or user with appropriate privileges

-- Enable the pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify the extension is installed
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector'; 
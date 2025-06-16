-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 001_extensions.sql
-- Description: Enable required PostgreSQL extensions
-- Version: 1.0
-- =============================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS for geographical data (needed for trails/segments)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable unaccent for better text search across languages
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Enable pg_trgm for fuzzy text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Enable citext for case-insensitive text fields
CREATE EXTENSION IF NOT EXISTS citext;

-- Enable moddatetime for automatic updated_at triggers
CREATE EXTENSION IF NOT EXISTS moddatetime;

-- Verify extensions are enabled
SELECT 
    extname,
    extversion,
    extnamespace::regnamespace AS schema
FROM pg_extension
WHERE extname IN (
    'uuid-ossp',
    'postgis',
    'unaccent',
    'pg_trgm',
    'citext',
    'moddatetime',
    'pgcrypto',
    'pg_stat_statements',
    'pg_graphql',
    'supabase_vault'
)
ORDER BY extname;
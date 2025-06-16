-- =====================================================================================
-- Module 1: PostgreSQL Extensions
-- Description: Enable required PostgreSQL extensions for the VDF database
-- =====================================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for encryption functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enable PostGIS for geographical features (needed for future modules)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable fuzzy text search capabilities
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Enable case-insensitive text type
CREATE EXTENSION IF NOT EXISTS citext;

-- Add comments about extensions
COMMENT ON EXTENSION "uuid-ossp" IS 'Provides UUID generation functions';
COMMENT ON EXTENSION pgcrypto IS 'Provides cryptographic functions';
COMMENT ON EXTENSION postgis IS 'Provides geographical/spatial data support';
COMMENT ON EXTENSION pg_trgm IS 'Provides trigram matching for fuzzy text search';
COMMENT ON EXTENSION citext IS 'Provides case-insensitive text type';
-- Module 2: Core Trail Hierarchy
-- 001_enums.sql: Create ENUM types for Module 2
-- 
-- Purpose: Define enumerated types for trail, route, and segment attributes
-- Dependencies: None

-- Trail operational status
CREATE TYPE trail_operational_status_enum AS ENUM (
    'active',
    'seasonal',
    'temporarily_closed',
    'permanently_closed',
    'under_development'
);

-- Route category
CREATE TYPE route_category_enum AS ENUM (
    'primary',
    'alternate',
    'variant',
    'detour',
    'historical'
);

-- Segment difficulty levels
CREATE TYPE segment_difficulty_enum AS ENUM (
    'very_easy',
    'easy',
    'moderate',
    'difficult',
    'very_difficult'
);

-- Segment sun exposure levels
CREATE TYPE segment_sun_exposure_enum AS ENUM (
    'fully_exposed',
    'mostly_exposed',
    'partial_shade',
    'mostly_shaded',
    'fully_shaded'
);

-- Segment travel direction (for one-way segments)
CREATE TYPE segment_travel_direction_enum AS ENUM (
    'forward_only',
    'backward_only',
    'bidirectional'
);
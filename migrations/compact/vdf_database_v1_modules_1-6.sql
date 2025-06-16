-- =====================================================================================
-- VDF Database - Compact Migration v1.0
-- Description: Complete database schema for Modules 1-6
-- Includes: User Infrastructure, Trail Hierarchy, Geography, Waypoints, 
--           Attractions, Dynamic Conditions, and User Interaction
-- Date: 2025-01-15
-- =====================================================================================

-- =====================================================================================
-- EXTENSIONS
-- =====================================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- =====================================================================================
-- MODULE 1: USER & CONTENT INFRASTRUCTURE
-- =====================================================================================

-- Helper function for updated_at triggers
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Profiles table
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE,
    display_name TEXT,
    bio TEXT,
    profile_photo_media_id BIGINT,
    roles TEXT[] NOT NULL DEFAULT ARRAY['pilgrim']::TEXT[],
    preferred_language_code TEXT DEFAULT 'en',
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT profiles_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- User roles master
CREATE TABLE public.user_roles_master (
    role_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default roles
INSERT INTO public.user_roles_master (role_code, default_name, default_description) VALUES
('pilgrim', 'Pilgrim', 'Standard user role for pilgrims'),
('host', 'Host', 'Accommodation or service provider'),
('moderator_regional', 'Regional Moderator', 'Content moderator for specific regions'),
('moderator_platform', 'Platform Moderator', 'Platform-wide content moderator'),
('admin_regional', 'Regional Admin', 'Administrator for specific regions'),
('admin_platform', 'Platform Admin', 'Platform-wide administrator'),
('content_creator', 'Content Creator', 'Can create editorial content'),
('photographer', 'Photographer', 'Can upload and manage media'),
('trail_maintainer', 'Trail Maintainer', 'Can update trail conditions');

-- Languages master
CREATE TABLE public.languages_master (
    language_code TEXT PRIMARY KEY,
    language_name_english TEXT NOT NULL,
    language_name_native TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_primary_supported BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert supported languages
INSERT INTO public.languages_master (language_code, language_name_english, language_name_native, is_primary_supported) VALUES
('en', 'English', 'English', true),
('it', 'Italian', 'Italiano', true),
('de', 'German', 'Deutsch', true),
('fr', 'French', 'Français', false),
('es', 'Spanish', 'Español', false);

-- Media table
CREATE TABLE public.media (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    original_filename TEXT NOT NULL,
    storage_bucket TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    width_pixels INTEGER,
    height_pixels INTEGER,
    duration_seconds NUMERIC,
    uploaded_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    alt_text TEXT,
    caption TEXT,
    attribution_name TEXT,
    attribution_url TEXT,
    license_type TEXT,
    is_sensitive BOOLEAN NOT NULL DEFAULT false,
    processing_status TEXT NOT NULL DEFAULT 'pending',
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Translations table
CREATE TABLE public.translations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_identifier TEXT NOT NULL,
    column_identifier TEXT NOT NULL,
    row_foreign_key TEXT NOT NULL,
    language_code TEXT NOT NULL REFERENCES public.languages_master(language_code) ON DELETE CASCADE,
    translated_text TEXT NOT NULL,
    translation_status TEXT NOT NULL DEFAULT 'auto_translated',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Create indexes for translations
CREATE INDEX idx_translations_lookup ON public.translations 
    (table_identifier, column_identifier, row_foreign_key, language_code, translation_status);

-- Role helper functions
CREATE OR REPLACE FUNCTION public.has_role(role_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN role_name = ANY(
        SELECT roles FROM public.profiles WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.has_role_on_profile(profile_id UUID, role_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN role_name = ANY(
        SELECT roles FROM public.profiles WHERE id = profile_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================================================
-- MODULE 2: CORE TRAIL HIERARCHY
-- =====================================================================================

-- Trail master ENUMs
CREATE TYPE public.trail_type_enum AS ENUM ('main', 'variant', 'connection', 'loop', 'detour');

-- Trails table
CREATE TABLE public.trails (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    default_description TEXT,
    trail_type public.trail_type_enum NOT NULL DEFAULT 'main',
    is_active BOOLEAN NOT NULL DEFAULT true,
    total_length_m NUMERIC GENERATED ALWAYS AS (
        SELECT COALESCE(SUM(r.length_m), 0)
        FROM public.routes r
        WHERE r.trail_id = id AND r.deleted_at IS NULL
    ) STORED,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ
);

-- Routes table
CREATE TABLE public.routes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trail_id BIGINT NOT NULL REFERENCES public.trails(id) ON DELETE CASCADE,
    slug TEXT NOT NULL,
    default_name TEXT NOT NULL,
    default_description TEXT,
    route_code TEXT,
    is_primary_route BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 0,
    length_m NUMERIC GENERATED ALWAYS AS (
        SELECT COALESCE(SUM(s.length_m), 0)
        FROM public.route_segments rs
        JOIN public.segments s ON rs.segment_id = s.id
        WHERE rs.route_id = id AND s.deleted_at IS NULL
    ) STORED,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT routes_unique_slug_per_trail UNIQUE (trail_id, slug)
);

-- Segments table with PostGIS
CREATE TABLE public.segments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    default_description TEXT,
    geometry geography(LineStringZ, 4326) NOT NULL,
    start_waypoint_id BIGINT,
    end_waypoint_id BIGINT,
    length_m NUMERIC GENERATED ALWAYS AS (ST_Length(geometry)) STORED,
    elevation_gain_m NUMERIC,
    elevation_loss_m NUMERIC,
    difficulty_rating INTEGER CHECK (difficulty_rating BETWEEN 1 AND 5),
    estimated_duration_minutes INTEGER,
    is_accessible BOOLEAN NOT NULL DEFAULT false,
    surface_type TEXT,
    trail_width_m NUMERIC,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ
);

-- Create spatial index
CREATE INDEX idx_segments_geometry ON public.segments USING GIST (geometry);

-- Route segments junction
CREATE TABLE public.route_segments (
    route_id BIGINT NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    segment_id BIGINT NOT NULL REFERENCES public.segments(id) ON DELETE CASCADE,
    sequence_number INTEGER NOT NULL,
    is_reversed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    PRIMARY KEY (route_id, segment_id),
    CONSTRAINT route_segments_unique_sequence UNIQUE (route_id, sequence_number)
);

-- Terrain types master
CREATE TABLE public.terrain_types_master (
    terrain_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    difficulty_modifier NUMERIC DEFAULT 1.0,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.terrain_types_master (terrain_code, default_name, default_description, difficulty_modifier, sort_order) VALUES
('asphalt', 'Asphalt', 'Paved asphalt surface', 0.8, 10),
('gravel', 'Gravel', 'Gravel or crushed stone path', 1.0, 20),
('dirt', 'Dirt', 'Natural earth path', 1.2, 30),
('rocky', 'Rocky', 'Rocky terrain with loose stones', 1.5, 40),
('forest', 'Forest Path', 'Path through wooded areas', 1.3, 50),
('meadow', 'Meadow', 'Path through open grassland', 1.0, 60),
('sand', 'Sand', 'Sandy terrain', 1.4, 70);

-- Usage types master
CREATE TABLE public.usage_types_master (
    usage_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.usage_types_master (usage_code, default_name, default_description, sort_order) VALUES
('hiking', 'Hiking', 'Suitable for hiking and walking', 10),
('cycling', 'Cycling', 'Suitable for bicycles', 20),
('wheelchair', 'Wheelchair', 'Wheelchair accessible', 30),
('horse', 'Horseback', 'Suitable for horseback riding', 40),
('pilgrimage', 'Pilgrimage', 'Traditional pilgrimage route', 50);

-- Trail media junction
CREATE TABLE public.trail_media (
    trail_id BIGINT NOT NULL REFERENCES public.trails(id) ON DELETE CASCADE,
    media_id BIGINT NOT NULL REFERENCES public.media(id) ON DELETE CASCADE,
    media_role TEXT NOT NULL DEFAULT 'gallery',
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    PRIMARY KEY (trail_id, media_id)
);

-- =====================================================================================
-- MODULE 3: GEOGRAPHICAL CONTEXT
-- =====================================================================================

-- Countries table
CREATE TABLE public.countries (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    country_code CHAR(2) UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.countries (country_code, default_name) VALUES
('IT', 'Italy'),
('VA', 'Vatican City');

-- Regions table
CREATE TABLE public.regions (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    region_code TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    country_id INTEGER NOT NULL REFERENCES public.countries(id) ON DELETE RESTRICT,
    geometry geography(MultiPolygon, 4326),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Provinces table  
CREATE TABLE public.provinces (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    province_code TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    region_id INTEGER NOT NULL REFERENCES public.regions(id) ON DELETE RESTRICT,
    geometry geography(MultiPolygon, 4326),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Town types master
CREATE TABLE public.town_types_master (
    town_type_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.town_types_master (town_type_code, default_name, sort_order) VALUES
('city', 'City', 10),
('town', 'Town', 20),
('village', 'Village', 30),
('hamlet', 'Hamlet', 40),
('locality', 'Locality', 50);

-- Towns table
CREATE TABLE public.towns (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    town_type_code TEXT NOT NULL REFERENCES public.town_types_master(town_type_code),
    province_id INTEGER NOT NULL REFERENCES public.provinces(id) ON DELETE RESTRICT,
    geometry geography(Point, 4326) NOT NULL,
    elevation_m INTEGER,
    population INTEGER,
    is_stage_start BOOLEAN NOT NULL DEFAULT false,
    is_stage_end BOOLEAN NOT NULL DEFAULT false,
    has_pilgrim_accommodation BOOLEAN NOT NULL DEFAULT false,
    has_camping BOOLEAN NOT NULL DEFAULT false,
    has_train_station BOOLEAN NOT NULL DEFAULT false,
    has_bus_service BOOLEAN NOT NULL DEFAULT false,
    patron_saint TEXT,
    feast_day DATE,
    website_url TEXT,
    tourism_url TEXT,
    tourism_phone TEXT,
    tourism_email TEXT,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ
);

-- Create spatial index
CREATE INDEX idx_towns_geometry ON public.towns USING GIST (geometry);

-- =====================================================================================
-- MODULE 4: WAYPOINT DETAILS
-- =====================================================================================

-- Content visibility enum
CREATE TYPE public.content_visibility_status_enum AS ENUM (
    'draft', 'pending_review', 'approved_published', 'approved_private',
    'rejected', 'archived'
);

-- Waypoint categories master
CREATE TABLE public.waypoint_categories_master (
    category_code TEXT PRIMARY KEY,
    parent_category_code TEXT REFERENCES public.waypoint_categories_master(category_code),
    default_name TEXT NOT NULL,
    icon_identifier TEXT,
    color_hex TEXT,
    is_accommodations BOOLEAN NOT NULL DEFAULT false,
    requires_booking BOOLEAN NOT NULL DEFAULT false,
    is_food_water BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert waypoint categories
INSERT INTO public.waypoint_categories_master 
    (category_code, default_name, is_accommodations, requires_booking, is_food_water, sort_order) VALUES
('accommodation', 'Accommodation', true, true, false, 10),
('religious_site', 'Religious Site', false, false, false, 20),
('attraction', 'Attraction', false, false, false, 30),
('food_drink', 'Food & Drink', false, false, true, 40),
('services', 'Services', false, false, false, 50),
('transportation', 'Transportation', false, false, false, 60),
('water_source', 'Water Source', false, false, true, 70),
('emergency', 'Emergency', false, false, false, 80);

-- Tags master
CREATE TABLE public.tags_master (
    tag_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Content statuses master
CREATE TABLE public.content_statuses_master (
    status_id INTEGER PRIMARY KEY,
    status_code TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    default_description TEXT,
    is_publicly_visible BOOLEAN NOT NULL DEFAULT false,
    requires_auth BOOLEAN NOT NULL DEFAULT false,
    can_transition_to INTEGER[],
    color_hex TEXT,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert content statuses
INSERT INTO public.content_statuses_master 
    (status_id, status_code, default_name, is_publicly_visible, can_transition_to, sort_order) VALUES
(1, 'draft', 'Draft', false, ARRAY[2], 10),
(2, 'pending_review', 'Pending Review', false, ARRAY[3,4,5], 20),
(3, 'approved_published', 'Published', true, ARRAY[6], 30),
(4, 'approved_private', 'Approved (Private)', false, ARRAY[3,6], 40),
(5, 'rejected', 'Rejected', false, ARRAY[1,2], 50),
(6, 'archived', 'Archived', false, ARRAY[3], 60);

-- Waypoints table
CREATE TABLE public.waypoints (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    description TEXT,
    geometry geography(PointZ, 4326) NOT NULL,
    category_code TEXT NOT NULL REFERENCES public.waypoint_categories_master(category_code),
    amenity_tags TEXT[] DEFAULT '{}',
    accessibility_tags TEXT[] DEFAULT '{}',
    town_id INTEGER REFERENCES public.towns(id) ON DELETE SET NULL,
    address_street TEXT,
    address_number TEXT,
    postal_code TEXT,
    plus_code TEXT,
    contact_phone TEXT,
    contact_phone_formatted TEXT,
    contact_email TEXT,
    contact_website TEXT,
    social_links JSONB,
    opening_hours_osm TEXT,
    opening_hours_structured JSONB,
    seasonal_openings JSONB,
    google_place_id TEXT,
    google_maps_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    verification_date DATE,
    is_permanently_closed BOOLEAN NOT NULL DEFAULT false,
    content_visibility_status_id INTEGER NOT NULL DEFAULT 1 
        REFERENCES public.content_statuses_master(status_id),
    up_vote_count INTEGER NOT NULL DEFAULT 0,
    down_vote_count INTEGER NOT NULL DEFAULT 0,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX idx_waypoints_geometry ON public.waypoints USING GIST (geometry);
CREATE INDEX idx_waypoints_category ON public.waypoints (category_code);
CREATE INDEX idx_waypoints_town ON public.waypoints (town_id);
CREATE INDEX idx_waypoints_visibility ON public.waypoints (content_visibility_status_id);
CREATE INDEX idx_waypoints_vote_counts ON public.waypoints (up_vote_count DESC, down_vote_count ASC) 
    WHERE deleted_at IS NULL;

-- =====================================================================================
-- MODULE 4B: ATTRACTIONS
-- =====================================================================================

-- Food/Water source types
CREATE TABLE public.food_water_source_types_master (
    source_type_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    is_potable BOOLEAN NOT NULL DEFAULT true,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.food_water_source_types_master 
    (source_type_code, default_name, is_potable, sort_order) VALUES
('fountain', 'Fountain', true, 10),
('tap', 'Tap', true, 20),
('spring', 'Spring', true, 30),
('well', 'Well', false, 40),
('stream', 'Stream', false, 50),
('restaurant', 'Restaurant', true, 60),
('bar', 'Bar/Cafe', true, 70),
('grocery', 'Grocery Store', true, 80);

-- Water reliability types
CREATE TABLE public.water_reliability_types_master (
    reliability_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5),
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.water_reliability_types_master 
    (reliability_code, default_name, confidence_level, sort_order) VALUES
('always', 'Always Available', 5, 10),
('seasonal', 'Seasonal', 3, 20),
('intermittent', 'Intermittent', 2, 30),
('unreliable', 'Unreliable', 1, 40),
('unknown', 'Unknown', NULL, 50);

-- Shop service types
CREATE TABLE public.shop_service_types_master (
    service_type_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    category TEXT NOT NULL,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Attraction details
CREATE TABLE public.attraction_details (
    waypoint_id BIGINT PRIMARY KEY REFERENCES public.waypoints(id) ON DELETE CASCADE,
    attraction_type TEXT NOT NULL,
    historical_period TEXT,
    architectural_style TEXT,
    entry_fee_euros NUMERIC(10,2),
    entry_fee_notes TEXT,
    typical_visit_duration_minutes INTEGER,
    has_guided_tours BOOLEAN NOT NULL DEFAULT false,
    has_audio_guide BOOLEAN NOT NULL DEFAULT false,
    has_wheelchair_access BOOLEAN NOT NULL DEFAULT false,
    best_photo_spots TEXT[],
    popular_times JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Food/Water sources
CREATE TABLE public.food_water_sources_details (
    waypoint_id BIGINT PRIMARY KEY REFERENCES public.waypoints(id) ON DELETE CASCADE,
    source_types TEXT[] NOT NULL,
    water_reliability_code TEXT REFERENCES public.water_reliability_types_master(reliability_code),
    has_seating BOOLEAN NOT NULL DEFAULT false,
    has_cover BOOLEAN NOT NULL DEFAULT false,
    last_tested_date DATE,
    test_results TEXT,
    seasonal_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shop services details
CREATE TABLE public.shops_and_services_details (
    waypoint_id BIGINT PRIMARY KEY REFERENCES public.waypoints(id) ON DELETE CASCADE,
    service_types TEXT[] NOT NULL,
    payment_methods TEXT[],
    has_pilgrim_discount BOOLEAN NOT NULL DEFAULT false,
    pilgrim_discount_details TEXT,
    languages_spoken TEXT[],
    has_wifi BOOLEAN NOT NULL DEFAULT false,
    has_charging BOOLEAN NOT NULL DEFAULT false,
    has_lockers BOOLEAN NOT NULL DEFAULT false,
    luggage_transfer_available BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================================================
-- MODULE 5: DYNAMIC CONDITIONS
-- =====================================================================================

-- Content moderation status (reused in Module 6)
CREATE TYPE public.content_moderation_status_enum AS ENUM (
    'pending_approval', 'approved_visible', 'rejected_hidden',
    'flagged_for_review_by_admin', 'archived_by_admin'
);

-- Warning types master
CREATE TABLE public.warning_types_master (
    warning_type_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    category TEXT NOT NULL,
    default_severity_id INTEGER,
    icon_identifier TEXT,
    color_hex TEXT,
    requires_exact_location BOOLEAN NOT NULL DEFAULT false,
    requires_date_range BOOLEAN NOT NULL DEFAULT false,
    auto_expire_days INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Warning severities master
CREATE TABLE public.warning_severities_master (
    severity_id INTEGER PRIMARY KEY,
    severity_code TEXT UNIQUE NOT NULL,
    default_name TEXT NOT NULL,
    numeric_level INTEGER NOT NULL CHECK (numeric_level BETWEEN 1 AND 5),
    color_hex TEXT,
    icon_identifier TEXT,
    is_blocking BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert warning severities
INSERT INTO public.warning_severities_master 
    (severity_id, severity_code, default_name, numeric_level, color_hex, is_blocking, sort_order) VALUES
(1, 'info', 'Information', 1, '#0066CC', false, 10),
(2, 'minor', 'Minor', 2, '#F59E0B', false, 20),
(3, 'moderate', 'Moderate', 3, '#F97316', false, 30),
(4, 'major', 'Major', 4, '#DC2626', false, 40),
(5, 'critical', 'Critical', 5, '#7C3AED', true, 50);

-- Insert warning types
INSERT INTO public.warning_types_master 
    (warning_type_code, default_name, category, default_severity_id, auto_expire_days, sort_order) VALUES
('trail_closure', 'Trail Closure', 'access', 5, NULL, 10),
('partial_closure', 'Partial Closure', 'access', 4, 30, 20),
('weather_hazard', 'Weather Hazard', 'weather', 3, 7, 30),
('trail_damage', 'Trail Damage', 'condition', 3, 60, 40),
('flooding', 'Flooding', 'hazard', 4, 14, 50),
('landslide', 'Landslide', 'hazard', 5, 90, 60),
('construction', 'Construction', 'temporary', 2, 180, 70),
('event_crowds', 'Event Crowds', 'temporary', 2, 7, 80),
('wildlife', 'Wildlife Activity', 'hazard', 3, 30, 90),
('security', 'Security Concern', 'safety', 4, 14, 100);

-- Warning source types
CREATE TABLE public.warning_source_types_master (
    source_type_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    requires_verification BOOLEAN NOT NULL DEFAULT true,
    trust_level INTEGER CHECK (trust_level BETWEEN 1 AND 5),
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.warning_source_types_master 
    (source_type_code, default_name, requires_verification, trust_level, sort_order) VALUES
('official', 'Official Authority', false, 5, 10),
('staff', 'Platform Staff', false, 5, 20),
('trail_maintainer', 'Trail Maintainer', false, 4, 30),
('verified_user', 'Verified User', true, 3, 40),
('user_report', 'User Report', true, 2, 50),
('automated', 'Automated System', false, 4, 60);

-- Workflow statuses master
CREATE TABLE public.workflow_statuses_master (
    status_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    applies_to TEXT[] NOT NULL,
    is_initial BOOLEAN NOT NULL DEFAULT false,
    is_terminal BOOLEAN NOT NULL DEFAULT false,
    allowed_transitions TEXT[],
    color_hex TEXT,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.workflow_statuses_master 
    (status_code, default_name, applies_to, is_initial, is_terminal, allowed_transitions, sort_order) VALUES
('draft', 'Draft', ARRAY['warning'], true, false, ARRAY['pending_verification', 'active'], 10),
('pending_verification', 'Pending Verification', ARRAY['warning'], false, false, ARRAY['active', 'rejected'], 20),
('active', 'Active', ARRAY['warning'], false, false, ARRAY['resolved', 'expired'], 30),
('resolved', 'Resolved', ARRAY['warning'], false, true, NULL, 40),
('expired', 'Expired', ARRAY['warning'], false, true, NULL, 50),
('rejected', 'Rejected', ARRAY['warning'], false, true, NULL, 60);

-- Segment warnings
CREATE TABLE public.segment_warnings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    segment_id BIGINT NOT NULL REFERENCES public.segments(id) ON DELETE CASCADE,
    warning_type_code TEXT NOT NULL REFERENCES public.warning_types_master(warning_type_code),
    severity_id INTEGER NOT NULL REFERENCES public.warning_severities_master(severity_id),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    reported_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    source_type_code TEXT NOT NULL REFERENCES public.warning_source_types_master(source_type_code),
    workflow_status_code TEXT NOT NULL DEFAULT 'draft' 
        REFERENCES public.workflow_statuses_master(status_code),
    geometry geography(PointZ, 4326),
    affected_length_m NUMERIC,
    affected_direction TEXT CHECK (affected_direction IN ('both', 'forward', 'backward')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_date_estimated BOOLEAN NOT NULL DEFAULT false,
    verification_date TIMESTAMPTZ,
    verified_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    external_reference_id TEXT,
    external_reference_url TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT segment_warnings_dates_check CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Create indexes
CREATE INDEX idx_segment_warnings_segment ON public.segment_warnings (segment_id);
CREATE INDEX idx_segment_warnings_active ON public.segment_warnings (workflow_status_code, start_date, end_date)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_segment_warnings_geometry ON public.segment_warnings USING GIST (geometry);

-- =====================================================================================
-- MODULE 6: USER INTERACTION
-- =====================================================================================

-- Vote type enum
CREATE TYPE public.vote_type_enum AS ENUM ('up', 'down');

-- Tip categories master
CREATE TABLE public.tip_categories_master (
    category_code TEXT PRIMARY KEY,
    default_name TEXT NOT NULL,
    default_description TEXT,
    icon_identifier TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Insert tip categories
INSERT INTO public.tip_categories_master 
    (category_code, default_name, default_description, icon_identifier, sort_order) VALUES
('practical_advice', 'Practical Advice', 'General tips related to practicality, gear, or general information.', 'icon-lightbulb', 10),
('safety_observation', 'Safety Observation', 'Tips related to safety, warnings, or potential hazards.', 'icon-warning', 20),
('hidden_gem', 'Hidden Gem', 'Tips about lesser-known spots or positive experiences.', 'icon-star', 30),
('poi_correction', 'POI Correction', 'Tips suggesting corrections to Point of Interest information.', 'icon-edit', 40),
('trail_condition', 'Trail Condition', 'Updates about current trail conditions, obstacles, or changes.', 'icon-map', 50),
('pilgrim_etiquette', 'Pilgrim Etiquette', 'Tips about proper behavior and customs on the pilgrimage.', 'icon-users', 60),
('spiritual_insight', 'Spiritual Insight', 'Reflections and spiritual observations along the way.', 'icon-heart', 70),
('local_recommendation', 'Local Recommendation', 'Recommendations for local services, food, or experiences.', 'icon-thumbs-up', 80);

-- User waypoint votes
CREATE TABLE public.user_waypoint_votes (
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    waypoint_id BIGINT NOT NULL REFERENCES public.waypoints(id) ON DELETE CASCADE,
    vote_type public.vote_type_enum NOT NULL,
    vote_source_platform TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (profile_id, waypoint_id)
);

-- Moderator check function
CREATE OR REPLACE FUNCTION public.check_if_user_is_moderator(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = user_id 
        AND (
            'moderator_platform' = ANY(roles) OR 
            'admin_platform' = ANY(roles) OR
            'moderator_regional' = ANY(roles)
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- User waypoint short tips
CREATE TABLE public.user_waypoint_short_tips (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    waypoint_id BIGINT NOT NULL REFERENCES public.waypoints(id) ON DELETE CASCADE,
    tip_text TEXT NOT NULL CHECK (char_length(tip_text) > 0 AND char_length(tip_text) <= 500),
    language_code TEXT NOT NULL REFERENCES public.languages_master(language_code) ON DELETE RESTRICT,
    tip_category_code TEXT REFERENCES public.tip_categories_master(category_code) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    tip_source_platform TEXT,
    moderation_status public.content_moderation_status_enum NOT NULL DEFAULT 'pending_approval',
    is_publicly_visible BOOLEAN GENERATED ALWAYS AS 
        (moderation_status = 'approved_visible' AND deleted_at IS NULL) STORED,
    is_pinned_by_admin BOOLEAN NOT NULL DEFAULT false,
    moderated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    moderation_timestamp TIMESTAMPTZ,
    moderation_notes_internal TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX idx_user_waypoint_votes_active ON public.user_waypoint_votes 
    (waypoint_id, vote_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_tip_categories_master_active_order ON public.tip_categories_master 
    (is_active, sort_order);
CREATE INDEX idx_user_waypoint_short_tips_visibility ON public.user_waypoint_short_tips 
    (waypoint_id, is_publicly_visible, is_pinned_by_admin DESC, created_at DESC);
CREATE INDEX idx_user_waypoint_short_tips_moderation ON public.user_waypoint_short_tips 
    (moderation_status, created_at ASC);

-- Vote count update trigger
CREATE OR REPLACE FUNCTION public.update_waypoint_vote_counts() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF NEW.deleted_at IS NULL THEN
            IF NEW.vote_type = 'up' THEN
                UPDATE public.waypoints SET up_vote_count = up_vote_count + 1 WHERE id = NEW.waypoint_id;
            ELSE
                UPDATE public.waypoints SET down_vote_count = down_vote_count + 1 WHERE id = NEW.waypoint_id;
            END IF;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        IF OLD.deleted_at IS NULL THEN
            IF OLD.vote_type = 'up' THEN
                UPDATE public.waypoints SET up_vote_count = GREATEST(0, up_vote_count - 1) WHERE id = OLD.waypoint_id;
            ELSE
                UPDATE public.waypoints SET down_vote_count = GREATEST(0, down_vote_count - 1) WHERE id = OLD.waypoint_id;
            END IF;
        END IF;
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Handle vote retraction
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
            IF OLD.vote_type = 'up' THEN
                UPDATE public.waypoints SET up_vote_count = GREATEST(0, up_vote_count - 1) WHERE id = OLD.waypoint_id;
            ELSE
                UPDATE public.waypoints SET down_vote_count = GREATEST(0, down_vote_count - 1) WHERE id = OLD.waypoint_id;
            END IF;
        -- Handle vote reinstatement
        ELSIF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL THEN
            IF NEW.vote_type = 'up' THEN
                UPDATE public.waypoints SET up_vote_count = up_vote_count + 1 WHERE id = NEW.waypoint_id;
            ELSE
                UPDATE public.waypoints SET down_vote_count = down_vote_count + 1 WHERE id = NEW.waypoint_id;
            END IF;
        -- Handle vote type change
        ELSIF OLD.deleted_at IS NULL AND NEW.deleted_at IS NULL AND OLD.vote_type <> NEW.vote_type THEN
            IF OLD.vote_type = 'up' THEN
                UPDATE public.waypoints SET up_vote_count = GREATEST(0, up_vote_count - 1) WHERE id = OLD.waypoint_id;
                UPDATE public.waypoints SET down_vote_count = down_vote_count + 1 WHERE id = NEW.waypoint_id;
            ELSE
                UPDATE public.waypoints SET down_vote_count = GREATEST(0, down_vote_count - 1) WHERE id = OLD.waypoint_id;
                UPDATE public.waypoints SET up_vote_count = up_vote_count + 1 WHERE id = NEW.waypoint_id;
            END IF;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================================================
-- TRIGGERS
-- =====================================================================================

-- Updated_at triggers
CREATE TRIGGER on_profiles_updated_at BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_user_roles_master_updated_at BEFORE UPDATE ON public.user_roles_master 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_languages_master_updated_at BEFORE UPDATE ON public.languages_master 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_media_updated_at BEFORE UPDATE ON public.media 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_translations_updated_at BEFORE UPDATE ON public.translations 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_trails_updated_at BEFORE UPDATE ON public.trails 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_routes_updated_at BEFORE UPDATE ON public.routes 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_segments_updated_at BEFORE UPDATE ON public.segments 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_countries_updated_at BEFORE UPDATE ON public.countries 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_regions_updated_at BEFORE UPDATE ON public.regions 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_provinces_updated_at BEFORE UPDATE ON public.provinces 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_towns_updated_at BEFORE UPDATE ON public.towns 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_waypoints_updated_at BEFORE UPDATE ON public.waypoints 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_segment_warnings_updated_at BEFORE UPDATE ON public.segment_warnings 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_tip_categories_master_updated_at BEFORE UPDATE ON public.tip_categories_master 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_user_waypoint_votes_updated_at BEFORE UPDATE ON public.user_waypoint_votes 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER on_user_waypoint_short_tips_updated_at BEFORE UPDATE ON public.user_waypoint_short_tips 
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Vote count trigger
CREATE TRIGGER after_user_waypoint_votes_change 
    AFTER INSERT OR UPDATE OR DELETE ON public.user_waypoint_votes 
    FOR EACH ROW EXECUTE FUNCTION public.update_waypoint_vote_counts();

-- Translation cleanup trigger for tip categories
CREATE OR REPLACE FUNCTION public.cleanup_tip_categories_master_translations() 
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.translations 
    WHERE table_identifier = 'tip_categories_master' 
    AND row_foreign_key = OLD.category_code;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_cleanup_translations_on_tip_category_delete 
    AFTER DELETE ON public.tip_categories_master 
    FOR EACH ROW EXECUTE FUNCTION public.cleanup_tip_categories_master_translations();

-- =====================================================================================
-- RLS POLICIES
-- =====================================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waypoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.segment_warnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tip_categories_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_waypoint_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_waypoint_short_tips ENABLE ROW LEVEL SECURITY;

-- Profile policies
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Media policies
CREATE POLICY "Media viewable by everyone" ON public.media
    FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "Authenticated users can upload media" ON public.media
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = uploaded_by_profile_id);

-- Translation policies
CREATE POLICY "Translations viewable by everyone" ON public.translations
    FOR SELECT USING (true);
CREATE POLICY "Moderators can manage translations" ON public.translations
    FOR ALL TO authenticated USING (public.has_role('moderator_platform'));

-- Trail policies
CREATE POLICY "Active trails viewable by everyone" ON public.trails
    FOR SELECT USING (is_active = true AND deleted_at IS NULL);
CREATE POLICY "Trail maintainers can update trails" ON public.trails
    FOR UPDATE TO authenticated USING (public.has_role('trail_maintainer'));

-- Route policies
CREATE POLICY "Routes viewable by everyone" ON public.routes
    FOR SELECT USING (deleted_at IS NULL);

-- Segment policies
CREATE POLICY "Segments viewable by everyone" ON public.segments
    FOR SELECT USING (deleted_at IS NULL);

-- Waypoint policies
CREATE POLICY "Published waypoints viewable by everyone" ON public.waypoints
    FOR SELECT USING (
        content_visibility_status_id = 3 
        AND deleted_at IS NULL
    );
CREATE POLICY "Authenticated can view own waypoints" ON public.waypoints
    FOR SELECT TO authenticated USING (created_by_profile_id = auth.uid());

-- Warning policies
CREATE POLICY "Active warnings viewable by everyone" ON public.segment_warnings
    FOR SELECT USING (
        workflow_status_code = 'active' 
        AND deleted_at IS NULL
    );
CREATE POLICY "Authenticated can report warnings" ON public.segment_warnings
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = reported_by_profile_id);

-- Tip category policies
CREATE POLICY "Admins can manage tip categories" ON public.tip_categories_master 
    FOR ALL TO authenticated 
    USING (public.has_role_on_profile(auth.uid(), 'admin_platform'))
    WITH CHECK (public.has_role_on_profile(auth.uid(), 'admin_platform'));
CREATE POLICY "Public can view active tip categories" ON public.tip_categories_master 
    FOR SELECT USING (is_active = true);

-- Vote policies
CREATE POLICY "Pilgrims can insert their own votes" ON public.user_waypoint_votes 
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Pilgrims can update their own votes" ON public.user_waypoint_votes 
    FOR UPDATE TO authenticated 
    USING (auth.uid() = profile_id) 
    WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Pilgrims can view their own votes" ON public.user_waypoint_votes 
    FOR SELECT TO authenticated USING (auth.uid() = profile_id);

-- Tip policies
CREATE POLICY "Pilgrims can insert their own tips" ON public.user_waypoint_short_tips 
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Pilgrims can view publicly visible tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated USING (is_publicly_visible = true);
CREATE POLICY "Pilgrims can view their own tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated USING (auth.uid() = profile_id);
CREATE POLICY "Pilgrims can update their own tips" ON public.user_waypoint_short_tips 
    FOR UPDATE TO authenticated 
    USING (auth.uid() = profile_id) 
    WITH CHECK (
        auth.uid() = profile_id AND (
            (OLD.deleted_at IS DISTINCT FROM NEW.deleted_at 
             AND OLD.tip_text = NEW.tip_text 
             AND OLD.language_code = NEW.language_code 
             AND OLD.tip_category_code IS NOT DISTINCT FROM NEW.tip_category_code 
             AND OLD.moderation_status = NEW.moderation_status)
            OR
            (OLD.moderation_status = 'pending_approval' 
             AND NEW.moderation_status = 'pending_approval')
        )
    );
CREATE POLICY "Moderators can view all tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated 
    USING (public.check_if_user_is_moderator(auth.uid()));
CREATE POLICY "Moderators can update moderation fields on tips" ON public.user_waypoint_short_tips 
    FOR UPDATE TO authenticated 
    USING (public.check_if_user_is_moderator(auth.uid())) 
    WITH CHECK (public.check_if_user_is_moderator(auth.uid()));

-- =====================================================================================
-- VIEWS
-- =====================================================================================

-- Tip categories localized view
CREATE OR REPLACE VIEW public.view_tip_categories_localized AS
SELECT 
    tcm.category_code,
    COALESCE(trans_name.translated_text, tcm.default_name) AS localized_name,
    COALESCE(trans_desc.translated_text, tcm.default_description) AS localized_description,
    tcm.icon_identifier,
    tcm.sort_order,
    tcm.is_active,
    tcm.created_at,
    tcm.updated_at,
    tcm.created_by_profile_id,
    tcm.updated_by_profile_id
FROM public.tip_categories_master tcm
LEFT JOIN public.translations trans_name ON 
    tcm.category_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'tip_categories_master' 
    AND trans_name.column_identifier = 'default_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    tcm.category_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'tip_categories_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE tcm.is_active = true;

-- Grant permissions
GRANT SELECT ON public.view_tip_categories_localized TO authenticated, anon;

-- =====================================================================================
-- FINAL SETUP
-- =====================================================================================

-- Add foreign key for segments to waypoints (deferred to avoid circular dependency)
ALTER TABLE public.segments 
    ADD CONSTRAINT segments_start_waypoint_fk 
    FOREIGN KEY (start_waypoint_id) REFERENCES public.waypoints(id) ON DELETE SET NULL,
    ADD CONSTRAINT segments_end_waypoint_fk 
    FOREIGN KEY (end_waypoint_id) REFERENCES public.waypoints(id) ON DELETE SET NULL;

-- Add check constraint to profiles for valid roles
ALTER TABLE public.profiles 
    ADD CONSTRAINT profiles_roles_check 
    CHECK (roles <@ ARRAY['pilgrim', 'host', 'moderator_regional', 'moderator_platform', 
                          'admin_regional', 'admin_platform', 'content_creator', 
                          'photographer', 'trail_maintainer']::TEXT[]);

-- Create composite indexes for common queries
CREATE INDEX idx_waypoints_category_town ON public.waypoints (category_code, town_id) 
    WHERE deleted_at IS NULL;
CREATE INDEX idx_segments_difficulty_accessible ON public.segments (difficulty_rating, is_accessible) 
    WHERE deleted_at IS NULL;
CREATE INDEX idx_trails_type_active ON public.trails (trail_type, is_active) 
    WHERE deleted_at IS NULL;

-- =====================================================================================
-- END OF COMPACT MIGRATION
-- =====================================================================================
-- Module 4: Waypoint Details
-- 008_waypoints_enhanced.sql: Enhanced waypoints table replacing stub
-- 
-- Purpose: Replace the stub waypoints table with full-featured implementation
-- Dependencies: All previous Module 4 migrations, Module 1, Module 3

-- Drop the existing waypoints stub table and its constraints
DROP TABLE IF EXISTS public.waypoints CASCADE;

-- Create the enhanced waypoints table
CREATE TABLE public.waypoints (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL CHECK (length(name) > 0 AND length(name) <= 255),
    slug TEXT UNIQUE CHECK (
        slug IS NULL OR (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$' AND 
            length(slug) > 0 AND 
            length(slug) <= 100
        )
    ),
    alternate_names_primary_lang TEXT[] NULL,
    waypoint_primary_category_id INTEGER NOT NULL,
    waypoint_subcategory_tag_ids INTEGER[] NULL,
    description TEXT NULL,
    geom GEOGRAPHY(PointZ, 4326) NOT NULL,
    latitude DOUBLE PRECISION GENERATED ALWAYS AS (ST_Y(ST_Transform(geom::geometry, 4326))) STORED,
    longitude DOUBLE PRECISION GENERATED ALWAYS AS (ST_X(ST_Transform(geom::geometry, 4326))) STORED,
    elevation_meters INTEGER GENERATED ALWAYS AS (ST_Z(ST_Transform(geom::geometry, 4326))) STORED NULL,
    town_id INTEGER NULL,
    parent_waypoint_id BIGINT NULL,
    address_text TEXT NULL,
    primary_image_media_id UUID NULL,
    primary_thumbnail_media_id UUID NULL,
    content_visibility_status_id INTEGER NOT NULL DEFAULT (
        SELECT id FROM public.content_statuses_master WHERE code = 'draft' LIMIT 1
    ),
    is_seasonal BOOLEAN NOT NULL DEFAULT FALSE,
    is_trail_access_point BOOLEAN NOT NULL DEFAULT FALSE,
    is_significant_trail_junction BOOLEAN NOT NULL DEFAULT FALSE,
    is_franciscan_highlight_site BOOLEAN NOT NULL DEFAULT FALSE,
    is_significant_pilgrim_poi BOOLEAN NOT NULL DEFAULT FALSE,
    short_narrative_for_dynamic_lists TEXT NULL CHECK (
        short_narrative_for_dynamic_lists IS NULL OR 
        length(short_narrative_for_dynamic_lists) <= 250
    ),
    waypoint_accessibility_notes TEXT NULL,
    general_tags_text TEXT[] NULL,
    primary_data_source_waypoint TEXT NULL,
    quality_score SMALLINT NULL CHECK (
        quality_score IS NULL OR 
        (quality_score >= 0 AND quality_score <= 100)
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by_profile_id UUID NULL,
    deleted_at TIMESTAMPTZ NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_waypoint_primary_category 
        FOREIGN KEY(waypoint_primary_category_id) 
        REFERENCES public.waypoint_categories_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_town 
        FOREIGN KEY(town_id) 
        REFERENCES public.towns(id) ON DELETE SET NULL,
    CONSTRAINT fk_parent_waypoint 
        FOREIGN KEY(parent_waypoint_id) 
        REFERENCES public.waypoints(id) ON DELETE SET NULL,
    CONSTRAINT fk_primary_image_media 
        FOREIGN KEY(primary_image_media_id) 
        REFERENCES public.media(id) ON DELETE SET NULL,
    CONSTRAINT fk_primary_thumbnail_media 
        FOREIGN KEY(primary_thumbnail_media_id) 
        REFERENCES public.media(id) ON DELETE SET NULL,
    CONSTRAINT fk_content_visibility_status 
        FOREIGN KEY(content_visibility_status_id) 
        REFERENCES public.content_statuses_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_created_by_profile 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_updated_by_profile 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.waypoints IS 'Central, generic repository for all distinct, geographically located points of interest (POIs), navigational markers, or service locations relevant to the pilgrimage trails. Version 1.3';
COMMENT ON COLUMN public.waypoints.id IS 'Unique identifier for each waypoint.';
COMMENT ON COLUMN public.waypoints.name IS 'Primary human-readable name. Primary reference language (English) text. Translatable via the ''translations'' table. Max 255 chars.';
COMMENT ON COLUMN public.waypoints.slug IS 'URL-friendly identifier (kebab-case), unique if set. Max 100 chars.';
COMMENT ON COLUMN public.waypoints.alternate_names_primary_lang IS 'Array of other known names or synonyms in the primary reference language (English). For other language names, use the ''translations'' table.';
COMMENT ON COLUMN public.waypoints.waypoint_primary_category_id IS 'FK to waypoint_categories_master. Broad category of the waypoint.';
COMMENT ON COLUMN public.waypoints.waypoint_subcategory_tag_ids IS 'Array of FKs to tags_master. Specific, managed tags. **Integrity of array elements MUST be enforced by a dedicated database trigger.**';
COMMENT ON COLUMN public.waypoints.description IS 'General, brief description. Primary reference language (English) text. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.waypoints.geom IS 'Authoritative PostGIS geography point (PointZ, SRID 4326 WGS84), including Z for elevation if available.';
COMMENT ON COLUMN public.waypoints.latitude IS 'Latitude (WGS 84 decimal degrees). Generated from geom. For non-PostGIS contexts.';
COMMENT ON COLUMN public.waypoints.longitude IS 'Longitude (WGS 84 decimal degrees). Generated from geom. For non-PostGIS contexts.';
COMMENT ON COLUMN public.waypoints.elevation_meters IS 'Elevation (meters above sea level). Generated from geom Z value if present. Nullable.';
COMMENT ON COLUMN public.waypoints.town_id IS 'FK to towns table. If the waypoint is located within or directly associated with a recognized town.';
COMMENT ON COLUMN public.waypoints.parent_waypoint_id IS 'FK to waypoints.id for hierarchical waypoints (e.g., specific chapel within La Verna complex).';
COMMENT ON COLUMN public.waypoints.address_text IS 'Textual street address, if applicable. Primary reference language (English) text. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.waypoints.primary_image_media_id IS 'FK to media table. Primary representative image.';
COMMENT ON COLUMN public.waypoints.primary_thumbnail_media_id IS 'FK to media table. Smaller thumbnail version of the primary image.';
COMMENT ON COLUMN public.waypoints.content_visibility_status_id IS 'FK to content_statuses_master. Manages the publication lifecycle.';
COMMENT ON COLUMN public.waypoints.is_seasonal IS 'Indicates if the waypoint''s availability, operation, or accessibility is seasonal.';
COMMENT ON COLUMN public.waypoints.is_trail_access_point IS 'Flags if this waypoint serves as a common or convenient access point to a trail.';
COMMENT ON COLUMN public.waypoints.is_significant_trail_junction IS 'Flags if this waypoint represents a major, named, or decision-critical trail junction.';
COMMENT ON COLUMN public.waypoints.is_franciscan_highlight_site IS 'Flags if this is a key site directly related to St. Francis, Franciscan history, or Franciscan spirituality.';
COMMENT ON COLUMN public.waypoints.is_significant_pilgrim_poi IS 'Flags if this is a point of interest of general major significance to pilgrims.';
COMMENT ON COLUMN public.waypoints.short_narrative_for_dynamic_lists IS 'Brief (1-2 sentence, max 250 chars) descriptive snippet. Primary reference language (English) text. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.waypoints.waypoint_accessibility_notes IS 'Specific notes regarding accessibility for individuals with disabilities. Primary reference language (English) text. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.waypoints.general_tags_text IS 'Array of general, free-text descriptive tags if not covered by structured waypoint_subcategory_tag_ids. Use with caution.';
COMMENT ON COLUMN public.waypoints.primary_data_source_waypoint IS 'Information on the source of this waypoint''s data (e.g., "Official Guidebook VdF 2024").';
COMMENT ON COLUMN public.waypoints.quality_score IS 'Internal score (0-100) indicating data confidence/completeness. Nullable.';
COMMENT ON COLUMN public.waypoints.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.waypoints.created_by_profile_id IS 'Profile ID of the user who created the record.';
COMMENT ON COLUMN public.waypoints.updated_at IS 'Timestamp of last update.';
COMMENT ON COLUMN public.waypoints.updated_by_profile_id IS 'Profile ID of the user who last updated the record.';
COMMENT ON COLUMN public.waypoints.deleted_at IS 'Timestamp for soft deletion. Active records have deleted_at IS NULL.';

-- Create indexes for performance
CREATE INDEX idx_waypoints_geom ON public.waypoints USING GIST (geom);
CREATE INDEX idx_waypoints_town_id ON public.waypoints(town_id) WHERE town_id IS NOT NULL;
CREATE INDEX idx_waypoints_parent_waypoint_id ON public.waypoints(parent_waypoint_id) WHERE parent_waypoint_id IS NOT NULL;
CREATE INDEX idx_waypoints_content_visibility_status_id ON public.waypoints(content_visibility_status_id);
CREATE INDEX idx_waypoints_waypoint_primary_category_id ON public.waypoints(waypoint_primary_category_id);
CREATE INDEX idx_waypoints_name_trgm ON public.waypoints USING GIN (name gin_trgm_ops);
CREATE INDEX idx_waypoints_subcategory_tag_ids ON public.waypoints USING GIN (waypoint_subcategory_tag_ids) WHERE waypoint_subcategory_tag_ids IS NOT NULL;
CREATE INDEX idx_waypoints_deleted_at ON public.waypoints(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_waypoints_created_by ON public.waypoints(created_by_profile_id);
CREATE INDEX idx_waypoints_updated_by ON public.waypoints(updated_by_profile_id);

-- Boolean flag indexes for common queries
CREATE INDEX idx_waypoints_is_seasonal ON public.waypoints(is_seasonal) WHERE is_seasonal = true;
CREATE INDEX idx_waypoints_is_trail_access_point ON public.waypoints(is_trail_access_point) WHERE is_trail_access_point = true;
CREATE INDEX idx_waypoints_is_significant_trail_junction ON public.waypoints(is_significant_trail_junction) WHERE is_significant_trail_junction = true;
CREATE INDEX idx_waypoints_is_franciscan_highlight_site ON public.waypoints(is_franciscan_highlight_site) WHERE is_franciscan_highlight_site = true;
CREATE INDEX idx_waypoints_is_significant_pilgrim_poi ON public.waypoints(is_significant_pilgrim_poi) WHERE is_significant_pilgrim_poi = true;

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_waypoints_set_updated_at
    BEFORE UPDATE ON public.waypoints
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Array FK validation trigger for subcategory tags
CREATE TRIGGER trigger_check_waypoint_subcategory_tags
    BEFORE INSERT OR UPDATE ON public.waypoints
    FOR EACH ROW
    EXECUTE FUNCTION public.check_waypoint_subcategory_tags();

-- Translation cleanup trigger (for when waypoints are hard deleted)
CREATE TRIGGER trigger_cleanup_waypoints_translations
    AFTER DELETE ON public.waypoints
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations('waypoints');

-- Add trigger comments
COMMENT ON TRIGGER trigger_waypoints_set_updated_at ON public.waypoints IS 
'Trigger to automatically update updated_at timestamp on row modification.';
COMMENT ON TRIGGER trigger_check_waypoint_subcategory_tags ON public.waypoints IS 
'Validates that all IDs in waypoint_subcategory_tag_ids array reference active tags in tags_master.';
COMMENT ON TRIGGER trigger_cleanup_waypoints_translations ON public.waypoints IS 
'Cleans up orphaned translations when a waypoint is hard deleted.';

-- Enable Row Level Security
ALTER TABLE public.waypoints ENABLE ROW LEVEL SECURITY;
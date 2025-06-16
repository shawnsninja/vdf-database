-- Module 2: Core Trail Hierarchy
-- 008_segments.sql: Granular sections of trail paths
-- 
-- Purpose: Define trail segments with 3D geometry and auto-calculated properties
-- Dependencies: waypoints, terrain_types_master, media

-- Create segments table
CREATE TABLE IF NOT EXISTS public.segments (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    start_waypoint_id BIGINT NOT NULL REFERENCES public.waypoints(id) ON DELETE RESTRICT,
    end_waypoint_id BIGINT NOT NULL REFERENCES public.waypoints(id) ON DELETE RESTRICT,
    path_geom GEOMETRY(LineStringZ, 4326) NOT NULL,
    distance_km REAL,
    elevation_gain_meters INTEGER,
    elevation_loss_meters INTEGER,
    min_elevation_meters INTEGER,
    max_elevation_meters INTEGER,
    elevation_profile_data JSONB,
    dominant_terrain_type_id INTEGER REFERENCES public.terrain_types_master(id) ON DELETE SET NULL,
    segment_difficulty segment_difficulty_enum NOT NULL DEFAULT 'moderate',
    sun_exposure_level segment_sun_exposure_enum,
    travel_direction segment_travel_direction_enum NOT NULL DEFAULT 'bidirectional',
    typical_duration_minutes_forward INTEGER CHECK (typical_duration_minutes_forward > 0),
    typical_duration_minutes_backward INTEGER CHECK (typical_duration_minutes_backward > 0),
    gpx_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    content_visibility_status content_visibility_status_enum NOT NULL DEFAULT 'draft',
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT different_start_end CHECK (start_waypoint_id != end_waypoint_id)
);

-- Add table and column comments
COMMENT ON TABLE public.segments IS 'Most granular trail sections defined by 3D geometry. Auto-calculates distance and elevation from path_geom. Version: 2.0';
COMMENT ON COLUMN public.segments.id IS 'Primary Key. Unique identifier for each segment.';
COMMENT ON COLUMN public.segments.name IS 'English name of the segment. Other languages in translations table.';
COMMENT ON COLUMN public.segments.slug IS 'URL-friendly identifier. Optional but unique if provided.';
COMMENT ON COLUMN public.segments.start_waypoint_id IS 'FK to starting waypoint. RESTRICT delete to maintain integrity.';
COMMENT ON COLUMN public.segments.end_waypoint_id IS 'FK to ending waypoint. RESTRICT delete to maintain integrity.';
COMMENT ON COLUMN public.segments.path_geom IS '3D LineString geometry (includes elevation). SRID 4326. Source for auto-calculations.';
COMMENT ON COLUMN public.segments.distance_km IS 'Distance in kilometers. Auto-calculated from path_geom via trigger.';
COMMENT ON COLUMN public.segments.elevation_gain_meters IS 'Total elevation gain. Auto-calculated from path_geom via trigger.';
COMMENT ON COLUMN public.segments.elevation_loss_meters IS 'Total elevation loss. Auto-calculated from path_geom via trigger.';
COMMENT ON COLUMN public.segments.elevation_profile_data IS 'JSON array of elevation points. Auto-calculated from path_geom.';
COMMENT ON COLUMN public.segments.dominant_terrain_type_id IS 'FK to primary terrain type. Additional types in segment_additional_terrain_types.';
COMMENT ON COLUMN public.segments.segment_difficulty IS 'Overall difficulty rating for this segment.';
COMMENT ON COLUMN public.segments.sun_exposure_level IS 'Amount of sun/shade on this segment.';
COMMENT ON COLUMN public.segments.travel_direction IS 'Whether segment can be traveled both ways or is one-way.';
COMMENT ON COLUMN public.segments.gpx_media_id IS 'FK to media table for segment GPX file.';
COMMENT ON COLUMN public.segments.deleted_at IS 'Timestamp for soft deletion. NULL means active.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_segments_slug ON public.segments(slug) WHERE slug IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_segments_start_waypoint_id ON public.segments(start_waypoint_id);
CREATE INDEX IF NOT EXISTS idx_segments_end_waypoint_id ON public.segments(end_waypoint_id);
CREATE INDEX IF NOT EXISTS idx_segments_path_geom ON public.segments USING GIST (path_geom);
CREATE INDEX IF NOT EXISTS idx_segments_dominant_terrain_type_id ON public.segments(dominant_terrain_type_id);
CREATE INDEX IF NOT EXISTS idx_segments_segment_difficulty ON public.segments(segment_difficulty);
CREATE INDEX IF NOT EXISTS idx_segments_content_visibility_status ON public.segments(content_visibility_status);
CREATE INDEX IF NOT EXISTS idx_segments_deleted_at ON public.segments(deleted_at);

-- Create function to calculate segment properties from geometry
CREATE OR REPLACE FUNCTION public.calculate_segment_properties()
RETURNS TRIGGER AS $$
DECLARE
    point_count INTEGER;
    prev_point GEOMETRY;
    curr_point GEOMETRY;
    total_distance_m NUMERIC := 0;
    total_gain_m NUMERIC := 0;
    total_loss_m NUMERIC := 0;
    min_elev NUMERIC := 999999;
    max_elev NUMERIC := -999999;
    prev_elev NUMERIC;
    curr_elev NUMERIC;
    elevation_profile JSONB := '[]'::jsonb;
    cumulative_distance_m NUMERIC := 0;
    segment_distance_m NUMERIC;
BEGIN
    -- Only calculate if path_geom has changed or is new
    IF TG_OP = 'UPDATE' AND OLD.path_geom IS NOT DISTINCT FROM NEW.path_geom THEN
        RETURN NEW;
    END IF;
    
    -- Get number of points
    point_count := ST_NPoints(NEW.path_geom);
    
    IF point_count < 2 THEN
        RAISE EXCEPTION 'Segment path must have at least 2 points';
    END IF;
    
    -- Initialize with first point
    prev_point := ST_PointN(NEW.path_geom, 1);
    prev_elev := ST_Z(prev_point);
    min_elev := prev_elev;
    max_elev := prev_elev;
    
    -- Add first point to elevation profile
    elevation_profile := elevation_profile || jsonb_build_object(
        'distance_km', 0,
        'elevation_m', prev_elev
    );
    
    -- Process each subsequent point
    FOR i IN 2..point_count LOOP
        curr_point := ST_PointN(NEW.path_geom, i);
        curr_elev := ST_Z(curr_point);
        
        -- Calculate distance for this segment
        segment_distance_m := ST_Distance(prev_point::geography, curr_point::geography);
        total_distance_m := total_distance_m + segment_distance_m;
        cumulative_distance_m := cumulative_distance_m + segment_distance_m;
        
        -- Calculate elevation changes
        IF curr_elev > prev_elev THEN
            total_gain_m := total_gain_m + (curr_elev - prev_elev);
        ELSIF curr_elev < prev_elev THEN
            total_loss_m := total_loss_m + (prev_elev - curr_elev);
        END IF;
        
        -- Update min/max
        min_elev := LEAST(min_elev, curr_elev);
        max_elev := GREATEST(max_elev, curr_elev);
        
        -- Add to elevation profile (sample every ~100m or at each point)
        IF i = point_count OR segment_distance_m > 100 THEN
            elevation_profile := elevation_profile || jsonb_build_object(
                'distance_km', ROUND((cumulative_distance_m / 1000.0)::numeric, 3),
                'elevation_m', ROUND(curr_elev::numeric, 1)
            );
        END IF;
        
        -- Move to next segment
        prev_point := curr_point;
        prev_elev := curr_elev;
    END LOOP;
    
    -- Set calculated values
    NEW.distance_km := ROUND((total_distance_m / 1000.0)::numeric, 3)::real;
    NEW.elevation_gain_meters := ROUND(total_gain_m)::integer;
    NEW.elevation_loss_meters := ROUND(total_loss_m)::integer;
    NEW.min_elevation_meters := ROUND(min_elev)::integer;
    NEW.max_elevation_meters := ROUND(max_elev)::integer;
    NEW.elevation_profile_data := elevation_profile;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create trigger for auto-calculation
CREATE TRIGGER trigger_calculate_segment_properties
    BEFORE INSERT OR UPDATE OF path_geom ON public.segments
    FOR EACH ROW
    EXECUTE FUNCTION public.calculate_segment_properties();

-- Create standard triggers
CREATE TRIGGER trigger_segments_set_updated_at
    BEFORE UPDATE ON public.segments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_segment_translations
    AFTER DELETE ON public.segments
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.segments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on segments" ON public.segments
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on segments" ON public.segments
    FOR SELECT TO authenticated
    USING (deleted_at IS NULL AND content_visibility_status = 'published');

CREATE POLICY "Allow anonymous users read access on segments" ON public.segments
    FOR SELECT TO anon
    USING (deleted_at IS NULL AND content_visibility_status = 'published');
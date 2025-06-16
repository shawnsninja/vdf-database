-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 004_curated_itinerary_segments.sql
-- Description: Create curated_itinerary_segments table for daily segments of itineraries
-- Dependencies: 
--   - Module 1 (profiles)
--   - Module 2 (segments)
--   - Module 3 (towns)
--   - Module 4 (waypoints, accommodations)
--   - 003_curated_itineraries.sql
-- Version: 1.0
-- =====================================================================================

-- Table: public.curated_itinerary_segments
-- Purpose: Stores daily segments of a curated itinerary with accommodations and highlights
CREATE TABLE public.curated_itinerary_segments (
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    curated_itinerary_id bigint NOT NULL,
    day_number smallint NOT NULL,
    segment_id bigint NOT NULL,
    start_waypoint_id bigint NULL,
    end_waypoint_id bigint NULL,
    start_town_id bigint NULL,
    end_town_id bigint NULL,
    suggested_accommodation_id bigint NULL,
    alternative_accommodation_ids bigint[] NULL,
    default_day_title text NOT NULL,
    default_day_description text NULL,
    default_highlights text[] NULL,
    walking_time_hours numeric(3,1) NOT NULL,
    distance_km numeric(5,2) NOT NULL,
    elevation_gain_m numeric(6,0) NULL,
    elevation_loss_m numeric(6,0) NULL,
    difficulty_notes text NULL,
    terrain_notes text NULL,
    services_available text[] NULL,
    lunch_stop_waypoint_id bigint NULL,
    lunch_stop_notes text NULL,
    alternative_route_notes text NULL,
    bad_weather_alternative text NULL,
    accessibility_notes text NULL,
    sort_order smallint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT curated_itinerary_segments_pkey PRIMARY KEY (id),
    CONSTRAINT curated_itinerary_segments_unique_day UNIQUE (curated_itinerary_id, day_number),
    CONSTRAINT curated_itinerary_segments_curated_itinerary_id_fkey 
        FOREIGN KEY (curated_itinerary_id) REFERENCES public.curated_itineraries(id) ON DELETE CASCADE,
    CONSTRAINT curated_itinerary_segments_segment_id_fkey 
        FOREIGN KEY (segment_id) REFERENCES public.segments(id) ON DELETE RESTRICT,
    CONSTRAINT curated_itinerary_segments_start_waypoint_id_fkey 
        FOREIGN KEY (start_waypoint_id) REFERENCES public.waypoints(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_end_waypoint_id_fkey 
        FOREIGN KEY (end_waypoint_id) REFERENCES public.waypoints(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_start_town_id_fkey 
        FOREIGN KEY (start_town_id) REFERENCES public.towns(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_end_town_id_fkey 
        FOREIGN KEY (end_town_id) REFERENCES public.towns(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_suggested_accommodation_id_fkey 
        FOREIGN KEY (suggested_accommodation_id) REFERENCES public.accommodations(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_lunch_stop_waypoint_id_fkey 
        FOREIGN KEY (lunch_stop_waypoint_id) REFERENCES public.waypoints(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT curated_itinerary_segments_day_number_check 
        CHECK (day_number > 0),
    CONSTRAINT curated_itinerary_segments_walking_time_hours_check 
        CHECK (walking_time_hours > 0),
    CONSTRAINT curated_itinerary_segments_distance_km_check 
        CHECK (distance_km > 0),
    CONSTRAINT curated_itinerary_segments_sort_order_check 
        CHECK (sort_order >= 0)
);

-- Add FK constraint for alternative_accommodation_ids array
CREATE OR REPLACE FUNCTION public.check_alternative_accommodations_exist()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.alternative_accommodation_ids IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
            FROM unnest(NEW.alternative_accommodation_ids) AS acc_id
            WHERE NOT EXISTS (
                SELECT 1 FROM public.accommodations 
                WHERE id = acc_id
            )
        ) THEN
            RAISE EXCEPTION 'Invalid accommodation ID in alternative_accommodation_ids array';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_alternative_accommodations_before_insert_update
    BEFORE INSERT OR UPDATE ON public.curated_itinerary_segments
    FOR EACH ROW
    EXECUTE FUNCTION public.check_alternative_accommodations_exist();

-- Comments
COMMENT ON TABLE public.curated_itinerary_segments IS 'Stores daily segments of curated itineraries with detailed information for each day. Version 1.0.';
COMMENT ON COLUMN public.curated_itinerary_segments.id IS 'Unique identifier for the itinerary segment.';
COMMENT ON COLUMN public.curated_itinerary_segments.curated_itinerary_id IS 'FK to curated_itineraries.id.';
COMMENT ON COLUMN public.curated_itinerary_segments.day_number IS 'Day number in the itinerary (1, 2, 3, etc.).';
COMMENT ON COLUMN public.curated_itinerary_segments.segment_id IS 'FK to segments.id - the trail segment for this day.';
COMMENT ON COLUMN public.curated_itinerary_segments.start_waypoint_id IS 'Optional FK to waypoints.id for starting point.';
COMMENT ON COLUMN public.curated_itinerary_segments.end_waypoint_id IS 'Optional FK to waypoints.id for ending point.';
COMMENT ON COLUMN public.curated_itinerary_segments.start_town_id IS 'Optional FK to towns.id for starting town.';
COMMENT ON COLUMN public.curated_itinerary_segments.end_town_id IS 'Optional FK to towns.id for ending town.';
COMMENT ON COLUMN public.curated_itinerary_segments.suggested_accommodation_id IS 'FK to accommodations.id for recommended lodging.';
COMMENT ON COLUMN public.curated_itinerary_segments.alternative_accommodation_ids IS 'Array of accommodation IDs for alternatives.';
COMMENT ON COLUMN public.curated_itinerary_segments.default_day_title IS 'Title for this day (e.g., "Day 1: Rieti to Poggio Bustone").';
COMMENT ON COLUMN public.curated_itinerary_segments.default_day_description IS 'Detailed description of the day''s journey.';
COMMENT ON COLUMN public.curated_itinerary_segments.default_highlights IS 'Array of highlights for this day.';
COMMENT ON COLUMN public.curated_itinerary_segments.walking_time_hours IS 'Estimated walking time in hours.';
COMMENT ON COLUMN public.curated_itinerary_segments.distance_km IS 'Distance for this day in kilometers.';
COMMENT ON COLUMN public.curated_itinerary_segments.elevation_gain_m IS 'Elevation gain for this day in meters.';
COMMENT ON COLUMN public.curated_itinerary_segments.elevation_loss_m IS 'Elevation loss for this day in meters.';
COMMENT ON COLUMN public.curated_itinerary_segments.difficulty_notes IS 'Specific difficulty notes for this day.';
COMMENT ON COLUMN public.curated_itinerary_segments.terrain_notes IS 'Description of terrain conditions.';
COMMENT ON COLUMN public.curated_itinerary_segments.services_available IS 'Array of available services (e.g., {"ATM", "Pharmacy", "Grocery"}).';
COMMENT ON COLUMN public.curated_itinerary_segments.lunch_stop_waypoint_id IS 'FK to waypoints.id for suggested lunch stop.';
COMMENT ON COLUMN public.curated_itinerary_segments.lunch_stop_notes IS 'Notes about lunch options.';
COMMENT ON COLUMN public.curated_itinerary_segments.alternative_route_notes IS 'Information about alternative routes for this day.';
COMMENT ON COLUMN public.curated_itinerary_segments.bad_weather_alternative IS 'Suggestions for bad weather days.';
COMMENT ON COLUMN public.curated_itinerary_segments.accessibility_notes IS 'Notes about accessibility for this segment.';
COMMENT ON COLUMN public.curated_itinerary_segments.sort_order IS 'Explicit sort order for flexibility.';

-- Indexes
CREATE INDEX idx_curated_itinerary_segments_itinerary ON public.curated_itinerary_segments (curated_itinerary_id, day_number);
CREATE INDEX idx_curated_itinerary_segments_segment ON public.curated_itinerary_segments (segment_id);
CREATE INDEX idx_curated_itinerary_segments_towns ON public.curated_itinerary_segments (start_town_id, end_town_id);
CREATE INDEX idx_curated_itinerary_segments_accommodation ON public.curated_itinerary_segments (suggested_accommodation_id);

-- Trigger
CREATE TRIGGER on_curated_itinerary_segments_updated_at 
    BEFORE UPDATE ON public.curated_itinerary_segments 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- RLS Policies
ALTER TABLE public.curated_itinerary_segments ENABLE ROW LEVEL SECURITY;

-- Read permissions inherit from parent itinerary
CREATE POLICY "Read permissions inherit from itinerary" ON public.curated_itinerary_segments 
    FOR SELECT TO authenticated, anon 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND ci.content_status_code = 'published'
            AND ci.deleted_at IS NULL
        )
    );

-- Content creators can read their own itinerary segments
CREATE POLICY "Content creators can read their own segments" ON public.curated_itinerary_segments 
    FOR SELECT TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (ci.author_profile_id = auth.uid() OR ci.created_by_profile_id = auth.uid())
        )
    );

-- Write permissions inherit from parent itinerary
CREATE POLICY "Write permissions inherit from itinerary" ON public.curated_itinerary_segments 
    FOR ALL TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    );

-- Function to validate itinerary segment consistency
CREATE OR REPLACE FUNCTION public.validate_itinerary_segments()
RETURNS TRIGGER AS $$
DECLARE
    v_total_days smallint;
    v_total_distance numeric;
    v_total_elevation_gain numeric;
    v_total_elevation_loss numeric;
BEGIN
    -- Only validate on INSERT or UPDATE of published itineraries
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Calculate totals from segments
        SELECT 
            COUNT(DISTINCT day_number),
            COALESCE(SUM(distance_km), 0),
            COALESCE(SUM(elevation_gain_m), 0),
            COALESCE(SUM(elevation_loss_m), 0)
        INTO 
            v_total_days,
            v_total_distance,
            v_total_elevation_gain,
            v_total_elevation_loss
        FROM public.curated_itinerary_segments
        WHERE curated_itinerary_id = NEW.curated_itinerary_id;
        
        -- Update the parent itinerary with calculated totals
        UPDATE public.curated_itineraries
        SET 
            total_days = v_total_days,
            total_distance_km = v_total_distance,
            total_elevation_gain_m = v_total_elevation_gain,
            total_elevation_loss_m = v_total_elevation_loss,
            updated_at = now()
        WHERE id = NEW.curated_itinerary_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to maintain consistency
CREATE TRIGGER validate_itinerary_segments_after_change
    AFTER INSERT OR UPDATE OR DELETE ON public.curated_itinerary_segments
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_itinerary_segments();
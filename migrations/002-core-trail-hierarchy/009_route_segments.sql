-- Module 2: Core Trail Hierarchy
-- 009_route_segments.sql: Links segments to routes in ordered sequence
-- 
-- Purpose: Define which segments make up each route and in what order
-- Dependencies: routes, segments

-- Create route_segments table
CREATE TABLE IF NOT EXISTS public.route_segments (
    id BIGSERIAL PRIMARY KEY,
    route_id BIGINT NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    segment_id BIGINT NOT NULL REFERENCES public.segments(id) ON DELETE CASCADE,
    order_in_route INTEGER NOT NULL CHECK (order_in_route > 0),
    contextual_notes_for_segment_in_route TEXT,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_route_order UNIQUE (route_id, order_in_route),
    CONSTRAINT unique_route_segment UNIQUE (route_id, segment_id)
);

-- Add table and column comments
COMMENT ON TABLE public.route_segments IS 'Links segments to routes in ordered sequence. Triggers update route aggregates. Version: 2.0';
COMMENT ON COLUMN public.route_segments.id IS 'Primary Key. Surrogate key for translation support.';
COMMENT ON COLUMN public.route_segments.route_id IS 'FK to routes table. CASCADE delete.';
COMMENT ON COLUMN public.route_segments.segment_id IS 'FK to segments table. CASCADE delete.';
COMMENT ON COLUMN public.route_segments.order_in_route IS 'Sequential order of segment within route. Must be > 0.';
COMMENT ON COLUMN public.route_segments.contextual_notes_for_segment_in_route IS 'English notes specific to this segment in this route context. Other languages in translations.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_route_segments_route_id ON public.route_segments(route_id);
CREATE INDEX IF NOT EXISTS idx_route_segments_segment_id ON public.route_segments(segment_id);
CREATE INDEX IF NOT EXISTS idx_route_segments_order ON public.route_segments(route_id, order_in_route);

-- Create function to update route aggregates
CREATE OR REPLACE FUNCTION public.update_route_aggregates()
RETURNS TRIGGER AS $$
DECLARE
    v_route_id BIGINT;
    v_total_distance_km REAL;
    v_total_gain_m INTEGER;
    v_total_loss_m INTEGER;
BEGIN
    -- Determine which route to update
    IF TG_OP = 'DELETE' THEN
        v_route_id := OLD.route_id;
    ELSE
        v_route_id := NEW.route_id;
    END IF;
    
    -- Calculate aggregates from all segments in the route
    SELECT 
        COALESCE(SUM(s.distance_km), 0)::real,
        COALESCE(SUM(s.elevation_gain_meters), 0)::integer,
        COALESCE(SUM(s.elevation_loss_meters), 0)::integer
    INTO v_total_distance_km, v_total_gain_m, v_total_loss_m
    FROM public.route_segments rs
    JOIN public.segments s ON rs.segment_id = s.id
    WHERE rs.route_id = v_route_id
    AND s.deleted_at IS NULL;
    
    -- Update the route
    UPDATE public.routes
    SET 
        total_distance_km = v_total_distance_km,
        estimated_total_elevation_gain_meters = v_total_gain_m,
        estimated_total_elevation_loss_meters = v_total_loss_m,
        updated_at = now()
    WHERE id = v_route_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create trigger to update route aggregates
CREATE TRIGGER trigger_update_route_aggregates
    AFTER INSERT OR UPDATE OR DELETE ON public.route_segments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_route_aggregates();

-- Also trigger on segment updates that might affect routes
CREATE TRIGGER trigger_update_routes_from_segments
    AFTER UPDATE OF distance_km, elevation_gain_meters, elevation_loss_meters, deleted_at ON public.segments
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.refresh_all_route_aggregates();

-- Function to refresh all routes (used by statement-level trigger)
CREATE OR REPLACE FUNCTION public.refresh_all_route_aggregates()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.routes r
    SET 
        total_distance_km = agg.total_distance,
        estimated_total_elevation_gain_meters = agg.total_gain,
        estimated_total_elevation_loss_meters = agg.total_loss,
        updated_at = now()
    FROM (
        SELECT 
            rs.route_id,
            COALESCE(SUM(s.distance_km), 0)::real AS total_distance,
            COALESCE(SUM(s.elevation_gain_meters), 0)::integer AS total_gain,
            COALESCE(SUM(s.elevation_loss_meters), 0)::integer AS total_loss
        FROM public.route_segments rs
        JOIN public.segments s ON rs.segment_id = s.id
        WHERE s.deleted_at IS NULL
        GROUP BY rs.route_id
    ) agg
    WHERE r.id = agg.route_id
    AND (
        r.total_distance_km IS DISTINCT FROM agg.total_distance OR
        r.estimated_total_elevation_gain_meters IS DISTINCT FROM agg.total_gain OR
        r.estimated_total_elevation_loss_meters IS DISTINCT FROM agg.total_loss
    );
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create standard triggers
CREATE TRIGGER trigger_route_segments_set_updated_at
    BEFORE UPDATE ON public.route_segments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_route_segment_translations
    AFTER DELETE ON public.route_segments
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.route_segments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on route_segments" ON public.route_segments
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on route_segments" ON public.route_segments
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.routes r
            WHERE r.id = route_segments.route_id
            AND r.deleted_at IS NULL
            AND r.content_visibility_status = 'published'
        )
    );

CREATE POLICY "Allow anonymous users read access on route_segments" ON public.route_segments
    FOR SELECT TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.routes r
            WHERE r.id = route_segments.route_id
            AND r.deleted_at IS NULL
            AND r.content_visibility_status = 'published'
        )
    );
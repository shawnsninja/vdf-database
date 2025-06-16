-- Module 2: Core Trail Hierarchy
-- 006_routes.sql: Named paths within trails
-- 
-- Purpose: Define specific routes within trails (e.g., Northern Route, Southern Route)
-- Dependencies: trails, towns (from Module 3), media

-- Create routes table
CREATE TABLE IF NOT EXISTS public.routes (
    id BIGSERIAL PRIMARY KEY,
    trail_id BIGINT NOT NULL REFERENCES public.trails(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    route_code TEXT UNIQUE,
    total_distance_km REAL,
    estimated_total_elevation_gain_meters INTEGER,
    estimated_total_elevation_loss_meters INTEGER,
    start_town_id INTEGER REFERENCES public.towns(id) ON DELETE SET NULL,
    end_town_id INTEGER REFERENCES public.towns(id) ON DELETE SET NULL,
    overall_gpx_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    route_category route_category_enum NOT NULL DEFAULT 'primary',
    is_primary_route_for_trail BOOLEAN NOT NULL DEFAULT false,
    content_visibility_status content_visibility_status_enum NOT NULL DEFAULT 'draft',
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- Add table and column comments
COMMENT ON TABLE public.routes IS 'Named paths within trails (e.g., Northern Route: La Verna to Assisi). Auto-calculates aggregates from segments. Version: 2.0';
COMMENT ON COLUMN public.routes.id IS 'Primary Key. Unique identifier for each route.';
COMMENT ON COLUMN public.routes.trail_id IS 'FK to parent trail. CASCADE delete.';
COMMENT ON COLUMN public.routes.name IS 'English name of the route. Other languages in translations table.';
COMMENT ON COLUMN public.routes.slug IS 'URL-friendly identifier. Must be globally unique.';
COMMENT ON COLUMN public.routes.route_code IS 'Optional code for the route (e.g., ''VDF-N'' for northern route). Unique if provided.';
COMMENT ON COLUMN public.routes.total_distance_km IS 'Total distance in kilometers. Auto-calculated from segments via trigger.';
COMMENT ON COLUMN public.routes.estimated_total_elevation_gain_meters IS 'Total elevation gain. Auto-calculated from segments via trigger.';
COMMENT ON COLUMN public.routes.estimated_total_elevation_loss_meters IS 'Total elevation loss. Auto-calculated from segments via trigger.';
COMMENT ON COLUMN public.routes.start_town_id IS 'FK to starting town. Can be NULL if starts at waypoint.';
COMMENT ON COLUMN public.routes.end_town_id IS 'FK to ending town. Can be NULL if ends at waypoint.';
COMMENT ON COLUMN public.routes.overall_gpx_media_id IS 'FK to media table for complete route GPX file.';
COMMENT ON COLUMN public.routes.route_category IS 'Category of route (primary, alternate, variant, etc.).';
COMMENT ON COLUMN public.routes.is_primary_route_for_trail IS 'Whether this is the main/default route for the trail.';
COMMENT ON COLUMN public.routes.deleted_at IS 'Timestamp for soft deletion. NULL means active.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_routes_trail_id ON public.routes(trail_id);
CREATE INDEX IF NOT EXISTS idx_routes_slug ON public.routes(slug);
CREATE INDEX IF NOT EXISTS idx_routes_route_code ON public.routes(route_code) WHERE route_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_routes_start_town_id ON public.routes(start_town_id);
CREATE INDEX IF NOT EXISTS idx_routes_end_town_id ON public.routes(end_town_id);
CREATE INDEX IF NOT EXISTS idx_routes_route_category ON public.routes(route_category);
CREATE INDEX IF NOT EXISTS idx_routes_is_primary ON public.routes(is_primary_route_for_trail) WHERE is_primary_route_for_trail = true;
CREATE INDEX IF NOT EXISTS idx_routes_content_visibility_status ON public.routes(content_visibility_status);
CREATE INDEX IF NOT EXISTS idx_routes_deleted_at ON public.routes(deleted_at);

-- Create triggers
CREATE TRIGGER trigger_routes_set_updated_at
    BEFORE UPDATE ON public.routes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_route_translations
    AFTER DELETE ON public.routes
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Note: We'll add the auto-calculation trigger after creating segments and route_segments

-- Enable RLS
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on routes" ON public.routes
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on routes" ON public.routes
    FOR SELECT TO authenticated
    USING (deleted_at IS NULL AND content_visibility_status = 'published');

CREATE POLICY "Allow anonymous users read access on routes" ON public.routes
    FOR SELECT TO anon
    USING (deleted_at IS NULL AND content_visibility_status = 'published');
-- Module 2: Core Trail Hierarchy
-- 007_waypoints_stub.sql: Temporary waypoints table stub
-- 
-- Purpose: Create minimal waypoints table for segments to reference
-- Note: This will be replaced/enhanced by Module 4 implementation

-- Create minimal waypoints table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.waypoints (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    latitude DOUBLE PRECISION NOT NULL CHECK (latitude >= -90 AND latitude <= 90),
    longitude DOUBLE PRECISION NOT NULL CHECK (longitude >= -180 AND longitude <= 180),
    elevation_meters INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comment
COMMENT ON TABLE public.waypoints IS 'STUB TABLE: Minimal waypoints for segment endpoints. Will be replaced by Module 4 full implementation.';

-- Create basic trigger
CREATE TRIGGER trigger_waypoints_set_updated_at
    BEFORE UPDATE ON public.waypoints
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Basic RLS
ALTER TABLE public.waypoints ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all users read access on waypoints" ON public.waypoints
    FOR SELECT
    USING (true);

CREATE POLICY "Allow admin full access on waypoints" ON public.waypoints
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());
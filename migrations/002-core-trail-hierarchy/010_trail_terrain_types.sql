-- Module 2: Core Trail Hierarchy
-- 010_trail_terrain_types.sql: Links trails to their terrain types
-- 
-- Purpose: Associate trails with the types of terrain they include
-- Dependencies: trails, terrain_types_master

-- Create trail_terrain_types table
CREATE TABLE IF NOT EXISTS public.trail_terrain_types (
    trail_id BIGINT NOT NULL REFERENCES public.trails(id) ON DELETE CASCADE,
    terrain_type_id INTEGER NOT NULL REFERENCES public.terrain_types_master(id) ON DELETE RESTRICT,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (trail_id, terrain_type_id)
);

-- Add table comment
COMMENT ON TABLE public.trail_terrain_types IS 'Links trails to terrain types they include. Many-to-many relationship. Version: 2.0';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_trail_terrain_types_terrain_type_id ON public.trail_terrain_types(terrain_type_id);

-- Create trigger
CREATE TRIGGER trigger_trail_terrain_types_set_updated_at
    BEFORE UPDATE ON public.trail_terrain_types
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS
ALTER TABLE public.trail_terrain_types ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on trail_terrain_types" ON public.trail_terrain_types
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on trail_terrain_types" ON public.trail_terrain_types
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.trails t
            WHERE t.id = trail_terrain_types.trail_id
            AND t.deleted_at IS NULL
            AND t.content_visibility_status = 'published'
        )
    );

CREATE POLICY "Allow anonymous users read access on trail_terrain_types" ON public.trail_terrain_types
    FOR SELECT TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.trails t
            WHERE t.id = trail_terrain_types.trail_id
            AND t.deleted_at IS NULL
            AND t.content_visibility_status = 'published'
        )
    );
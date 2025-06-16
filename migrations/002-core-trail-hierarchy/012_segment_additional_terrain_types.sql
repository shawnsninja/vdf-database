-- Module 2: Core Trail Hierarchy
-- 012_segment_additional_terrain_types.sql: Additional terrain types for segments
-- 
-- Purpose: Link segments to terrain types beyond the dominant one
-- Dependencies: segments, terrain_types_master

-- Create segment_additional_terrain_types table
CREATE TABLE IF NOT EXISTS public.segment_additional_terrain_types (
    segment_id BIGINT NOT NULL REFERENCES public.segments(id) ON DELETE CASCADE,
    terrain_type_id INTEGER NOT NULL REFERENCES public.terrain_types_master(id) ON DELETE RESTRICT,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (segment_id, terrain_type_id)
);

-- Add table comment
COMMENT ON TABLE public.segment_additional_terrain_types IS 'Additional terrain types for segments beyond the dominant type. Many-to-many relationship. Version: 2.0';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_segment_additional_terrain_types_terrain_type_id ON public.segment_additional_terrain_types(terrain_type_id);

-- Create trigger
CREATE TRIGGER trigger_segment_additional_terrain_types_set_updated_at
    BEFORE UPDATE ON public.segment_additional_terrain_types
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS
ALTER TABLE public.segment_additional_terrain_types ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on segment_additional_terrain_types" ON public.segment_additional_terrain_types
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on segment_additional_terrain_types" ON public.segment_additional_terrain_types
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.segments s
            WHERE s.id = segment_additional_terrain_types.segment_id
            AND s.deleted_at IS NULL
            AND s.content_visibility_status = 'published'
        )
    );

CREATE POLICY "Allow anonymous users read access on segment_additional_terrain_types" ON public.segment_additional_terrain_types
    FOR SELECT TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.segments s
            WHERE s.id = segment_additional_terrain_types.segment_id
            AND s.deleted_at IS NULL
            AND s.content_visibility_status = 'published'
        )
    );
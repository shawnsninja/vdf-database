-- Module 2: Core Trail Hierarchy
-- 002_terrain_types_master.sql: Master lookup for terrain types
-- 
-- Purpose: Canonical list of terrain types for trails and segments
-- Dependencies: profiles, translations

-- Create terrain_types_master table
CREATE TABLE IF NOT EXISTS public.terrain_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    icon_identifier TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.terrain_types_master IS 'Master lookup for terrain types used by trails and segments. Names/descriptions in translations. Version: 2.0';
COMMENT ON COLUMN public.terrain_types_master.id IS 'Primary Key. Unique identifier for each terrain type.';
COMMENT ON COLUMN public.terrain_types_master.code IS 'Unique code for the terrain type (e.g., ''forest_path'', ''paved_road''). Lowercase, stable.';
COMMENT ON COLUMN public.terrain_types_master.icon_identifier IS 'Optional identifier for UI icon associated with this terrain type.';
COMMENT ON COLUMN public.terrain_types_master.display_order IS 'For ordering terrain types in UI.';
COMMENT ON COLUMN public.terrain_types_master.is_active IS 'Whether this terrain type is active and available for use.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_terrain_types_master_code ON public.terrain_types_master(code);
CREATE INDEX IF NOT EXISTS idx_terrain_types_master_is_active ON public.terrain_types_master(is_active);
CREATE INDEX IF NOT EXISTS idx_terrain_types_master_display_order ON public.terrain_types_master(display_order);

-- Create triggers
CREATE TRIGGER trigger_terrain_types_master_set_updated_at
    BEFORE UPDATE ON public.terrain_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_terrain_type_translations
    AFTER DELETE ON public.terrain_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.terrain_types_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on terrain_types_master" ON public.terrain_types_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on terrain_types_master" ON public.terrain_types_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on terrain_types_master" ON public.terrain_types_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data
INSERT INTO public.terrain_types_master (code, icon_identifier, display_order, is_active) VALUES 
    -- Natural surfaces
    ('forest_path', 'icon-forest', 10, true),
    ('mountain_path', 'icon-mountain', 20, true),
    ('meadow_path', 'icon-meadow', 30, true),
    ('dirt_road', 'icon-dirt-road', 40, true),
    ('gravel_road', 'icon-gravel', 50, true),
    
    -- Paved surfaces
    ('paved_road', 'icon-road', 100, true),
    ('cobblestone', 'icon-cobblestone', 110, true),
    ('urban_sidewalk', 'icon-city', 120, true),
    
    -- Challenging terrain
    ('rocky_terrain', 'icon-rocks', 200, true),
    ('scree', 'icon-scree', 210, true),
    ('stream_crossing', 'icon-stream', 220, true),
    
    -- Mixed/Other
    ('mixed_terrain', 'icon-mixed', 300, true),
    ('stairs', 'icon-stairs', 310, true),
    ('bridge', 'icon-bridge', 320, true)
ON CONFLICT (code) DO NOTHING;
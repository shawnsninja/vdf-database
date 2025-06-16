-- Module 2: Core Trail Hierarchy
-- 013_media_roles_master.sql: Master lookup for media roles
-- 
-- Purpose: Define roles/purposes for media items in galleries
-- Dependencies: profiles, translations
-- Note: This should eventually move to Module 1

-- Create media_roles_master table
CREATE TABLE IF NOT EXISTS public.media_roles_master (
    code TEXT PRIMARY KEY,
    applicable_to_tables TEXT[] NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.media_roles_master IS 'Master lookup for media roles/purposes in galleries. Names/descriptions in translations. Version: 2.0';
COMMENT ON COLUMN public.media_roles_master.code IS 'Primary Key. Unique code for the media role (e.g., ''hero'', ''gallery'', ''map'').';
COMMENT ON COLUMN public.media_roles_master.applicable_to_tables IS 'Array of table names this role can be used with.';
COMMENT ON COLUMN public.media_roles_master.display_order IS 'For ordering roles in UI.';
COMMENT ON COLUMN public.media_roles_master.is_active IS 'Whether this media role is active and available for use.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_media_roles_master_is_active ON public.media_roles_master(is_active);
CREATE INDEX IF NOT EXISTS idx_media_roles_master_applicable_to_tables ON public.media_roles_master USING GIN (applicable_to_tables);

-- Create triggers
CREATE TRIGGER trigger_media_roles_master_set_updated_at
    BEFORE UPDATE ON public.media_roles_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_media_role_translations
    AFTER DELETE ON public.media_roles_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.media_roles_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on media_roles_master" ON public.media_roles_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on media_roles_master" ON public.media_roles_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on media_roles_master" ON public.media_roles_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data
INSERT INTO public.media_roles_master (code, applicable_to_tables, display_order, is_active) VALUES 
    ('hero', ARRAY['segments', 'trails', 'routes', 'waypoints'], 10, true),
    ('gallery', ARRAY['segments', 'trails', 'routes', 'waypoints'], 20, true),
    ('map', ARRAY['segments', 'routes'], 30, true),
    ('elevation_profile', ARRAY['segments', 'routes'], 40, true),
    ('panorama', ARRAY['segments', 'waypoints'], 50, true),
    ('detail', ARRAY['segments', 'waypoints'], 60, true),
    ('historical', ARRAY['segments', 'trails', 'waypoints'], 70, true),
    ('seasonal_summer', ARRAY['segments', 'trails'], 80, true),
    ('seasonal_winter', ARRAY['segments', 'trails'], 90, true)
ON CONFLICT (code) DO NOTHING;
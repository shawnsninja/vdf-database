-- Module 2: Core Trail Hierarchy
-- 004_trails.sql: Main overarching pilgrimage trails
-- 
-- Purpose: Define major pilgrimage trails like Via di Francesco
-- Dependencies: media, profiles, translations

-- Create trails table
CREATE TABLE IF NOT EXISTS public.trails (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    trail_short_code TEXT UNIQUE,
    operational_status trail_operational_status_enum NOT NULL DEFAULT 'active',
    content_visibility_status content_visibility_status_enum NOT NULL DEFAULT 'draft',
    logo_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    banner_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- Add table and column comments
COMMENT ON TABLE public.trails IS 'Main overarching pilgrimage trails (e.g., Via di Francesco). Core entity for trail hierarchy. Version: 2.0';
COMMENT ON COLUMN public.trails.id IS 'Primary Key. Unique identifier for each trail.';
COMMENT ON COLUMN public.trails.name IS 'English name of the trail. Other languages in translations table.';
COMMENT ON COLUMN public.trails.slug IS 'URL-friendly identifier (e.g., ''via-di-francesco''). Must be unique.';
COMMENT ON COLUMN public.trails.trail_short_code IS 'Optional short code for the trail (e.g., ''VDF''). Must be unique if provided.';
COMMENT ON COLUMN public.trails.operational_status IS 'Current operational status of the trail.';
COMMENT ON COLUMN public.trails.content_visibility_status IS 'Publication status for content moderation.';
COMMENT ON COLUMN public.trails.logo_media_id IS 'FK to media table for trail logo image.';
COMMENT ON COLUMN public.trails.banner_media_id IS 'FK to media table for trail banner/hero image.';
COMMENT ON COLUMN public.trails.is_featured IS 'Whether to highlight this trail in featured sections.';
COMMENT ON COLUMN public.trails.deleted_at IS 'Timestamp for soft deletion. NULL means active.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_trails_slug ON public.trails(slug);
CREATE INDEX IF NOT EXISTS idx_trails_trail_short_code ON public.trails(trail_short_code) WHERE trail_short_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_trails_operational_status ON public.trails(operational_status);
CREATE INDEX IF NOT EXISTS idx_trails_content_visibility_status ON public.trails(content_visibility_status);
CREATE INDEX IF NOT EXISTS idx_trails_is_featured ON public.trails(is_featured);
CREATE INDEX IF NOT EXISTS idx_trails_deleted_at ON public.trails(deleted_at);

-- Create triggers
CREATE TRIGGER trigger_trails_set_updated_at
    BEFORE UPDATE ON public.trails
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_trail_translations
    AFTER DELETE ON public.trails
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.trails ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on trails" ON public.trails
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on trails" ON public.trails
    FOR SELECT TO authenticated
    USING (deleted_at IS NULL AND content_visibility_status = 'published');

CREATE POLICY "Allow anonymous users read access on trails" ON public.trails
    FOR SELECT TO anon
    USING (deleted_at IS NULL AND content_visibility_status = 'published');
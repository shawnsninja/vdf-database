-- Module 2: Core Trail Hierarchy
-- 014_segment_media.sql: Links segments to media items
-- 
-- Purpose: Associate segments with gallery images and other media
-- Dependencies: segments, media, media_roles_master

-- Create segment_media table
CREATE TABLE IF NOT EXISTS public.segment_media (
    id BIGSERIAL PRIMARY KEY,
    segment_id BIGINT NOT NULL REFERENCES public.segments(id) ON DELETE CASCADE,
    media_id INTEGER NOT NULL REFERENCES public.media(id) ON DELETE CASCADE,
    media_role_code TEXT NOT NULL REFERENCES public.media_roles_master(code) ON DELETE RESTRICT,
    display_order INTEGER NOT NULL DEFAULT 0,
    caption TEXT,
    alt_text TEXT,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_segment_media_role UNIQUE (segment_id, media_id, media_role_code),
    CONSTRAINT unique_segment_display_order UNIQUE (segment_id, display_order, media_role_code)
);

-- Add table and column comments
COMMENT ON TABLE public.segment_media IS 'Links segments to media items with roles (hero, gallery, etc.). Supports captions and alt text. Version: 2.0';
COMMENT ON COLUMN public.segment_media.id IS 'Primary Key. Surrogate key for translation support.';
COMMENT ON COLUMN public.segment_media.segment_id IS 'FK to segments table. CASCADE delete.';
COMMENT ON COLUMN public.segment_media.media_id IS 'FK to media table. CASCADE delete.';
COMMENT ON COLUMN public.segment_media.media_role_code IS 'FK to media role (hero, gallery, map, etc.). RESTRICT delete.';
COMMENT ON COLUMN public.segment_media.display_order IS 'Order within the same role for this segment.';
COMMENT ON COLUMN public.segment_media.caption IS 'English caption for this media in this context. Other languages in translations.';
COMMENT ON COLUMN public.segment_media.alt_text IS 'English alt text for accessibility. Other languages in translations.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_segment_media_segment_id ON public.segment_media(segment_id);
CREATE INDEX IF NOT EXISTS idx_segment_media_media_id ON public.segment_media(media_id);
CREATE INDEX IF NOT EXISTS idx_segment_media_role ON public.segment_media(media_role_code);
CREATE INDEX IF NOT EXISTS idx_segment_media_order ON public.segment_media(segment_id, media_role_code, display_order);

-- Create trigger to validate media role
CREATE OR REPLACE FUNCTION public.validate_segment_media_role()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the media role is applicable to segments
    IF NOT EXISTS (
        SELECT 1 FROM public.media_roles_master
        WHERE code = NEW.media_role_code
        AND is_active = true
        AND 'segments' = ANY(applicable_to_tables)
    ) THEN
        RAISE EXCEPTION 'Media role "%" is not active or not applicable to segments', NEW.media_role_code;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER trigger_validate_segment_media_role
    BEFORE INSERT OR UPDATE OF media_role_code ON public.segment_media
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_segment_media_role();

-- Create standard triggers
CREATE TRIGGER trigger_segment_media_set_updated_at
    BEFORE UPDATE ON public.segment_media
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_segment_media_translations
    AFTER DELETE ON public.segment_media
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.segment_media ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on segment_media" ON public.segment_media
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on segment_media" ON public.segment_media
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.segments s
            WHERE s.id = segment_media.segment_id
            AND s.deleted_at IS NULL
            AND s.content_visibility_status = 'published'
        )
    );

CREATE POLICY "Allow anonymous users read access on segment_media" ON public.segment_media
    FOR SELECT TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.segments s
            WHERE s.id = segment_media.segment_id
            AND s.deleted_at IS NULL
            AND s.content_visibility_status = 'published'
        )
    );
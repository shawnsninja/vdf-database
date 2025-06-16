-- Module 4: Waypoint Details
-- 005_content_statuses_master.sql: Content publication status definitions
-- 
-- Purpose: Define publication lifecycle states for content management
-- Dependencies: Module 1 (profiles, translations)

-- Create content_statuses_master table
CREATE TABLE IF NOT EXISTS public.content_statuses_master (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL CHECK (
        length(code) > 0 AND 
        length(code) <= 50 AND 
        code ~ '^[a-z0-9_]+$'
    ),
    label TEXT NOT NULL CHECK (
        length(label) > 0 AND 
        length(label) <= 100
    ),
    description TEXT NULL,
    is_publicly_visible BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add comments
COMMENT ON TABLE public.content_statuses_master IS 'Master list of content publication statuses. `label` and `description` are translatable. Codes are snake_case, max 50 chars.';
COMMENT ON COLUMN public.content_statuses_master.id IS 'Unique identifier for the content status.';
COMMENT ON COLUMN public.content_statuses_master.code IS 'Short, stable, machine-readable code (snake_case). Max 50 chars.';
COMMENT ON COLUMN public.content_statuses_master.label IS 'Primary reference language (English) label. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.content_statuses_master.description IS 'Optional primary reference language (English) description. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.content_statuses_master.is_publicly_visible IS 'True if content with this status is visible to public users; false if restricted.';
COMMENT ON COLUMN public.content_statuses_master.sort_order IS 'Determines display order in UI workflows. Lower numbers appear first.';
COMMENT ON COLUMN public.content_statuses_master.is_active IS 'True if the status is active and available for use; false if retired.';
COMMENT ON COLUMN public.content_statuses_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.content_statuses_master.updated_at IS 'Timestamp of last update (auto-updated by trigger).';
COMMENT ON COLUMN public.content_statuses_master.created_by_profile_id IS 'Profile ID of the user who created the record.';
COMMENT ON COLUMN public.content_statuses_master.updated_by_profile_id IS 'Profile ID of the user who last updated the record.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_content_statuses_sort_order ON public.content_statuses_master(sort_order);
CREATE INDEX IF NOT EXISTS idx_content_statuses_is_active ON public.content_statuses_master(is_active);
CREATE INDEX IF NOT EXISTS idx_content_statuses_is_publicly_visible ON public.content_statuses_master(is_publicly_visible);
CREATE INDEX IF NOT EXISTS idx_content_statuses_label ON public.content_statuses_master(label);
CREATE INDEX IF NOT EXISTS idx_content_statuses_created_by ON public.content_statuses_master(created_by_profile_id);
CREATE INDEX IF NOT EXISTS idx_content_statuses_updated_by ON public.content_statuses_master(updated_by_profile_id);

-- Create updated_at trigger
CREATE TRIGGER trigger_content_statuses_master_set_updated_at
    BEFORE UPDATE ON public.content_statuses_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create translation cleanup trigger
CREATE TRIGGER trigger_cleanup_content_statuses_translations
    AFTER DELETE ON public.content_statuses_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations('content_statuses_master');

COMMENT ON TRIGGER trigger_cleanup_content_statuses_translations ON public.content_statuses_master IS 
'Cleans up orphaned translations when a content status is deleted.';

-- Enable Row Level Security
ALTER TABLE public.content_statuses_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public read access to active statuses
CREATE POLICY "Allow public read access to active content statuses" ON public.content_statuses_master
    FOR SELECT
    USING (is_active = true);

-- Platform admins have full access
CREATE POLICY "Allow platform_admins full access to content statuses" ON public.content_statuses_master
    FOR ALL
    USING (public.has_role('platform_admin'))
    WITH CHECK (public.has_role('platform_admin'));
-- Module 4: Waypoint Details
-- 003_tags_master.sql: Master list of descriptive tags
-- 
-- Purpose: Standardized tags for granular classification of waypoints and other entities
-- Dependencies: Module 1 (profiles, translations)

-- Create tags_master table
CREATE TABLE IF NOT EXISTS public.tags_master (
    id SERIAL PRIMARY KEY,
    tag_code TEXT UNIQUE NOT NULL CHECK (
        length(tag_code) > 0 AND 
        length(tag_code) <= 50 AND 
        tag_code ~ '^[a-z0-9_]+$'
    ),
    label TEXT NOT NULL CHECK (
        length(label) > 0 AND 
        length(label) <= 100
    ),
    description TEXT NULL,
    tag_type TEXT NULL CHECK (
        tag_type IS NULL OR 
        length(tag_type) <= 50
    ),
    icon_identifier TEXT NULL CHECK (
        icon_identifier IS NULL OR 
        length(icon_identifier) <= 100
    ),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add comments
COMMENT ON TABLE public.tags_master IS 'Master list of descriptive tags for various entities. `label` and `description` are translatable. Codes are snake_case, max 50 chars.';
COMMENT ON COLUMN public.tags_master.id IS 'Unique identifier for the tag.';
COMMENT ON COLUMN public.tags_master.tag_code IS 'Short, stable, machine-readable code (snake_case). Max 50 chars.';
COMMENT ON COLUMN public.tags_master.label IS 'Primary reference language (English) label. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.tags_master.description IS 'Optional primary reference language (English) description. Translatable via the ''translations'' table.';
COMMENT ON COLUMN public.tags_master.tag_type IS 'Optional grouping/category for the tag (e.g., ''amenity'', ''accessibility'', ''pilgrim_feature''). Max 50 chars.';
COMMENT ON COLUMN public.tags_master.icon_identifier IS 'Optional icon name, class, or path for UI display. Max 100 chars.';
COMMENT ON COLUMN public.tags_master.sort_order IS 'Determines display order in UI lists. Lower numbers appear first.';
COMMENT ON COLUMN public.tags_master.is_active IS 'True if the tag is active and available for use; false if retired.';
COMMENT ON COLUMN public.tags_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.tags_master.updated_at IS 'Timestamp of last update (auto-updated by trigger).';
COMMENT ON COLUMN public.tags_master.created_by_profile_id IS 'Profile ID of the user who created the record.';
COMMENT ON COLUMN public.tags_master.updated_by_profile_id IS 'Profile ID of the user who last updated the record.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_tags_master_tag_type ON public.tags_master(tag_type);
CREATE INDEX IF NOT EXISTS idx_tags_master_sort_order ON public.tags_master(sort_order);
CREATE INDEX IF NOT EXISTS idx_tags_master_is_active ON public.tags_master(is_active);
CREATE INDEX IF NOT EXISTS idx_tags_master_label ON public.tags_master(label);
CREATE INDEX IF NOT EXISTS idx_tags_master_created_by ON public.tags_master(created_by_profile_id);
CREATE INDEX IF NOT EXISTS idx_tags_master_updated_by ON public.tags_master(updated_by_profile_id);

-- Create updated_at trigger
CREATE TRIGGER trigger_tags_master_set_updated_at
    BEFORE UPDATE ON public.tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create translation cleanup trigger
CREATE TRIGGER trigger_cleanup_tags_master_translations
    AFTER DELETE ON public.tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations('tags_master');

COMMENT ON TRIGGER trigger_cleanup_tags_master_translations ON public.tags_master IS 
'Cleans up orphaned translations when a tag is deleted.';

-- Enable Row Level Security
ALTER TABLE public.tags_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public read access to active tags
CREATE POLICY "Allow public read access to active tags" ON public.tags_master
    FOR SELECT
    USING (is_active = true);

-- Platform admins have full access
CREATE POLICY "Allow platform_admins full access to tags" ON public.tags_master
    FOR ALL
    USING (public.has_role('platform_admin'))
    WITH CHECK (public.has_role('platform_admin'));

-- Admins can read all tags and create/update tags
CREATE POLICY "Allow admins read and write access to tags" ON public.tags_master
    FOR ALL
    USING (public.has_role('admin'))
    WITH CHECK (public.has_role('admin'));
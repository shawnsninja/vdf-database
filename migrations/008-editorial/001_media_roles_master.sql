-- =====================================================================================
-- VDF Database - Module 8: Editorial (Platform Content)
-- Migration: 001_media_roles_master.sql
-- Description: Create media_roles_master table for defining media roles/contexts
-- Dependencies: Module 1 (profiles)
-- Version: 1.0
-- =====================================================================================

-- Table: public.media_roles_master
-- Purpose: Defines controlled vocabulary of roles for media items when linked to entities
CREATE TABLE public.media_roles_master (
    role_code text NOT NULL PRIMARY KEY,
    default_display_name text NOT NULL,
    default_description text NULL,
    icon_identifier text NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT media_roles_master_role_code_format CHECK (
        role_code = lower(role_code) AND 
        role_code ~ '^[a-z0-9_]+$' AND 
        char_length(role_code) > 0 AND 
        char_length(role_code) <= 50
    ),
    CONSTRAINT media_roles_master_default_display_name_length CHECK (
        char_length(default_display_name) > 0 AND 
        char_length(default_display_name) <= 100
    ),
    CONSTRAINT media_roles_master_default_description_length CHECK (
        default_description IS NULL OR 
        char_length(default_description) <= 255
    ),
    CONSTRAINT media_roles_master_icon_identifier_length CHECK (
        icon_identifier IS NULL OR 
        char_length(icon_identifier) <= 50
    ),
    CONSTRAINT media_roles_master_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT media_roles_master_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.media_roles_master IS 'Defines a controlled vocabulary of roles for media items when linked to other entities (e.g., gallery_image for an article). Module 8. Version 1.0.';
COMMENT ON COLUMN public.media_roles_master.role_code IS 'PK. Machine-readable code (e.g., gallery_image, profile_avatar). Lowercase, snake_case, >0 and <=50 chars.';
COMMENT ON COLUMN public.media_roles_master.default_display_name IS 'Default human-readable name in the primary reference language (e.g., "Gallery Image"). >0 and <=100 chars. (Translatable via public.translations)';
COMMENT ON COLUMN public.media_roles_master.default_description IS 'Default detailed description of the role in the primary reference language. Max 255 chars. (Translatable via public.translations)';
COMMENT ON COLUMN public.media_roles_master.icon_identifier IS 'Optional identifier for a UI icon representing the role (e.g., a Material Design Icon name). Max 50 chars.';
COMMENT ON COLUMN public.media_roles_master.is_active IS 'If true, this media role is active and can be assigned in linking tables. Default is true.';
COMMENT ON COLUMN public.media_roles_master.created_at IS 'Timestamp of role definition creation.';
COMMENT ON COLUMN public.media_roles_master.updated_at IS 'Timestamp of last role definition update (auto-updated by trigger).';
COMMENT ON COLUMN public.media_roles_master.created_by_profile_id IS 'Profile ID of the user who initially created this role. FK to profiles.id.';
COMMENT ON COLUMN public.media_roles_master.updated_by_profile_id IS 'Profile ID of the user who last updated this role. FK to profiles.id.';

-- Indexes
CREATE INDEX idx_media_roles_master_is_active ON public.media_roles_master (is_active);
CREATE INDEX idx_media_roles_master_created_by_profile_id ON public.media_roles_master (created_by_profile_id) WHERE created_by_profile_id IS NOT NULL;
CREATE INDEX idx_media_roles_master_updated_by_profile_id ON public.media_roles_master (updated_by_profile_id) WHERE updated_by_profile_id IS NOT NULL;

-- Trigger
CREATE TRIGGER on_media_roles_master_updated_at 
    BEFORE UPDATE ON public.media_roles_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger function to clean up related translations on delete
CREATE OR REPLACE FUNCTION public.cleanup_media_roles_master_translations() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        DELETE FROM public.translations
        WHERE table_identifier = 'media_roles_master'
        AND column_identifier IN ('default_display_name', 'default_description')
        AND row_foreign_key = OLD.role_code;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.cleanup_media_roles_master_translations() IS 'Removes related entries from public.translations for default_display_name and default_description when a media_roles_master entry is deleted. Runs as SECURITY DEFINER.';

-- Apply the cleanup trigger for translations
CREATE TRIGGER trigger_cleanup_media_roles_master_translations_after_delete
    AFTER DELETE ON public.media_roles_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_media_roles_master_translations();

COMMENT ON TRIGGER trigger_cleanup_media_roles_master_translations_after_delete ON public.media_roles_master IS 'After a media role is deleted, removes its associated translations from the public.translations table.';

-- RLS Policies
ALTER TABLE public.media_roles_master ENABLE ROW LEVEL SECURITY;

-- Public can read active media roles
CREATE POLICY "Public can read active media roles" ON public.media_roles_master 
    FOR SELECT TO authenticated, anon 
    USING (is_active = true);

-- Admins can manage all media roles
CREATE POLICY "Admins can manage all media roles" ON public.media_roles_master 
    FOR ALL TO authenticated 
    USING (public.has_role('admin_platform'))
    WITH CHECK (public.has_role('admin_platform'));
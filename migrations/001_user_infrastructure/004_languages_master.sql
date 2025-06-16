-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 004_languages_master.sql
-- Description: Languages master table for i18n support
-- Version: 2.1
-- =============================================

-- Create languages_master table
CREATE TABLE IF NOT EXISTS public.languages_master (
    language_code text NOT NULL PRIMARY KEY,
    display_name_native text NOT NULL,
    display_name_en text NOT NULL,
    icon_identifier text NULL,
    is_active_for_platform boolean NOT NULL DEFAULT false,
    is_primary_content_language boolean NOT NULL DEFAULT false,
    display_order_ui integer NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT check_language_code_format CHECK (
        language_code ~ '^[a-z]{2}(-[A-Z]{2})?$' AND 
        char_length(language_code) >= 2 AND 
        char_length(language_code) <= 5
    ),
    CONSTRAINT uq_languages_master_display_order_ui UNIQUE (display_order_ui)
);

-- Create unique partial index to ensure only one primary content language
CREATE UNIQUE INDEX uq_one_primary_content_language 
    ON public.languages_master (is_primary_content_language) 
    WHERE (is_primary_content_language = TRUE);

-- Create indexes
CREATE INDEX idx_languages_master_active_order 
    ON public.languages_master (is_active_for_platform, display_order_ui);
CREATE INDEX idx_languages_master_created_by_profile_id 
    ON public.languages_master (created_by_profile_id) 
    WHERE created_by_profile_id IS NOT NULL;
CREATE INDEX idx_languages_master_updated_by_profile_id 
    ON public.languages_master (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;

-- Add comments
COMMENT ON TABLE public.languages_master IS 
'Defines all languages supported or planned for the platform, including display names, active status, the primary reference language, and optional UI icon identifiers. Authoritative list for translations. Version 2.1.';

COMMENT ON COLUMN public.languages_master.language_code IS 
'PK. ISO 639-1 (e.g., en, it) or IETF language tag (e.g., en-GB, pt-BR). Max length 5.';

COMMENT ON COLUMN public.languages_master.display_name_native IS 
'The name of the language in its own native script and language (e.g., "Italiano", "Deutsch").';

COMMENT ON COLUMN public.languages_master.display_name_en IS 
'The common name of the language in English (e.g., "Italian", "German"). For admin/developer reference.';

COMMENT ON COLUMN public.languages_master.icon_identifier IS 
'Optional identifier for a UI icon representing the language (e.g., a flag icon class name or an SVG identifier).';

COMMENT ON COLUMN public.languages_master.is_active_for_platform IS 
'If true, language is actively supported and available for user selection and content display.';

COMMENT ON COLUMN public.languages_master.is_primary_content_language IS 
'Flags the primary reference language. Content in this language is stored in main table columns. Only one can be true (enforced by partial unique index).';

COMMENT ON COLUMN public.languages_master.display_order_ui IS 
'Optional unique order for displaying languages in UI selectors. Nullable, but unique if provided.';

COMMENT ON COLUMN public.languages_master.created_at IS 
'Timestamp of when this language record was created.';

COMMENT ON COLUMN public.languages_master.updated_at IS 
'Timestamp of when this language record was last updated (auto-updated by trigger).';

COMMENT ON COLUMN public.languages_master.created_by_profile_id IS 
'Profile ID of the user who initially created this language entry. FK to profiles.id. ON DELETE SET NULL.';

COMMENT ON COLUMN public.languages_master.updated_by_profile_id IS 
'Profile ID of the user who last updated this language entry. FK to profiles.id. ON DELETE SET NULL.';

-- Create trigger for updated_at timestamp
CREATE TRIGGER handle_languages_master_updated_at 
    BEFORE UPDATE ON public.languages_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();
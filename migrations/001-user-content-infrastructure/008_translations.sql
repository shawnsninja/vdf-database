-- =====================================================================================
-- Module 1: User & Content Infrastructure - translations table
-- Version: 2.1
-- Description: Stores all translated textual content for specified fields from various
--              tables across the platform, enabling multilingual support with audit trails
-- Dependencies: 
--   - public.profiles (for FK references)
--   - public.languages_master (for language_code FK)
--   - extensions.moddatetime or handle_updated_at() function
-- =====================================================================================

-- Table Definition
CREATE TABLE public.translations (
    -- Primary Key
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    
    -- Translation Identification
    table_identifier text NOT NULL CHECK (char_length(table_identifier) > 0),
    column_identifier text NOT NULL CHECK (char_length(column_identifier) > 0),
    row_foreign_key text NOT NULL,  -- PK value of source record as text
    
    -- Translation Content
    language_code text NOT NULL,
    translated_text text NOT NULL,
    
    -- Translation Workflow
    translation_status text NULL CHECK (
        translation_status IN ('draft', 'needs_review', 'published_live', 'needs_update') 
        OR translation_status IS NULL
    ),
    translated_by_profile_id uuid NULL,
    translation_last_updated_at timestamp with time zone NULL,
    
    -- Standard Audit Columns
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    -- Primary Key Constraint
    CONSTRAINT translations_pkey PRIMARY KEY (id),
    
    -- Foreign Key Constraints
    CONSTRAINT translations_language_code_fkey 
        FOREIGN KEY (language_code) 
        REFERENCES public.languages_master (language_code) 
        ON UPDATE CASCADE ON DELETE RESTRICT,
    
    CONSTRAINT translations_translated_by_profile_id_fkey 
        FOREIGN KEY (translated_by_profile_id) 
        REFERENCES public.profiles (id) 
        ON DELETE SET NULL,
    
    CONSTRAINT translations_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) 
        REFERENCES public.profiles (id) 
        ON DELETE SET NULL,
    
    CONSTRAINT translations_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) 
        REFERENCES public.profiles (id) 
        ON DELETE SET NULL,
    
    -- Unique Constraint
    CONSTRAINT uq_translation_entry 
        UNIQUE (table_identifier, column_identifier, row_foreign_key, language_code)
);

-- Indexes for Performance
CREATE INDEX idx_translations_lookup 
    ON public.translations (table_identifier, column_identifier, row_foreign_key, language_code, translation_status);

CREATE INDEX idx_translations_language_code 
    ON public.translations (language_code);

CREATE INDEX idx_translations_row_foreign_key 
    ON public.translations (row_foreign_key);

CREATE INDEX idx_translations_status_updated_at 
    ON public.translations (translation_status, translation_last_updated_at) 
    WHERE translation_status IS NOT NULL AND translation_last_updated_at IS NOT NULL;

CREATE INDEX idx_translations_translated_by_profile_id 
    ON public.translations (translated_by_profile_id) 
    WHERE translated_by_profile_id IS NOT NULL;

CREATE INDEX idx_translations_created_by_profile_id 
    ON public.translations (created_by_profile_id) 
    WHERE created_by_profile_id IS NOT NULL;

CREATE INDEX idx_translations_updated_by_profile_id 
    ON public.translations (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;

-- Table and Column Comments
COMMENT ON TABLE public.translations IS 
    'Stores all translated textual content for specified fields from various tables, enabling multilingual support and audit trails. Version 2.1.';

COMMENT ON COLUMN public.translations.row_foreign_key IS 
    'Stores the PK of the source record as text. Integrity handled by parent table DELETE triggers.';

COMMENT ON COLUMN public.translations.translated_by_profile_id IS 
    'Profile ID of the user/agent who provided/last updated the translated_text content.';

COMMENT ON COLUMN public.translations.translation_last_updated_at IS 
    'Timestamp when translated_text or translation_status was last modified by a translator/editor.';

COMMENT ON COLUMN public.translations.created_by_profile_id IS 
    'Profile ID of the user/process that created this translation row. FK to profiles.id. ON DELETE SET NULL.';

COMMENT ON COLUMN public.translations.updated_by_profile_id IS 
    'Profile ID of the user/process that last updated this translation row metadata. FK to profiles.id. ON DELETE SET NULL.';

-- Trigger for automatically updating updated_at timestamp
CREATE TRIGGER handle_translations_updated_at 
    BEFORE UPDATE ON public.translations 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================================================
-- Note: The cleanup_related_translations() function is defined in 002_helper_functions.sql
-- =====================================================================================
-- Example trigger for parent tables (to be added to each table with translatable fields)
-- =====================================================================================
-- Example for user_roles_master table:
-- CREATE TRIGGER cleanup_user_roles_translations
--     AFTER DELETE ON public.user_roles_master
--     FOR EACH ROW
--     EXECUTE FUNCTION public.cleanup_related_translations();
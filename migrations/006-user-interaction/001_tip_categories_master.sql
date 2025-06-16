-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 001_tip_categories_master.sql
-- Description: Create tip_categories_master table for user-submitted tip categorization
-- Dependencies: Module 1 (profiles, translations)
-- Version: 2.1
-- =====================================================================================

-- Table Definition for tip_categories_master
CREATE TABLE public.tip_categories_master (
    category_code text NOT NULL PRIMARY KEY,
    default_name text NOT NULL,
    default_description text NULL,
    icon_identifier text NULL,
    is_active boolean NOT NULL DEFAULT true,
    sort_order smallint NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments on Table and Columns
COMMENT ON TABLE public.tip_categories_master IS 'Master table for defining categories for user-submitted tips, supporting i18n, icons, audit, and lifecycle. Version 2.1.';
COMMENT ON COLUMN public.tip_categories_master.category_code IS 'PK. Unique code for the category (e.g., ''practical_advice'', ''safety_observation'').';
COMMENT ON COLUMN public.tip_categories_master.default_name IS 'Default human-readable name for the category in the primary reference language (e.g., English). (Translatable via public.translations)';
COMMENT ON COLUMN public.tip_categories_master.default_description IS 'Optional default detailed description of the category in the primary reference language. (Translatable via public.translations)';
COMMENT ON COLUMN public.tip_categories_master.icon_identifier IS 'Optional identifier for an icon associated with this category (e.g., ''icon-lightbulb'', ''icon-warning'').';
COMMENT ON COLUMN public.tip_categories_master.is_active IS 'Whether the category is currently active and available for use/display. Defaults to true.';
COMMENT ON COLUMN public.tip_categories_master.sort_order IS 'Defines a sort order for displaying categories in UI lists. Defaults to 0.';
COMMENT ON COLUMN public.tip_categories_master.created_at IS 'Timestamp of when the category was created.';
COMMENT ON COLUMN public.tip_categories_master.updated_at IS 'Timestamp of when the category was last updated. Auto-updated by a trigger.';
COMMENT ON COLUMN public.tip_categories_master.created_by_profile_id IS 'Profile ID of the user who created this category. FK to profiles.id. ON DELETE SET NULL.';
COMMENT ON COLUMN public.tip_categories_master.updated_by_profile_id IS 'Profile ID of the user who last updated this category. FK to profiles.id. ON DELETE SET NULL.';

-- Indexes
CREATE INDEX ix_tip_categories_master_active_order ON public.tip_categories_master (is_active, sort_order);
CREATE INDEX ix_tip_categories_master_created_by ON public.tip_categories_master (created_by_profile_id) WHERE created_by_profile_id IS NOT NULL;
CREATE INDEX ix_tip_categories_master_updated_by ON public.tip_categories_master (updated_by_profile_id) WHERE updated_by_profile_id IS NOT NULL;

-- Trigger for updated_at timestamp (Ensure public.handle_updated_at() function exists)
CREATE TRIGGER on_tip_categories_master_updated_at 
    BEFORE UPDATE ON public.tip_categories_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for cleaning up related translations
CREATE OR REPLACE FUNCTION public.cleanup_tip_categories_master_translations() 
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.translations 
    WHERE table_identifier = 'tip_categories_master' 
    AND row_foreign_key = OLD.category_code;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_cleanup_translations_on_tip_category_delete 
    AFTER DELETE ON public.tip_categories_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.cleanup_tip_categories_master_translations();

COMMENT ON TRIGGER trigger_cleanup_translations_on_tip_category_delete ON public.tip_categories_master IS 
    'Cleans up orphaned translations from public.translations when a tip category is deleted.';

-- RLS Policies
ALTER TABLE public.tip_categories_master ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage tip categories" ON public.tip_categories_master 
    FOR ALL TO authenticated 
    USING (public.has_role_on_profile(auth.uid(), 'admin_platform'))
    WITH CHECK (public.has_role_on_profile(auth.uid(), 'admin_platform'));

CREATE POLICY "Public can view active tip categories" ON public.tip_categories_master 
    FOR SELECT 
    USING (is_active = true);

COMMENT ON POLICY "Admins can manage tip categories" ON public.tip_categories_master IS 
    'Allows platform administrators (or users with equivalent roles) to manage all tip categories.';
COMMENT ON POLICY "Public can view active tip categories" ON public.tip_categories_master IS 
    'Allows all users (anonymous and authenticated) to view active tip categories.';
-- =====================================================================================
-- Module 1: Translation Cleanup Triggers
-- Description: Adds AFTER DELETE triggers to all tables with translatable fields
--              to automatically remove orphaned translations when parent records are deleted
-- Dependencies: 
--   - public.cleanup_related_translations() function
--   - All master tables with translatable fields
-- =====================================================================================

-- user_roles_master table (translatable: default_display_name, default_description)
CREATE TRIGGER cleanup_user_roles_translations
    AFTER DELETE ON public.user_roles_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- languages_master table (no translatable fields, but included for completeness)
-- Note: languages_master contains display names in native language and English,
-- but these are not typically translated via the translations table
-- CREATE TRIGGER cleanup_languages_translations
--     AFTER DELETE ON public.languages_master
--     FOR EACH ROW
--     EXECUTE FUNCTION public.cleanup_related_translations();

-- media table (translatable: default_alt_text, default_caption, attribution_text)
CREATE TRIGGER cleanup_media_translations
    AFTER DELETE ON public.media
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- =====================================================================================
-- Note: Additional cleanup triggers should be added to tables in other modules
-- as they are implemented. Any table with translatable text fields needs this trigger.
-- =====================================================================================
-- =====================================================================================
-- Module 1: Row Level Security (RLS) Policies
-- Description: Implements RLS policies for all Module 1 tables to control access
--              based on user roles and ownership
-- Dependencies: All Module 1 tables and helper functions must exist
-- =====================================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.languages_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.translations ENABLE ROW LEVEL SECURITY;

-- =====================================================================================
-- PROFILES TABLE POLICIES
-- =====================================================================================

-- Public users can view profiles marked as publicly visible
CREATE POLICY "profiles_public_read" ON public.profiles
    FOR SELECT
    USING (is_profile_publicly_visible = true);

-- Authenticated users can view their own profile
CREATE POLICY "profiles_own_read" ON public.profiles
    FOR SELECT
    TO authenticated
    USING (id = auth.uid());

-- Authenticated users can update their own profile
CREATE POLICY "profiles_own_update" ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Platform admins can view all profiles
CREATE POLICY "profiles_admin_read" ON public.profiles
    FOR SELECT
    TO authenticated
    USING (public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Platform admins can update all profiles
CREATE POLICY "profiles_admin_update" ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (public.has_role('platform_admin') OR public.has_role('admin_super'))
    WITH CHECK (public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Only super admins can delete profiles (soft delete via updated_at)
CREATE POLICY "profiles_admin_delete" ON public.profiles
    FOR DELETE
    TO authenticated
    USING (public.has_role('admin_super'));

-- =====================================================================================
-- USER_ROLES_MASTER TABLE POLICIES
-- =====================================================================================

-- All authenticated users can read active roles
CREATE POLICY "user_roles_master_read" ON public.user_roles_master
    FOR SELECT
    TO authenticated
    USING (is_role_active = true AND deleted_at IS NULL);

-- Only super admins can insert new roles
CREATE POLICY "user_roles_master_admin_insert" ON public.user_roles_master
    FOR INSERT
    TO authenticated
    WITH CHECK (public.has_role('admin_super'));

-- Only super admins can update roles
CREATE POLICY "user_roles_master_admin_update" ON public.user_roles_master
    FOR UPDATE
    TO authenticated
    USING (public.has_role('admin_super'))
    WITH CHECK (public.has_role('admin_super'));

-- Only super admins can delete roles
CREATE POLICY "user_roles_master_admin_delete" ON public.user_roles_master
    FOR DELETE
    TO authenticated
    USING (public.has_role('admin_super'));

-- =====================================================================================
-- LANGUAGES_MASTER TABLE POLICIES
-- =====================================================================================

-- Everyone can read active languages (including anonymous users)
CREATE POLICY "languages_master_public_read" ON public.languages_master
    FOR SELECT
    USING (is_active_for_platform = true);

-- Only super admins can insert new languages
CREATE POLICY "languages_master_admin_insert" ON public.languages_master
    FOR INSERT
    TO authenticated
    WITH CHECK (public.has_role('admin_super'));

-- Only super admins can update languages
CREATE POLICY "languages_master_admin_update" ON public.languages_master
    FOR UPDATE
    TO authenticated
    USING (public.has_role('admin_super'))
    WITH CHECK (public.has_role('admin_super'));

-- Only super admins can delete languages
CREATE POLICY "languages_master_admin_delete" ON public.languages_master
    FOR DELETE
    TO authenticated
    USING (public.has_role('admin_super'));

-- =====================================================================================
-- MEDIA TABLE POLICIES
-- =====================================================================================

-- Public users can view published/approved media
CREATE POLICY "media_public_read" ON public.media
    FOR SELECT
    USING (media_status = 'published_approved' AND deleted_at IS NULL);

-- Authenticated users can insert their own media
CREATE POLICY "media_authenticated_insert" ON public.media
    FOR INSERT
    TO authenticated
    WITH CHECK (uploader_profile_id = auth.uid());

-- Users can view their own media regardless of status
CREATE POLICY "media_own_read" ON public.media
    FOR SELECT
    TO authenticated
    USING (uploader_profile_id = auth.uid());

-- Users can update their own media if it's not yet approved
CREATE POLICY "media_own_update" ON public.media
    FOR UPDATE
    TO authenticated
    USING (uploader_profile_id = auth.uid() AND media_status IN ('processing_upload', 'pending_review', 'rejected_hidden'))
    WITH CHECK (uploader_profile_id = auth.uid());

-- Content moderators can view all media except deleted
CREATE POLICY "media_moderator_read" ON public.media
    FOR SELECT
    TO authenticated
    USING ((public.has_role('content_moderator') OR public.has_role('platform_admin') OR public.has_role('admin_super')) 
           AND deleted_at IS NULL);

-- Content moderators can update media status
CREATE POLICY "media_moderator_update" ON public.media
    FOR UPDATE
    TO authenticated
    USING (public.has_role('content_moderator') OR public.has_role('platform_admin') OR public.has_role('admin_super'))
    WITH CHECK (public.has_role('content_moderator') OR public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Only admins can soft delete media
CREATE POLICY "media_admin_delete" ON public.media
    FOR UPDATE
    TO authenticated
    USING (public.has_role('platform_admin') OR public.has_role('admin_super'))
    WITH CHECK ((public.has_role('platform_admin') OR public.has_role('admin_super')) AND deleted_at IS NOT NULL);

-- =====================================================================================
-- TRANSLATIONS TABLE POLICIES
-- =====================================================================================

-- Public users can read published translations
CREATE POLICY "translations_public_read" ON public.translations
    FOR SELECT
    USING (translation_status = 'published_live' OR translation_status IS NULL);

-- Translators can insert new translations
CREATE POLICY "translations_translator_insert" ON public.translations
    FOR INSERT
    TO authenticated
    WITH CHECK (public.has_role('translator') OR public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Translators can view all translations
CREATE POLICY "translations_translator_read" ON public.translations
    FOR SELECT
    TO authenticated
    USING (public.has_role('translator') OR public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Translators can update translations
CREATE POLICY "translations_translator_update" ON public.translations
    FOR UPDATE
    TO authenticated
    USING (public.has_role('translator') OR public.has_role('platform_admin') OR public.has_role('admin_super'))
    WITH CHECK (public.has_role('translator') OR public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Only admins can delete translations
CREATE POLICY "translations_admin_delete" ON public.translations
    FOR DELETE
    TO authenticated
    USING (public.has_role('platform_admin') OR public.has_role('admin_super'));

-- =====================================================================================
-- Grant necessary permissions to authenticated users
-- =====================================================================================

-- Grant basic permissions to authenticated role
GRANT SELECT ON public.profiles TO authenticated;
GRANT UPDATE (
    username, full_name, public_display_name, public_avatar_media_id, public_bio,
    preferred_language_code, preferred_units_of_measure, preferred_timezone,
    pilgrim_experience_level, pilgrimage_interests_tags, contributor_organization_name,
    contributor_organization_role, contact_public_email, website_url_profile,
    notification_preferences_json, is_profile_publicly_visible, terms_accepted_at,
    last_login_at, last_activity_at
) ON public.profiles TO authenticated;

GRANT SELECT ON public.user_roles_master TO authenticated;
GRANT SELECT ON public.languages_master TO authenticated;
GRANT SELECT, INSERT ON public.media TO authenticated;
GRANT UPDATE (
    file_name_original, default_alt_text, default_caption, attribution_text,
    attribution_url, tags
) ON public.media TO authenticated;

GRANT SELECT ON public.translations TO authenticated;

-- Grant permissions to anonymous users for public data
GRANT SELECT ON public.profiles TO anon;
GRANT SELECT ON public.languages_master TO anon;
GRANT SELECT ON public.media TO anon;
GRANT SELECT ON public.translations TO anon;

-- =====================================================================================
-- Comments
-- =====================================================================================
COMMENT ON POLICY "profiles_public_read" ON public.profiles IS 
    'Allow public read access to profiles marked as publicly visible';

COMMENT ON POLICY "profiles_own_read" ON public.profiles IS 
    'Allow authenticated users to read their own profile';

COMMENT ON POLICY "profiles_own_update" ON public.profiles IS 
    'Allow authenticated users to update their own profile';

COMMENT ON POLICY "media_public_read" ON public.media IS 
    'Allow public read access to approved media';

COMMENT ON POLICY "media_authenticated_insert" ON public.media IS 
    'Allow authenticated users to upload media';

COMMENT ON POLICY "translations_public_read" ON public.translations IS 
    'Allow public read access to published translations';
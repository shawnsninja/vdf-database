-- =====================================================================================
-- Module 1: Helper Functions
-- Description: Core utility functions used throughout the VDF database
-- =====================================================================================

-- =====================================================================================
-- Function: handle_updated_at()
-- Description: Automatically updates the updated_at timestamp on row modification
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.handle_updated_at() IS 
    'Trigger function that automatically updates the updated_at timestamp when a row is modified';

-- =====================================================================================
-- Function: has_role(role_code)
-- Description: Checks if the current authenticated user has a specific role
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.has_role(role_code text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = auth.uid() 
        AND role_code = ANY(roles)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

COMMENT ON FUNCTION public.has_role(text) IS 
    'Checks if the current authenticated user has the specified role';

-- =====================================================================================
-- Function: has_role_on_profile(profile_id, role_code)
-- Description: Checks if a specific profile has a specific role
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.has_role_on_profile(profile_id uuid, role_code text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = profile_id 
        AND role_code = ANY(roles)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

COMMENT ON FUNCTION public.has_role_on_profile(uuid, text) IS 
    'Checks if the specified profile has the specified role';

-- =====================================================================================
-- Function: check_profile_roles()
-- Description: Validates that all roles in the roles array exist in user_roles_master
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.check_profile_roles()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if all roles exist in user_roles_master
    IF NOT (
        SELECT bool_and(role_exists)
        FROM unnest(NEW.roles) AS role_code
        LEFT JOIN LATERAL (
            SELECT EXISTS (
                SELECT 1 
                FROM public.user_roles_master 
                WHERE code = role_code
            ) AS role_exists
        ) AS role_check ON true
    ) THEN
        RAISE EXCEPTION 'Invalid role code in roles array';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.check_profile_roles() IS 
    'Trigger function that validates all roles in the roles array exist in user_roles_master';

-- =====================================================================================
-- Function: handle_new_user()
-- Description: Creates a profile record when a new user signs up via Supabase Auth
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        email,
        display_name,
        roles,
        preferred_language_code,
        unit_preference,
        account_status
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        ARRAY['pilgrim_user']::text[], -- Default role
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en'),
        'metric',
        'active'
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

COMMENT ON FUNCTION public.handle_new_user() IS 
    'Creates a profile record with default role when a new user signs up';

-- =====================================================================================
-- Function: sync_profile_roles_to_auth_user()
-- Description: Syncs the roles array from profiles table to auth.users JWT claims
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.sync_profile_roles_to_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the auth.users raw_app_meta_data with the new roles
    UPDATE auth.users
    SET raw_app_meta_data = 
        COALESCE(raw_app_meta_data, '{}'::jsonb) || 
        jsonb_build_object('roles', NEW.roles)
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

COMMENT ON FUNCTION public.sync_profile_roles_to_auth_user() IS 
    'Syncs the roles array from profiles to auth.users JWT claims for immediate effect';

-- =====================================================================================
-- Function: get_user_language()
-- Description: Returns the current user's preferred language code
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.get_user_language()
RETURNS text AS $$
DECLARE
    user_language text;
BEGIN
    SELECT preferred_language_code 
    INTO user_language
    FROM public.profiles 
    WHERE id = auth.uid();
    
    RETURN COALESCE(user_language, 'en'); -- Default to English if not found
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE
SET search_path = public, auth;

COMMENT ON FUNCTION public.get_user_language() IS 
    'Returns the current authenticated user''s preferred language code, defaulting to English';

-- =====================================================================================
-- Function: cleanup_related_translations()
-- Description: Removes orphaned translation records when a parent record is deleted
-- Note: This function is called by AFTER DELETE triggers on tables with translatable fields
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.cleanup_related_translations()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete all translations for the deleted record
    DELETE FROM public.translations
    WHERE table_identifier = TG_TABLE_NAME
      AND row_foreign_key = OLD.id::text;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.cleanup_related_translations() IS 
    'Removes orphaned translation records when a parent record is deleted. Called by AFTER DELETE triggers on tables with translatable fields.';
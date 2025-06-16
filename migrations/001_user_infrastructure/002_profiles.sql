-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 002_profiles.sql
-- Description: User profiles table extending auth.users
-- Version: 2.3
-- =============================================

-- Create ENUM types first
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'units_preference_enum') THEN
        CREATE TYPE public.units_preference_enum AS ENUM ('metric', 'imperial');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pilgrim_experience_enum') THEN
        CREATE TYPE public.pilgrim_experience_enum AS ENUM (
            'novice_first_pilgrimage',
            'intermediate_few_pilgrimages',
            'experienced_many_pilgrimages',
            'long_distance_veteran'
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_account_status_enum') THEN
        CREATE TYPE public.user_account_status_enum AS ENUM (
            'active',
            'pending_verification',
            'email_unconfirmed',
            'suspended_by_admin',
            'deactivated_by_user'
        );
    END IF;
END$$;

-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    roles text[] NOT NULL,
    username text NULL UNIQUE,
    full_name text NULL,
    public_display_name text NULL UNIQUE,
    public_avatar_media_id uuid NULL, -- Will reference media table later
    public_bio text NULL,
    preferred_language_code text NOT NULL DEFAULT 'en', -- Will reference languages_master later
    preferred_units_of_measure public.units_preference_enum NOT NULL DEFAULT 'metric',
    preferred_timezone text NULL DEFAULT 'Europe/Rome',
    pilgrim_experience_level public.pilgrim_experience_enum NULL,
    pilgrimage_interests_tags text[] NULL,
    contributor_organization_name text NULL,
    contributor_organization_role text NULL,
    contact_public_email text NULL,
    website_url_profile text NULL,
    notification_preferences_json jsonb NULL,
    is_profile_publicly_visible boolean NOT NULL DEFAULT false,
    contribution_score integer NOT NULL DEFAULT 0,
    account_status public.user_account_status_enum NOT NULL DEFAULT 'active',
    terms_accepted_at timestamp with time zone NULL,
    last_login_at timestamp with time zone NULL,
    last_activity_at timestamp with time zone NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT check_preferred_language_code_format CHECK (preferred_language_code ~ '^[a-z]{2}(-[A-Z]{2})?$'),
    CONSTRAINT check_contact_public_email_format CHECK (
        contact_public_email IS NULL OR 
        contact_public_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT check_website_url_profile_format CHECK (
        website_url_profile IS NULL OR 
        website_url_profile ~* '^https?://.+'
    ),
    CONSTRAINT check_contribution_score_non_negative CHECK (contribution_score >= 0)
);

-- Create indexes
CREATE INDEX idx_profiles_roles ON public.profiles USING GIN (roles);
CREATE INDEX idx_profiles_pilgrimage_interests_tags ON public.profiles USING GIN (pilgrimage_interests_tags);
CREATE INDEX idx_profiles_account_status ON public.profiles (account_status);
CREATE INDEX idx_profiles_updated_by_profile_id ON public.profiles (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;
CREATE INDEX idx_profiles_last_activity_at ON public.profiles (last_activity_at DESC NULLS LAST) 
    WHERE last_activity_at IS NOT NULL;

-- Add comments
COMMENT ON TABLE public.profiles IS 
'Stores application-specific user data, extending Supabase Auth users. Manages identity, roles (synchronized to auth.users), preferences, contributor context, account status, activity timestamps, and admin update audit. Version 2.3.';

COMMENT ON COLUMN public.profiles.id IS 
'User''s ID from auth.users table (PK, FK). Profile deleted if auth user is deleted. Implicitly `created_by`.';

COMMENT ON COLUMN public.profiles.roles IS 
'Array of role codes (e.g., {"pilgrim_user"}). Validated by `check_profile_roles` trigger. Synchronized to `auth.users.raw_app_meta_data.roles`.';

COMMENT ON COLUMN public.profiles.last_activity_at IS 
'Timestamp of the last recorded significant user activity (e.g., interaction, content submission). Mechanism for updates (API calls, specific DB triggers) to be defined.';

COMMENT ON COLUMN public.profiles.updated_by_profile_id IS 
'Profile ID of another user (typically an admin) who last made significant updates to this profile record. ON DELETE SET NULL.';

-- Create trigger for updated_at timestamp
CREATE TRIGGER handle_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Note: Role validation and synchronization triggers will be created after user_roles_master table exists
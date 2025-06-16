-- =====================================================================================
-- Module 1: User & Content Infrastructure - profiles table
-- Version: 2.3
-- Description: Stores application-specific user data, extending Supabase Auth users
--              with roles, preferences, and audit trails
-- Dependencies:
--   - auth.users table (Supabase Auth)
--   - public.languages_master table
--   - public.media table
--   - ENUM types (created below)
-- =====================================================================================

-- Create ENUM Types
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

-- Table Definition
CREATE TABLE public.profiles (
    -- Primary Key (1:1 with auth.users)
    id uuid NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Core Identity & Roles
    roles text[] NOT NULL,
    username text NULL,
    full_name text NULL,
    public_display_name text NULL,
    
    -- Media & Profile Content
    public_avatar_media_id uuid NULL,
    public_bio text NULL,
    
    -- User Preferences
    preferred_language_code text NOT NULL DEFAULT 'en',
    preferred_units_of_measure public.units_preference_enum NOT NULL DEFAULT 'metric',
    preferred_timezone text NULL DEFAULT 'Europe/Rome',
    
    -- Pilgrim-specific Fields
    pilgrim_experience_level public.pilgrim_experience_enum NULL,
    pilgrimage_interests_tags text[] NULL,
    
    -- Contributor Information
    contributor_organization_name text NULL,
    contributor_organization_role text NULL,
    contact_public_email text NULL,
    website_url_profile text NULL,
    
    -- Platform Settings
    notification_preferences_json jsonb NULL,
    is_profile_publicly_visible boolean NOT NULL DEFAULT false,
    contribution_score integer NOT NULL DEFAULT 0,
    account_status public.user_account_status_enum NOT NULL DEFAULT 'active',
    
    -- Activity Tracking
    terms_accepted_at timestamp with time zone NULL,
    last_login_at timestamp with time zone NULL,
    last_activity_at timestamp with time zone NULL,
    
    -- Standard Audit Columns
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_by_profile_id uuid NULL,
    
    -- Unique Constraints
    CONSTRAINT uq_profiles_username UNIQUE (username),
    CONSTRAINT uq_profiles_public_display_name UNIQUE (public_display_name),
    
    -- Check Constraints
    CONSTRAINT check_preferred_language_code_format 
        CHECK (preferred_language_code ~ '^[a-z]{2}(-[A-Z]{2})?$'),
    
    CONSTRAINT check_contact_public_email_format 
        CHECK (contact_public_email IS NULL OR 
               contact_public_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    CONSTRAINT check_website_url_profile_format 
        CHECK (website_url_profile IS NULL OR 
               website_url_profile ~* '^https?://.+'),
    
    CONSTRAINT check_contribution_score_non_negative 
        CHECK (contribution_score >= 0)
);

-- Add Foreign Key Constraints (after table creation to avoid circular dependencies)
ALTER TABLE public.profiles 
    ADD CONSTRAINT profiles_public_avatar_media_id_fkey 
    FOREIGN KEY (public_avatar_media_id) 
    REFERENCES public.media(id) 
    ON DELETE SET NULL;

ALTER TABLE public.profiles 
    ADD CONSTRAINT profiles_preferred_language_code_fkey 
    FOREIGN KEY (preferred_language_code) 
    REFERENCES public.languages_master(language_code) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.profiles 
    ADD CONSTRAINT profiles_updated_by_profile_id_fkey 
    FOREIGN KEY (updated_by_profile_id) 
    REFERENCES public.profiles(id) 
    ON DELETE SET NULL;

-- Indexes for Performance
CREATE INDEX idx_profiles_roles ON public.profiles USING GIN (roles);
CREATE INDEX idx_profiles_pilgrimage_interests_tags ON public.profiles USING GIN (pilgrimage_interests_tags);
CREATE INDEX idx_profiles_account_status ON public.profiles (account_status);
CREATE INDEX idx_profiles_updated_by_profile_id ON public.profiles (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;
CREATE INDEX idx_profiles_last_activity_at ON public.profiles (last_activity_at DESC NULLS LAST) 
    WHERE last_activity_at IS NOT NULL;

-- Table and Column Comments
COMMENT ON TABLE public.profiles IS 
    'Stores application-specific user data, extending Supabase Auth users. Manages identity, roles (synchronized to auth.users), preferences, contributor context, account status, activity timestamps, and admin update audit. Version 2.3.';

COMMENT ON COLUMN public.profiles.id IS 
    'User''s ID from auth.users table (PK, FK). Profile deleted if auth user is deleted. Implicitly created_by.';

COMMENT ON COLUMN public.profiles.roles IS 
    'Array of role codes (e.g., {"pilgrim_user"}). Validated by check_profile_roles trigger. Synchronized to auth.users.raw_app_meta_data.roles.';

COMMENT ON COLUMN public.profiles.last_activity_at IS 
    'Timestamp of the last recorded significant user activity (e.g., interaction, content submission). Mechanism for updates (API calls, specific DB triggers) to be defined.';

COMMENT ON COLUMN public.profiles.updated_by_profile_id IS 
    'Profile ID of another user (typically an admin) who last made significant updates to this profile record. ON DELETE SET NULL.';

-- Trigger for automatically updating updated_at timestamp
CREATE TRIGGER handle_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for validating roles array
CREATE TRIGGER trigger_check_profile_roles_on_insert_or_update 
    BEFORE INSERT OR UPDATE OF roles ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.check_profile_roles();

COMMENT ON TRIGGER trigger_check_profile_roles_on_insert_or_update ON public.profiles IS 
    'Validates roles against user_roles_master before profile insert or roles update.';

-- Trigger for synchronizing roles to auth.users JWT claims
CREATE TRIGGER trigger_sync_roles_to_auth_user_on_profile_change 
    AFTER INSERT OR UPDATE OF roles ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.sync_profile_roles_to_auth_user();

COMMENT ON TRIGGER trigger_sync_roles_to_auth_user_on_profile_change ON public.profiles IS 
    'When roles in public.profiles are inserted or updated, synchronizes them to auth.users.raw_app_meta_data.roles.';

-- Trigger for auto-creating profile on new auth.users entry
CREATE TRIGGER on_auth_user_created 
    AFTER INSERT ON auth.users 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_user();

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 
    'After a new user is created in auth.users, this trigger creates their corresponding profile and sets initial roles and activity timestamp.';
-- =====================================================================================
-- Module 1: User & Content Infrastructure - user_roles_master table
-- Version: 2.1
-- Description: Defines all available user roles within the platform, serving as the
--              authoritative source for role codes, names, descriptions, and permissions
-- Dependencies:
--   - public.profiles table (for FK references)
--   - public.cleanup_related_translations() function
-- =====================================================================================

-- Table Definition
CREATE TABLE public.user_roles_master (
    -- Primary Key
    role_code text NOT NULL PRIMARY KEY,
    
    -- Role Definition
    default_display_name text NOT NULL,
    default_description text NULL,
    icon_identifier text NULL,
    
    -- Role Configuration
    permissions_summary_json jsonb NULL,
    role_hierarchy_level integer NULL,
    is_system_role boolean NOT NULL DEFAULT false,
    is_role_active boolean NOT NULL DEFAULT true,
    default_for_new_pilgrim_users boolean NOT NULL DEFAULT false,
    
    -- Standard Audit Columns
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Soft Delete
    deleted_at timestamp with time zone NULL,
    
    -- Check Constraints
    CONSTRAINT check_role_code_format 
        CHECK (role_code = lower(role_code) AND role_code ~ '^[a-z0-9_]+$')
);

-- Unique Partial Index to ensure only one role is default for new pilgrim users
CREATE UNIQUE INDEX uq_one_default_for_new_pilgrim_users 
    ON public.user_roles_master (default_for_new_pilgrim_users) 
    WHERE (default_for_new_pilgrim_users = TRUE);

-- Performance Indexes
CREATE INDEX idx_user_roles_master_active_default 
    ON public.user_roles_master (is_role_active, default_for_new_pilgrim_users);

CREATE INDEX idx_user_roles_master_created_by_profile_id 
    ON public.user_roles_master (created_by_profile_id) 
    WHERE created_by_profile_id IS NOT NULL;

CREATE INDEX idx_user_roles_master_updated_by_profile_id 
    ON public.user_roles_master (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;

-- Table and Column Comments
COMMENT ON TABLE public.user_roles_master IS 
    'Defines all available user roles, their default names/descriptions (in primary reference language), permission summaries, UI icons, and audit trails for RBAC. Version 2.1.';

COMMENT ON COLUMN public.user_roles_master.role_code IS 
    'PK. Short, unique, machine-readable, lowercase role code (e.g., pilgrim_user). Used in profiles.roles.';

COMMENT ON COLUMN public.user_roles_master.default_display_name IS 
    'Human-readable name in the primary reference language. (Translatable via translations table).';

COMMENT ON COLUMN public.user_roles_master.default_description IS 
    'Detailed description of the role in the primary reference language. (Translatable via translations table).';

COMMENT ON COLUMN public.user_roles_master.icon_identifier IS 
    'Optional identifier for a UI icon representing the role (e.g., a Material Design Icon name like ''person_outline'').';

COMMENT ON COLUMN public.user_roles_master.permissions_summary_json IS 
    'JSONB storing a human-readable summary of key permissions. For documentation/admin UI; enforcement via RLS/app logic.';

COMMENT ON COLUMN public.user_roles_master.is_system_role IS 
    'If true, this is a core system role resistant to easy deletion/modification.';

COMMENT ON COLUMN public.user_roles_master.default_for_new_pilgrim_users IS 
    'If true, role is auto-assigned to new pilgrims. Enforced unique true value by partial index.';

COMMENT ON COLUMN public.user_roles_master.created_by_profile_id IS 
    'Profile ID of the user who initially created this role entry. FK to profiles.id. ON DELETE SET NULL.';

COMMENT ON COLUMN public.user_roles_master.updated_by_profile_id IS 
    'Profile ID of the user who last updated this role entry. FK to profiles.id. ON DELETE SET NULL.';

COMMENT ON COLUMN public.user_roles_master.deleted_at IS 
    'Timestamp for soft deletion. Prefer is_role_active = false for retiring roles in use. Used by profiles.check_profile_roles trigger.';

-- Trigger for automatically updating updated_at timestamp
CREATE TRIGGER handle_user_roles_master_updated_at 
    BEFORE UPDATE ON public.user_roles_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();
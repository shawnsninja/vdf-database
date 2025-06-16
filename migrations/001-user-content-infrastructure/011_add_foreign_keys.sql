-- =====================================================================================
-- Module 1: Add Foreign Keys
-- Description: Adds foreign key constraints that couldn't be created during initial
--              table creation due to circular dependencies
-- Dependencies: All Module 1 tables must exist
-- =====================================================================================

-- Note: The profiles table has several self-referencing and cross-referencing FKs
-- that were already created in the main table DDL. This file is primarily for
-- future use if additional cross-table dependencies are discovered.

-- Currently, all foreign keys for Module 1 have been created inline with their
-- respective table definitions. This file serves as a placeholder for any
-- deferred foreign key constraints that might be needed.

-- =====================================================================================
-- Verification: Check that all expected foreign keys exist
-- =====================================================================================
DO $$
DECLARE
    fk_count integer;
BEGIN
    -- Count foreign keys in Module 1 tables
    SELECT COUNT(*) INTO fk_count
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public'
    AND table_name IN ('profiles', 'user_roles_master', 'languages_master', 'media', 'translations');
    
    -- We expect at least these foreign keys:
    -- profiles: auth.users(id), media(id), languages_master(language_code), profiles(id)
    -- user_roles_master: profiles(id) x2
    -- languages_master: profiles(id) x2
    -- media: profiles(id) x2
    -- translations: languages_master(language_code), profiles(id) x3
    -- Total minimum expected: 13
    
    IF fk_count < 13 THEN
        RAISE WARNING 'Expected at least 13 foreign keys in Module 1 tables, but found only %', fk_count;
    ELSE
        RAISE NOTICE 'Module 1 foreign key constraints verified: % foreign keys found', fk_count;
    END IF;
END $$;
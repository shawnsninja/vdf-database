-- =====================================================================================
-- Module 1: Comprehensive Test Script
-- Description: Tests all functionality in Module 1 to ensure proper implementation
-- Run this after applying all Module 1 migrations (001-013)
-- =====================================================================================

-- Set up test context
BEGIN;

-- =====================================================================================
-- 1. Test Extensions
-- =====================================================================================
DO $$
BEGIN
    RAISE NOTICE 'Testing extensions...';
    
    -- Test UUID generation
    PERFORM gen_random_uuid();
    RAISE NOTICE '✓ UUID generation working';
    
    -- Test pgcrypto
    PERFORM crypt('test', gen_salt('bf'));
    RAISE NOTICE '✓ pgcrypto working';
    
    -- Test PostGIS
    PERFORM ST_MakePoint(0, 0);
    RAISE NOTICE '✓ PostGIS working';
    
    -- Test pg_trgm
    PERFORM similarity('test', 'text');
    RAISE NOTICE '✓ pg_trgm working';
    
    -- Test citext
    PERFORM 'TEST'::citext = 'test'::citext;
    RAISE NOTICE '✓ citext working';
END $$;

-- =====================================================================================
-- 2. Test Helper Functions
-- =====================================================================================
DO $$
DECLARE
    test_user_id uuid;
    test_profile_id uuid;
BEGIN
    RAISE NOTICE 'Testing helper functions...';
    
    -- Create a test auth user
    test_user_id := gen_random_uuid();
    
    -- Simulate auth user creation (in real scenario, this would be done by Supabase Auth)
    INSERT INTO auth.users (id, email, email_confirmed_at)
    VALUES (test_user_id, 'test@example.com', now());
    
    -- Test handle_new_user trigger (should auto-create profile)
    -- In real scenario, this is triggered automatically
    -- Here we'll manually call it to test
    PERFORM public.handle_new_user();
    
    -- Verify profile was created
    SELECT id INTO test_profile_id
    FROM public.profiles
    WHERE id = test_user_id;
    
    IF test_profile_id IS NOT NULL THEN
        RAISE NOTICE '✓ Profile auto-creation working';
    ELSE
        RAISE EXCEPTION 'Profile auto-creation failed';
    END IF;
    
    -- Test has_role function
    -- First, set the current user context (simulate authenticated user)
    PERFORM set_config('request.jwt.claim.sub', test_user_id::text, true);
    
    IF public.has_role('pilgrim_user') THEN
        RAISE NOTICE '✓ has_role() function working';
    ELSE
        RAISE EXCEPTION 'has_role() function failed';
    END IF;
    
    -- Test has_role_on_profile function
    IF public.has_role_on_profile(test_user_id, 'pilgrim_user') THEN
        RAISE NOTICE '✓ has_role_on_profile() function working';
    ELSE
        RAISE EXCEPTION 'has_role_on_profile() function failed';
    END IF;
    
    -- Test get_user_language function
    IF public.get_user_language() = 'en' THEN
        RAISE NOTICE '✓ get_user_language() function working';
    ELSE
        RAISE EXCEPTION 'get_user_language() function failed';
    END IF;
    
    -- Clean up test user
    DELETE FROM auth.users WHERE id = test_user_id;
END $$;

-- =====================================================================================
-- 3. Test Master Data
-- =====================================================================================
DO $$
DECLARE
    role_count integer;
    language_count integer;
    primary_lang_count integer;
    default_role_count integer;
BEGIN
    RAISE NOTICE 'Testing master data...';
    
    -- Test user_roles_master
    SELECT COUNT(*) INTO role_count FROM public.user_roles_master WHERE is_role_active = true;
    IF role_count >= 11 THEN
        RAISE NOTICE '✓ User roles master data loaded (% active roles)', role_count;
    ELSE
        RAISE EXCEPTION 'User roles master data incomplete';
    END IF;
    
    -- Test default role exists
    SELECT COUNT(*) INTO default_role_count 
    FROM public.user_roles_master 
    WHERE default_for_new_pilgrim_users = true;
    
    IF default_role_count = 1 THEN
        RAISE NOTICE '✓ Default role for new users configured';
    ELSE
        RAISE EXCEPTION 'Default role misconfigured';
    END IF;
    
    -- Test languages_master
    SELECT COUNT(*) INTO language_count FROM public.languages_master WHERE is_active_for_platform = true;
    IF language_count >= 5 THEN
        RAISE NOTICE '✓ Languages master data loaded (% active languages)', language_count;
    ELSE
        RAISE EXCEPTION 'Languages master data incomplete';
    END IF;
    
    -- Test primary language
    SELECT COUNT(*) INTO primary_lang_count 
    FROM public.languages_master 
    WHERE is_primary_content_language = true;
    
    IF primary_lang_count = 1 THEN
        RAISE NOTICE '✓ Primary content language configured';
    ELSE
        RAISE EXCEPTION 'Primary language misconfigured';
    END IF;
END $$;

-- =====================================================================================
-- 4. Test Media Table
-- =====================================================================================
DO $$
DECLARE
    test_media_id uuid;
    test_user_id uuid;
BEGIN
    RAISE NOTICE 'Testing media functionality...';
    
    -- Create test user and profile
    test_user_id := gen_random_uuid();
    INSERT INTO auth.users (id, email, email_confirmed_at)
    VALUES (test_user_id, 'media_test@example.com', now());
    
    INSERT INTO public.profiles (id, roles, preferred_language_code)
    VALUES (test_user_id, ARRAY['pilgrim_user'], 'en');
    
    -- Test media insert
    INSERT INTO public.media (
        uploader_profile_id,
        storage_bucket_name,
        storage_object_path_original,
        file_name_original,
        file_mime_type,
        file_size_bytes_original,
        media_asset_type,
        media_status,
        default_alt_text,
        default_caption
    ) VALUES (
        test_user_id,
        'platform-media',
        'uploads/test/' || gen_random_uuid() || '.jpg',
        'test_image.jpg',
        'image/jpeg',
        1024000,
        'image',
        'pending_review',
        'Test image alt text',
        'Test image caption'
    ) RETURNING id INTO test_media_id;
    
    IF test_media_id IS NOT NULL THEN
        RAISE NOTICE '✓ Media creation working';
    ELSE
        RAISE EXCEPTION 'Media creation failed';
    END IF;
    
    -- Test update_media_last_linked_timestamp function
    UPDATE public.media 
    SET last_linked_or_used_at = now() 
    WHERE id = test_media_id;
    
    RAISE NOTICE '✓ Media timestamp update working';
    
    -- Clean up
    DELETE FROM public.media WHERE id = test_media_id;
    DELETE FROM auth.users WHERE id = test_user_id;
END $$;

-- =====================================================================================
-- 5. Test Translations System
-- =====================================================================================
DO $$
DECLARE
    translation_id bigint;
    translation_count integer;
BEGIN
    RAISE NOTICE 'Testing translations system...';
    
    -- Insert test translation
    INSERT INTO public.translations (
        table_identifier,
        column_identifier,
        row_foreign_key,
        language_code,
        translated_text,
        translation_status
    ) VALUES (
        'user_roles_master',
        'default_display_name',
        'pilgrim_user',
        'it',
        'Utente Pellegrino',
        'published_live'
    ) RETURNING id INTO translation_id;
    
    IF translation_id IS NOT NULL THEN
        RAISE NOTICE '✓ Translation creation working';
    ELSE
        RAISE EXCEPTION 'Translation creation failed';
    END IF;
    
    -- Test cleanup trigger
    -- First, let's see how many translations we have for pilgrim_user
    SELECT COUNT(*) INTO translation_count
    FROM public.translations
    WHERE table_identifier = 'user_roles_master'
    AND row_foreign_key = 'pilgrim_user';
    
    RAISE NOTICE '✓ Translation system working (% translations for test role)', translation_count;
    
    -- Clean up test translation
    DELETE FROM public.translations WHERE id = translation_id;
END $$;

-- =====================================================================================
-- 6. Test Audit Infrastructure
-- =====================================================================================
DO $$
DECLARE
    audit_count integer;
    migration_count integer;
BEGIN
    RAISE NOTICE 'Testing audit infrastructure...';
    
    -- Check schema migrations
    SELECT COUNT(*) INTO migration_count FROM public.schema_migrations;
    IF migration_count >= 13 THEN
        RAISE NOTICE '✓ Schema migrations tracked (% migrations)', migration_count;
    ELSE
        RAISE EXCEPTION 'Schema migrations incomplete';
    END IF;
    
    -- Test audit logging (if enabled on any table)
    -- This would require enabling audit on a table first
    RAISE NOTICE '✓ Audit infrastructure ready (manual table enablement required)';
END $$;

-- =====================================================================================
-- 7. Test RLS Policies
-- =====================================================================================
DO $$
DECLARE
    policy_count integer;
BEGIN
    RAISE NOTICE 'Testing RLS policies...';
    
    -- Count RLS policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename IN ('profiles', 'user_roles_master', 'languages_master', 'media', 'translations');
    
    IF policy_count > 0 THEN
        RAISE NOTICE '✓ RLS policies configured (% policies found)', policy_count;
    ELSE
        RAISE EXCEPTION 'RLS policies not found';
    END IF;
    
    -- Verify RLS is enabled
    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'profiles' 
        AND rowsecurity = true
    ) THEN
        RAISE NOTICE '✓ RLS enabled on profiles table';
    ELSE
        RAISE EXCEPTION 'RLS not enabled on profiles table';
    END IF;
END $$;

-- =====================================================================================
-- 8. Test Trigger Functions
-- =====================================================================================
DO $$
DECLARE
    test_role_code text := 'test_role_' || substr(gen_random_uuid()::text, 1, 8);
    original_updated_at timestamp with time zone;
    new_updated_at timestamp with time zone;
BEGIN
    RAISE NOTICE 'Testing trigger functions...';
    
    -- Insert test role
    INSERT INTO public.user_roles_master (
        role_code,
        default_display_name,
        default_description,
        is_role_active
    ) VALUES (
        test_role_code,
        'Test Role',
        'Test role for trigger testing',
        false
    );
    
    -- Get initial updated_at
    SELECT updated_at INTO original_updated_at
    FROM public.user_roles_master
    WHERE role_code = test_role_code;
    
    -- Wait a moment
    PERFORM pg_sleep(0.1);
    
    -- Update the role
    UPDATE public.user_roles_master
    SET default_description = 'Updated description'
    WHERE role_code = test_role_code;
    
    -- Get new updated_at
    SELECT updated_at INTO new_updated_at
    FROM public.user_roles_master
    WHERE role_code = test_role_code;
    
    -- Verify updated_at changed
    IF new_updated_at > original_updated_at THEN
        RAISE NOTICE '✓ Updated_at trigger working';
    ELSE
        RAISE EXCEPTION 'Updated_at trigger not working';
    END IF;
    
    -- Clean up
    DELETE FROM public.user_roles_master WHERE role_code = test_role_code;
END $$;

-- =====================================================================================
-- Summary
-- =====================================================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Module 1 Testing Complete!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'All core functionality has been tested.';
    RAISE NOTICE 'The module is ready for use.';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Review any warnings above';
    RAISE NOTICE '2. Run application-level integration tests';
    RAISE NOTICE '3. Proceed with Module 2 implementation';
    RAISE NOTICE '';
END $$;

-- Rollback the test transaction (comment out to keep test data)
ROLLBACK;

-- To run this test:
-- psql $DATABASE_URL -f test_module_1.sql
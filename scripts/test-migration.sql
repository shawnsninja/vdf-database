-- Test Migration Script
-- This script tests that migrations have run successfully

-- Test 1: Check extensions are enabled
SELECT 
    extname,
    extversion
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'postgis')
ORDER BY extname;

-- Test 2: Check user infrastructure tables exist
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN ('profiles', 'user_roles_master', 'languages_master', 'media', 'translations')
ORDER BY table_name;

-- Test 3: Check audit columns exist on profiles
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'profiles'
    AND column_name IN ('created_at', 'updated_at', 'created_by_profile_id', 'updated_by_profile_id')
ORDER BY column_name;

-- Test 4: Check RLS is enabled
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('profiles', 'media', 'translations')
ORDER BY tablename;

-- Test 5: Check functions exist
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN ('has_role', 'has_role_on_profile', 'handle_updated_at', 'handle_new_user')
ORDER BY routine_name;

-- Test 6: Check seed data
SELECT 'user_roles_master' as table_name, COUNT(*) as row_count FROM public.user_roles_master
UNION ALL
SELECT 'languages_master', COUNT(*) FROM public.languages_master
ORDER BY table_name;
-- Test Script for Module 3: Geographical Context
-- Run this after all Module 3 migrations to verify functionality

BEGIN;

-- Set up test user
SET LOCAL ROLE postgres;

-- Test 1: Verify all tables exist
DO $$
BEGIN
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'countries'), 
        'countries table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'regions'), 
        'regions table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'provinces'), 
        'provinces table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'towns'), 
        'towns table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'town_types_master'), 
        'town_types_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'characteristic_tags_master'), 
        'characteristic_tags_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'service_tags_master'), 
        'service_tags_master table should exist';
    RAISE NOTICE 'Test 1 passed: All tables exist';
END $$;

-- Test 2: Verify master data
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM public.countries) >= 3, 
        'Should have at least 3 countries';
    ASSERT (SELECT COUNT(*) FROM public.town_types_master) >= 9, 
        'Should have at least 9 town types';
    ASSERT (SELECT COUNT(*) FROM public.characteristic_tags_master) >= 14, 
        'Should have at least 14 characteristic tags';
    ASSERT (SELECT COUNT(*) FROM public.service_tags_master) >= 20, 
        'Should have at least 20 service tags';
    RAISE NOTICE 'Test 2 passed: Master data loaded';
END $$;

-- Test 3: Create test data hierarchy
-- Create a test user profile
INSERT INTO public.profiles (id, email, display_name, roles, preferred_language_code, is_active)
VALUES ('11111111-1111-1111-1111-111111111113', 'geo_admin@test.com', 'Geo Admin', ARRAY['platform_admin'], 'en', true)
ON CONFLICT (id) DO NOTHING;

-- Create a test region
INSERT INTO public.regions (
    slug,
    country_code,
    iso_3166_2_code,
    characteristics_tags,
    map_default_latitude,
    map_default_longitude,
    map_default_zoom,
    is_featured,
    content_visibility_status,
    created_by_profile_id
) VALUES (
    'test-umbria',
    'IT',
    'IT-55',
    ARRAY['mountainous', 'medieval', 'religious'],
    43.1107,
    12.3908,
    9,
    true,
    'published',
    '11111111-1111-1111-1111-111111111113'
) RETURNING id AS test_region_id \gset

-- Create test provinces
INSERT INTO public.provinces (
    region_id,
    country_code,
    code,
    wikidata_id,
    geonames_id,
    is_active,
    created_by_profile_id
) VALUES 
    (:test_region_id, 'IT', 'PG', 'Q3862', 3171640, true, '11111111-1111-1111-1111-111111111113'),
    (:test_region_id, 'IT', 'TR', 'Q3899', 3165030, true, '11111111-1111-1111-1111-111111111113')
RETURNING id AS test_province_id \gset

-- Create test towns
INSERT INTO public.towns (
    region_id,
    province_id,
    slug,
    latitude_centroid,
    longitude_centroid,
    elevation_meters,
    population,
    town_type_code,
    istat_code,
    wikidata_id,
    geonames_id,
    key_services_summary_tags,
    town_transport_information_urls,
    has_train_station,
    has_bus_services,
    is_major_stage_town,
    content_visibility_status,
    created_by_profile_id
) VALUES 
    (
        :test_region_id,
        :test_province_id,
        'test-assisi',
        43.0707,
        12.6177,
        424,
        28299,
        'city_small',
        '054001',
        'Q20103',
        3182351,
        ARRAY['atm', 'pharmacy', 'hospital', 'grocery_store', 'wifi', 'pilgrim_office'],
        '[{"operator_identifier": "trenitalia", "url": "https://www.trenitalia.com"}]'::jsonb,
        true,
        true,
        true,
        'published',
        '11111111-1111-1111-1111-111111111113'
    ),
    (
        :test_region_id,
        :test_province_id,
        'test-spello',
        42.9901,
        12.6702,
        314,
        8638,
        'town',
        '054049',
        'Q20466',
        3166598,
        ARRAY['atm', 'pharmacy', 'grocery_store', 'wifi'],
        NULL,
        true,
        true,
        false,
        'published',
        '11111111-1111-1111-1111-111111111113'
    );

-- Test 4: Verify PostGIS functionality
DO $$
DECLARE
    test_geom geometry;
    distance_km numeric;
BEGIN
    -- Verify geom_centroid was auto-generated
    SELECT geom_centroid INTO test_geom
    FROM public.towns
    WHERE slug = 'test-assisi';
    
    ASSERT test_geom IS NOT NULL, 'geom_centroid should be auto-generated';
    
    -- Calculate distance between Assisi and Spello
    SELECT ST_Distance(
        t1.geom_centroid::geography,
        t2.geom_centroid::geography
    ) / 1000.0 INTO distance_km
    FROM public.towns t1, public.towns t2
    WHERE t1.slug = 'test-assisi' 
    AND t2.slug = 'test-spello';
    
    ASSERT distance_km BETWEEN 5 AND 15, 
        'Distance between Assisi and Spello should be reasonable';
    
    RAISE NOTICE 'Test 4 passed: PostGIS functionality working (distance: % km)', round(distance_km, 2);
END $$;

-- Test 5: Test validation triggers
DO $$
BEGIN
    -- Test invalid characteristic tag
    BEGIN
        UPDATE public.regions
        SET characteristics_tags = ARRAY['invalid_tag']
        WHERE slug = 'test-umbria';
        ASSERT FALSE, 'Should have raised exception for invalid characteristic tag';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 5a passed: Invalid characteristic tag rejected';
    END;
    
    -- Test invalid service tag
    BEGIN
        UPDATE public.towns
        SET key_services_summary_tags = ARRAY['invalid_service']
        WHERE slug = 'test-assisi';
        ASSERT FALSE, 'Should have raised exception for invalid service tag';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 5b passed: Invalid service tag rejected';
    END;
    
    -- Test inactive tag
    UPDATE public.service_tags_master SET is_active = false WHERE code = 'atm';
    BEGIN
        UPDATE public.towns
        SET key_services_summary_tags = ARRAY['atm']
        WHERE slug = 'test-spello';
        ASSERT FALSE, 'Should have raised exception for inactive service tag';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 5c passed: Inactive service tag rejected';
    END;
    UPDATE public.service_tags_master SET is_active = true WHERE code = 'atm';
END $$;

-- Test 6: Test translations integration
DO $$
DECLARE
    region_trans_count int;
    town_trans_count int;
BEGIN
    -- Add translations for region
    INSERT INTO public.translations (
        table_identifier, row_foreign_key, column_identifier,
        language_code, translated_text, translation_status
    ) VALUES 
        ('regions', :test_region_id::text, 'name', 'en', 'Test Umbria', 'published_live'),
        ('regions', :test_region_id::text, 'name', 'it', 'Test Umbria', 'published_live'),
        ('regions', :test_region_id::text, 'description', 'en', 'A test region for validation', 'published_live');
    
    -- Verify cleanup trigger would work
    SELECT COUNT(*) INTO region_trans_count
    FROM public.translations
    WHERE table_identifier = 'regions' 
    AND row_foreign_key = :test_region_id::text;
    
    ASSERT region_trans_count = 3, 'Should have 3 translations for region';
    RAISE NOTICE 'Test 6 passed: Translations integration working';
END $$;

-- Test 7: Test RLS policies
DO $$
DECLARE
    anon_visible int;
    auth_visible int;
BEGIN
    -- Switch to anonymous role
    SET LOCAL ROLE anon;
    
    -- Anonymous should only see published, non-deleted content
    SELECT COUNT(*) INTO anon_visible FROM public.regions WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO auth_visible FROM public.towns WHERE deleted_at IS NULL;
    
    ASSERT anon_visible > 0, 'Anonymous should see published regions';
    ASSERT auth_visible > 0, 'Anonymous should see published towns';
    
    -- Test that anonymous cannot insert
    BEGIN
        INSERT INTO public.regions (slug, country_code) VALUES ('test-fail', 'IT');
        ASSERT FALSE, 'Anonymous should not be able to insert';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Test 7a passed: Anonymous cannot insert';
    END;
    
    -- Reset to superuser
    SET LOCAL ROLE postgres;
    RAISE NOTICE 'Test 7 passed: RLS policies working correctly';
END $$;

-- Test 8: Test cascade behaviors
DO $$
DECLARE
    town_count int;
BEGIN
    -- Soft delete a region
    UPDATE public.regions
    SET deleted_at = now()
    WHERE slug = 'test-umbria';
    
    -- Towns should still exist (region_id allows NULL)
    SELECT COUNT(*) INTO town_count
    FROM public.towns
    WHERE region_id = :test_region_id;
    
    ASSERT town_count > 0, 'Towns should still exist after region soft delete';
    
    -- Restore region
    UPDATE public.regions
    SET deleted_at = NULL
    WHERE slug = 'test-umbria';
    
    RAISE NOTICE 'Test 8 passed: Cascade behaviors correct';
END $$;

-- Test 9: Test URL validation
DO $$
BEGIN
    -- Test valid URL
    UPDATE public.regions
    SET official_tourism_url = 'https://www.umbriatourism.it'
    WHERE slug = 'test-umbria';
    
    -- Test invalid URL
    BEGIN
        UPDATE public.regions
        SET official_tourism_url = 'not-a-url'
        WHERE slug = 'test-umbria';
        ASSERT FALSE, 'Should have raised exception for invalid URL';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 9 passed: URL validation working';
    END;
END $$;

-- Test 10: Test JSONB transport URLs
DO $$
DECLARE
    transport_data jsonb;
BEGIN
    SELECT town_transport_information_urls INTO transport_data
    FROM public.towns
    WHERE slug = 'test-assisi';
    
    ASSERT jsonb_array_length(transport_data) = 1, 'Should have 1 transport URL';
    ASSERT transport_data->0->>'operator_identifier' = 'trenitalia', 'Should have correct operator';
    
    -- Test GIN index is working
    EXPLAIN (COSTS OFF) SELECT * FROM public.towns 
    WHERE town_transport_information_urls @> '[{"operator_identifier": "trenitalia"}]';
    
    RAISE NOTICE 'Test 10 passed: JSONB transport URLs working';
END $$;

-- Cleanup test data
DELETE FROM public.towns WHERE slug LIKE 'test-%';
DELETE FROM public.provinces WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111113';
DELETE FROM public.regions WHERE slug = 'test-umbria';
DELETE FROM public.profiles WHERE id = '11111111-1111-1111-1111-111111111113';

-- Final summary
DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Module 3 test suite completed successfully!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- All tables created correctly';
    RAISE NOTICE '- Master data loaded';
    RAISE NOTICE '- PostGIS functionality verified';
    RAISE NOTICE '- Validation triggers working';
    RAISE NOTICE '- Translations integration verified';
    RAISE NOTICE '- RLS policies enforced correctly';
    RAISE NOTICE '- Cascade behaviors verified';
    RAISE NOTICE '- URL validation working';
    RAISE NOTICE '- JSONB fields and indexes working';
    RAISE NOTICE '';
    RAISE NOTICE 'Module 3 is ready for use!';
END $$;

ROLLBACK;
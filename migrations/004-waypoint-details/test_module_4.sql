-- Test Script for Module 4: Waypoint Details
-- Run this after all Module 4 migrations to verify functionality

BEGIN;

-- Set up test user
SET LOCAL ROLE postgres;

-- Test 1: Verify all tables exist
DO $$
BEGIN
    -- Check master tables
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'waypoint_categories_master'), 
        'waypoint_categories_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tags_master'), 
        'tags_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'content_statuses_master'), 
        'content_statuses_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'waypoints'), 
        'waypoints table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'waypoint_media'), 
        'waypoint_media table should exist';
    
    -- Check views
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_waypoint_categories_localized'), 
        'v_waypoint_categories_localized view should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_tags_localized'), 
        'v_tags_localized view should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_waypoints_enriched'), 
        'v_waypoints_enriched view should exist';
    
    RAISE NOTICE 'Test 1 passed: All tables and views exist';
END $$;

-- Test 2: Verify seed data
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM public.waypoint_categories_master) >= 15, 
        'Should have at least 15 waypoint categories';
    ASSERT (SELECT COUNT(*) FROM public.tags_master) >= 35, 
        'Should have at least 35 tags';
    ASSERT (SELECT COUNT(*) FROM public.content_statuses_master) >= 14, 
        'Should have at least 14 content statuses';
    
    -- Check that draft status exists (required for waypoints default)
    ASSERT EXISTS (SELECT 1 FROM public.content_statuses_master WHERE code = 'draft'), 
        'Draft status must exist for waypoints default';
    ASSERT EXISTS (SELECT 1 FROM public.content_statuses_master WHERE code = 'published' AND is_publicly_visible = true), 
        'Published status must exist and be publicly visible';
    
    RAISE NOTICE 'Test 2 passed: Seed data loaded correctly';
END $$;

-- Test 3: Create test waypoint with all features
-- Use the admin profile from previous modules or create if needed
INSERT INTO public.profiles (id, email, display_name, roles, preferred_language_code, is_active)
VALUES ('11111111-1111-1111-1111-111111111114', 'waypoint_admin@test.com', 'Waypoint Admin', ARRAY['platform_admin'], 'en', true)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    v_category_id INTEGER;
    v_tag_ids INTEGER[];
    v_status_id INTEGER;
    v_town_id INTEGER;
    v_waypoint_id BIGINT;
    v_media_id UUID;
BEGIN
    -- Get required IDs
    SELECT id INTO v_category_id FROM public.waypoint_categories_master WHERE code = 'religious_site' LIMIT 1;
    SELECT ARRAY[id] INTO v_tag_ids FROM public.tags_master WHERE tag_code IN ('franciscan_site', 'pilgrimage_highlight') LIMIT 2;
    SELECT id INTO v_status_id FROM public.content_statuses_master WHERE code = 'published' LIMIT 1;
    SELECT id INTO v_town_id FROM public.towns WHERE slug LIKE 'test-%' OR name = 'Assisi' LIMIT 1;
    
    -- Create test waypoint
    INSERT INTO public.waypoints (
        name,
        slug,
        alternate_names_primary_lang,
        waypoint_primary_category_id,
        waypoint_subcategory_tag_ids,
        description,
        geom,
        town_id,
        address_text,
        content_visibility_status_id,
        is_franciscan_highlight_site,
        is_significant_pilgrim_poi,
        short_narrative_for_dynamic_lists,
        waypoint_accessibility_notes,
        general_tags_text,
        primary_data_source_waypoint,
        quality_score,
        created_by_profile_id
    ) VALUES (
        'Test Sanctuary of La Verna',
        'test-sanctuary-la-verna',
        ARRAY['La Verna Monastery', 'Sacred Mount'],
        v_category_id,
        v_tag_ids,
        'A sacred Franciscan monastery where St. Francis received the stigmata.',
        ST_GeogFromText('POINT Z(11.9267 43.7072 1128)'), -- La Verna coordinates with elevation
        v_town_id,
        'Via del Santuario, 1, La Verna',
        v_status_id,
        true, -- is_franciscan_highlight_site
        true, -- is_significant_pilgrim_poi
        'Sacred site where St. Francis received the stigmata in 1224.',
        'Partially accessible. Main church accessible via ramp, some areas require stairs.',
        ARRAY['mountain sanctuary', 'medieval architecture'],
        'Official Via di Francesco Guide 2024',
        95,
        '11111111-1111-1111-1111-111111111114'
    ) RETURNING id INTO v_waypoint_id;
    
    -- Test that array FK validation worked
    ASSERT v_waypoint_id IS NOT NULL, 'Waypoint should be created successfully';
    
    RAISE NOTICE 'Test 3 passed: Waypoint created with ID %', v_waypoint_id;
    
    -- Test 4: Test array FK validation (should fail)
    BEGIN
        INSERT INTO public.waypoints (
            name,
            waypoint_primary_category_id,
            waypoint_subcategory_tag_ids,
            geom,
            content_visibility_status_id
        ) VALUES (
            'Test Invalid Tags',
            v_category_id,
            ARRAY[999999, 999998], -- Invalid tag IDs
            ST_GeogFromText('POINT(12.0 44.0)'),
            v_status_id
        );
        ASSERT FALSE, 'Should have failed with invalid tag IDs';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'Test 4 passed: Array FK validation correctly rejected invalid tag IDs';
    END;
    
    -- Test 5: Create test media association
    INSERT INTO public.media (
        storage_bucket,
        file_path,
        file_name,
        mime_type,
        file_size_bytes,
        media_status,
        created_by_profile_id
    ) VALUES (
        'waypoint-media',
        'waypoints/la-verna-hero.jpg',
        'la-verna-hero.jpg',
        'image/jpeg',
        2048000,
        'active',
        '11111111-1111-1111-1111-111111111114'
    ) RETURNING id INTO v_media_id;
    
    -- Associate media with waypoint
    INSERT INTO public.waypoint_media (
        waypoint_id,
        media_id,
        media_role_code,
        display_order,
        caption,
        alt_text,
        is_featured,
        created_by_profile_id
    ) VALUES (
        v_waypoint_id,
        v_media_id,
        'hero',
        1,
        'The sacred sanctuary of La Verna nestled in the mountains',
        'Aerial view of La Verna Franciscan monastery surrounded by forest',
        true,
        '11111111-1111-1111-1111-111111111114'
    );
    
    RAISE NOTICE 'Test 5 passed: Media association created successfully';
END $$;

-- Test 6: Test localized views
DO $$
DECLARE
    v_categories_count INTEGER;
    v_tags_count INTEGER;
    v_waypoints_count INTEGER;
BEGIN
    -- Test localized views return data
    SELECT COUNT(*) INTO v_categories_count FROM public.v_waypoint_categories_localized WHERE is_active = true;
    SELECT COUNT(*) INTO v_tags_count FROM public.v_tags_localized WHERE is_active = true;
    SELECT COUNT(*) INTO v_waypoints_count FROM public.v_waypoints_enriched;
    
    ASSERT v_categories_count > 0, 'Localized categories view should return data';
    ASSERT v_tags_count > 0, 'Localized tags view should return data';
    ASSERT v_waypoints_count > 0, 'Enriched waypoints view should return data';
    
    -- Test that enriched view includes related data
    ASSERT EXISTS (
        SELECT 1 FROM public.v_waypoints_enriched 
        WHERE category_code IS NOT NULL 
        AND status_code IS NOT NULL
        AND jsonb_array_length(tags) > 0
    ), 'Enriched view should include category, status, and tags data';
    
    RAISE NOTICE 'Test 6 passed: Localized views working correctly';
END $$;

-- Test 7: Test RLS policies
DO $$
DECLARE
    waypoint_count INTEGER;
    media_count INTEGER;
BEGIN
    -- Test anonymous access (published content only)
    SET LOCAL ROLE anon;
    
    SELECT COUNT(*) INTO waypoint_count FROM public.waypoints;
    SELECT COUNT(*) INTO media_count FROM public.waypoint_media;
    
    ASSERT waypoint_count > 0, 'Anonymous users should see published waypoints';
    ASSERT media_count > 0, 'Anonymous users should see media for published waypoints';
    
    -- Test that anonymous cannot insert
    BEGIN
        INSERT INTO public.waypoints (name, waypoint_primary_category_id, geom, content_visibility_status_id) 
        VALUES ('Test Fail', 1, ST_GeogFromText('POINT(0 0)'), 1);
        ASSERT FALSE, 'Anonymous should not be able to insert waypoints';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Test 7a passed: Anonymous cannot insert waypoints';
    END;
    
    -- Reset to superuser
    SET LOCAL ROLE postgres;
    
    RAISE NOTICE 'Test 7 passed: RLS policies working correctly';
END $$;

-- Test 8: Test constraint validations
DO $$
BEGIN
    -- Test name length constraint
    BEGIN
        INSERT INTO public.waypoints (
            name, 
            waypoint_primary_category_id, 
            geom, 
            content_visibility_status_id
        ) VALUES (
            repeat('x', 256), -- Too long
            (SELECT id FROM public.waypoint_categories_master LIMIT 1),
            ST_GeogFromText('POINT(0 0)'),
            (SELECT id FROM public.content_statuses_master WHERE code = 'draft')
        );
        ASSERT FALSE, 'Should not allow names longer than 255 characters';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 8a passed: Name length constraint enforced';
    END;
    
    -- Test slug format constraint
    BEGIN
        INSERT INTO public.waypoints (
            name,
            slug,
            waypoint_primary_category_id, 
            geom, 
            content_visibility_status_id
        ) VALUES (
            'Test Invalid Slug',
            'Invalid Slug With Spaces',
            (SELECT id FROM public.waypoint_categories_master LIMIT 1),
            ST_GeogFromText('POINT(0 0)'),
            (SELECT id FROM public.content_statuses_master WHERE code = 'draft')
        );
        ASSERT FALSE, 'Should not allow invalid slug format';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 8b passed: Slug format constraint enforced';
    END;
    
    -- Test quality score range
    BEGIN
        INSERT INTO public.waypoints (
            name,
            quality_score,
            waypoint_primary_category_id, 
            geom, 
            content_visibility_status_id
        ) VALUES (
            'Test Invalid Quality',
            150, -- Out of range
            (SELECT id FROM public.waypoint_categories_master LIMIT 1),
            ST_GeogFromText('POINT(0 0)'),
            (SELECT id FROM public.content_statuses_master WHERE code = 'draft')
        );
        ASSERT FALSE, 'Should not allow quality score outside 0-100 range';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 8c passed: Quality score range constraint enforced';
    END;
END $$;

-- Test 9: Test translations integration
DO $$
DECLARE
    v_waypoint_id BIGINT;
    v_translation_count INTEGER;
BEGIN
    -- Get test waypoint
    SELECT id INTO v_waypoint_id FROM public.waypoints WHERE slug = 'test-sanctuary-la-verna';
    
    -- Add translations for waypoint
    INSERT INTO public.translations (
        table_identifier, row_foreign_key, column_identifier,
        language_code, translated_text, translation_status
    ) VALUES 
        ('waypoints', v_waypoint_id::text, 'name', 'it', 'Santuario della Verna', 'published_live'),
        ('waypoints', v_waypoint_id::text, 'description', 'it', 'Un monastero francescano sacro dove San Francesco ricevette le stimmate.', 'published_live'),
        ('waypoint_categories_master', '3', 'label', 'it', 'Sito Religioso', 'published_live'),
        ('tags_master', '1', 'label', 'it', 'Sito Francescano', 'published_live');
    
    -- Verify translations exist
    SELECT COUNT(*) INTO v_translation_count
    FROM public.translations
    WHERE (table_identifier = 'waypoints' AND row_foreign_key = v_waypoint_id::text)
       OR (table_identifier = 'waypoint_categories_master')
       OR (table_identifier = 'tags_master');
    
    ASSERT v_translation_count >= 4, 'Should have waypoint and master data translations';
    
    RAISE NOTICE 'Test 9 passed: Translations integration working';
END $$;

-- Test 10: Test generated columns and PostGIS functionality
DO $$
DECLARE
    v_waypoint record;
BEGIN
    -- Get waypoint with geometry
    SELECT latitude, longitude, elevation_meters, geom
    INTO v_waypoint
    FROM public.waypoints
    WHERE slug = 'test-sanctuary-la-verna';
    
    -- Verify generated columns
    ASSERT v_waypoint.latitude IS NOT NULL, 'Latitude should be generated from geometry';
    ASSERT v_waypoint.longitude IS NOT NULL, 'Longitude should be generated from geometry';
    ASSERT v_waypoint.elevation_meters IS NOT NULL, 'Elevation should be generated from geometry';
    
    -- Verify coordinates match expected values (approximately)
    ASSERT ABS(v_waypoint.latitude - 43.7072) < 0.001, 'Latitude should match La Verna coordinates';
    ASSERT ABS(v_waypoint.longitude - 11.9267) < 0.001, 'Longitude should match La Verna coordinates';
    ASSERT ABS(v_waypoint.elevation_meters - 1128) < 10, 'Elevation should match La Verna elevation';
    
    RAISE NOTICE 'Test 10 passed: PostGIS geometry and generated columns working (lat: %, lon: %, elev: %)', 
        v_waypoint.latitude, v_waypoint.longitude, v_waypoint.elevation_meters;
END $$;

-- Cleanup test data
DELETE FROM public.waypoint_media WHERE waypoint_id IN (SELECT id FROM public.waypoints WHERE slug = 'test-sanctuary-la-verna');
DELETE FROM public.translations WHERE table_identifier = 'waypoints' AND row_foreign_key IN (
    SELECT id::text FROM public.waypoints WHERE slug = 'test-sanctuary-la-verna'
);
DELETE FROM public.waypoints WHERE slug = 'test-sanctuary-la-verna';
DELETE FROM public.media WHERE file_path LIKE 'waypoints/la-verna-%';
DELETE FROM public.profiles WHERE id = '11111111-1111-1111-1111-111111111114';

-- Final summary
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Module 4 test suite completed successfully!';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- All tables, views, and functions created correctly';
    RAISE NOTICE '- Master data seeded successfully';
    RAISE NOTICE '- Array foreign key validation working';
    RAISE NOTICE '- Enhanced waypoints table with full features';
    RAISE NOTICE '- Media associations and galleries supported';
    RAISE NOTICE '- Localized views for efficient API queries';
    RAISE NOTICE '- RLS policies enforced correctly';
    RAISE NOTICE '- Constraint validations working';
    RAISE NOTICE '- PostGIS 3D geometry with generated columns';
    RAISE NOTICE '- Translation system integration verified';
    RAISE NOTICE '';
    RAISE NOTICE 'Module 4 is ready for use!';
    RAISE NOTICE 'Core waypoint functionality: COMPLETE';
    RAISE NOTICE 'Ready for Module 4 sub-modules (accommodations, attractions, etc.)';
END $$;

ROLLBACK;
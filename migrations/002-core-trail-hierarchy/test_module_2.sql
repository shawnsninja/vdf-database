-- Test Script for Module 2: Core Trail Hierarchy
-- Run this after all Module 2 migrations to verify functionality

BEGIN;

-- Set up test user
SET LOCAL ROLE postgres;

-- Test 1: Verify all tables and types exist
DO $$
BEGIN
    -- Check ENUMs
    ASSERT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trail_operational_status_enum'), 
        'trail_operational_status_enum should exist';
    ASSERT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'route_category_enum'), 
        'route_category_enum should exist';
    ASSERT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'segment_difficulty_enum'), 
        'segment_difficulty_enum should exist';
    ASSERT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'segment_sun_exposure_enum'), 
        'segment_sun_exposure_enum should exist';
    ASSERT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'segment_travel_direction_enum'), 
        'segment_travel_direction_enum should exist';
    
    -- Check tables
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'terrain_types_master'), 
        'terrain_types_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'usage_types_master'), 
        'usage_types_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'trails'), 
        'trails table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'routes'), 
        'routes table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'segments'), 
        'segments table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'waypoints'), 
        'waypoints table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'media_roles_master'), 
        'media_roles_master table should exist';
    
    RAISE NOTICE 'Test 1 passed: All tables and types exist';
END $$;

-- Test 2: Verify master data
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM public.terrain_types_master) >= 14, 
        'Should have at least 14 terrain types';
    ASSERT (SELECT COUNT(*) FROM public.usage_types_master) >= 9, 
        'Should have at least 9 usage types';
    ASSERT (SELECT COUNT(*) FROM public.media_roles_master) >= 9, 
        'Should have at least 9 media roles';
    RAISE NOTICE 'Test 2 passed: Master data loaded';
END $$;

-- Test 3: Create test trail hierarchy
-- Use the admin profile from Module 1 or create if needed
INSERT INTO public.profiles (id, email, display_name, roles, preferred_language_code, is_active)
VALUES ('11111111-1111-1111-1111-111111111112', 'trail_admin@test.com', 'Trail Admin', ARRAY['platform_admin'], 'en', true)
ON CONFLICT (id) DO NOTHING;

-- Create test trail
INSERT INTO public.trails (
    name,
    slug,
    trail_short_code,
    operational_status,
    content_visibility_status,
    is_featured,
    created_by_profile_id
) VALUES (
    'Test Via di Francesco',
    'test-via-di-francesco',
    'TEST-VDF',
    'active',
    'published',
    true,
    '11111111-1111-1111-1111-111111111112'
) RETURNING id AS test_trail_id \gset

-- Link trail to regions (using test region from Module 3 tests if exists)
INSERT INTO public.trail_regions (
    trail_id,
    region_id,
    display_order,
    regional_significance_notes,
    created_by_profile_id
) 
SELECT 
    :test_trail_id,
    id,
    1,
    'Test trail passes through this region',
    '11111111-1111-1111-1111-111111111112'
FROM public.regions
WHERE slug LIKE 'test-%' OR slug = 'umbria'
LIMIT 1;

-- Add terrain types to trail
INSERT INTO public.trail_terrain_types (trail_id, terrain_type_id)
SELECT :test_trail_id, id
FROM public.terrain_types_master
WHERE code IN ('forest_path', 'paved_road', 'dirt_road')
AND is_active = true;

-- Add usage types to trail
INSERT INTO public.trail_usage_types (trail_id, usage_type_id)
SELECT :test_trail_id, id
FROM public.usage_types_master
WHERE code IN ('walking_only', 'dogs_allowed')
AND is_active = true;

-- Create test waypoints
INSERT INTO public.waypoints (name, slug, latitude, longitude, elevation_meters)
VALUES 
    ('Test Start Waypoint', 'test-start', 43.4633, 11.8797, 300),
    ('Test Mid Waypoint 1', 'test-mid-1', 43.4000, 11.8500, 350),
    ('Test Mid Waypoint 2', 'test-mid-2', 43.3500, 11.8200, 400),
    ('Test End Waypoint', 'test-end', 43.3000, 11.8000, 250)
RETURNING id AS test_waypoint_id \gset

-- Get all waypoint IDs
WITH waypoint_ids AS (
    SELECT id, slug FROM public.waypoints WHERE slug LIKE 'test-%' ORDER BY slug
)
SELECT array_agg(id ORDER BY slug) AS waypoint_ids FROM waypoint_ids \gset

-- Create test route
INSERT INTO public.routes (
    trail_id,
    name,
    slug,
    route_code,
    route_category,
    is_primary_route_for_trail,
    content_visibility_status,
    created_by_profile_id
) VALUES (
    :test_trail_id,
    'Test Northern Route',
    'test-northern-route',
    'TEST-N',
    'primary',
    true,
    'published',
    '11111111-1111-1111-1111-111111111112'
) RETURNING id AS test_route_id \gset

-- Test 4: Create segments with 3D geometry
DO $$
DECLARE
    v_waypoint_ids bigint[];
    v_segment_ids bigint[];
    v_terrain_types integer[];
BEGIN
    -- Get waypoint IDs
    SELECT array_agg(id ORDER BY slug) INTO v_waypoint_ids
    FROM public.waypoints WHERE slug LIKE 'test-%';
    
    -- Get terrain type IDs
    SELECT array_agg(id) INTO v_terrain_types
    FROM public.terrain_types_master
    WHERE code IN ('forest_path', 'dirt_road', 'paved_road');
    
    -- Create segments with 3D LineString geometry
    INSERT INTO public.segments (
        name,
        slug,
        start_waypoint_id,
        end_waypoint_id,
        path_geom,
        dominant_terrain_type_id,
        segment_difficulty,
        sun_exposure_level,
        typical_duration_minutes_forward,
        typical_duration_minutes_backward,
        content_visibility_status,
        created_by_profile_id
    ) VALUES 
        (
            'Test Segment 1',
            'test-segment-1',
            v_waypoint_ids[1],
            v_waypoint_ids[2],
            ST_GeomFromText('LINESTRING Z(11.8797 43.4633 300, 11.8700 43.4500 320, 11.8600 43.4300 340, 11.8500 43.4000 350)', 4326),
            v_terrain_types[1],
            'easy',
            'partial_shade',
            45,
            50,
            'published',
            '11111111-1111-1111-1111-111111111112'
        ),
        (
            'Test Segment 2',
            'test-segment-2',
            v_waypoint_ids[2],
            v_waypoint_ids[3],
            ST_GeomFromText('LINESTRING Z(11.8500 43.4000 350, 11.8400 43.3800 370, 11.8300 43.3600 390, 11.8200 43.3500 400)', 4326),
            v_terrain_types[2],
            'moderate',
            'mostly_exposed',
            60,
            65,
            'published',
            '11111111-1111-1111-1111-111111111112'
        ),
        (
            'Test Segment 3',
            'test-segment-3',
            v_waypoint_ids[3],
            v_waypoint_ids[4],
            ST_GeomFromText('LINESTRING Z(11.8200 43.3500 400, 11.8100 43.3300 350, 11.8000 43.3000 250)', 4326),
            v_terrain_types[3],
            'easy',
            'fully_exposed',
            40,
            45,
            'published',
            '11111111-1111-1111-1111-111111111112'
        )
    RETURNING array_agg(id ORDER BY slug) INTO v_segment_ids;
    
    -- Verify auto-calculations worked
    ASSERT (SELECT distance_km FROM public.segments WHERE slug = 'test-segment-1') > 0,
        'Segment distance should be auto-calculated';
    ASSERT (SELECT elevation_gain_meters FROM public.segments WHERE slug = 'test-segment-2') > 0,
        'Segment elevation gain should be auto-calculated';
    ASSERT (SELECT elevation_profile_data FROM public.segments WHERE slug = 'test-segment-1') IS NOT NULL,
        'Segment elevation profile should be auto-calculated';
    
    RAISE NOTICE 'Test 4 passed: Segments created with auto-calculated properties';
    
    -- Add segments to route
    INSERT INTO public.route_segments (
        route_id,
        segment_id,
        order_in_route,
        contextual_notes_for_segment_in_route
    )
    SELECT 
        :test_route_id,
        id,
        row_number() OVER (ORDER BY slug)::integer,
        'Test note for segment ' || slug
    FROM public.segments
    WHERE slug LIKE 'test-segment-%';
    
    -- Add additional terrain types to a segment
    INSERT INTO public.segment_additional_terrain_types (segment_id, terrain_type_id)
    SELECT v_segment_ids[1], id
    FROM public.terrain_types_master
    WHERE code = 'stream_crossing';
END $$;

-- Test 5: Verify route aggregation
DO $$
DECLARE
    v_route_distance real;
    v_route_gain integer;
    v_route_loss integer;
    v_total_segment_distance real;
BEGIN
    -- Get route aggregates
    SELECT total_distance_km, estimated_total_elevation_gain_meters, estimated_total_elevation_loss_meters
    INTO v_route_distance, v_route_gain, v_route_loss
    FROM public.routes
    WHERE slug = 'test-northern-route';
    
    -- Calculate expected total from segments
    SELECT SUM(s.distance_km)
    INTO v_total_segment_distance
    FROM public.route_segments rs
    JOIN public.segments s ON rs.segment_id = s.id
    WHERE rs.route_id = :test_route_id;
    
    -- Verify aggregates match
    ASSERT v_route_distance = v_total_segment_distance,
        format('Route distance (%s) should match sum of segments (%s)', v_route_distance, v_total_segment_distance);
    ASSERT v_route_gain > 0, 'Route should have elevation gain';
    ASSERT v_route_loss > 0, 'Route should have elevation loss';
    
    RAISE NOTICE 'Test 5 passed: Route aggregation working (distance: % km, gain: % m, loss: % m)', 
        v_route_distance, v_route_gain, v_route_loss;
END $$;

-- Test 6: Test media associations
DO $$
DECLARE
    v_segment_id bigint;
    v_media_id integer;
BEGIN
    -- Get a test segment
    SELECT id INTO v_segment_id FROM public.segments WHERE slug = 'test-segment-1';
    
    -- Create test media if needed
    INSERT INTO public.media (
        storage_bucket,
        file_path,
        file_name,
        mime_type,
        file_size_bytes,
        media_status,
        created_by_profile_id
    ) VALUES (
        'test-bucket',
        'segments/test-hero.jpg',
        'test-hero.jpg',
        'image/jpeg',
        1024000,
        'active',
        '11111111-1111-1111-1111-111111111112'
    ) RETURNING id INTO v_media_id;
    
    -- Associate media with segment
    INSERT INTO public.segment_media (
        segment_id,
        media_id,
        media_role_code,
        display_order,
        caption,
        alt_text
    ) VALUES (
        v_segment_id,
        v_media_id,
        'hero',
        1,
        'Test hero image for segment',
        'Scenic view of the test trail segment'
    );
    
    -- Test invalid media role
    BEGIN
        INSERT INTO public.segment_media (segment_id, media_id, media_role_code, display_order)
        VALUES (v_segment_id, v_media_id, 'invalid_role', 2);
        ASSERT FALSE, 'Should have raised exception for invalid media role';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 6a passed: Invalid media role rejected';
    END;
    
    RAISE NOTICE 'Test 6 passed: Media associations working';
END $$;

-- Test 7: Test RLS policies
DO $$
DECLARE
    trail_count int;
    route_count int;
BEGIN
    -- Switch to anonymous role
    SET LOCAL ROLE anon;
    
    -- Anonymous should see published content
    SELECT COUNT(*) INTO trail_count FROM public.trails WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO route_count FROM public.routes WHERE deleted_at IS NULL;
    
    ASSERT trail_count > 0, 'Anonymous should see published trails';
    ASSERT route_count > 0, 'Anonymous should see published routes';
    
    -- Test that anonymous cannot insert
    BEGIN
        INSERT INTO public.trails (name, slug) VALUES ('test-fail', 'test-fail');
        ASSERT FALSE, 'Anonymous should not be able to insert';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Test 7a passed: Anonymous cannot insert';
    END;
    
    -- Reset to superuser
    SET LOCAL ROLE postgres;
    
    -- Test cascade RLS (route_segments visible based on route visibility)
    UPDATE public.routes SET content_visibility_status = 'draft' WHERE slug = 'test-northern-route';
    
    SET LOCAL ROLE anon;
    ASSERT NOT EXISTS (
        SELECT 1 FROM public.route_segments rs
        JOIN public.routes r ON rs.route_id = r.id
        WHERE r.slug = 'test-northern-route'
    ), 'Anonymous should not see route_segments for draft routes';
    
    SET LOCAL ROLE postgres;
    UPDATE public.routes SET content_visibility_status = 'published' WHERE slug = 'test-northern-route';
    
    RAISE NOTICE 'Test 7 passed: RLS policies working correctly';
END $$;

-- Test 8: Test constraint validations
DO $$
BEGIN
    -- Test same start/end waypoint constraint
    BEGIN
        INSERT INTO public.segments (
            name, start_waypoint_id, end_waypoint_id, path_geom,
            segment_difficulty, content_visibility_status
        )
        SELECT 
            'Invalid segment', id, id, 
            ST_GeomFromText('LINESTRING Z(0 0 0, 1 1 1)', 4326),
            'easy', 'draft'
        FROM public.waypoints LIMIT 1;
        ASSERT FALSE, 'Should not allow same start and end waypoint';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 8a passed: Same waypoint constraint enforced';
    END;
    
    -- Test order_in_route constraint
    BEGIN
        INSERT INTO public.route_segments (route_id, segment_id, order_in_route)
        VALUES (:test_route_id, (SELECT id FROM public.segments LIMIT 1), 0);
        ASSERT FALSE, 'Should not allow order_in_route <= 0';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 8b passed: order_in_route constraint enforced';
    END;
    
    -- Test unique constraints
    BEGIN
        INSERT INTO public.route_segments (route_id, segment_id, order_in_route)
        VALUES (:test_route_id, (SELECT id FROM public.segments WHERE slug = 'test-segment-1'), 1);
        ASSERT FALSE, 'Should not allow duplicate order_in_route';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Test 8c passed: Unique order constraint enforced';
    END;
END $$;

-- Test 9: Test segment geometry calculations
DO $$
DECLARE
    v_segment record;
    v_profile jsonb;
BEGIN
    -- Get a test segment with calculations
    SELECT * INTO v_segment
    FROM public.segments
    WHERE slug = 'test-segment-1';
    
    -- Verify all calculations
    ASSERT v_segment.distance_km > 0, 'Distance should be calculated';
    ASSERT v_segment.elevation_gain_meters >= 0, 'Elevation gain should be calculated';
    ASSERT v_segment.elevation_loss_meters >= 0, 'Elevation loss should be calculated';
    ASSERT v_segment.min_elevation_meters IS NOT NULL, 'Min elevation should be calculated';
    ASSERT v_segment.max_elevation_meters IS NOT NULL, 'Max elevation should be calculated';
    ASSERT v_segment.elevation_profile_data IS NOT NULL, 'Elevation profile should be calculated';
    
    -- Check elevation profile structure
    v_profile := v_segment.elevation_profile_data;
    ASSERT jsonb_array_length(v_profile) >= 2, 'Profile should have at least start and end points';
    ASSERT v_profile->0->>'distance_km' = '0', 'Profile should start at 0 km';
    ASSERT (v_profile->0->>'elevation_m')::numeric > 0, 'Profile should have elevation data';
    
    RAISE NOTICE 'Test 9 passed: Segment geometry calculations verified';
END $$;

-- Test 10: Test translations integration
DO $$
DECLARE
    trail_trans_count int;
BEGIN
    -- Add translations for trail
    INSERT INTO public.translations (
        table_identifier, row_foreign_key, column_identifier,
        language_code, translated_text, translation_status
    ) VALUES 
        ('trails', :test_trail_id::text, 'name', 'it', 'Test Via di Francesco', 'published_live'),
        ('trails', :test_trail_id::text, 'description', 'en', 'A test pilgrimage trail', 'published_live'),
        ('trails', :test_trail_id::text, 'description', 'it', 'Un sentiero di pellegrinaggio di prova', 'published_live');
    
    -- Verify translations exist
    SELECT COUNT(*) INTO trail_trans_count
    FROM public.translations
    WHERE table_identifier = 'trails' 
    AND row_foreign_key = :test_trail_id::text;
    
    ASSERT trail_trans_count >= 3, 'Should have translations for trail';
    RAISE NOTICE 'Test 10 passed: Translations integration working';
END $$;

-- Cleanup test data
DELETE FROM public.segment_media WHERE segment_id IN (SELECT id FROM public.segments WHERE slug LIKE 'test-%');
DELETE FROM public.route_segments WHERE route_id = :test_route_id;
DELETE FROM public.segments WHERE slug LIKE 'test-%';
DELETE FROM public.waypoints WHERE slug LIKE 'test-%';
DELETE FROM public.routes WHERE slug = 'test-northern-route';
DELETE FROM public.trail_regions WHERE trail_id = :test_trail_id;
DELETE FROM public.trail_terrain_types WHERE trail_id = :test_trail_id;
DELETE FROM public.trail_usage_types WHERE trail_id = :test_trail_id;
DELETE FROM public.trails WHERE slug = 'test-via-di-francesco';
DELETE FROM public.media WHERE file_path LIKE 'segments/test-%';
DELETE FROM public.profiles WHERE id = '11111111-1111-1111-1111-111111111112';

-- Final summary
DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Module 2 test suite completed successfully!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- All tables and ENUMs created correctly';
    RAISE NOTICE '- Master data loaded';
    RAISE NOTICE '- Trail hierarchy relationships working';
    RAISE NOTICE '- Segment geometry auto-calculations verified';
    RAISE NOTICE '- Route aggregation triggers working';
    RAISE NOTICE '- Media associations and validations working';
    RAISE NOTICE '- RLS policies enforced correctly';
    RAISE NOTICE '- Constraint validations working';
    RAISE NOTICE '- Translations integration verified';
    RAISE NOTICE '';
    RAISE NOTICE 'Module 2 is ready for use!';
END $$;

ROLLBACK;
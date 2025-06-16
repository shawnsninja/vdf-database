-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 006_test_module_7.sql
-- Description: Test script for Module 7 tables and functionality
-- Version: 1.0
-- =====================================================================================

-- Test runner
DO $$
DECLARE
    v_test_name TEXT;
    v_error_count INTEGER := 0;
    v_total_tests INTEGER := 0;
    v_test_author_id UUID;
    v_test_trail_id BIGINT;
    v_test_segment_id BIGINT;
    v_test_waypoint_id BIGINT;
    v_test_town_id BIGINT;
    v_test_itinerary_id BIGINT;
    v_test_segment_day_id BIGINT;
BEGIN
    -- Initialize test
    RAISE NOTICE '=== Module 7: Curated Itineraries - Test Suite ===';
    RAISE NOTICE 'Starting at: %', clock_timestamp();

    -- Create test data
    -- Create test content creator
    INSERT INTO public.profiles (id, email, username, display_name, roles)
    VALUES 
        ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'test_content_creator@example.com', 'test_content_creator', 'Test Content Creator', ARRAY['pilgrim', 'content_creator'])
    ON CONFLICT (id) DO NOTHING;
    
    v_test_author_id := 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21';

    -- Get test data from existing tables
    SELECT id INTO v_test_trail_id FROM public.trails WHERE deleted_at IS NULL LIMIT 1;
    SELECT id INTO v_test_segment_id FROM public.segments WHERE deleted_at IS NULL LIMIT 1;
    SELECT id INTO v_test_waypoint_id FROM public.waypoints WHERE deleted_at IS NULL LIMIT 1;
    SELECT id INTO v_test_town_id FROM public.towns WHERE deleted_at IS NULL LIMIT 1;

    -- -------------------------------------------------------------------------
    -- Test 1: Master Tables Seed Data
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 1: Master Tables Seed Data';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Check if categories were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.itinerary_categories_master 
            WHERE category_code = 'spiritual_journey'
        ) THEN
            RAISE EXCEPTION 'Itinerary categories not properly seeded';
        END IF;

        -- Check if seasons were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.seasons_master 
            WHERE season_code = 'spring'
        ) THEN
            RAISE EXCEPTION 'Seasons not properly seeded';
        END IF;

        -- Check if difficulty levels were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.trail_difficulty_levels_master 
            WHERE difficulty_code = 'moderate'
        ) THEN
            RAISE EXCEPTION 'Trail difficulty levels not properly seeded';
        END IF;

        -- Check if content statuses were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.content_statuses_master 
            WHERE status_code = 'published'
        ) THEN
            RAISE EXCEPTION 'Content statuses not properly seeded';
        END IF;

        -- Check translations
        IF NOT EXISTS (
            SELECT 1 FROM public.translations 
            WHERE table_identifier = 'itinerary_categories_master' 
            AND row_foreign_key = 'spiritual_journey' 
            AND language_code = 'it'
        ) THEN
            RAISE EXCEPTION 'Master table translations not found';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 2: Create Curated Itinerary
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 2: Create Curated Itinerary';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Insert a test itinerary
        INSERT INTO public.curated_itineraries (
            code, trail_id, default_title, default_subtitle, default_description,
            default_highlights, total_days, total_distance_km, total_elevation_gain_m,
            total_elevation_loss_m, difficulty_level_code, fitness_level_notes,
            author_profile_id, content_status_code
        )
        VALUES (
            'test-7-day-classic', v_test_trail_id, 'Test 7-Day Classic Journey',
            'A wonderful test journey', 'This is a test itinerary for Module 7 testing.',
            ARRAY['Test highlight 1', 'Test highlight 2'], 7, 150.5, 3000,
            2800, 'moderate', 'Good fitness required', v_test_author_id, 'draft'
        )
        RETURNING id INTO v_test_itinerary_id;

        -- Add categories
        INSERT INTO public.curated_itinerary_to_category (curated_itinerary_id, itinerary_category_code)
        VALUES 
            (v_test_itinerary_id, 'spiritual_journey'),
            (v_test_itinerary_id, 'slow_travel');

        -- Add seasons
        INSERT INTO public.curated_itinerary_to_season (curated_itinerary_id, season_code, is_best_season)
        VALUES 
            (v_test_itinerary_id, 'spring', true),
            (v_test_itinerary_id, 'autumn', false);

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 3: Create Itinerary Segments
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 3: Create Itinerary Segments';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Insert test segments for days 1-3
        INSERT INTO public.curated_itinerary_segments (
            curated_itinerary_id, day_number, segment_id, start_waypoint_id,
            end_waypoint_id, start_town_id, end_town_id, default_day_title,
            default_day_description, default_highlights, walking_time_hours,
            distance_km, elevation_gain_m, elevation_loss_m, sort_order
        )
        VALUES 
            (v_test_itinerary_id, 1, v_test_segment_id, v_test_waypoint_id,
             v_test_waypoint_id, v_test_town_id, v_test_town_id, 'Day 1: Starting Out',
             'First day of our test journey', ARRAY['Morning prayer', 'Beautiful views'],
             5.5, 22.3, 450, 320, 1),
            (v_test_itinerary_id, 2, v_test_segment_id, v_test_waypoint_id,
             v_test_waypoint_id, v_test_town_id, v_test_town_id, 'Day 2: Into the Hills',
             'Second day with more elevation', ARRAY['Mountain views', 'Historic chapel'],
             6.0, 24.5, 680, 550, 2),
            (v_test_itinerary_id, 3, v_test_segment_id, v_test_waypoint_id,
             v_test_waypoint_id, v_test_town_id, v_test_town_id, 'Day 3: Valley Walk',
             'Easier day through the valley', ARRAY['River crossing', 'Local market'],
             4.5, 18.7, 250, 380, 3)
        RETURNING id INTO v_test_segment_day_id;

        -- Check if totals were updated
        IF (SELECT total_days FROM public.curated_itineraries WHERE id = v_test_itinerary_id) != 3 THEN
            RAISE EXCEPTION 'Itinerary total_days not updated correctly';
        END IF;

        IF (SELECT total_distance_km FROM public.curated_itineraries WHERE id = v_test_itinerary_id) != 65.5 THEN
            RAISE EXCEPTION 'Itinerary total_distance_km not updated correctly';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 4: Workflow and Publishing
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 4: Workflow and Publishing';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Update status to ready for review
        UPDATE public.curated_itineraries 
        SET content_status_code = 'ready_for_review'
        WHERE id = v_test_itinerary_id;

        -- Simulate approval and publishing
        UPDATE public.curated_itineraries 
        SET 
            content_status_code = 'published',
            published_at = now(),
            is_featured = true,
            featured_order = 1
        WHERE id = v_test_itinerary_id;

        -- Check if it appears in published view
        IF NOT EXISTS (
            SELECT 1 FROM public.view_curated_itineraries_list
            WHERE id = v_test_itinerary_id
        ) THEN
            RAISE EXCEPTION 'Published itinerary not visible in list view';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 5: Localized Views
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 5: Localized Views';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Add Italian translation for test itinerary
        INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
        VALUES 
            ('curated_itineraries', v_test_itinerary_id::text, 'default_title', 'it', 'Viaggio Classico di 7 Giorni di Prova')
        ON CONFLICT DO NOTHING;

        -- Set language to Italian
        PERFORM set_config('app.current_lang', 'it', true);
        
        -- Check if Italian translation is returned
        IF NOT EXISTS (
            SELECT 1 FROM public.view_curated_itinerary_detail 
            WHERE id = v_test_itinerary_id 
            AND localized_title = 'Viaggio Classico di 7 Giorni di Prova'
        ) THEN
            RAISE EXCEPTION 'Italian translation not returned in localized view';
        END IF;

        -- Reset language
        PERFORM set_config('app.current_lang', 'en', true);

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 6: RLS Policies
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 6: RLS Policies';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Test that non-published itinerary is not visible in public views
        UPDATE public.curated_itineraries 
        SET content_status_code = 'draft'
        WHERE id = v_test_itinerary_id;

        IF EXISTS (
            SELECT 1 FROM public.view_curated_itineraries_list
            WHERE id = v_test_itinerary_id
        ) THEN
            RAISE EXCEPTION 'Draft itinerary should not be visible in public list view';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Cleanup
    -- -------------------------------------------------------------------------
    -- Delete test itinerary (cascades to segments and relationships)
    DELETE FROM public.curated_itineraries WHERE id = v_test_itinerary_id;
    
    -- Delete test translations
    DELETE FROM public.translations 
    WHERE table_identifier = 'curated_itineraries' 
    AND row_foreign_key = v_test_itinerary_id::text;

    -- -------------------------------------------------------------------------
    -- Final Summary
    -- -------------------------------------------------------------------------
    RAISE NOTICE '=== Test Summary ===';
    RAISE NOTICE 'Total tests: %', v_total_tests;
    RAISE NOTICE 'Passed: %', v_total_tests - v_error_count;
    RAISE NOTICE 'Failed: %', v_error_count;
    
    IF v_error_count > 0 THEN
        RAISE EXCEPTION 'Module 7 tests failed with % errors', v_error_count;
    ELSE
        RAISE NOTICE 'All Module 7 tests passed successfully!';
    END IF;
END $$;
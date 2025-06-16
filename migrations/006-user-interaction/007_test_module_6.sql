-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 007_test_module_6.sql
-- Description: Test script for Module 6 tables and functionality
-- Version: 1.0
-- =====================================================================================

-- Test runner
DO $$
DECLARE
    v_test_name TEXT;
    v_error_count INTEGER := 0;
    v_total_tests INTEGER := 0;
    v_test_user_id UUID;
    v_test_moderator_id UUID;
    v_test_waypoint_id BIGINT;
    v_test_tip_id BIGINT;
    v_initial_up_votes INTEGER;
    v_initial_down_votes INTEGER;
BEGIN
    -- Initialize test
    RAISE NOTICE '=== Module 6: User Interaction - Test Suite ===';
    RAISE NOTICE 'Starting at: %', clock_timestamp();

    -- Create test data
    -- Create test users
    INSERT INTO public.profiles (id, email, username, display_name, roles)
    VALUES 
        ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'test_user@example.com', 'test_user', 'Test User', ARRAY['pilgrim']),
        ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'test_moderator@example.com', 'test_moderator', 'Test Moderator', ARRAY['pilgrim', 'moderator_platform'])
    ON CONFLICT (id) DO NOTHING;
    
    v_test_user_id := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
    v_test_moderator_id := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';

    -- Get a test waypoint (use first active one)
    SELECT id INTO v_test_waypoint_id 
    FROM public.waypoints 
    WHERE deleted_at IS NULL 
    LIMIT 1;
    
    IF v_test_waypoint_id IS NULL THEN
        RAISE EXCEPTION 'No waypoints found for testing';
    END IF;

    -- -------------------------------------------------------------------------
    -- Test 1: Tip Categories Master Table
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 1: Tip Categories Master Table';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Check if categories were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.tip_categories_master 
            WHERE category_code = 'practical_advice'
        ) THEN
            RAISE EXCEPTION 'Tip categories not properly seeded';
        END IF;

        -- Check translations
        IF NOT EXISTS (
            SELECT 1 FROM public.translations 
            WHERE table_identifier = 'tip_categories_master' 
            AND row_foreign_key = 'practical_advice' 
            AND language_code = 'it'
        ) THEN
            RAISE EXCEPTION 'Tip category translations not found';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 2: User Waypoint Votes - Insert and Update Counts
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 2: User Waypoint Votes - Insert and Update Counts';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Get initial vote counts
        SELECT up_vote_count, down_vote_count 
        INTO v_initial_up_votes, v_initial_down_votes
        FROM public.waypoints 
        WHERE id = v_test_waypoint_id;

        -- Insert an up vote
        INSERT INTO public.user_waypoint_votes (profile_id, waypoint_id, vote_type)
        VALUES (v_test_user_id, v_test_waypoint_id, 'up');

        -- Check if count increased
        IF (SELECT up_vote_count FROM public.waypoints WHERE id = v_test_waypoint_id) 
           != v_initial_up_votes + 1 THEN
            RAISE EXCEPTION 'Up vote count not updated correctly';
        END IF;

        -- Change vote to down
        UPDATE public.user_waypoint_votes 
        SET vote_type = 'down', updated_at = now()
        WHERE profile_id = v_test_user_id AND waypoint_id = v_test_waypoint_id;

        -- Check if counts updated correctly
        IF (SELECT up_vote_count FROM public.waypoints WHERE id = v_test_waypoint_id) 
           != v_initial_up_votes THEN
            RAISE EXCEPTION 'Up vote count not decremented after vote change';
        END IF;

        IF (SELECT down_vote_count FROM public.waypoints WHERE id = v_test_waypoint_id) 
           != v_initial_down_votes + 1 THEN
            RAISE EXCEPTION 'Down vote count not incremented after vote change';
        END IF;

        -- Soft delete the vote
        UPDATE public.user_waypoint_votes 
        SET deleted_at = now()
        WHERE profile_id = v_test_user_id AND waypoint_id = v_test_waypoint_id;

        -- Check if count decreased
        IF (SELECT down_vote_count FROM public.waypoints WHERE id = v_test_waypoint_id) 
           != v_initial_down_votes THEN
            RAISE EXCEPTION 'Down vote count not decremented after soft delete';
        END IF;

        -- Clean up
        DELETE FROM public.user_waypoint_votes 
        WHERE profile_id = v_test_user_id AND waypoint_id = v_test_waypoint_id;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 3: User Waypoint Short Tips - Moderation Workflow
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 3: User Waypoint Short Tips - Moderation Workflow';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Insert a tip
        INSERT INTO public.user_waypoint_short_tips 
            (profile_id, waypoint_id, tip_text, language_code, tip_category_code)
        VALUES 
            (v_test_user_id, v_test_waypoint_id, 'Great place to rest!', 'en', 'practical_advice')
        RETURNING id INTO v_test_tip_id;

        -- Check if tip is not publicly visible (pending approval)
        IF (SELECT is_publicly_visible FROM public.user_waypoint_short_tips WHERE id = v_test_tip_id) THEN
            RAISE EXCEPTION 'New tip should not be publicly visible';
        END IF;

        -- Approve the tip as moderator
        UPDATE public.user_waypoint_short_tips 
        SET 
            moderation_status = 'approved_visible',
            moderated_by_profile_id = v_test_moderator_id,
            moderation_timestamp = now()
        WHERE id = v_test_tip_id;

        -- Check if tip is now publicly visible
        IF NOT (SELECT is_publicly_visible FROM public.user_waypoint_short_tips WHERE id = v_test_tip_id) THEN
            RAISE EXCEPTION 'Approved tip should be publicly visible';
        END IF;

        -- Clean up
        DELETE FROM public.user_waypoint_short_tips WHERE id = v_test_tip_id;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 4: Localized Views
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 4: Localized Views';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Set language to Italian
        PERFORM set_config('app.current_lang', 'it', true);
        
        -- Check if Italian translation is returned
        IF NOT EXISTS (
            SELECT 1 FROM public.view_tip_categories_localized 
            WHERE category_code = 'practical_advice' 
            AND localized_name = 'Consigli Pratici'
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
    -- Test 5: RLS Policies
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 5: RLS Policies';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Test moderator check function
        IF NOT public.check_if_user_is_moderator(v_test_moderator_id) THEN
            RAISE EXCEPTION 'Moderator check function failed for moderator user';
        END IF;

        IF public.check_if_user_is_moderator(v_test_user_id) THEN
            RAISE EXCEPTION 'Moderator check function should return false for regular user';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 6: Character Length Constraint
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 6: Character Length Constraint';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Try to insert a tip that's too long
        BEGIN
            INSERT INTO public.user_waypoint_short_tips 
                (profile_id, waypoint_id, tip_text, language_code)
            VALUES 
                (v_test_user_id, v_test_waypoint_id, REPEAT('A', 501), 'en');
            
            RAISE EXCEPTION 'Should not allow tips longer than 500 characters';
        EXCEPTION
            WHEN check_violation THEN
                -- This is expected
                NULL;
        END;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Final Summary
    -- -------------------------------------------------------------------------
    RAISE NOTICE '=== Test Summary ===';
    RAISE NOTICE 'Total tests: %', v_total_tests;
    RAISE NOTICE 'Passed: %', v_total_tests - v_error_count;
    RAISE NOTICE 'Failed: %', v_error_count;
    
    IF v_error_count > 0 THEN
        RAISE EXCEPTION 'Module 6 tests failed with % errors', v_error_count;
    ELSE
        RAISE NOTICE 'All Module 6 tests passed successfully!';
    END IF;
END $$;
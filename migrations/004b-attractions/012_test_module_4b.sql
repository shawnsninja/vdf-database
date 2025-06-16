-- Module 4b: Attractions - Test Suite
-- 012_test_module_4b.sql: Comprehensive tests for Module 4b attractions functionality
-- 
-- Purpose: Test all Module 4b tables, functions, triggers, and constraints

-- Test runner setup
DO $$
DECLARE
    test_count INTEGER := 0;
    passed_count INTEGER := 0;
    failed_count INTEGER := 0;
    test_name TEXT;
    error_message TEXT;
BEGIN
    RAISE NOTICE 'Starting Module 4b (Attractions) Test Suite';
    RAISE NOTICE '================================================';

    -- Test 1: Verify all master tables exist and have data
    test_count := test_count + 1;
    test_name := 'Master tables existence and seed data';
    BEGIN
        ASSERT (SELECT COUNT(*) FROM public.attraction_types_master WHERE is_active = true) >= 15,
            'Should have at least 15 active attraction types';
        ASSERT (SELECT COUNT(*) FROM public.visitor_amenities_master WHERE is_active = true) >= 30,
            'Should have at least 30 active visitor amenities';
        ASSERT (SELECT COUNT(*) FROM public.religious_service_types_master WHERE is_active = true) >= 14,
            'Should have at least 14 active religious service types';
        ASSERT (SELECT COUNT(*) FROM public.food_water_source_types_master WHERE is_active = true) >= 12,
            'Should have at least 12 active food/water source types';
        ASSERT (SELECT COUNT(*) FROM public.water_reliability_types_master WHERE is_active = true) >= 8,
            'Should have at least 8 active water reliability types';
        ASSERT (SELECT COUNT(*) FROM public.shop_service_types_master WHERE is_active = true) >= 30,
            'Should have at least 30 active shop/service types';
        ASSERT (SELECT COUNT(*) FROM public.establishment_price_ranges_master WHERE is_active = true) >= 6,
            'Should have at least 6 active price ranges';
        ASSERT (SELECT COUNT(*) FROM public.meal_type_tags_master WHERE is_active = true) >= 12,
            'Should have at least 12 active meal types';
        ASSERT (SELECT COUNT(*) FROM public.dietary_option_tags_master WHERE is_active = true) >= 15,
            'Should have at least 15 active dietary options';
        ASSERT (SELECT COUNT(*) FROM public.payment_methods_master WHERE is_active = true) >= 17,
            'Should have at least 17 active payment methods';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 2: Verify additional master table fields exist
    test_count := test_count + 1;
    test_name := 'Additional master table fields';
    BEGIN
        ASSERT (SELECT COUNT(*) FROM information_schema.columns 
                WHERE table_name = 'food_water_source_types_master' AND column_name = 'is_commercial') = 1,
            'food_water_source_types_master should have is_commercial field';
        ASSERT (SELECT COUNT(*) FROM information_schema.columns 
                WHERE table_name = 'water_reliability_types_master' AND column_name = 'advisory_level') = 1,
            'water_reliability_types_master should have advisory_level field';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 3: Test attraction details table functionality
    test_count := test_count + 1;
    test_name := 'Attraction details table operations';
    BEGIN
        -- This test requires an existing waypoint and master data
        IF EXISTS (SELECT 1 FROM public.waypoints LIMIT 1) AND 
           EXISTS (SELECT 1 FROM public.attraction_types_master WHERE is_active = true LIMIT 1) THEN
            
            DECLARE
                test_waypoint_id BIGINT;
                test_attraction_type_id INTEGER;
                test_amenity_ids INTEGER[];
            BEGIN
                SELECT id INTO test_waypoint_id FROM public.waypoints LIMIT 1;
                SELECT id INTO test_attraction_type_id FROM public.attraction_types_master WHERE is_active = true LIMIT 1;
                SELECT ARRAY[id] INTO test_amenity_ids FROM public.visitor_amenities_master WHERE is_active = true LIMIT 1;
                
                -- Insert test attraction details
                INSERT INTO public.attraction_details (
                    id, attraction_type_id, visitor_amenity_ids, 
                    entry_fee_eur, pilgrim_discount_available,
                    wheelchair_accessible, data_confidence_score
                ) VALUES (
                    test_waypoint_id, test_attraction_type_id, test_amenity_ids,
                    15.50, true, true, 85
                );
                
                -- Verify data was inserted correctly
                ASSERT EXISTS (SELECT 1 FROM public.attraction_details WHERE id = test_waypoint_id),
                    'Attraction details should be inserted';
                
                -- Test update trigger
                UPDATE public.attraction_details SET entry_fee_eur = 18.00 WHERE id = test_waypoint_id;
                ASSERT (SELECT updated_at > created_at FROM public.attraction_details WHERE id = test_waypoint_id),
                    'Updated timestamp should be greater than created timestamp';
                
                -- Cleanup
                DELETE FROM public.attraction_details WHERE id = test_waypoint_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 4: Test shops and services details table
    test_count := test_count + 1;
    test_name := 'Shops and services details table operations';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.waypoints LIMIT 1) AND 
           EXISTS (SELECT 1 FROM public.shop_service_types_master WHERE is_active = true LIMIT 1) THEN
            
            DECLARE
                test_waypoint_id BIGINT;
                test_shop_type_ids INTEGER[];
                test_payment_method_ids INTEGER[];
            BEGIN
                SELECT id INTO test_waypoint_id FROM public.waypoints LIMIT 1;
                SELECT ARRAY[id] INTO test_shop_type_ids FROM public.shop_service_types_master WHERE is_active = true LIMIT 1;
                SELECT ARRAY[id] INTO test_payment_method_ids FROM public.payment_methods_master WHERE is_active = true LIMIT 1;
                
                -- Insert test shops and services details
                INSERT INTO public.shops_and_services_details (
                    id, shop_service_type_ids, payment_method_ids,
                    accepts_credit_cards, pilgrim_discount_available,
                    wheelchair_accessible, overall_rating
                ) VALUES (
                    test_waypoint_id, test_shop_type_ids, test_payment_method_ids,
                    true, true, true, 4.5
                );
                
                -- Verify data was inserted correctly
                ASSERT EXISTS (SELECT 1 FROM public.shops_and_services_details WHERE id = test_waypoint_id),
                    'Shops and services details should be inserted';
                
                -- Cleanup
                DELETE FROM public.shops_and_services_details WHERE id = test_waypoint_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 5: Test food water sources details table
    test_count := test_count + 1;
    test_name := 'Food water sources details table operations';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.waypoints LIMIT 1) AND 
           EXISTS (SELECT 1 FROM public.food_water_source_types_master WHERE is_active = true LIMIT 1) THEN
            
            DECLARE
                test_waypoint_id BIGINT;
                test_source_type_ids INTEGER[];
                test_reliability_id INTEGER;
            BEGIN
                SELECT id INTO test_waypoint_id FROM public.waypoints LIMIT 1;
                SELECT ARRAY[id] INTO test_source_type_ids FROM public.food_water_source_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_reliability_id FROM public.water_reliability_types_master WHERE is_active = true LIMIT 1;
                
                -- Insert test food water sources details
                INSERT INTO public.food_water_sources_details (
                    id, source_type_ids, water_reliability_type_id,
                    is_potable_water, always_available, free_access,
                    bottle_filling_friendly, data_confidence_score
                ) VALUES (
                    test_waypoint_id, test_source_type_ids, test_reliability_id,
                    true, true, true, true, 90
                );
                
                -- Verify data was inserted correctly
                ASSERT EXISTS (SELECT 1 FROM public.food_water_sources_details WHERE id = test_waypoint_id),
                    'Food water sources details should be inserted';
                
                -- Cleanup
                DELETE FROM public.food_water_sources_details WHERE id = test_waypoint_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 6: Test array foreign key validation triggers
    test_count := test_count + 1;
    test_name := 'Array foreign key validation triggers';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.waypoints LIMIT 1) THEN
            DECLARE
                test_waypoint_id BIGINT;
                invalid_ids INTEGER[] := ARRAY[99999, 99998];
            BEGIN
                SELECT id INTO test_waypoint_id FROM public.waypoints LIMIT 1;
                
                -- Test invalid shop service type IDs should fail
                BEGIN
                    INSERT INTO public.shops_and_services_details (
                        id, shop_service_type_ids, accepts_credit_cards
                    ) VALUES (
                        test_waypoint_id, invalid_ids, true
                    );
                    RAISE EXCEPTION 'Should have failed with invalid shop service type IDs';
                EXCEPTION WHEN foreign_key_violation THEN
                    -- Expected behavior
                    NULL;
                END;
                
                -- Test invalid payment method IDs should fail
                BEGIN
                    INSERT INTO public.shops_and_services_details (
                        id, shop_service_type_ids, payment_method_ids, accepts_credit_cards
                    ) VALUES (
                        test_waypoint_id, ARRAY[1], invalid_ids, true
                    );
                    RAISE EXCEPTION 'Should have failed with invalid payment method IDs';
                EXCEPTION WHEN foreign_key_violation THEN
                    -- Expected behavior
                    NULL;
                END;
                
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 7: Test religious service schedules
    test_count := test_count + 1;
    test_name := 'Religious service schedules functionality';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.attraction_details LIMIT 1) AND 
           EXISTS (SELECT 1 FROM public.religious_service_types_master WHERE is_active = true LIMIT 1) THEN
            
            DECLARE
                test_attraction_id BIGINT;
                test_service_type_id INTEGER;
                test_schedule_id BIGINT;
            BEGIN
                SELECT id INTO test_attraction_id FROM public.attraction_details LIMIT 1;
                SELECT id INTO test_service_type_id FROM public.religious_service_types_master WHERE is_active = true LIMIT 1;
                
                -- Insert test religious service schedule
                INSERT INTO public.religious_service_schedules (
                    attraction_id, service_type_id, day_of_week, 
                    service_time, duration_minutes, is_regular_service
                ) VALUES (
                    test_attraction_id, test_service_type_id, 0, -- Sunday
                    '10:00'::TIME, 60, true
                ) RETURNING id INTO test_schedule_id;
                
                -- Verify data was inserted correctly
                ASSERT EXISTS (SELECT 1 FROM public.religious_service_schedules WHERE id = test_schedule_id),
                    'Religious service schedule should be inserted';
                
                -- Cleanup
                DELETE FROM public.religious_service_schedules WHERE id = test_schedule_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 8: Test localized views exist and function
    test_count := test_count + 1;
    test_name := 'Localized views functionality';
    BEGIN
        -- Test that all localized views exist and can be queried
        PERFORM COUNT(*) FROM public.v_waypoint_attraction_details_localized;
        PERFORM COUNT(*) FROM public.v_waypoint_food_water_sources_localized;
        PERFORM COUNT(*) FROM public.v_waypoint_shops_services_localized;
        PERFORM COUNT(*) FROM public.v_religious_service_schedules_localized;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 9: Test media linking tables exist and function
    test_count := test_count + 1;
    test_name := 'Media linking tables functionality';
    BEGIN
        -- Verify all media linking tables exist
        ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'attraction_details_media'),
            'attraction_details_media table should exist';
        ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'food_water_sources_media'),
            'food_water_sources_media table should exist';
        ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'shops_and_services_media'),
            'shops_and_services_media table should exist';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 10: Test RLS policies exist
    test_count := test_count + 1;
    test_name := 'Row Level Security policies';
    BEGIN
        -- Check that RLS is enabled and policies exist for key tables
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'attraction_details') >= 4,
            'attraction_details should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'shops_and_services_details') >= 4,
            'shops_and_services_details should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'food_water_sources_details') >= 4,
            'food_water_sources_details should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'religious_service_schedules') >= 4,
            'religious_service_schedules should have at least 4 RLS policies';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test Summary
    RAISE NOTICE '';
    RAISE NOTICE 'Module 4b Test Suite Results:';
    RAISE NOTICE '============================';
    RAISE NOTICE 'Total Tests: %', test_count;
    RAISE NOTICE 'Passed: %', passed_count;
    RAISE NOTICE 'Failed: %', failed_count;
    
    IF failed_count > 0 THEN
        RAISE NOTICE 'SUCCESS RATE: %% (% failures)', 
            ROUND((passed_count::NUMERIC / test_count::NUMERIC) * 100, 1), failed_count;
        RAISE WARNING 'Module 4b tests completed with % failures', failed_count;
    ELSE
        RAISE NOTICE 'SUCCESS RATE: 100%% (All tests passed!)';
        RAISE NOTICE 'Module 4b tests completed successfully!';
    END IF;
END $$;
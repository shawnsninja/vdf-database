-- Module 5: Dynamic Conditions - Test Suite
-- 005_test_module_5.sql: Comprehensive tests for Module 5 dynamic conditions functionality
-- 
-- Purpose: Test all Module 5 tables, functions, triggers, constraints, and views

-- Test runner setup
DO $$
DECLARE
    test_count INTEGER := 0;
    passed_count INTEGER := 0;
    failed_count INTEGER := 0;
    test_name TEXT;
    error_message TEXT;
BEGIN
    RAISE NOTICE 'Starting Module 5 (Dynamic Conditions) Test Suite';
    RAISE NOTICE '====================================================';

    -- Test 1: Verify all master tables exist with expected data
    test_count := test_count + 1;
    test_name := 'Master tables existence and seed data';
    BEGIN
        ASSERT (SELECT COUNT(*) FROM public.warning_types_master WHERE is_active = true) >= 15,
            'Should have at least 15 active warning types';
        ASSERT (SELECT COUNT(*) FROM public.warning_severities_master WHERE is_active = true) >= 6,
            'Should have at least 6 active warning severities';
        ASSERT (SELECT COUNT(*) FROM public.warning_source_types_master WHERE is_active = true) >= 12,
            'Should have at least 12 active warning source types';
        ASSERT (SELECT COUNT(*) FROM public.workflow_statuses_master WHERE is_active = true) >= 12,
            'Should have at least 12 active workflow statuses';
        
        -- Test foreign key relationship between warning types and severities
        ASSERT EXISTS (SELECT 1 FROM public.warning_types_master wt 
                      JOIN public.warning_severities_master ws ON wt.default_severity_id = ws.id),
            'Warning types should have valid default severity references';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 2: Test segment warnings table functionality
    test_count := test_count + 1;
    test_name := 'Segment warnings table operations';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.segments LIMIT 1) THEN
            DECLARE
                test_segment_id BIGINT;
                test_warning_id BIGINT;
                test_warning_type_id INTEGER;
                test_severity_id INTEGER;
                test_source_type_id INTEGER;
                test_workflow_status_id INTEGER;
            BEGIN
                -- Get test data
                SELECT id INTO test_segment_id FROM public.segments LIMIT 1;
                SELECT id INTO test_warning_type_id FROM public.warning_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_severity_id FROM public.warning_severities_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_source_type_id FROM public.warning_source_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_workflow_status_id FROM public.workflow_statuses_master WHERE is_active = true LIMIT 1;
                
                -- Insert test warning
                INSERT INTO public.segment_warnings (
                    segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                    title, description,
                    date_warning_effective_from, date_warning_expected_resolution,
                    affects_entire_segment, safety_impact_level, accessibility_impact_level
                ) VALUES (
                    test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                    'Test Warning', 'This is a test warning description for validation purposes.',
                    NOW(), NOW() + INTERVAL '7 days',
                    false, 3, 2
                ) RETURNING id INTO test_warning_id;
                
                -- Verify data was inserted correctly
                ASSERT EXISTS (SELECT 1 FROM public.segment_warnings WHERE id = test_warning_id),
                    'Segment warning should be inserted';
                
                -- Test computed column for active status
                ASSERT (SELECT is_currently_active FROM public.segment_warnings WHERE id = test_warning_id) = true,
                    'Warning should be currently active based on date range';
                
                -- Test update trigger
                UPDATE public.segment_warnings SET title = 'Updated Test Warning' WHERE id = test_warning_id;
                ASSERT (SELECT updated_at > created_at FROM public.segment_warnings WHERE id = test_warning_id),
                    'Updated timestamp should be greater than created timestamp';
                
                -- Test resolving warning (should make it inactive)
                UPDATE public.segment_warnings SET date_warning_resolved_or_expired = NOW() WHERE id = test_warning_id;
                ASSERT (SELECT is_currently_active FROM public.segment_warnings WHERE id = test_warning_id) = false,
                    'Warning should become inactive when resolved';
                
                -- Cleanup
                DELETE FROM public.segment_warnings WHERE id = test_warning_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 3: Test PostGIS geometry functionality
    test_count := test_count + 1;
    test_name := 'PostGIS geometry support';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.segments LIMIT 1) THEN
            DECLARE
                test_segment_id BIGINT;
                test_warning_id BIGINT;
                test_point GEOMETRY(PointZ, 4326);
                test_warning_type_id INTEGER;
                test_severity_id INTEGER;
                test_source_type_id INTEGER;
                test_workflow_status_id INTEGER;
            BEGIN
                -- Get test data
                SELECT id INTO test_segment_id FROM public.segments LIMIT 1;
                SELECT id INTO test_warning_type_id FROM public.warning_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_severity_id FROM public.warning_severities_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_source_type_id FROM public.warning_source_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_workflow_status_id FROM public.workflow_statuses_master WHERE is_active = true LIMIT 1;
                
                -- Create test 3D point
                test_point := ST_SetSRID(ST_MakePoint(12.123456, 43.123456, 850.5), 4326);
                
                -- Insert warning with geometry
                INSERT INTO public.segment_warnings (
                    segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                    title, description,
                    location_on_segment_geom, location_description,
                    affects_entire_segment
                ) VALUES (
                    test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                    'Geometry Test Warning', 'Warning with 3D location geometry.',
                    test_point, 'Test location on segment',
                    false
                ) RETURNING id INTO test_warning_id;
                
                -- Verify geometry was stored correctly
                ASSERT (SELECT ST_CoordDim(location_on_segment_geom) FROM public.segment_warnings WHERE id = test_warning_id) = 3,
                    'Geometry should be 3D (PointZ)';
                ASSERT (SELECT ST_SRID(location_on_segment_geom) FROM public.segment_warnings WHERE id = test_warning_id) = 4326,
                    'Geometry should have SRID 4326';
                ASSERT (SELECT ST_Z(location_on_segment_geom) FROM public.segment_warnings WHERE id = test_warning_id) = 850.5,
                    'Geometry should preserve elevation value';
                
                -- Cleanup
                DELETE FROM public.segment_warnings WHERE id = test_warning_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 4: Test constraint validations
    test_count := test_count + 1;
    test_name := 'Constraint validations';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.segments LIMIT 1) THEN
            DECLARE
                test_segment_id BIGINT;
                test_warning_type_id INTEGER;
                test_severity_id INTEGER;
                test_source_type_id INTEGER;
                test_workflow_status_id INTEGER;
            BEGIN
                -- Get test data
                SELECT id INTO test_segment_id FROM public.segments LIMIT 1;
                SELECT id INTO test_warning_type_id FROM public.warning_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_severity_id FROM public.warning_severities_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_source_type_id FROM public.warning_source_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_workflow_status_id FROM public.workflow_statuses_master WHERE is_active = true LIMIT 1;
                
                -- Test title length constraint (should fail with title too short)
                BEGIN
                    INSERT INTO public.segment_warnings (
                        segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                        title, description
                    ) VALUES (
                        test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                        'Hi', 'This title is too short and should fail validation.'
                    );
                    RAISE EXCEPTION 'Should have failed with title too short';
                EXCEPTION WHEN check_violation THEN
                    -- Expected behavior
                    NULL;
                END;
                
                -- Test safety impact level constraint (should fail with invalid range)
                BEGIN
                    INSERT INTO public.segment_warnings (
                        segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                        title, description, safety_impact_level
                    ) VALUES (
                        test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                        'Valid Title', 'Valid description with at least ten characters.',
                        15  -- Invalid impact level > 10
                    );
                    RAISE EXCEPTION 'Should have failed with invalid safety impact level';
                EXCEPTION WHEN check_violation THEN
                    -- Expected behavior
                    NULL;
                END;
                
                -- Test URL format constraint (should fail with invalid URL)
                BEGIN
                    INSERT INTO public.segment_warnings (
                        segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                        title, description, source_reference_url
                    ) VALUES (
                        test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                        'Valid Title', 'Valid description with at least ten characters.',
                        'invalid-url-format'
                    );
                    RAISE EXCEPTION 'Should have failed with invalid URL format';
                EXCEPTION WHEN check_violation THEN
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

    -- Test 5: Test localized views functionality
    test_count := test_count + 1;
    test_name := 'Localized views functionality';
    BEGIN
        -- Test that all localized views exist and can be queried
        PERFORM COUNT(*) FROM public.v_segment_warnings_localized;
        PERFORM COUNT(*) FROM public.v_public_active_segment_warnings;
        PERFORM COUNT(*) FROM public.v_segment_warnings_summary;
        PERFORM COUNT(*) FROM public.v_segment_warnings_geographic;
        
        -- Test that views have expected columns
        ASSERT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'v_segment_warnings_localized' 
                      AND column_name = 'warning_type_label'),
            'Localized view should have warning_type_label column';
        ASSERT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'v_public_active_segment_warnings' 
                      AND column_name = 'severity_color'),
            'Public view should have severity_color column';
        ASSERT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'v_segment_warnings_summary' 
                      AND column_name = 'active_warnings'),
            'Summary view should have active_warnings column';
        ASSERT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'v_segment_warnings_geographic' 
                      AND column_name = 'segment_geometry'),
            'Geographic view should have segment_geometry column';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 6: Test RLS policies exist and function
    test_count := test_count + 1;
    test_name := 'Row Level Security policies';
    BEGIN
        -- Check that RLS is enabled and policies exist for key tables
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'segment_warnings') >= 4,
            'segment_warnings should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'warning_types_master') >= 4,
            'warning_types_master should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'warning_severities_master') >= 4,
            'warning_severities_master should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'warning_source_types_master') >= 4,
            'warning_source_types_master should have at least 4 RLS policies';
        ASSERT (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'workflow_statuses_master') >= 4,
            'workflow_statuses_master should have at least 4 RLS policies';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 7: Test master table data quality
    test_count := test_count + 1;
    test_name := 'Master table data quality';
    BEGIN
        -- Check that severity levels are properly distributed
        ASSERT (SELECT COUNT(*) FROM public.warning_severities_master 
                WHERE urgency_level >= 8) >= 2,
            'Should have at least 2 high urgency severity levels';
        ASSERT (SELECT COUNT(*) FROM public.warning_severities_master 
                WHERE urgency_level <= 3) >= 2,
            'Should have at least 2 low urgency severity levels';
        
        -- Check that source types have proper reliability scores
        ASSERT (SELECT COUNT(*) FROM public.warning_source_types_master 
                WHERE reliability_score >= 9) >= 2,
            'Should have at least 2 high reliability source types';
        ASSERT (SELECT COUNT(*) FROM public.warning_source_types_master 
                WHERE requires_verification = true) >= 5,
            'Should have at least 5 source types requiring verification';
        
        -- Check that workflow statuses cover key states
        ASSERT EXISTS (SELECT 1 FROM public.workflow_statuses_master 
                      WHERE is_draft_status = true AND is_active = true),
            'Should have at least one draft status';
        ASSERT EXISTS (SELECT 1 FROM public.workflow_statuses_master 
                      WHERE is_published_status = true AND is_active = true),
            'Should have at least one published status';
        ASSERT EXISTS (SELECT 1 FROM public.workflow_statuses_master 
                      WHERE is_archived_status = true AND is_active = true),
            'Should have at least one archived status';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 8: Test indexes exist for performance
    test_count := test_count + 1;
    test_name := 'Performance indexes';
    BEGIN
        -- Check key indexes exist
        ASSERT EXISTS (SELECT 1 FROM pg_indexes 
                      WHERE tablename = 'segment_warnings' 
                      AND indexname LIKE '%currently_active%'),
            'Should have index on is_currently_active';
        ASSERT EXISTS (SELECT 1 FROM pg_indexes 
                      WHERE tablename = 'segment_warnings' 
                      AND indexname LIKE '%segment_id%'),
            'Should have index on segment_id';
        ASSERT EXISTS (SELECT 1 FROM pg_indexes 
                      WHERE tablename = 'segment_warnings' 
                      AND indexname LIKE '%location_gist%'),
            'Should have spatial GIST index on location geometry';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 9: Test workflow status logic
    test_count := test_count + 1;
    test_name := 'Workflow status logic';
    BEGIN
        -- Test that published statuses allow public access
        ASSERT NOT EXISTS (SELECT 1 FROM public.workflow_statuses_master 
                          WHERE is_published_status = true 
                          AND allows_public_access = false
                          AND is_active = true),
            'Published statuses should allow public access';
        
        -- Test that draft statuses are not publicly visible
        ASSERT NOT EXISTS (SELECT 1 FROM public.workflow_statuses_master 
                          WHERE is_draft_status = true 
                          AND is_publicly_visible = true
                          AND is_active = true),
            'Draft statuses should not be publicly visible';
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test 10: Test supporting media array functionality
    test_count := test_count + 1;
    test_name := 'Supporting media array functionality';
    BEGIN
        IF EXISTS (SELECT 1 FROM public.segments LIMIT 1) AND 
           EXISTS (SELECT 1 FROM public.media LIMIT 2) THEN
            DECLARE
                test_segment_id BIGINT;
                test_warning_id BIGINT;
                test_media_ids BIGINT[];
                test_warning_type_id INTEGER;
                test_severity_id INTEGER;
                test_source_type_id INTEGER;
                test_workflow_status_id INTEGER;
            BEGIN
                -- Get test data
                SELECT id INTO test_segment_id FROM public.segments LIMIT 1;
                SELECT ARRAY(SELECT id FROM public.media LIMIT 2) INTO test_media_ids;
                SELECT id INTO test_warning_type_id FROM public.warning_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_severity_id FROM public.warning_severities_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_source_type_id FROM public.warning_source_types_master WHERE is_active = true LIMIT 1;
                SELECT id INTO test_workflow_status_id FROM public.workflow_statuses_master WHERE is_active = true LIMIT 1;
                
                -- Insert warning with supporting media array
                INSERT INTO public.segment_warnings (
                    segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
                    title, description, supporting_media_ids
                ) VALUES (
                    test_segment_id, test_warning_type_id, test_severity_id, test_source_type_id, test_workflow_status_id,
                    'Media Array Test', 'Testing supporting media array functionality.',
                    test_media_ids
                ) RETURNING id INTO test_warning_id;
                
                -- Verify array was stored correctly
                ASSERT (SELECT array_length(supporting_media_ids, 1) FROM public.segment_warnings WHERE id = test_warning_id) >= 1,
                    'Supporting media array should have at least one element';
                
                -- Cleanup
                DELETE FROM public.segment_warnings WHERE id = test_warning_id;
            END;
        END IF;
        
        passed_count := passed_count + 1;
        RAISE NOTICE 'PASS: %', test_name;
    EXCEPTION WHEN OTHERS THEN
        failed_count := failed_count + 1;
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'FAIL: % - %', test_name, error_message;
    END;

    -- Test Summary
    RAISE NOTICE '';
    RAISE NOTICE 'Module 5 Test Suite Results:';
    RAISE NOTICE '============================';
    RAISE NOTICE 'Total Tests: %', test_count;
    RAISE NOTICE 'Passed: %', passed_count;
    RAISE NOTICE 'Failed: %', failed_count;
    
    IF failed_count > 0 THEN
        RAISE NOTICE 'SUCCESS RATE: %% (% failures)', 
            ROUND((passed_count::NUMERIC / test_count::NUMERIC) * 100, 1), failed_count;
        RAISE WARNING 'Module 5 tests completed with % failures', failed_count;
    ELSE
        RAISE NOTICE 'SUCCESS RATE: 100%% (All tests passed!)';
        RAISE NOTICE 'Module 5 tests completed successfully!';
    END IF;
END $$;
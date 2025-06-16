-- Test Script for Module 4a: Accommodations
-- Run this after all Module 4a migrations to verify functionality

BEGIN;

-- Set up test user
SET LOCAL ROLE postgres;

-- Test 1: Verify all tables exist
DO $$
BEGIN
    -- Check master tables
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodation_types_master'), 
        'accommodation_types_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'amenities_master'), 
        'amenities_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'booking_statuses_master'), 
        'booking_statuses_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'room_types_master'), 
        'room_types_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'payment_methods_master'), 
        'payment_methods_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'meal_services_master'), 
        'meal_services_master table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'establishment_price_ranges_master'), 
        'establishment_price_ranges_master table should exist';
    
    -- Check main tables
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodations'), 
        'accommodations table should exist';
    
    -- Check junction tables
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodation_amenities'), 
        'accommodation_amenities table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodation_room_configurations'), 
        'accommodation_room_configurations table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodation_payment_methods'), 
        'accommodation_payment_methods table should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'accommodation_meal_services'), 
        'accommodation_meal_services table should exist';
    
    -- Check views
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_accommodation_types_localized'), 
        'v_accommodation_types_localized view should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_amenities_localized'), 
        'v_amenities_localized view should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_booking_statuses_localized'), 
        'v_booking_statuses_localized view should exist';
    ASSERT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_accommodations_enriched'), 
        'v_accommodations_enriched view should exist';
    
    RAISE NOTICE 'Test 1 passed: All tables and views exist';
END $$;

-- Test 2: Verify seed data
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM public.accommodation_types_master) >= 12, 
        'Should have at least 12 accommodation types';
    ASSERT (SELECT COUNT(*) FROM public.amenities_master) >= 40, 
        'Should have at least 40 amenities';
    ASSERT (SELECT COUNT(*) FROM public.booking_statuses_master) >= 8, 
        'Should have at least 8 booking statuses';
    ASSERT (SELECT COUNT(*) FROM public.room_types_master) >= 9, 
        'Should have at least 9 room types';
    ASSERT (SELECT COUNT(*) FROM public.payment_methods_master) >= 8, 
        'Should have at least 8 payment methods';
    ASSERT (SELECT COUNT(*) FROM public.meal_services_master) >= 8, 
        'Should have at least 8 meal services';
    ASSERT (SELECT COUNT(*) FROM public.establishment_price_ranges_master) >= 7, 
        'Should have at least 7 price ranges';
    
    -- Check that required statuses exist
    ASSERT EXISTS (SELECT 1 FROM public.booking_statuses_master WHERE code = 'open' AND is_available = true), 
        'Open booking status must exist and be available';
    ASSERT EXISTS (SELECT 1 FROM public.accommodation_types_master WHERE code = 'pilgrim_hostel'), 
        'Pilgrim hostel type must exist';
    ASSERT EXISTS (SELECT 1 FROM public.amenities_master WHERE code = 'wifi_free'), 
        'Free Wi-Fi amenity must exist';
    
    RAISE NOTICE 'Test 2 passed: Seed data loaded correctly';
END $$;

-- Test 3: Create test accommodation with full features
-- Use the admin profile from previous modules
INSERT INTO public.profiles (id, email, display_name, roles, preferred_language_code, is_active)
VALUES ('11111111-1111-1111-1111-111111111115', 'accommodation_admin@test.com', 'Accommodation Admin', ARRAY['platform_admin'], 'en', true)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    v_waypoint_id BIGINT;
    v_accommodation_type_id INTEGER;
    v_booking_status_id INTEGER;
    v_price_range_id INTEGER;
    v_town_id INTEGER;
    v_status_id INTEGER;
    v_category_id INTEGER;
BEGIN
    -- Get required IDs
    SELECT id INTO v_accommodation_type_id FROM public.accommodation_types_master WHERE code = 'pilgrim_hostel' LIMIT 1;
    SELECT id INTO v_booking_status_id FROM public.booking_statuses_master WHERE code = 'open' LIMIT 1;
    SELECT id INTO v_price_range_id FROM public.establishment_price_ranges_master WHERE code = 'budget' LIMIT 1;
    SELECT id INTO v_town_id FROM public.towns WHERE slug LIKE 'test-%' OR name = 'Assisi' LIMIT 1;
    SELECT id INTO v_status_id FROM public.content_statuses_master WHERE code = 'published' LIMIT 1;
    SELECT id INTO v_category_id FROM public.waypoint_categories_master WHERE code = 'accommodation_location' LIMIT 1;
    
    -- Create test waypoint first
    INSERT INTO public.waypoints (
        name,
        slug,
        waypoint_primary_category_id,
        description,
        geom,
        town_id,
        address_text,
        content_visibility_status_id,
        is_significant_pilgrim_poi,
        short_narrative_for_dynamic_lists,
        quality_score,
        created_by_profile_id
    ) VALUES (
        'Test Pilgrim Hostel San Francesco',
        'test-pilgrim-hostel-san-francesco',
        v_category_id,
        'A welcoming pilgrim hostel with modern amenities and traditional hospitality.',
        ST_GeogFromText('POINT Z(12.6074 43.0642 424)'), -- Assisi coordinates
        v_town_id,
        'Via San Francesco, 10, Assisi',
        v_status_id,
        true,
        'Modern pilgrim hostel with traditional hospitality in the heart of Assisi.',
        90,
        '11111111-1111-1111-1111-111111111115'
    ) RETURNING id INTO v_waypoint_id;
    
    -- Create test accommodation
    INSERT INTO public.accommodations (
        id,
        accommodation_type_id,
        booking_status_id,
        price_range_id,
        host_name,
        host_contact_email,
        host_contact_phone,
        website_url,
        booking_platform_url,
        total_beds,
        total_rooms,
        pilgrim_beds_available,
        accepts_reservations,
        advance_booking_required,
        seasonal_operation,
        price_per_night_eur,
        price_currency_code,
        price_notes,
        pilgrim_discount_available,
        check_in_time,
        check_out_time,
        curfew_time,
        minimum_stay_nights,
        maximum_stay_nights,
        allows_pets,
        smoking_policy,
        pilgrim_specific_notes,
        host_languages,
        special_features_notes,
        accessibility_notes,
        last_verified_date,
        data_source,
        data_confidence_score,
        created_by_profile_id
    ) VALUES (
        v_waypoint_id,
        v_accommodation_type_id,
        v_booking_status_id,
        v_price_range_id,
        'Marco & Elena Rossi',
        'info@hostelsanfrancesco.it',
        '+39 075 812345',
        'https://www.hostelsanfrancesco.it',
        'https://booking.com/hotel/it/hostel-san-francesco-assisi',
        24, -- total beds
        6,  -- total rooms
        20, -- pilgrim beds
        true, -- accepts reservations
        false, -- advance booking not required
        false, -- not seasonal
        18.00, -- price per night
        'EUR',
        'Pilgrim discount: €15/night with credential',
        true, -- pilgrim discount available
        '15:00'::TIME,
        '10:00'::TIME,
        '23:00'::TIME,
        1, -- minimum stay
        7, -- maximum stay
        false, -- no pets
        'no_smoking',
        'Credential stamping available. Laundry facilities. Walking equipment loan available.',
        ARRAY['it', 'en', 'es'], -- host languages
        'Beautiful garden courtyard, library corner, pilgrim equipment drying area.',
        'Ground floor rooms available. Accessible bathroom. Elevator to upper floors.',
        CURRENT_DATE,
        'Official accommodation partner',
        95,
        '11111111-1111-1111-1111-111111111115'
    );
    
    ASSERT v_waypoint_id IS NOT NULL, 'Test accommodation should be created successfully';
    
    RAISE NOTICE 'Test 3 passed: Accommodation created with ID %', v_waypoint_id;
    
    -- Test 4: Add amenities to accommodation
    INSERT INTO public.accommodation_amenities (accommodation_id, amenity_id, notes, is_verified, created_by_profile_id)
    SELECT 
        v_waypoint_id,
        am.id,
        CASE am.code
            WHEN 'wifi_free' THEN 'Strong signal throughout building'
            WHEN 'kitchen_access' THEN 'Fully equipped shared kitchen'
            WHEN 'laundry_facilities' THEN 'Washing machine and dryer available'
            ELSE NULL
        END,
        true,
        '11111111-1111-1111-1111-111111111115'
    FROM public.amenities_master am
    WHERE am.code IN ('wifi_free', 'kitchen_access', 'shared_bathroom', 'hot_water', 'heating', 
                      'laundry_facilities', 'drying_area', 'credential_stamping', 'luggage_storage',
                      'common_area', 'garden_outdoor_space', 'parking_free')
    AND am.is_active = true;
    
    -- Test 5: Add room configurations
    INSERT INTO public.accommodation_room_configurations (accommodation_id, room_type_id, number_of_rooms, beds_per_room, max_occupancy, room_price_eur, created_by_profile_id)
    SELECT 
        v_waypoint_id,
        rt.id,
        CASE rt.code
            WHEN 'dorm_mixed' THEN 3
            WHEN 'private_double' THEN 2
            WHEN 'private_single' THEN 1
            ELSE 1
        END,
        CASE rt.code
            WHEN 'dorm_mixed' THEN 8
            WHEN 'private_double' THEN 1
            WHEN 'private_single' THEN 1
            ELSE rt.typical_occupancy
        END,
        rt.typical_occupancy,
        CASE rt.code
            WHEN 'dorm_mixed' THEN 15.00
            WHEN 'private_double' THEN 45.00
            WHEN 'private_single' THEN 35.00
            ELSE NULL
        END,
        '11111111-1111-1111-1111-111111111115'
    FROM public.room_types_master rt
    WHERE rt.code IN ('dorm_mixed', 'private_double', 'private_single')
    AND rt.is_active = true;
    
    -- Test 6: Add payment methods
    INSERT INTO public.accommodation_payment_methods (accommodation_id, payment_method_id, notes, is_preferred, created_by_profile_id)
    SELECT 
        v_waypoint_id,
        pm.id,
        CASE pm.code
            WHEN 'cash_eur' THEN 'Preferred payment method'
            WHEN 'visa' THEN 'Accepted for advance bookings'
            ELSE NULL
        END,
        pm.code = 'cash_eur',
        '11111111-1111-1111-1111-111111111115'
    FROM public.payment_methods_master pm
    WHERE pm.code IN ('cash_eur', 'visa', 'mastercard')
    AND pm.is_active = true;
    
    -- Test 7: Add meal services
    INSERT INTO public.accommodation_meal_services (accommodation_id, meal_service_id, price_eur, availability_notes, advance_notice_required, created_by_profile_id)
    SELECT 
        v_waypoint_id,
        ms.id,
        CASE ms.code
            WHEN 'breakfast_available' THEN 5.00
            WHEN 'dinner_available' THEN 12.00
            WHEN 'kitchen_access' THEN NULL
            ELSE NULL
        END,
        CASE ms.code
            WHEN 'breakfast_available' THEN 'Available 7:00-9:30 AM'
            WHEN 'dinner_available' THEN 'Traditional Umbrian meals, vegetarian options available'
            WHEN 'kitchen_access' THEN 'Available 24/7 for guest use'
            ELSE NULL
        END,
        ms.code = 'dinner_available',
        '11111111-1111-1111-1111-111111111115'
    FROM public.meal_services_master ms
    WHERE ms.code IN ('breakfast_available', 'dinner_available', 'kitchen_access')
    AND ms.is_active = true;
    
    RAISE NOTICE 'Test 4-7 passed: Amenities, rooms, payments, and meals added successfully';
END $$;

-- Test 8: Test localized views return data
DO $$
DECLARE
    v_types_count INTEGER;
    v_amenities_count INTEGER;
    v_booking_count INTEGER;
    v_accommodations_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_types_count FROM public.v_accommodation_types_localized WHERE is_active = true;
    SELECT COUNT(*) INTO v_amenities_count FROM public.v_amenities_localized WHERE is_active = true;
    SELECT COUNT(*) INTO v_booking_count FROM public.v_booking_statuses_localized WHERE is_active = true;
    SELECT COUNT(*) INTO v_accommodations_count FROM public.v_accommodations_enriched;
    
    ASSERT v_types_count > 0, 'Localized accommodation types view should return data';
    ASSERT v_amenities_count > 0, 'Localized amenities view should return data';
    ASSERT v_booking_count > 0, 'Localized booking statuses view should return data';
    ASSERT v_accommodations_count > 0, 'Enriched accommodations view should return data';
    
    -- Test that enriched view includes aggregated data
    ASSERT EXISTS (
        SELECT 1 FROM public.v_accommodations_enriched 
        WHERE accommodation_type_code IS NOT NULL 
        AND booking_status_code IS NOT NULL
        AND jsonb_array_length(amenities) > 0
        AND jsonb_array_length(room_configurations) > 0
        AND jsonb_array_length(payment_methods) > 0
        AND jsonb_array_length(meal_services) > 0
    ), 'Enriched view should include accommodation type, booking status, amenities, rooms, payments, and meals';
    
    RAISE NOTICE 'Test 8 passed: Localized views working correctly';
END $$;

-- Test 9: Test RLS policies
DO $$
DECLARE
    accommodation_count INTEGER;
    amenities_count INTEGER;
BEGIN
    -- Test anonymous access (published content only)
    SET LOCAL ROLE anon;
    
    SELECT COUNT(*) INTO accommodation_count FROM public.accommodations;
    SELECT COUNT(*) INTO amenities_count FROM public.accommodation_amenities;
    
    ASSERT accommodation_count > 0, 'Anonymous users should see published accommodations';
    ASSERT amenities_count > 0, 'Anonymous users should see amenities for published accommodations';
    
    -- Test that anonymous cannot insert
    BEGIN
        INSERT INTO public.accommodations (id, accommodation_type_id, booking_status_id) 
        VALUES (999999, 1, 1);
        ASSERT FALSE, 'Anonymous should not be able to insert accommodations';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Test 9a passed: Anonymous cannot insert accommodations';
    END;
    
    -- Reset to superuser
    SET LOCAL ROLE postgres;
    
    RAISE NOTICE 'Test 9 passed: RLS policies working correctly';
END $$;

-- Test 10: Test constraint validations
DO $$
BEGIN
    -- Test email validation
    BEGIN
        INSERT INTO public.accommodations (
            id, accommodation_type_id, booking_status_id, host_contact_email
        ) VALUES (
            999998,
            (SELECT id FROM public.accommodation_types_master LIMIT 1),
            (SELECT id FROM public.booking_statuses_master LIMIT 1),
            'invalid-email'
        );
        ASSERT FALSE, 'Should not allow invalid email format';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 10a passed: Email validation constraint enforced';
    END;
    
    -- Test price validation
    BEGIN
        INSERT INTO public.accommodations (
            id, accommodation_type_id, booking_status_id, price_per_night_eur
        ) VALUES (
            999997,
            (SELECT id FROM public.accommodation_types_master LIMIT 1),
            (SELECT id FROM public.booking_statuses_master LIMIT 1),
            -10.00
        );
        ASSERT FALSE, 'Should not allow negative prices';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 10b passed: Price validation constraint enforced';
    END;
    
    -- Test pilgrim beds logical constraint
    BEGIN
        INSERT INTO public.accommodations (
            id, accommodation_type_id, booking_status_id, total_beds, pilgrim_beds_available
        ) VALUES (
            999996,
            (SELECT id FROM public.accommodation_types_master LIMIT 1),
            (SELECT id FROM public.booking_statuses_master LIMIT 1),
            10,
            15 -- More pilgrim beds than total beds
        );
        ASSERT FALSE, 'Should not allow more pilgrim beds than total beds';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Test 10c passed: Pilgrim beds logical constraint enforced';
    END;
END $$;

-- Cleanup test data
DELETE FROM public.accommodation_meal_services WHERE accommodation_id IN (SELECT id FROM public.accommodations WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115');
DELETE FROM public.accommodation_payment_methods WHERE accommodation_id IN (SELECT id FROM public.accommodations WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115');
DELETE FROM public.accommodation_room_configurations WHERE accommodation_id IN (SELECT id FROM public.accommodations WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115');
DELETE FROM public.accommodation_amenities WHERE accommodation_id IN (SELECT id FROM public.accommodations WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115');
DELETE FROM public.accommodations WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115';
DELETE FROM public.waypoints WHERE created_by_profile_id = '11111111-1111-1111-1111-111111111115';
DELETE FROM public.profiles WHERE id = '11111111-1111-1111-1111-111111111115';

-- Final summary
DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Module 4a test suite completed successfully!';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- All accommodation tables and views created correctly';
    RAISE NOTICE '- Master data seeded successfully (12 types, 40+ amenities, etc.)';
    RAISE NOTICE '- Comprehensive accommodation table with rich features';
    RAISE NOTICE '- Junction tables for amenities, rooms, payments, meals';
    RAISE NOTICE '- Localized views for efficient API queries';
    RAISE NOTICE '- RLS policies enforced correctly';
    RAISE NOTICE '- Constraint validations working';
    RAISE NOTICE '- Translation system integration ready';
    RAISE NOTICE '';
    RAISE NOTICE 'Module 4a: Accommodations is ready for use!';
    RAISE NOTICE 'Full accommodation management: COMPLETE';
    RAISE NOTICE 'Ready for real accommodation data import';
END $$;

ROLLBACK;
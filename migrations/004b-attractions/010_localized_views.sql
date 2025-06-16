-- Module 4b: Attractions
-- 010_localized_views.sql: Localized views for API consumption
-- 
-- Purpose: Create localized views for efficient API consumption of attraction data

-- Create localized view for attraction details
CREATE OR REPLACE VIEW public.v_waypoint_attraction_details_localized AS
SELECT 
    -- Core waypoint and attraction information
    w.id,
    w.name,
    w.description,
    w.geometry,
    w.town_id,
    w.waypoint_category_id,
    w.content_visibility_status_id,
    
    -- Attraction details
    ad.attraction_type_id,
    ad.visitor_amenity_ids,
    ad.opening_hours,
    ad.seasonal_hours,
    ad.special_closure_dates,
    ad.entry_fee_eur,
    ad.entry_fee_currency,
    ad.entry_fee_notes,
    ad.pilgrim_discount_available,
    ad.pilgrim_discount_notes,
    ad.advance_booking_required,
    ad.contact_phone,
    ad.contact_email,
    ad.website_url,
    ad.booking_url,
    ad.typical_visit_duration_minutes,
    ad.recommended_seasons,
    ad.difficulty_level,
    ad.age_restrictions,
    ad.group_size_limits,
    ad.guided_tours_available,
    ad.audio_guides_available,
    ad.multilingual_support,
    ad.languages_supported,
    ad.photography_policy,
    ad.wheelchair_accessible,
    ad.accessibility_notes,
    ad.parking_available,
    ad.parking_notes,
    ad.historical_period,
    ad.architectural_style,
    ad.cultural_significance,
    ad.unesco_status,
    ad.franciscan_connection,
    ad.pilgrimage_significance,
    ad.spiritual_practices_offered,
    ad.last_verified_date,
    ad.data_source,
    ad.data_confidence_score,
    ad.visitor_rating,
    ad.visitor_review_count,
    
    -- Localized master data
    at_master.label as attraction_type_label,
    at_master.description as attraction_type_description,
    at_master.icon_identifier as attraction_type_icon,
    
    -- Waypoint category info
    wc_master.label as waypoint_category_label,
    wc_master.description as waypoint_category_description,
    wc_master.icon_identifier as waypoint_category_icon,
    
    -- Content status info
    cs_master.label as content_status_label,
    cs_master.description as content_status_description,
    cs_master.is_publicly_visible,
    
    -- Town information
    t.name as town_name,
    t.latitude as town_latitude,
    t.longitude as town_longitude,
    
    -- Audit information
    ad.created_at,
    ad.updated_at,
    ad.deleted_at
    
FROM public.waypoints w
JOIN public.attraction_details ad ON w.id = ad.id
LEFT JOIN public.attraction_types_master at_master ON ad.attraction_type_id = at_master.id
LEFT JOIN public.waypoint_categories_master wc_master ON w.waypoint_category_id = wc_master.id  
LEFT JOIN public.content_statuses_master cs_master ON w.content_visibility_status_id = cs_master.id
LEFT JOIN public.towns t ON w.town_id = t.id
WHERE w.deleted_at IS NULL 
AND ad.deleted_at IS NULL;

-- Create localized view for food and water sources details
CREATE OR REPLACE VIEW public.v_waypoint_food_water_sources_localized AS
SELECT 
    -- Core waypoint information
    w.id,
    w.name,
    w.description,
    w.geometry,
    w.town_id,
    w.waypoint_category_id,
    w.content_visibility_status_id,
    
    -- Food water sources details
    fws.source_type_ids,
    fws.water_reliability_type_id,
    fws.price_range_id,
    fws.is_potable_water,
    fws.requires_treatment,
    fws.treatment_method,
    fws.water_quality_notes,
    fws.always_available,
    fws.seasonal_availability,
    fws.available_seasons,
    fws.operating_hours,
    fws.access_restrictions,
    fws.flow_rate_description,
    fws.capacity_notes,
    fws.multiple_taps,
    fws.number_of_access_points,
    fws.free_access,
    fws.cost_eur,
    fws.cost_currency,
    fws.cost_notes,
    fws.bottle_filling_friendly,
    fws.food_available,
    fws.food_type_description,
    fws.meal_times,
    fws.meal_type_ids,
    fws.dietary_option_ids,
    fws.payment_method_ids,
    fws.reservation_required,
    fws.contact_phone,
    fws.contact_email,
    fws.distance_from_trail_meters,
    fws.access_difficulty,
    fws.parking_available,
    fws.last_tested_date,
    fws.testing_authority,
    fws.safety_warnings,
    fws.last_verified_date,
    fws.data_source,
    fws.data_confidence_score,
    
    -- Localized master data
    wrt_master.label as water_reliability_label,
    wrt_master.description as water_reliability_description,
    wrt_master.icon_identifier as water_reliability_icon,
    wrt_master.advisory_level as water_reliability_advisory_level,
    
    pr_master.label as price_range_label,
    pr_master.description as price_range_description,
    pr_master.min_price_eur as price_range_min,
    pr_master.max_price_eur as price_range_max,
    
    -- Waypoint category info
    wc_master.label as waypoint_category_label,
    wc_master.description as waypoint_category_description,
    wc_master.icon_identifier as waypoint_category_icon,
    
    -- Content status info
    cs_master.label as content_status_label,
    cs_master.description as content_status_description,
    cs_master.is_publicly_visible,
    
    -- Town information
    t.name as town_name,
    t.latitude as town_latitude,
    t.longitude as town_longitude,
    
    -- Audit information
    fws.created_at,
    fws.updated_at,
    fws.deleted_at
    
FROM public.waypoints w
JOIN public.food_water_sources_details fws ON w.id = fws.id
LEFT JOIN public.water_reliability_types_master wrt_master ON fws.water_reliability_type_id = wrt_master.id
LEFT JOIN public.establishment_price_ranges_master pr_master ON fws.price_range_id = pr_master.id
LEFT JOIN public.waypoint_categories_master wc_master ON w.waypoint_category_id = wc_master.id  
LEFT JOIN public.content_statuses_master cs_master ON w.content_visibility_status_id = cs_master.id
LEFT JOIN public.towns t ON w.town_id = t.id
WHERE w.deleted_at IS NULL 
AND fws.deleted_at IS NULL;

-- Create localized view for shops and services details
CREATE OR REPLACE VIEW public.v_waypoint_shops_services_localized AS
SELECT 
    -- Core waypoint information
    w.id,
    w.name,
    w.description,
    w.geometry,
    w.town_id,
    w.waypoint_category_id,
    w.content_visibility_status_id,
    
    -- Shops and services details
    ss.shop_service_type_ids,
    ss.price_range_id,
    ss.opening_hours,
    ss.seasonal_hours,
    ss.special_closure_dates,
    ss.holiday_hours,
    ss.contact_phone,
    ss.contact_email,
    ss.website_url,
    ss.online_ordering_url,
    ss.business_name,
    ss.business_registration_number,
    ss.vat_number,
    ss.accepts_reservations,
    ss.reservation_required,
    ss.payment_method_ids,
    ss.accepts_credit_cards,
    ss.accepts_cash,
    ss.currency_accepted,
    ss.average_price_eur,
    ss.pilgrim_discount_available,
    ss.pilgrim_discount_percentage,
    ss.pilgrim_discount_notes,
    ss.meal_type_ids,
    ss.dietary_option_ids,
    ss.serves_alcohol,
    ss.takeaway_available,
    ss.delivery_available,
    ss.delivery_radius_km,
    ss.seating_capacity,
    ss.outdoor_seating,
    ss.wifi_available,
    ss.wifi_password,
    ss.parking_available,
    ss.parking_notes,
    ss.wheelchair_accessible,
    ss.accessibility_notes,
    ss.luggage_storage,
    ss.bicycle_parking,
    ss.credential_stamping,
    ss.luggage_transport_service,
    ss.equipment_rental,
    ss.equipment_repair,
    ss.pilgrim_information,
    ss.multilingual_staff,
    ss.languages_spoken,
    ss.quality_rating,
    ss.service_rating,
    ss.value_rating,
    ss.overall_rating,
    ss.review_count,
    ss.staff_count,
    ss.established_year,
    ss.chain_franchise,
    ss.local_ownership,
    ss.seasonal_business,
    ss.peak_season_months,
    ss.off_season_closure,
    ss.last_verified_date,
    ss.data_source,
    ss.data_confidence_score,
    ss.verification_notes,
    
    -- Localized master data
    pr_master.label as price_range_label,
    pr_master.description as price_range_description,
    pr_master.min_price_eur as price_range_min,
    pr_master.max_price_eur as price_range_max,
    
    -- Waypoint category info
    wc_master.label as waypoint_category_label,
    wc_master.description as waypoint_category_description,
    wc_master.icon_identifier as waypoint_category_icon,
    
    -- Content status info
    cs_master.label as content_status_label,
    cs_master.description as content_status_description,
    cs_master.is_publicly_visible,
    
    -- Town information
    t.name as town_name,
    t.latitude as town_latitude,
    t.longitude as town_longitude,
    
    -- Audit information
    ss.created_at,
    ss.updated_at,
    ss.deleted_at
    
FROM public.waypoints w
JOIN public.shops_and_services_details ss ON w.id = ss.id
LEFT JOIN public.establishment_price_ranges_master pr_master ON ss.price_range_id = pr_master.id
LEFT JOIN public.waypoint_categories_master wc_master ON w.waypoint_category_id = wc_master.id  
LEFT JOIN public.content_statuses_master cs_master ON w.content_visibility_status_id = cs_master.id
LEFT JOIN public.towns t ON w.town_id = t.id
WHERE w.deleted_at IS NULL 
AND ss.deleted_at IS NULL;

-- Create helper view for religious service schedules with localization
CREATE OR REPLACE VIEW public.v_religious_service_schedules_localized AS
SELECT 
    rss.id,
    rss.attraction_id,
    rss.service_type_id,
    rss.day_of_week,
    rss.service_time,
    rss.duration_minutes,
    rss.language_code,
    rss.celebrant_name,
    rss.special_notes,
    rss.seasonal_schedule,
    rss.seasonal_start_date,
    rss.seasonal_end_date,
    rss.is_regular_service,
    rss.is_active,
    rss.last_verified_date,
    
    -- Localized master data
    rst_master.label as service_type_label,
    rst_master.description as service_type_description,
    rst_master.icon_identifier as service_type_icon,
    
    -- Language information
    l_master.name as language_name,
    l_master.native_name as language_native_name,
    
    -- Day of week as text
    CASE rss.day_of_week
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_of_week_name,
    
    -- Audit information
    rss.created_at,
    rss.updated_at
    
FROM public.religious_service_schedules rss
LEFT JOIN public.religious_service_types_master rst_master ON rss.service_type_id = rst_master.id
LEFT JOIN public.languages_master l_master ON rss.language_code = l_master.code
WHERE rss.is_active = true;

-- Add comments for all views
COMMENT ON VIEW public.v_waypoint_attraction_details_localized IS 'Localized view combining waypoint and attraction details with master table labels for efficient API consumption.';
COMMENT ON VIEW public.v_waypoint_food_water_sources_localized IS 'Localized view combining waypoint and food/water source details with master table labels for efficient API consumption.';
COMMENT ON VIEW public.v_waypoint_shops_services_localized IS 'Localized view combining waypoint and shops/services details with master table labels for efficient API consumption.';
COMMENT ON VIEW public.v_religious_service_schedules_localized IS 'Localized view for religious service schedules with master table labels and day name conversion.';
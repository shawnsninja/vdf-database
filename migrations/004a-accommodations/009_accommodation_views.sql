-- Module 4a: Accommodations
-- 009_accommodation_views.sql: Views for accommodations data
-- 
-- Purpose: Create localized views and comprehensive accommodation view for API efficiency

-- Localized view for accommodation types
CREATE OR REPLACE VIEW public.v_accommodation_types_localized AS
SELECT 
    at.id,
    at.code,
    at.label,
    at.description,
    at.icon_identifier,
    at.sort_order,
    at.is_active,
    at.created_at,
    at.updated_at,
    at.created_by_profile_id,
    at.updated_by_profile_id,
    -- Aggregate all translations for this type
    COALESCE(
        jsonb_object_agg(
            t.language_code,
            jsonb_build_object(
                'label', CASE WHEN t.column_identifier = 'label' THEN t.translated_text END,
                'description', CASE WHEN t.column_identifier = 'description' THEN t.translated_text END
            )
        ) FILTER (WHERE t.translated_text IS NOT NULL),
        '{}'::jsonb
    ) AS all_translations
FROM public.accommodation_types_master at
LEFT JOIN public.translations t ON (
    t.table_identifier = 'accommodation_types_master' 
    AND t.row_foreign_key = at.id::text
    AND t.column_identifier IN ('label', 'description')
    AND t.translation_status = 'published_live'
)
GROUP BY 
    at.id, at.code, at.label, at.description, at.icon_identifier,
    at.sort_order, at.is_active, at.created_at, at.updated_at, 
    at.created_by_profile_id, at.updated_by_profile_id
ORDER BY at.sort_order, at.label;

-- Localized view for amenities
CREATE OR REPLACE VIEW public.v_amenities_localized AS
SELECT 
    a.id,
    a.code,
    a.label,
    a.description,
    a.icon_identifier,
    a.category,
    a.sort_order,
    a.is_active,
    a.created_at,
    a.updated_at,
    a.created_by_profile_id,
    a.updated_by_profile_id,
    -- Aggregate all translations for this amenity
    COALESCE(
        jsonb_object_agg(
            t.language_code,
            jsonb_build_object(
                'label', CASE WHEN t.column_identifier = 'label' THEN t.translated_text END,
                'description', CASE WHEN t.column_identifier = 'description' THEN t.translated_text END
            )
        ) FILTER (WHERE t.translated_text IS NOT NULL),
        '{}'::jsonb
    ) AS all_translations
FROM public.amenities_master a
LEFT JOIN public.translations t ON (
    t.table_identifier = 'amenities_master' 
    AND t.row_foreign_key = a.id::text
    AND t.column_identifier IN ('label', 'description')
    AND t.translation_status = 'published_live'
)
GROUP BY 
    a.id, a.code, a.label, a.description, a.icon_identifier, a.category,
    a.sort_order, a.is_active, a.created_at, a.updated_at, 
    a.created_by_profile_id, a.updated_by_profile_id
ORDER BY a.category, a.sort_order, a.label;

-- Localized view for booking statuses
CREATE OR REPLACE VIEW public.v_booking_statuses_localized AS
SELECT 
    bs.id,
    bs.code,
    bs.label,
    bs.description,
    bs.icon_identifier,
    bs.is_available,
    bs.sort_order,
    bs.is_active,
    bs.created_at,
    bs.updated_at,
    bs.created_by_profile_id,
    bs.updated_by_profile_id,
    -- Aggregate all translations for this status
    COALESCE(
        jsonb_object_agg(
            t.language_code,
            jsonb_build_object(
                'label', CASE WHEN t.column_identifier = 'label' THEN t.translated_text END,
                'description', CASE WHEN t.column_identifier = 'description' THEN t.translated_text END
            )
        ) FILTER (WHERE t.translated_text IS NOT NULL),
        '{}'::jsonb
    ) AS all_translations
FROM public.booking_statuses_master bs
LEFT JOIN public.translations t ON (
    t.table_identifier = 'booking_statuses_master' 
    AND t.row_foreign_key = bs.id::text
    AND t.column_identifier IN ('label', 'description')
    AND t.translation_status = 'published_live'
)
GROUP BY 
    bs.id, bs.code, bs.label, bs.description, bs.icon_identifier, bs.is_available,
    bs.sort_order, bs.is_active, bs.created_at, bs.updated_at, 
    bs.created_by_profile_id, bs.updated_by_profile_id
ORDER BY bs.sort_order, bs.label;

-- Comprehensive accommodations view with all related data
CREATE OR REPLACE VIEW public.v_accommodations_enriched AS
SELECT 
    -- Waypoint base information
    w.id,
    w.name,
    w.slug,
    w.description,
    w.geom,
    w.latitude,
    w.longitude,
    w.elevation_meters,
    w.address_text,
    w.is_franciscan_highlight_site,
    w.is_significant_pilgrim_poi,
    w.short_narrative_for_dynamic_lists,
    w.quality_score,
    
    -- Accommodation specific information
    a.accommodation_type_id,
    at.code AS accommodation_type_code,
    at.label AS accommodation_type_label,
    at.icon_identifier AS accommodation_type_icon,
    
    a.booking_status_id,
    bs.code AS booking_status_code,
    bs.label AS booking_status_label,
    bs.is_available AS booking_is_available,
    bs.icon_identifier AS booking_status_icon,
    
    a.price_range_id,
    pr.code AS price_range_code,
    pr.label AS price_range_label,
    pr.min_price_eur,
    pr.max_price_eur,
    
    -- Host information
    a.host_name,
    a.host_contact_email,
    a.host_contact_phone,
    a.website_url,
    a.booking_platform_url,
    
    -- Capacity and pricing
    a.total_beds,
    a.total_rooms,
    a.pilgrim_beds_available,
    a.price_per_night_eur,
    a.price_currency_code,
    a.price_notes,
    a.pilgrim_discount_available,
    
    -- Availability and policies
    a.accepts_reservations,
    a.advance_booking_required,
    a.seasonal_operation,
    a.seasonal_open_date,
    a.seasonal_close_date,
    a.check_in_time,
    a.check_out_time,
    a.curfew_time,
    a.minimum_stay_nights,
    a.maximum_stay_nights,
    a.allows_pets,
    a.smoking_policy,
    
    -- Special information
    a.pilgrim_specific_notes,
    a.host_languages,
    a.special_features_notes,
    a.accessibility_notes,
    
    -- Data management
    a.last_verified_date,
    a.data_source,
    a.data_confidence_score,
    
    -- Geographic context
    t.name AS town_name,
    t.slug AS town_slug,
    r.name AS region_name,
    
    -- Content status
    cs.code AS content_status_code,
    cs.label AS content_status_label,
    cs.is_publicly_visible,
    
    -- Amenities (aggregated)
    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', am.id,
                    'code', am.code,
                    'label', am.label,
                    'category', am.category,
                    'icon', am.icon_identifier,
                    'notes', aa.notes,
                    'is_verified', aa.is_verified
                )
                ORDER BY am.category, am.sort_order, am.label
            )
            FROM public.accommodation_amenities aa
            JOIN public.amenities_master am ON aa.amenity_id = am.id
            WHERE aa.accommodation_id = a.id
            AND am.is_active = true
        ),
        '[]'::jsonb
    ) AS amenities,
    
    -- Room configurations (aggregated)
    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'room_type_id', rt.id,
                    'room_type_code', rt.code,
                    'room_type_label', rt.label,
                    'number_of_rooms', arc.number_of_rooms,
                    'beds_per_room', arc.beds_per_room,
                    'max_occupancy', arc.max_occupancy,
                    'room_price_eur', arc.room_price_eur,
                    'room_notes', arc.room_notes,
                    'is_available', arc.is_available,
                    'typical_occupancy', rt.typical_occupancy
                )
                ORDER BY rt.sort_order, rt.label
            )
            FROM public.accommodation_room_configurations arc
            JOIN public.room_types_master rt ON arc.room_type_id = rt.id
            WHERE arc.accommodation_id = a.id
            AND rt.is_active = true
        ),
        '[]'::jsonb
    ) AS room_configurations,
    
    -- Payment methods (aggregated)
    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'payment_method_id', pm.id,
                    'code', pm.code,
                    'label', pm.label,
                    'icon', pm.icon_identifier,
                    'is_digital', pm.is_digital,
                    'notes', apm.notes,
                    'is_preferred', apm.is_preferred
                )
                ORDER BY apm.is_preferred DESC, pm.sort_order, pm.label
            )
            FROM public.accommodation_payment_methods apm
            JOIN public.payment_methods_master pm ON apm.payment_method_id = pm.id
            WHERE apm.accommodation_id = a.id
            AND pm.is_active = true
        ),
        '[]'::jsonb
    ) AS payment_methods,
    
    -- Meal services (aggregated)
    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'meal_service_id', ms.id,
                    'code', ms.code,
                    'label', ms.label,
                    'meal_type', ms.meal_type,
                    'icon', ms.icon_identifier,
                    'price_eur', ams.price_eur,
                    'availability_notes', ams.availability_notes,
                    'advance_notice_required', ams.advance_notice_required
                )
                ORDER BY ms.sort_order, ms.label
            )
            FROM public.accommodation_meal_services ams
            JOIN public.meal_services_master ms ON ams.meal_service_id = ms.id
            WHERE ams.accommodation_id = a.id
            AND ms.is_active = true
        ),
        '[]'::jsonb
    ) AS meal_services,
    
    -- Timestamps
    a.created_at,
    a.updated_at,
    a.deleted_at
    
FROM public.accommodations a
JOIN public.waypoints w ON a.id = w.id
JOIN public.accommodation_types_master at ON a.accommodation_type_id = at.id
JOIN public.booking_statuses_master bs ON a.booking_status_id = bs.id
LEFT JOIN public.establishment_price_ranges_master pr ON a.price_range_id = pr.id
LEFT JOIN public.towns t ON w.town_id = t.id
LEFT JOIN public.regions r ON t.region_id = r.id
LEFT JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
WHERE a.deleted_at IS NULL 
AND w.deleted_at IS NULL;

-- Add comments to views
COMMENT ON VIEW public.v_accommodation_types_localized IS 
'Accommodation types with all translations aggregated in all_translations JSONB column for API efficiency.';

COMMENT ON VIEW public.v_amenities_localized IS 
'Amenities with all translations aggregated in all_translations JSONB column for API efficiency.';

COMMENT ON VIEW public.v_booking_statuses_localized IS 
'Booking statuses with all translations aggregated in all_translations JSONB column for API efficiency.';

COMMENT ON VIEW public.v_accommodations_enriched IS 
'Comprehensive accommodation view with all related master data, amenities, rooms, payments, and meals for efficient API queries. Excludes soft-deleted accommodations.';
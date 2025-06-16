-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 005_localized_views.sql
-- Description: Create localized views for API access to curated itineraries
-- Dependencies: All previous Module 7 migrations, Module 1 (translations)
-- Version: 1.0
-- =====================================================================================

-- View: public.view_itinerary_categories_localized
-- Purpose: Provides localized itinerary categories
CREATE OR REPLACE VIEW public.view_itinerary_categories_localized AS
SELECT 
    icm.category_code,
    COALESCE(trans_name.translated_text, icm.default_name) AS localized_name,
    COALESCE(trans_desc.translated_text, icm.default_description) AS localized_description,
    icm.icon_identifier,
    icm.sort_order
FROM 
    public.itinerary_categories_master icm
LEFT JOIN public.translations trans_name ON 
    icm.category_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'itinerary_categories_master' 
    AND trans_name.column_identifier = 'default_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    icm.category_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'itinerary_categories_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE 
    icm.is_active = true
ORDER BY 
    icm.sort_order, icm.category_code;

COMMENT ON VIEW public.view_itinerary_categories_localized IS 'Localized view of itinerary categories. Version 1.0.';
GRANT SELECT ON public.view_itinerary_categories_localized TO authenticated, anon;

-- View: public.view_seasons_localized
-- Purpose: Provides localized seasons
CREATE OR REPLACE VIEW public.view_seasons_localized AS
SELECT 
    sm.season_code,
    COALESCE(trans_name.translated_text, sm.default_name) AS localized_name,
    COALESCE(trans_desc.translated_text, sm.default_description) AS localized_description,
    sm.typical_months,
    sm.sort_order
FROM 
    public.seasons_master sm
LEFT JOIN public.translations trans_name ON 
    sm.season_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'seasons_master' 
    AND trans_name.column_identifier = 'default_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    sm.season_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'seasons_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE 
    sm.is_active = true
ORDER BY 
    sm.sort_order, sm.season_code;

COMMENT ON VIEW public.view_seasons_localized IS 'Localized view of seasons. Version 1.0.';
GRANT SELECT ON public.view_seasons_localized TO authenticated, anon;

-- View: public.view_trail_difficulty_levels_localized
-- Purpose: Provides localized difficulty levels
CREATE OR REPLACE VIEW public.view_trail_difficulty_levels_localized AS
SELECT 
    tdl.difficulty_code,
    COALESCE(trans_name.translated_text, tdl.default_name) AS localized_name,
    COALESCE(trans_desc.translated_text, tdl.default_description) AS localized_description,
    tdl.numeric_level,
    tdl.daily_distance_km_min,
    tdl.daily_distance_km_max,
    tdl.elevation_gain_m_typical,
    tdl.fitness_requirement_notes,
    tdl.icon_identifier,
    tdl.color_hex
FROM 
    public.trail_difficulty_levels_master tdl
LEFT JOIN public.translations trans_name ON 
    tdl.difficulty_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'trail_difficulty_levels_master' 
    AND trans_name.column_identifier = 'default_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    tdl.difficulty_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'trail_difficulty_levels_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE 
    tdl.is_active = true
ORDER BY 
    tdl.numeric_level;

COMMENT ON VIEW public.view_trail_difficulty_levels_localized IS 'Localized view of trail difficulty levels. Version 1.0.';
GRANT SELECT ON public.view_trail_difficulty_levels_localized TO authenticated, anon;

-- View: public.view_curated_itineraries_list
-- Purpose: Provides list view of published itineraries with basic info
CREATE OR REPLACE VIEW public.view_curated_itineraries_list AS
SELECT 
    ci.id,
    ci.code,
    ci.trail_id,
    t.code AS trail_code,
    COALESCE(trans_trail.translated_text, t.default_name) AS trail_name,
    COALESCE(trans_title.translated_text, ci.default_title) AS localized_title,
    COALESCE(trans_subtitle.translated_text, ci.default_subtitle) AS localized_subtitle,
    ci.total_days,
    ci.total_distance_km,
    ci.difficulty_level_code,
    COALESCE(trans_diff.translated_text, tdl.default_name) AS difficulty_level_name,
    tdl.numeric_level AS difficulty_numeric_level,
    tdl.color_hex AS difficulty_color,
    ci.hero_image_media_id,
    hm.storage_path AS hero_image_path,
    ci.is_featured,
    ci.featured_order,
    ci.author_profile_id,
    p.display_name AS author_name,
    p.profile_photo_media_id AS author_photo_id,
    ARRAY_AGG(DISTINCT ic.itinerary_category_code) FILTER (WHERE ic.itinerary_category_code IS NOT NULL) AS category_codes,
    ARRAY_AGG(DISTINCT s.season_code) FILTER (WHERE s.season_code IS NOT NULL) AS season_codes,
    ci.published_at,
    ci.created_at
FROM 
    public.curated_itineraries ci
INNER JOIN public.trails t ON ci.trail_id = t.id
INNER JOIN public.trail_difficulty_levels_master tdl ON ci.difficulty_level_code = tdl.difficulty_code
INNER JOIN public.profiles p ON ci.author_profile_id = p.id
LEFT JOIN public.media hm ON ci.hero_image_media_id = hm.id
LEFT JOIN public.curated_itinerary_to_category ic ON ci.id = ic.curated_itinerary_id
LEFT JOIN public.curated_itinerary_to_season s ON ci.id = s.curated_itinerary_id
LEFT JOIN public.translations trans_title ON 
    ci.id::text = trans_title.row_foreign_key 
    AND trans_title.table_identifier = 'curated_itineraries' 
    AND trans_title.column_identifier = 'default_title' 
    AND trans_title.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_subtitle ON 
    ci.id::text = trans_subtitle.row_foreign_key 
    AND trans_subtitle.table_identifier = 'curated_itineraries' 
    AND trans_subtitle.column_identifier = 'default_subtitle' 
    AND trans_subtitle.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_trail ON 
    t.id::text = trans_trail.row_foreign_key 
    AND trans_trail.table_identifier = 'trails' 
    AND trans_trail.column_identifier = 'default_name' 
    AND trans_trail.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_diff ON 
    tdl.difficulty_code = trans_diff.row_foreign_key 
    AND trans_diff.table_identifier = 'trail_difficulty_levels_master' 
    AND trans_diff.column_identifier = 'default_name' 
    AND trans_diff.language_code = current_setting('app.current_lang', true)
WHERE 
    ci.content_status_code = 'published'
    AND ci.deleted_at IS NULL
GROUP BY 
    ci.id, ci.code, ci.trail_id, t.code, t.default_name, trans_trail.translated_text,
    ci.default_title, trans_title.translated_text, ci.default_subtitle, trans_subtitle.translated_text,
    ci.total_days, ci.total_distance_km, ci.difficulty_level_code,
    tdl.default_name, trans_diff.translated_text, tdl.numeric_level, tdl.color_hex,
    ci.hero_image_media_id, hm.storage_path, ci.is_featured, ci.featured_order,
    ci.author_profile_id, p.display_name, p.profile_photo_media_id,
    ci.published_at, ci.created_at
ORDER BY 
    ci.is_featured DESC, 
    ci.featured_order NULLS LAST, 
    ci.published_at DESC;

COMMENT ON VIEW public.view_curated_itineraries_list IS 'List view of published curated itineraries with localized content. Version 1.0.';
GRANT SELECT ON public.view_curated_itineraries_list TO authenticated, anon;

-- View: public.view_curated_itinerary_detail
-- Purpose: Provides detailed view of a single itinerary with all segments
CREATE OR REPLACE VIEW public.view_curated_itinerary_detail AS
SELECT 
    ci.id,
    ci.code,
    ci.trail_id,
    COALESCE(trans_title.translated_text, ci.default_title) AS localized_title,
    COALESCE(trans_subtitle.translated_text, ci.default_subtitle) AS localized_subtitle,
    COALESCE(trans_desc.translated_text, ci.default_description) AS localized_description,
    -- Translate highlights array
    CASE 
        WHEN ci.default_highlights IS NOT NULL THEN
            ARRAY(
                SELECT COALESCE(
                    trans_h.translated_text,
                    h.highlight
                )
                FROM unnest(ci.default_highlights) WITH ORDINALITY AS h(highlight, ord)
                LEFT JOIN public.translations trans_h ON 
                    ci.id::text = trans_h.row_foreign_key 
                    AND trans_h.table_identifier = 'curated_itineraries' 
                    AND trans_h.column_identifier = 'default_highlights[' || h.ord || ']'
                    AND trans_h.language_code = current_setting('app.current_lang', true)
                ORDER BY h.ord
            )
        ELSE NULL
    END AS localized_highlights,
    ci.total_days,
    ci.total_distance_km,
    ci.total_elevation_gain_m,
    ci.total_elevation_loss_m,
    ci.difficulty_level_code,
    ci.fitness_level_notes,
    ci.hero_image_media_id,
    ci.map_image_media_id,
    ci.author_profile_id,
    ci.is_featured,
    ci.featured_order,
    ci.published_at,
    -- Categories with localized names
    COALESCE(
        json_agg(DISTINCT 
            jsonb_build_object(
                'code', ic.itinerary_category_code,
                'name', COALESCE(trans_cat.translated_text, icm.default_name),
                'icon', icm.icon_identifier
            )
        ) FILTER (WHERE ic.itinerary_category_code IS NOT NULL),
        '[]'::json
    ) AS categories,
    -- Seasons with localized names
    COALESCE(
        json_agg(DISTINCT 
            jsonb_build_object(
                'code', its.season_code,
                'name', COALESCE(trans_season.translated_text, sm.default_name),
                'is_best', its.is_best_season,
                'notes', its.season_notes
            )
        ) FILTER (WHERE its.season_code IS NOT NULL),
        '[]'::json
    ) AS seasons
FROM 
    public.curated_itineraries ci
LEFT JOIN public.curated_itinerary_to_category ic ON ci.id = ic.curated_itinerary_id
LEFT JOIN public.itinerary_categories_master icm ON ic.itinerary_category_code = icm.category_code
LEFT JOIN public.curated_itinerary_to_season its ON ci.id = its.curated_itinerary_id
LEFT JOIN public.seasons_master sm ON its.season_code = sm.season_code
-- Translations
LEFT JOIN public.translations trans_title ON 
    ci.id::text = trans_title.row_foreign_key 
    AND trans_title.table_identifier = 'curated_itineraries' 
    AND trans_title.column_identifier = 'default_title' 
    AND trans_title.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_subtitle ON 
    ci.id::text = trans_subtitle.row_foreign_key 
    AND trans_subtitle.table_identifier = 'curated_itineraries' 
    AND trans_subtitle.column_identifier = 'default_subtitle' 
    AND trans_subtitle.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    ci.id::text = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'curated_itineraries' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_cat ON 
    icm.category_code = trans_cat.row_foreign_key 
    AND trans_cat.table_identifier = 'itinerary_categories_master' 
    AND trans_cat.column_identifier = 'default_name' 
    AND trans_cat.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_season ON 
    sm.season_code = trans_season.row_foreign_key 
    AND trans_season.table_identifier = 'seasons_master' 
    AND trans_season.column_identifier = 'default_name' 
    AND trans_season.language_code = current_setting('app.current_lang', true)
WHERE 
    ci.content_status_code = 'published'
    AND ci.deleted_at IS NULL
GROUP BY 
    ci.id, ci.code, ci.trail_id, ci.default_title, trans_title.translated_text,
    ci.default_subtitle, trans_subtitle.translated_text, ci.default_description, trans_desc.translated_text,
    ci.default_highlights, ci.total_days, ci.total_distance_km, ci.total_elevation_gain_m,
    ci.total_elevation_loss_m, ci.difficulty_level_code, ci.fitness_level_notes,
    ci.hero_image_media_id, ci.map_image_media_id, ci.author_profile_id,
    ci.is_featured, ci.featured_order, ci.published_at;

COMMENT ON VIEW public.view_curated_itinerary_detail IS 'Detailed view of a curated itinerary with localized content. Version 1.0.';
GRANT SELECT ON public.view_curated_itinerary_detail TO authenticated, anon;

-- View: public.view_curated_itinerary_segments
-- Purpose: Provides localized segments for an itinerary
CREATE OR REPLACE VIEW public.view_curated_itinerary_segments AS
SELECT 
    cis.id,
    cis.curated_itinerary_id,
    cis.day_number,
    cis.segment_id,
    s.code AS segment_code,
    COALESCE(trans_day_title.translated_text, cis.default_day_title) AS localized_day_title,
    COALESCE(trans_day_desc.translated_text, cis.default_day_description) AS localized_day_description,
    -- Translate highlights array (similar pattern as above)
    CASE 
        WHEN cis.default_highlights IS NOT NULL THEN
            ARRAY(
                SELECT COALESCE(
                    trans_h.translated_text,
                    h.highlight
                )
                FROM unnest(cis.default_highlights) WITH ORDINALITY AS h(highlight, ord)
                LEFT JOIN public.translations trans_h ON 
                    cis.id::text = trans_h.row_foreign_key 
                    AND trans_h.table_identifier = 'curated_itinerary_segments' 
                    AND trans_h.column_identifier = 'default_highlights[' || h.ord || ']'
                    AND trans_h.language_code = current_setting('app.current_lang', true)
                ORDER BY h.ord
            )
        ELSE NULL
    END AS localized_highlights,
    cis.walking_time_hours,
    cis.distance_km,
    cis.elevation_gain_m,
    cis.elevation_loss_m,
    cis.difficulty_notes,
    cis.terrain_notes,
    cis.services_available,
    cis.alternative_route_notes,
    cis.bad_weather_alternative,
    cis.accessibility_notes,
    -- Start location info
    cis.start_waypoint_id,
    sw.name AS start_waypoint_name,
    cis.start_town_id,
    COALESCE(trans_start_town.translated_text, st.default_name) AS start_town_name,
    -- End location info
    cis.end_waypoint_id,
    ew.name AS end_waypoint_name,
    cis.end_town_id,
    COALESCE(trans_end_town.translated_text, et.default_name) AS end_town_name,
    -- Accommodation info
    cis.suggested_accommodation_id,
    a.name AS suggested_accommodation_name,
    cis.alternative_accommodation_ids,
    -- Lunch stop info
    cis.lunch_stop_waypoint_id,
    lw.name AS lunch_stop_name,
    cis.lunch_stop_notes,
    cis.sort_order
FROM 
    public.curated_itinerary_segments cis
INNER JOIN public.segments s ON cis.segment_id = s.id
LEFT JOIN public.waypoints sw ON cis.start_waypoint_id = sw.id
LEFT JOIN public.waypoints ew ON cis.end_waypoint_id = ew.id
LEFT JOIN public.waypoints lw ON cis.lunch_stop_waypoint_id = lw.id
LEFT JOIN public.towns st ON cis.start_town_id = st.id
LEFT JOIN public.towns et ON cis.end_town_id = et.id
LEFT JOIN public.accommodations a ON cis.suggested_accommodation_id = a.id
-- Translations
LEFT JOIN public.translations trans_day_title ON 
    cis.id::text = trans_day_title.row_foreign_key 
    AND trans_day_title.table_identifier = 'curated_itinerary_segments' 
    AND trans_day_title.column_identifier = 'default_day_title' 
    AND trans_day_title.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_day_desc ON 
    cis.id::text = trans_day_desc.row_foreign_key 
    AND trans_day_desc.table_identifier = 'curated_itinerary_segments' 
    AND trans_day_desc.column_identifier = 'default_day_description' 
    AND trans_day_desc.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_start_town ON 
    st.id::text = trans_start_town.row_foreign_key 
    AND trans_start_town.table_identifier = 'towns' 
    AND trans_start_town.column_identifier = 'default_name' 
    AND trans_start_town.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_end_town ON 
    et.id::text = trans_end_town.row_foreign_key 
    AND trans_end_town.table_identifier = 'towns' 
    AND trans_end_town.column_identifier = 'default_name' 
    AND trans_end_town.language_code = current_setting('app.current_lang', true)
WHERE 
    EXISTS (
        SELECT 1 FROM public.curated_itineraries ci
        WHERE ci.id = cis.curated_itinerary_id
        AND ci.content_status_code = 'published'
        AND ci.deleted_at IS NULL
    )
ORDER BY 
    cis.day_number, cis.sort_order;

COMMENT ON VIEW public.view_curated_itinerary_segments IS 'Localized view of itinerary segments. Version 1.0.';
GRANT SELECT ON public.view_curated_itinerary_segments TO authenticated, anon;
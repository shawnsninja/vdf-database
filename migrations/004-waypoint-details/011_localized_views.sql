-- Module 4: Waypoint Details
-- 011_localized_views.sql: Localized views for master data
-- 
-- Purpose: Create views that include translations for API efficiency

-- View for localized waypoint categories
CREATE OR REPLACE VIEW public.v_waypoint_categories_localized AS
SELECT 
    wc.id,
    wc.code,
    wc.label,
    wc.description,
    wc.icon_identifier,
    wc.requires_detail_table,
    wc.sort_order,
    wc.is_active,
    wc.created_at,
    wc.updated_at,
    wc.created_by_profile_id,
    wc.updated_by_profile_id,
    -- Aggregate all translations for this category
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
FROM public.waypoint_categories_master wc
LEFT JOIN public.translations t ON (
    t.table_identifier = 'waypoint_categories_master' 
    AND t.row_foreign_key = wc.id::text
    AND t.column_identifier IN ('label', 'description')
    AND t.translation_status = 'published_live'
)
GROUP BY 
    wc.id, wc.code, wc.label, wc.description, wc.icon_identifier, 
    wc.requires_detail_table, wc.sort_order, wc.is_active, 
    wc.created_at, wc.updated_at, wc.created_by_profile_id, wc.updated_by_profile_id
ORDER BY wc.sort_order, wc.label;

COMMENT ON VIEW public.v_waypoint_categories_localized IS 
'Waypoint categories with all translations aggregated in all_translations JSONB column for API efficiency.';

-- View for localized tags
CREATE OR REPLACE VIEW public.v_tags_localized AS
SELECT 
    t.id,
    t.tag_code,
    t.label,
    t.description,
    t.tag_type,
    t.icon_identifier,
    t.sort_order,
    t.is_active,
    t.created_at,
    t.updated_at,
    t.created_by_profile_id,
    t.updated_by_profile_id,
    -- Aggregate all translations for this tag
    COALESCE(
        jsonb_object_agg(
            tr.language_code,
            jsonb_build_object(
                'label', CASE WHEN tr.column_identifier = 'label' THEN tr.translated_text END,
                'description', CASE WHEN tr.column_identifier = 'description' THEN tr.translated_text END
            )
        ) FILTER (WHERE tr.translated_text IS NOT NULL),
        '{}'::jsonb
    ) AS all_translations
FROM public.tags_master t
LEFT JOIN public.translations tr ON (
    tr.table_identifier = 'tags_master' 
    AND tr.row_foreign_key = t.id::text
    AND tr.column_identifier IN ('label', 'description')
    AND tr.translation_status = 'published_live'
)
GROUP BY 
    t.id, t.tag_code, t.label, t.description, t.tag_type, t.icon_identifier,
    t.sort_order, t.is_active, t.created_at, t.updated_at, 
    t.created_by_profile_id, t.updated_by_profile_id
ORDER BY t.tag_type, t.sort_order, t.label;

COMMENT ON VIEW public.v_tags_localized IS 
'Tags with all translations aggregated in all_translations JSONB column for API efficiency.';

-- View for localized content statuses
CREATE OR REPLACE VIEW public.v_content_statuses_localized AS
SELECT 
    cs.id,
    cs.code,
    cs.label,
    cs.description,
    cs.is_publicly_visible,
    cs.sort_order,
    cs.is_active,
    cs.created_at,
    cs.updated_at,
    cs.created_by_profile_id,
    cs.updated_by_profile_id,
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
FROM public.content_statuses_master cs
LEFT JOIN public.translations t ON (
    t.table_identifier = 'content_statuses_master' 
    AND t.row_foreign_key = cs.id::text
    AND t.column_identifier IN ('label', 'description')
    AND t.translation_status = 'published_live'
)
GROUP BY 
    cs.id, cs.code, cs.label, cs.description, cs.is_publicly_visible,
    cs.sort_order, cs.is_active, cs.created_at, cs.updated_at, 
    cs.created_by_profile_id, cs.updated_by_profile_id
ORDER BY cs.sort_order, cs.label;

COMMENT ON VIEW public.v_content_statuses_localized IS 
'Content statuses with all translations aggregated in all_translations JSONB column for API efficiency.';

-- Comprehensive waypoint view with related data
CREATE OR REPLACE VIEW public.v_waypoints_enriched AS
SELECT 
    w.id,
    w.name,
    w.slug,
    w.alternate_names_primary_lang,
    w.description,
    w.geom,
    w.latitude,
    w.longitude,
    w.elevation_meters,
    w.address_text,
    w.is_seasonal,
    w.is_trail_access_point,
    w.is_significant_trail_junction,
    w.is_franciscan_highlight_site,
    w.is_significant_pilgrim_poi,
    w.short_narrative_for_dynamic_lists,
    w.waypoint_accessibility_notes,
    w.general_tags_text,
    w.primary_data_source_waypoint,
    w.quality_score,
    w.created_at,
    w.updated_at,
    w.deleted_at,
    
    -- Category information
    wc.code AS category_code,
    wc.label AS category_label,
    wc.icon_identifier AS category_icon,
    wc.requires_detail_table,
    
    -- Content status information
    cs.code AS status_code,
    cs.label AS status_label,
    cs.is_publicly_visible,
    
    -- Town information
    t.name AS town_name,
    t.slug AS town_slug,
    
    -- Parent waypoint information
    pw.name AS parent_waypoint_name,
    pw.slug AS parent_waypoint_slug,
    
    -- Media information
    pi.id AS primary_image_id,
    pi.file_path AS primary_image_path,
    pt.id AS primary_thumbnail_id,
    pt.file_path AS primary_thumbnail_path,
    
    -- Tag information (array of tag objects)
    CASE 
        WHEN w.waypoint_subcategory_tag_ids IS NOT NULL THEN
            COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', tm.id,
                            'code', tm.tag_code,
                            'label', tm.label,
                            'type', tm.tag_type,
                            'icon', tm.icon_identifier
                        )
                        ORDER BY tm.sort_order, tm.label
                    )
                    FROM public.tags_master tm
                    WHERE tm.id = ANY(w.waypoint_subcategory_tag_ids)
                    AND tm.is_active = true
                ),
                '[]'::jsonb
            )
        ELSE '[]'::jsonb
    END AS tags,
    
    -- Media gallery count
    (
        SELECT COUNT(*)
        FROM public.waypoint_media wm
        WHERE wm.waypoint_id = w.id
    ) AS media_count
    
FROM public.waypoints w
LEFT JOIN public.waypoint_categories_master wc ON w.waypoint_primary_category_id = wc.id
LEFT JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
LEFT JOIN public.towns t ON w.town_id = t.id
LEFT JOIN public.waypoints pw ON w.parent_waypoint_id = pw.id
LEFT JOIN public.media pi ON w.primary_image_media_id = pi.id
LEFT JOIN public.media pt ON w.primary_thumbnail_media_id = pt.id
WHERE w.deleted_at IS NULL;

COMMENT ON VIEW public.v_waypoints_enriched IS 
'Comprehensive waypoint view with all related master data for efficient API queries. Excludes soft-deleted waypoints.';
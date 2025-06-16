-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 006_localized_views.sql
-- Description: Create localized views for API access to user interaction data
-- Dependencies: 
--   - 001_tip_categories_master.sql
--   - Module 1 (translations table)
-- Version: 1.0
-- =====================================================================================

-- View: public.view_tip_categories_localized
-- Purpose: Provides localized list of active tip categories with translations
CREATE OR REPLACE VIEW public.view_tip_categories_localized AS
SELECT 
    tcm.category_code,
    COALESCE(
        trans_name.translated_text,      -- Translated name in the current language
        tcm.default_name                 -- Fallback to default name
    ) AS localized_name,
    COALESCE(
        trans_desc.translated_text,      -- Translated description in the current language
        tcm.default_description          -- Fallback to default description
    ) AS localized_description,
    tcm.icon_identifier,
    tcm.sort_order,
    tcm.is_active,
    tcm.created_at,
    tcm.updated_at,
    tcm.created_by_profile_id,
    tcm.updated_by_profile_id
FROM 
    public.tip_categories_master tcm
LEFT JOIN public.translations trans_name ON 
    tcm.category_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'tip_categories_master' 
    AND trans_name.column_identifier = 'default_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    tcm.category_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'tip_categories_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE 
    tcm.is_active = true;

-- Comments on View
COMMENT ON VIEW public.view_tip_categories_localized IS 
    'Provides a localized list of active tip categories, joining with the translations table based on the current language setting (app.current_lang GUC). Falls back to default names/descriptions if translations are not found. Version 1.0.';
COMMENT ON COLUMN public.view_tip_categories_localized.category_code IS 
    'The unique code for the tip category. From tip_categories_master.category_code.';
COMMENT ON COLUMN public.view_tip_categories_localized.localized_name IS 
    'Localized name of the tip category. Falls back to default_name from tip_categories_master if no translation exists for the current language context.';
COMMENT ON COLUMN public.view_tip_categories_localized.localized_description IS 
    'Localized description of the tip category. Falls back to default_description from tip_categories_master if no translation exists. Can be NULL.';
COMMENT ON COLUMN public.view_tip_categories_localized.icon_identifier IS 
    'Optional identifier for a UI icon representing the category. From tip_categories_master.icon_identifier.';
COMMENT ON COLUMN public.view_tip_categories_localized.sort_order IS 
    'The sort order for displaying the category in UI lists. From tip_categories_master.sort_order.';
COMMENT ON COLUMN public.view_tip_categories_localized.is_active IS 
    'Indicates if the category is active (view is pre-filtered for true). From tip_categories_master.is_active.';
COMMENT ON COLUMN public.view_tip_categories_localized.created_at IS 
    'Timestamp of when the category record was created. From tip_categories_master.created_at.';
COMMENT ON COLUMN public.view_tip_categories_localized.updated_at IS 
    'Timestamp of when the category record was last updated. From tip_categories_master.updated_at.';
COMMENT ON COLUMN public.view_tip_categories_localized.created_by_profile_id IS 
    'Profile ID of the user who originally created the category record. From tip_categories_master.created_by_profile_id.';
COMMENT ON COLUMN public.view_tip_categories_localized.updated_by_profile_id IS 
    'Profile ID of the user who last updated the category record. From tip_categories_master.updated_by_profile_id.';

-- Grant SELECT permissions on the view
GRANT SELECT ON public.view_tip_categories_localized TO authenticated, anon;

-- View: public.view_user_waypoint_tips_enriched
-- Purpose: Provides enriched view of publicly visible tips with category and profile info
CREATE OR REPLACE VIEW public.view_user_waypoint_tips_enriched AS
SELECT 
    t.id,
    t.waypoint_id,
    t.tip_text,
    t.language_code,
    t.tip_category_code,
    COALESCE(
        trans_cat.translated_text,
        tc.default_name
    ) AS tip_category_name_localized,
    tc.icon_identifier AS tip_category_icon,
    t.is_pinned_by_admin,
    t.created_at,
    t.profile_id,
    p.username AS author_username,
    p.display_name AS author_display_name,
    p.profile_photo_media_id
FROM 
    public.user_waypoint_short_tips t
INNER JOIN public.profiles p ON t.profile_id = p.id
LEFT JOIN public.tip_categories_master tc ON t.tip_category_code = tc.category_code
LEFT JOIN public.translations trans_cat ON 
    tc.category_code = trans_cat.row_foreign_key 
    AND trans_cat.table_identifier = 'tip_categories_master' 
    AND trans_cat.column_identifier = 'default_name' 
    AND trans_cat.language_code = current_setting('app.current_lang', true)
WHERE 
    t.is_publicly_visible = true
ORDER BY 
    t.is_pinned_by_admin DESC,
    t.created_at DESC;

-- Comments on View
COMMENT ON VIEW public.view_user_waypoint_tips_enriched IS 
    'Provides an enriched view of publicly visible tips with author profile information and localized category names. Ordered by pinned status and creation date.';

-- Grant SELECT permissions on the view
GRANT SELECT ON public.view_user_waypoint_tips_enriched TO authenticated, anon;

-- View: public.view_waypoint_user_interaction_summary
-- Purpose: Provides summary of user interaction data per waypoint
CREATE OR REPLACE VIEW public.view_waypoint_user_interaction_summary AS
SELECT 
    w.id AS waypoint_id,
    w.up_vote_count,
    w.down_vote_count,
    COALESCE(w.up_vote_count, 0) - COALESCE(w.down_vote_count, 0) AS net_vote_score,
    CASE 
        WHEN (COALESCE(w.up_vote_count, 0) + COALESCE(w.down_vote_count, 0)) > 0 
        THEN ROUND((COALESCE(w.up_vote_count, 0)::numeric / (COALESCE(w.up_vote_count, 0) + COALESCE(w.down_vote_count, 0))::numeric) * 100, 1)
        ELSE NULL 
    END AS approval_percentage,
    COUNT(DISTINCT t.id) FILTER (WHERE t.is_publicly_visible = true) AS visible_tips_count,
    COUNT(DISTINCT t.id) FILTER (WHERE t.is_publicly_visible = true AND t.is_pinned_by_admin = true) AS pinned_tips_count,
    MAX(t.created_at) FILTER (WHERE t.is_publicly_visible = true) AS latest_tip_date
FROM 
    public.waypoints w
LEFT JOIN public.user_waypoint_short_tips t ON w.id = t.waypoint_id
WHERE 
    w.deleted_at IS NULL
GROUP BY 
    w.id, w.up_vote_count, w.down_vote_count;

-- Comments on View
COMMENT ON VIEW public.view_waypoint_user_interaction_summary IS 
    'Provides a summary of user interaction metrics for each waypoint including vote counts, net score, approval percentage, and tip statistics.';

-- Grant SELECT permissions on the view
GRANT SELECT ON public.view_waypoint_user_interaction_summary TO authenticated, anon;
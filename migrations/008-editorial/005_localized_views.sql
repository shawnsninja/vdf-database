-- =====================================================================================
-- VDF Database - Module 8: Editorial (Platform Content)
-- Migration: 005_localized_views.sql
-- Description: Create localized views for API access to editorial content
-- Dependencies: All previous Module 8 migrations, Module 1 (translations)
-- Version: 1.0
-- =====================================================================================

-- View: public.view_media_roles_localized
-- Purpose: Provides localized media roles
CREATE OR REPLACE VIEW public.view_media_roles_localized AS
SELECT 
    mrm.role_code,
    COALESCE(trans_name.translated_text, mrm.default_display_name) AS localized_display_name,
    COALESCE(trans_desc.translated_text, mrm.default_description) AS localized_description,
    mrm.icon_identifier
FROM 
    public.media_roles_master mrm
LEFT JOIN public.translations trans_name ON 
    mrm.role_code = trans_name.row_foreign_key 
    AND trans_name.table_identifier = 'media_roles_master' 
    AND trans_name.column_identifier = 'default_display_name' 
    AND trans_name.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_desc ON 
    mrm.role_code = trans_desc.row_foreign_key 
    AND trans_desc.table_identifier = 'media_roles_master' 
    AND trans_desc.column_identifier = 'default_description' 
    AND trans_desc.language_code = current_setting('app.current_lang', true)
WHERE 
    mrm.is_active = true
ORDER BY 
    mrm.role_code;

COMMENT ON VIEW public.view_media_roles_localized IS 'Localized view of media roles. Version 1.0.';
GRANT SELECT ON public.view_media_roles_localized TO authenticated, anon;

-- View: public.view_published_articles
-- Purpose: Provides a denormalized view of published articles with author and featured image
CREATE OR REPLACE VIEW public.view_published_articles AS
SELECT 
    a.id,
    a.slug,
    COALESCE(trans_title.translated_text, a.title) AS localized_title,
    COALESCE(trans_excerpt.translated_text, a.excerpt) AS localized_excerpt,
    a.publication_date,
    a.tags,
    a.author_profile_id,
    p.username AS author_username,
    p.display_name AS author_display_name,
    p.profile_photo_media_id AS author_photo_id,
    a.featured_image_media_id,
    fm.storage_path AS featured_image_path,
    fm.alt_text AS featured_image_alt_text,
    a.associated_trail_id,
    t.code AS trail_code,
    COALESCE(trans_trail.translated_text, t.default_name) AS trail_name,
    a.associated_region_id,
    r.code AS region_code,
    COALESCE(trans_region.translated_text, r.default_name) AS region_name,
    a.associated_town_id,
    tw.default_name AS town_name,
    COALESCE(trans_town.translated_text, tw.default_name) AS localized_town_name,
    a.created_at,
    a.updated_at
FROM 
    public.articles a
INNER JOIN public.profiles p ON a.author_profile_id = p.id
LEFT JOIN public.media fm ON a.featured_image_media_id = fm.id
LEFT JOIN public.trails t ON a.associated_trail_id = t.id
LEFT JOIN public.regions r ON a.associated_region_id = r.id
LEFT JOIN public.towns tw ON a.associated_town_id = tw.id
-- Translations
LEFT JOIN public.translations trans_title ON 
    a.id::text = trans_title.row_foreign_key 
    AND trans_title.table_identifier = 'articles' 
    AND trans_title.column_identifier = 'title' 
    AND trans_title.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_excerpt ON 
    a.id::text = trans_excerpt.row_foreign_key 
    AND trans_excerpt.table_identifier = 'articles' 
    AND trans_excerpt.column_identifier = 'excerpt' 
    AND trans_excerpt.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_trail ON 
    t.id::text = trans_trail.row_foreign_key 
    AND trans_trail.table_identifier = 'trails' 
    AND trans_trail.column_identifier = 'default_name' 
    AND trans_trail.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_region ON 
    r.id::text = trans_region.row_foreign_key 
    AND trans_region.table_identifier = 'regions' 
    AND trans_region.column_identifier = 'default_name' 
    AND trans_region.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_town ON 
    tw.id::text = trans_town.row_foreign_key 
    AND trans_town.table_identifier = 'towns' 
    AND trans_town.column_identifier = 'default_name' 
    AND trans_town.language_code = current_setting('app.current_lang', true)
WHERE 
    a.article_status = 'published'::public.content_visibility_status_enum
    AND a.deleted_at IS NULL
    AND (a.publication_date IS NULL OR a.publication_date <= now())
ORDER BY 
    a.publication_date DESC NULLS LAST,
    a.created_at DESC;

COMMENT ON VIEW public.view_published_articles IS 'Denormalized view of published articles with author information and featured image details. Version 1.0.';
GRANT SELECT ON public.view_published_articles TO authenticated, anon;

-- View: public.view_article_detail
-- Purpose: Provides detailed view of a single article with full content
CREATE OR REPLACE VIEW public.view_article_detail AS
SELECT 
    a.id,
    a.slug,
    COALESCE(trans_title.translated_text, a.title) AS localized_title,
    COALESCE(trans_body.translated_text, a.body_content) AS localized_body_content,
    COALESCE(trans_excerpt.translated_text, a.excerpt) AS localized_excerpt,
    a.publication_date,
    a.tags,
    a.author_profile_id,
    p.username AS author_username,
    p.display_name AS author_display_name,
    p.bio AS author_bio,
    p.profile_photo_media_id AS author_photo_id,
    a.featured_image_media_id,
    fm.storage_path AS featured_image_path,
    fm.alt_text AS featured_image_alt_text,
    fm.caption AS featured_image_caption,
    a.associated_trail_id,
    a.associated_region_id,
    a.associated_town_id,
    -- Media gallery count
    (
        SELECT COUNT(*)
        FROM public.article_media am
        WHERE am.article_id = a.id
        AND am.media_role_code = 'gallery_image'
    ) AS gallery_image_count,
    a.created_at,
    a.updated_at
FROM 
    public.articles a
INNER JOIN public.profiles p ON a.author_profile_id = p.id
LEFT JOIN public.media fm ON a.featured_image_media_id = fm.id
-- Translations
LEFT JOIN public.translations trans_title ON 
    a.id::text = trans_title.row_foreign_key 
    AND trans_title.table_identifier = 'articles' 
    AND trans_title.column_identifier = 'title' 
    AND trans_title.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_body ON 
    a.id::text = trans_body.row_foreign_key 
    AND trans_body.table_identifier = 'articles' 
    AND trans_body.column_identifier = 'body_content' 
    AND trans_body.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_excerpt ON 
    a.id::text = trans_excerpt.row_foreign_key 
    AND trans_excerpt.table_identifier = 'articles' 
    AND trans_excerpt.column_identifier = 'excerpt' 
    AND trans_excerpt.language_code = current_setting('app.current_lang', true)
WHERE 
    a.article_status = 'published'::public.content_visibility_status_enum
    AND a.deleted_at IS NULL
    AND (a.publication_date IS NULL OR a.publication_date <= now());

COMMENT ON VIEW public.view_article_detail IS 'Detailed view of published articles with full content and metadata. Version 1.0.';
GRANT SELECT ON public.view_article_detail TO authenticated, anon;

-- View: public.view_article_media_gallery
-- Purpose: Provides all media items linked to articles with localized overrides
CREATE OR REPLACE VIEW public.view_article_media_gallery AS
SELECT 
    am.id,
    am.article_id,
    am.media_id,
    am.media_role_code,
    COALESCE(trans_role.translated_text, mrm.default_display_name) AS localized_role_name,
    mrm.icon_identifier AS role_icon,
    am.display_order,
    m.storage_path,
    m.mime_type,
    m.file_size_bytes,
    m.width_pixels,
    m.height_pixels,
    m.image_variants_json,
    -- Use override if available, otherwise use media defaults
    COALESCE(trans_caption.translated_text, am.caption_override, m.caption) AS localized_caption,
    COALESCE(trans_alt.translated_text, am.alt_text_override, m.alt_text) AS localized_alt_text,
    am.created_at,
    am.updated_at
FROM 
    public.article_media am
INNER JOIN public.media m ON am.media_id = m.id
INNER JOIN public.media_roles_master mrm ON am.media_role_code = mrm.role_code
-- Article check
INNER JOIN public.articles a ON am.article_id = a.id
-- Translations for role
LEFT JOIN public.translations trans_role ON 
    mrm.role_code = trans_role.row_foreign_key 
    AND trans_role.table_identifier = 'media_roles_master' 
    AND trans_role.column_identifier = 'default_display_name' 
    AND trans_role.language_code = current_setting('app.current_lang', true)
-- Translations for overrides
LEFT JOIN public.translations trans_caption ON 
    am.id::text = trans_caption.row_foreign_key 
    AND trans_caption.table_identifier = 'article_media' 
    AND trans_caption.column_identifier = 'caption_override' 
    AND trans_caption.language_code = current_setting('app.current_lang', true)
LEFT JOIN public.translations trans_alt ON 
    am.id::text = trans_alt.row_foreign_key 
    AND trans_alt.table_identifier = 'article_media' 
    AND trans_alt.column_identifier = 'alt_text_override' 
    AND trans_alt.language_code = current_setting('app.current_lang', true)
WHERE 
    a.article_status = 'published'::public.content_visibility_status_enum
    AND a.deleted_at IS NULL
    AND (a.publication_date IS NULL OR a.publication_date <= now())
ORDER BY 
    am.article_id, am.media_role_code, am.display_order;

COMMENT ON VIEW public.view_article_media_gallery IS 'Comprehensive view of all media items linked to published articles with localized text. Version 1.0.';
GRANT SELECT ON public.view_article_media_gallery TO authenticated, anon;
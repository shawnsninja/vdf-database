-- =====================================================================================
-- VDF Database - Module 8: Editorial (Platform Content)
-- Migration: 004_article_media.sql
-- Description: Create article_media linking table for associating media with articles
-- Dependencies: 
--   - Module 1 (profiles, media)
--   - 001_media_roles_master.sql
--   - 003_articles.sql
-- Version: 1.0
-- =====================================================================================

-- Table: public.article_media
-- Purpose: Links articles to media items with roles, order, and optional text overrides
CREATE TABLE public.article_media (
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    article_id bigint NOT NULL,
    media_id uuid NOT NULL,
    media_role_code text NOT NULL,
    display_order integer NOT NULL DEFAULT 1,
    caption_override text NULL,
    alt_text_override text NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT article_media_pkey PRIMARY KEY (id),
    CONSTRAINT article_media_unique_link UNIQUE (article_id, media_id, media_role_code),
    CONSTRAINT article_media_article_id_fkey 
        FOREIGN KEY (article_id) REFERENCES public.articles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT article_media_media_id_fkey 
        FOREIGN KEY (media_id) REFERENCES public.media(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT article_media_media_role_code_fkey 
        FOREIGN KEY (media_role_code) REFERENCES public.media_roles_master(role_code) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT article_media_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT article_media_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT article_media_display_order_positive CHECK (display_order > 0),
    CONSTRAINT article_media_caption_override_length CHECK (
        caption_override IS NULL OR 
        char_length(caption_override) <= 500
    ),
    CONSTRAINT article_media_alt_text_override_length CHECK (
        alt_text_override IS NULL OR 
        char_length(alt_text_override) <= 255
    )
);

-- Comments
COMMENT ON TABLE public.article_media IS 'Links articles to media items, defining the role, order, and providing translatable text overrides. Module 8. Version 1.0.';
COMMENT ON COLUMN public.article_media.id IS 'PK. Unique identifier for the article-media link.';
COMMENT ON COLUMN public.article_media.article_id IS 'FK to public.articles.id. Identifies the article. ON DELETE CASCADE.';
COMMENT ON COLUMN public.article_media.media_id IS 'FK to public.media.id. Identifies the media item. ON DELETE RESTRICT.';
COMMENT ON COLUMN public.article_media.media_role_code IS 'FK to public.media_roles_master.role_code. Role of this media within the article. ON DELETE RESTRICT.';
COMMENT ON COLUMN public.article_media.display_order IS 'Order of appearance for media items, typically within the same article_id and media_role_code. Default 1.';
COMMENT ON COLUMN public.article_media.caption_override IS 'Optional override for the media''s default caption, specific to this article context. Max 500 chars. (Translatable via public.translations)';
COMMENT ON COLUMN public.article_media.alt_text_override IS 'Optional override for the media''s default alt text, specific to this article context. Max 255 chars. (Translatable via public.translations)';
COMMENT ON COLUMN public.article_media.created_at IS 'Timestamp of when this link was created.';
COMMENT ON COLUMN public.article_media.updated_at IS 'Timestamp of when this link was last updated (auto-updated by trigger).';
COMMENT ON COLUMN public.article_media.created_by_profile_id IS 'Profile ID of the user who created this link. FK to profiles.id.';
COMMENT ON COLUMN public.article_media.updated_by_profile_id IS 'Profile ID of the user who last updated this link. FK to profiles.id.';
COMMENT ON CONSTRAINT article_media_unique_link ON public.article_media IS 'Ensures a specific media item is not linked with the same role multiple times to the same article.';

-- Indexes
CREATE INDEX idx_article_media_article_id ON public.article_media (article_id);
CREATE INDEX idx_article_media_media_id ON public.article_media (media_id);
CREATE INDEX idx_article_media_media_role_code ON public.article_media (media_role_code);
CREATE INDEX idx_article_media_article_role_order ON public.article_media (article_id, media_role_code, display_order);
CREATE INDEX idx_article_media_created_by_profile_id ON public.article_media (created_by_profile_id) WHERE created_by_profile_id IS NOT NULL;
CREATE INDEX idx_article_media_updated_by_profile_id ON public.article_media (updated_by_profile_id) WHERE updated_by_profile_id IS NOT NULL;

-- Trigger
CREATE TRIGGER on_article_media_updated_at 
    BEFORE UPDATE ON public.article_media 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger function to clean up related translations on delete
CREATE OR REPLACE FUNCTION public.cleanup_article_media_translations() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        DELETE FROM public.translations
        WHERE table_identifier = 'article_media'
        AND column_identifier IN ('caption_override', 'alt_text_override')
        AND row_foreign_key = OLD.id::text;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.cleanup_article_media_translations() IS 'Removes related entries from public.translations for caption_override and alt_text_override when an article_media link is deleted. Runs as SECURITY DEFINER.';

-- Apply the cleanup trigger for translations
CREATE TRIGGER trigger_cleanup_article_media_translations_after_delete
    AFTER DELETE ON public.article_media
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_article_media_translations();

COMMENT ON TRIGGER trigger_cleanup_article_media_translations_after_delete ON public.article_media IS 'After an article_media link is deleted, removes its associated translations for overrides from the public.translations table.';

-- RLS Policies
ALTER TABLE public.article_media ENABLE ROW LEVEL SECURITY;

-- Users can view media links for viewable articles
CREATE POLICY "Users can view media for viewable articles" ON public.article_media 
    FOR SELECT TO authenticated, anon 
    USING (
        EXISTS (
            SELECT 1 FROM public.articles a
            WHERE a.id = article_id
            AND a.article_status = 'published'::public.content_visibility_status_enum
            AND a.deleted_at IS NULL
        )
    );

-- Users who can edit articles can manage their media links
-- This reuses the article edit permission logic
CREATE POLICY "Article editors can manage media links" ON public.article_media 
    FOR ALL TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.articles a
            WHERE a.id = article_id
            AND (
                -- Author can edit their own draft/pending articles
                (a.author_profile_id = auth.uid() 
                 AND a.article_status IN ('draft'::public.content_visibility_status_enum, 'pending_review'::public.content_visibility_status_enum)
                 AND a.deleted_at IS NULL)
                OR
                -- Admins and content managers can edit any article
                public.has_role('admin_platform')
                OR
                public.has_role('regional_content_manager')
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.articles a
            WHERE a.id = article_id
            AND (
                -- Author can edit their own draft/pending articles
                (a.author_profile_id = auth.uid() 
                 AND a.article_status IN ('draft'::public.content_visibility_status_enum, 'pending_review'::public.content_visibility_status_enum)
                 AND a.deleted_at IS NULL)
                OR
                -- Admins and content managers can edit any article
                public.has_role('admin_platform')
                OR
                public.has_role('regional_content_manager')
            )
        )
    );
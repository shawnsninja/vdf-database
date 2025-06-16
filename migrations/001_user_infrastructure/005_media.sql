-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 005_media.sql
-- Description: Central media metadata repository
-- Version: 2.2
-- =============================================

-- Create ENUM types for media
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_asset_type_enum') THEN
        CREATE TYPE public.media_asset_type_enum AS ENUM (
            'image',
            'document_pdf',
            'audio_clip',
            'video_clip',
            'gpx_file',
            'other_file'
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_licence_enum') THEN
        CREATE TYPE public.media_licence_enum AS ENUM (
            'all_rights_reserved',
            'cc_by',
            'cc_by_sa',
            'cc_by_nd',
            'cc_by_nc',
            'cc_by_nc_sa',
            'cc_by_nc_nd',
            'cc0_public_domain',
            'uploader_owns_contact_for_use',
            'official_permission_granted',
            'unknown_licence'
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_status_enum') THEN
        CREATE TYPE public.media_status_enum AS ENUM (
            'processing_upload',
            'pending_review',
            'published_approved',
            'rejected_hidden',
            'archived',
            'error_uploading'
        );
    END IF;
END$$;

-- Create media table
CREATE TABLE IF NOT EXISTS public.media (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    uploader_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    storage_bucket_name text NOT NULL,
    storage_object_path_original text NOT NULL,
    file_name_original text NOT NULL,
    file_mime_type text NOT NULL,
    file_size_bytes_original bigint NULL,
    image_width_px_original integer NULL,
    image_height_px_original integer NULL,
    image_variants_json jsonb NULL,
    default_alt_text text NULL,
    default_caption text NULL,
    attribution_text text NULL,
    attribution_url text NULL,
    licence public.media_licence_enum NULL DEFAULT 'all_rights_reserved',
    media_asset_type public.media_asset_type_enum NOT NULL DEFAULT 'image',
    media_status public.media_status_enum NOT NULL DEFAULT 'pending_review',
    tags text[] NULL,
    checksum_sha256_original text NULL,
    dominant_color_hex text NULL,
    last_linked_or_used_at timestamp with time zone NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_by_profile_id uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    deleted_at timestamp with time zone NULL,
    
    -- Constraints
    CONSTRAINT uq_media_storage_object_path UNIQUE (storage_object_path_original),
    CONSTRAINT uq_media_checksum_original UNIQUE (checksum_sha256_original),
    CONSTRAINT check_file_size_positive CHECK (file_size_bytes_original IS NULL OR file_size_bytes_original > 0),
    CONSTRAINT check_image_width_positive CHECK (image_width_px_original IS NULL OR image_width_px_original > 0),
    CONSTRAINT check_image_height_positive CHECK (image_height_px_original IS NULL OR image_height_px_original > 0),
    CONSTRAINT check_dominant_color_hex_format CHECK (
        dominant_color_hex IS NULL OR 
        dominant_color_hex ~ '^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$'
    ),
    CONSTRAINT check_attribution_url_format CHECK (
        attribution_url IS NULL OR 
        attribution_url ~* '^https?://.+'
    )
);

-- Create indexes
CREATE INDEX idx_media_uploader_profile_id ON public.media (uploader_profile_id) 
    WHERE uploader_profile_id IS NOT NULL;
CREATE INDEX idx_media_updated_by_profile_id ON public.media (updated_by_profile_id) 
    WHERE updated_by_profile_id IS NOT NULL;
CREATE INDEX idx_media_asset_type_status ON public.media (media_asset_type, media_status);
CREATE INDEX idx_media_tags ON public.media USING GIN (tags);
CREATE INDEX idx_media_deleted_at ON public.media (deleted_at) 
    WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_media_last_linked_or_used_at ON public.media (last_linked_or_used_at) 
    WHERE last_linked_or_used_at IS NOT NULL;

-- Add comments
COMMENT ON TABLE public.media IS 
'Central metadata repository for media files, referencing files in Supabase Storage and including audit trails. Version 2.2.';

COMMENT ON COLUMN public.media.uploader_profile_id IS 
'Profile ID of the user who uploaded this media (serves as created_by). If uploader''s profile is deleted, this becomes NULL.';

COMMENT ON COLUMN public.media.image_variants_json IS 
'JSONB storing relative paths/identifiers for optimized versions (e.g., thumbnails, webp). Populated by the application layer/backend. Example: {"thumb_s": "variants/uuid_thumb_s.webp", "display_l": "variants/uuid_display_l.jpg"}.';

COMMENT ON COLUMN public.media.default_alt_text IS 
'Default alternative text in the primary reference language for accessibility (WCAG). (Translatable via ''translations'' table).';

COMMENT ON COLUMN public.media.default_caption IS 
'Default caption in the primary reference language for display. (Translatable via ''translations'' table).';

COMMENT ON COLUMN public.media.updated_by_profile_id IS 
'Profile ID of the user who last significantly updated this media record (e.g., status change, key metadata update). ON DELETE SET NULL.';

COMMENT ON COLUMN public.media.last_linked_or_used_at IS 
'Timestamp when this media item was last actively linked. Updated by triggers on linking tables. Useful for identifying orphaned media.';

-- Create trigger for updated_at timestamp
CREATE TRIGGER handle_media_updated_at 
    BEFORE UPDATE ON public.media 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Note: Translation cleanup trigger will be created after translations table exists
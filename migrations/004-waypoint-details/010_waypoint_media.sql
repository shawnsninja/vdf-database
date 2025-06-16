-- Module 4: Waypoint Details
-- 010_waypoint_media.sql: Waypoint media association table
-- 
-- Purpose: Link waypoints to multiple media items with roles (galleries, etc.)
-- Dependencies: waypoints table, media table, media_roles_master from Module 2

-- Create waypoint_media linking table
CREATE TABLE IF NOT EXISTS public.waypoint_media (
    id BIGSERIAL PRIMARY KEY,
    waypoint_id BIGINT NOT NULL,
    media_id UUID NOT NULL,
    media_role_code TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 1,
    caption TEXT NULL,
    alt_text TEXT NULL,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_waypoint_media_waypoint 
        FOREIGN KEY(waypoint_id) 
        REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT fk_waypoint_media_media 
        FOREIGN KEY(media_id) 
        REFERENCES public.media(id) ON DELETE CASCADE,
    CONSTRAINT fk_waypoint_media_role 
        FOREIGN KEY(media_role_code) 
        REFERENCES public.media_roles_master(code) ON DELETE RESTRICT,
    CONSTRAINT fk_waypoint_media_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_waypoint_media_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraint to prevent duplicate media-role combinations per waypoint
    CONSTRAINT uk_waypoint_media_role UNIQUE (waypoint_id, media_id, media_role_code),
    
    -- Check constraints
    CONSTRAINT chk_waypoint_media_display_order CHECK (display_order > 0),
    CONSTRAINT chk_waypoint_media_caption_length CHECK (
        caption IS NULL OR length(caption) <= 500
    ),
    CONSTRAINT chk_waypoint_media_alt_text_length CHECK (
        alt_text IS NULL OR length(alt_text) <= 200
    )
);

-- Add table and column comments
COMMENT ON TABLE public.waypoint_media IS 'Links waypoints to media items with specific roles for galleries and media collections.';
COMMENT ON COLUMN public.waypoint_media.id IS 'Unique identifier for the waypoint-media association.';
COMMENT ON COLUMN public.waypoint_media.waypoint_id IS 'FK to waypoints table.';
COMMENT ON COLUMN public.waypoint_media.media_id IS 'FK to media table.';
COMMENT ON COLUMN public.waypoint_media.media_role_code IS 'FK to media_roles_master. Defines the purpose of this media (gallery, hero, map, etc.).';
COMMENT ON COLUMN public.waypoint_media.display_order IS 'Order for displaying media within the same role. Lower numbers appear first.';
COMMENT ON COLUMN public.waypoint_media.caption IS 'Optional caption for the media item. Max 500 chars. Translatable via translations table.';
COMMENT ON COLUMN public.waypoint_media.alt_text IS 'Alternative text for accessibility. Max 200 chars. Translatable via translations table.';
COMMENT ON COLUMN public.waypoint_media.is_featured IS 'Whether this media item should be prominently featured.';
COMMENT ON COLUMN public.waypoint_media.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.waypoint_media.updated_at IS 'Timestamp of last update.';
COMMENT ON COLUMN public.waypoint_media.created_by_profile_id IS 'Profile ID of the user who created the association.';
COMMENT ON COLUMN public.waypoint_media.updated_by_profile_id IS 'Profile ID of the user who last updated the association.';

-- Create indexes for performance
CREATE INDEX idx_waypoint_media_waypoint_id ON public.waypoint_media(waypoint_id);
CREATE INDEX idx_waypoint_media_media_id ON public.waypoint_media(media_id);
CREATE INDEX idx_waypoint_media_role_code ON public.waypoint_media(media_role_code);
CREATE INDEX idx_waypoint_media_display_order ON public.waypoint_media(waypoint_id, media_role_code, display_order);
CREATE INDEX idx_waypoint_media_is_featured ON public.waypoint_media(waypoint_id) WHERE is_featured = true;
CREATE INDEX idx_waypoint_media_created_by ON public.waypoint_media(created_by_profile_id);
CREATE INDEX idx_waypoint_media_updated_by ON public.waypoint_media(updated_by_profile_id);

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_waypoint_media_set_updated_at
    BEFORE UPDATE ON public.waypoint_media
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_waypoint_media_set_updated_at ON public.waypoint_media IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Enable Row Level Security
ALTER TABLE public.waypoint_media ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read media for published waypoints
CREATE POLICY "Allow public read access to waypoint media for published waypoints" ON public.waypoint_media
    FOR SELECT
    USING (
        waypoint_id IN (
            SELECT id FROM public.waypoints 
            WHERE content_visibility_status_id IN (
                SELECT id FROM public.content_statuses_master 
                WHERE is_publicly_visible = true AND is_active = true
            ) 
            AND deleted_at IS NULL
        )
    );

-- Authenticated users can read all waypoint media for non-deleted waypoints
CREATE POLICY "Allow authenticated users read access to waypoint media" ON public.waypoint_media
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND waypoint_id IN (
            SELECT id FROM public.waypoints WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage waypoint media
CREATE POLICY "Allow content creators to manage waypoint media" ON public.waypoint_media
    FOR ALL
    USING (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    );

-- Service role can perform all operations
CREATE POLICY "Allow service role full access to waypoint media" ON public.waypoint_media
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
-- Module 4b: Attractions
-- 009_media_linking_tables.sql: Media linking tables for attractions
-- 
-- Purpose: Create media gallery linking tables for all attraction detail types

-- Create attraction details media linking table
CREATE TABLE IF NOT EXISTS public.attraction_details_media (
    id BIGSERIAL PRIMARY KEY,
    attraction_id BIGINT NOT NULL,
    media_id BIGINT NOT NULL,
    media_role_code TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    caption TEXT NULL,
    alt_text TEXT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_attraction_media_attraction 
        FOREIGN KEY(attraction_id) 
        REFERENCES public.attraction_details(id) ON DELETE CASCADE,
    CONSTRAINT fk_attraction_media_media 
        FOREIGN KEY(media_id) 
        REFERENCES public.media(id) ON DELETE CASCADE,
    CONSTRAINT fk_attraction_media_role 
        FOREIGN KEY(media_role_code) 
        REFERENCES public.media_roles_master(code) ON DELETE RESTRICT,
    CONSTRAINT fk_attraction_media_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_attraction_media_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraints
    CONSTRAINT uq_attraction_media_unique UNIQUE(attraction_id, media_id, media_role_code),
    CONSTRAINT uq_attraction_media_primary_per_role UNIQUE(attraction_id, media_role_code, is_primary) DEFERRABLE INITIALLY DEFERRED,
    
    -- Check constraints
    CONSTRAINT chk_attraction_media_caption_length CHECK (
        caption IS NULL OR length(caption) <= 500
    ),
    CONSTRAINT chk_attraction_media_alt_text_length CHECK (
        alt_text IS NULL OR length(alt_text) <= 255
    )
);

-- Create food water sources media linking table
CREATE TABLE IF NOT EXISTS public.food_water_sources_media (
    id BIGSERIAL PRIMARY KEY,
    source_id BIGINT NOT NULL,
    media_id BIGINT NOT NULL,
    media_role_code TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    caption TEXT NULL,
    alt_text TEXT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_food_water_sources_media_source 
        FOREIGN KEY(source_id) 
        REFERENCES public.food_water_sources_details(id) ON DELETE CASCADE,
    CONSTRAINT fk_food_water_sources_media_media 
        FOREIGN KEY(media_id) 
        REFERENCES public.media(id) ON DELETE CASCADE,
    CONSTRAINT fk_food_water_sources_media_role 
        FOREIGN KEY(media_role_code) 
        REFERENCES public.media_roles_master(code) ON DELETE RESTRICT,
    CONSTRAINT fk_food_water_sources_media_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_food_water_sources_media_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraints
    CONSTRAINT uq_food_water_sources_media_unique UNIQUE(source_id, media_id, media_role_code),
    CONSTRAINT uq_food_water_sources_media_primary_per_role UNIQUE(source_id, media_role_code, is_primary) DEFERRABLE INITIALLY DEFERRED,
    
    -- Check constraints
    CONSTRAINT chk_food_water_sources_media_caption_length CHECK (
        caption IS NULL OR length(caption) <= 500
    ),
    CONSTRAINT chk_food_water_sources_media_alt_text_length CHECK (
        alt_text IS NULL OR length(alt_text) <= 255
    )
);

-- Create shops and services media linking table
CREATE TABLE IF NOT EXISTS public.shops_and_services_media (
    id BIGSERIAL PRIMARY KEY,
    shop_service_id BIGINT NOT NULL,
    media_id BIGINT NOT NULL,
    media_role_code TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    caption TEXT NULL,
    alt_text TEXT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_shops_services_media_shop_service 
        FOREIGN KEY(shop_service_id) 
        REFERENCES public.shops_and_services_details(id) ON DELETE CASCADE,
    CONSTRAINT fk_shops_services_media_media 
        FOREIGN KEY(media_id) 
        REFERENCES public.media(id) ON DELETE CASCADE,
    CONSTRAINT fk_shops_services_media_role 
        FOREIGN KEY(media_role_code) 
        REFERENCES public.media_roles_master(code) ON DELETE RESTRICT,
    CONSTRAINT fk_shops_services_media_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_shops_services_media_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraints
    CONSTRAINT uq_shops_services_media_unique UNIQUE(shop_service_id, media_id, media_role_code),
    CONSTRAINT uq_shops_services_media_primary_per_role UNIQUE(shop_service_id, media_role_code, is_primary) DEFERRABLE INITIALLY DEFERRED,
    
    -- Check constraints
    CONSTRAINT chk_shops_services_media_caption_length CHECK (
        caption IS NULL OR length(caption) <= 500
    ),
    CONSTRAINT chk_shops_services_media_alt_text_length CHECK (
        alt_text IS NULL OR length(alt_text) <= 255
    )
);

-- Add table and column comments
COMMENT ON TABLE public.attraction_details_media IS 'Media gallery linking table for attraction details.';
COMMENT ON COLUMN public.attraction_details_media.attraction_id IS 'FK to attraction_details table.';
COMMENT ON COLUMN public.attraction_details_media.media_id IS 'FK to media table.';
COMMENT ON COLUMN public.attraction_details_media.media_role_code IS 'FK to media_roles_master (primary, gallery, etc.).';
COMMENT ON COLUMN public.attraction_details_media.sort_order IS 'Display order within the media role.';
COMMENT ON COLUMN public.attraction_details_media.caption IS 'Caption or description for the media item.';
COMMENT ON COLUMN public.attraction_details_media.alt_text IS 'Alternative text for accessibility.';
COMMENT ON COLUMN public.attraction_details_media.is_primary IS 'Whether this is the primary media item for the role.';

COMMENT ON TABLE public.food_water_sources_media IS 'Media gallery linking table for food and water sources.';
COMMENT ON COLUMN public.food_water_sources_media.source_id IS 'FK to food_water_sources_details table.';
COMMENT ON COLUMN public.food_water_sources_media.media_id IS 'FK to media table.';
COMMENT ON COLUMN public.food_water_sources_media.media_role_code IS 'FK to media_roles_master (primary, gallery, etc.).';
COMMENT ON COLUMN public.food_water_sources_media.sort_order IS 'Display order within the media role.';
COMMENT ON COLUMN public.food_water_sources_media.caption IS 'Caption or description for the media item.';
COMMENT ON COLUMN public.food_water_sources_media.alt_text IS 'Alternative text for accessibility.';
COMMENT ON COLUMN public.food_water_sources_media.is_primary IS 'Whether this is the primary media item for the role.';

COMMENT ON TABLE public.shops_and_services_media IS 'Media gallery linking table for shops and services.';
COMMENT ON COLUMN public.shops_and_services_media.shop_service_id IS 'FK to shops_and_services_details table.';
COMMENT ON COLUMN public.shops_and_services_media.media_id IS 'FK to media table.';
COMMENT ON COLUMN public.shops_and_services_media.media_role_code IS 'FK to media_roles_master (primary, gallery, etc.).';
COMMENT ON COLUMN public.shops_and_services_media.sort_order IS 'Display order within the media role.';
COMMENT ON COLUMN public.shops_and_services_media.caption IS 'Caption or description for the media item.';
COMMENT ON COLUMN public.shops_and_services_media.alt_text IS 'Alternative text for accessibility.';
COMMENT ON COLUMN public.shops_and_services_media.is_primary IS 'Whether this is the primary media item for the role.';

-- Create indexes for all media linking tables
-- Attraction details media indexes
CREATE INDEX idx_attraction_media_attraction_id ON public.attraction_details_media(attraction_id);
CREATE INDEX idx_attraction_media_media_id ON public.attraction_details_media(media_id);
CREATE INDEX idx_attraction_media_role_code ON public.attraction_details_media(media_role_code);
CREATE INDEX idx_attraction_media_sort_order ON public.attraction_details_media(attraction_id, media_role_code, sort_order);
CREATE INDEX idx_attraction_media_is_primary ON public.attraction_details_media(attraction_id, media_role_code, is_primary) WHERE is_primary = true;
CREATE INDEX idx_attraction_media_created_by ON public.attraction_details_media(created_by_profile_id);
CREATE INDEX idx_attraction_media_updated_by ON public.attraction_details_media(updated_by_profile_id);

-- Food water sources media indexes
CREATE INDEX idx_food_water_sources_media_source_id ON public.food_water_sources_media(source_id);
CREATE INDEX idx_food_water_sources_media_media_id ON public.food_water_sources_media(media_id);
CREATE INDEX idx_food_water_sources_media_role_code ON public.food_water_sources_media(media_role_code);
CREATE INDEX idx_food_water_sources_media_sort_order ON public.food_water_sources_media(source_id, media_role_code, sort_order);
CREATE INDEX idx_food_water_sources_media_is_primary ON public.food_water_sources_media(source_id, media_role_code, is_primary) WHERE is_primary = true;
CREATE INDEX idx_food_water_sources_media_created_by ON public.food_water_sources_media(created_by_profile_id);
CREATE INDEX idx_food_water_sources_media_updated_by ON public.food_water_sources_media(updated_by_profile_id);

-- Shops and services media indexes
CREATE INDEX idx_shops_services_media_shop_service_id ON public.shops_and_services_media(shop_service_id);
CREATE INDEX idx_shops_services_media_media_id ON public.shops_and_services_media(media_id);
CREATE INDEX idx_shops_services_media_role_code ON public.shops_and_services_media(media_role_code);
CREATE INDEX idx_shops_services_media_sort_order ON public.shops_and_services_media(shop_service_id, media_role_code, sort_order);
CREATE INDEX idx_shops_services_media_is_primary ON public.shops_and_services_media(shop_service_id, media_role_code, is_primary) WHERE is_primary = true;
CREATE INDEX idx_shops_services_media_created_by ON public.shops_and_services_media(created_by_profile_id);
CREATE INDEX idx_shops_services_media_updated_by ON public.shops_and_services_media(updated_by_profile_id);

-- Create update triggers for all media linking tables
CREATE TRIGGER trigger_attraction_media_set_updated_at
    BEFORE UPDATE ON public.attraction_details_media
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_food_water_sources_media_set_updated_at
    BEFORE UPDATE ON public.food_water_sources_media
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_shops_services_media_set_updated_at
    BEFORE UPDATE ON public.shops_and_services_media
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security on all media linking tables
ALTER TABLE public.attraction_details_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_water_sources_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shops_and_services_media ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for attraction details media
-- Public can read media for published attractions
CREATE POLICY "Allow public read access to attraction media for published waypoints" ON public.attraction_details_media
    FOR SELECT
    USING (
        attraction_id IN (
            SELECT ad.id FROM public.attraction_details ad
            JOIN public.waypoints w ON ad.id = w.id
            JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
            WHERE ad.deleted_at IS NULL 
            AND w.deleted_at IS NULL
            AND cs.is_publicly_visible = true 
            AND cs.is_active = true
        )
    );

-- Authenticated users can read all attraction media for non-deleted attractions
CREATE POLICY "Allow authenticated users read access to attraction media" ON public.attraction_details_media
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND attraction_id IN (
            SELECT id FROM public.attraction_details WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage attraction media
CREATE POLICY "Allow content creators to manage attraction media" ON public.attraction_details_media
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
CREATE POLICY "Allow service role full access to attraction media" ON public.attraction_details_media
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Create RLS policies for food water sources media (similar pattern)
CREATE POLICY "Allow public read access to food water sources media for published waypoints" ON public.food_water_sources_media
    FOR SELECT
    USING (
        source_id IN (
            SELECT fws.id FROM public.food_water_sources_details fws
            JOIN public.waypoints w ON fws.id = w.id
            JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
            WHERE fws.deleted_at IS NULL 
            AND w.deleted_at IS NULL
            AND cs.is_publicly_visible = true 
            AND cs.is_active = true
        )
    );

CREATE POLICY "Allow authenticated users read access to food water sources media" ON public.food_water_sources_media
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND source_id IN (
            SELECT id FROM public.food_water_sources_details WHERE deleted_at IS NULL
        )
    );

CREATE POLICY "Allow content creators to manage food water sources media" ON public.food_water_sources_media
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

CREATE POLICY "Allow service role full access to food water sources media" ON public.food_water_sources_media
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Create RLS policies for shops and services media (similar pattern)
CREATE POLICY "Allow public read access to shops services media for published waypoints" ON public.shops_and_services_media
    FOR SELECT
    USING (
        shop_service_id IN (
            SELECT ss.id FROM public.shops_and_services_details ss
            JOIN public.waypoints w ON ss.id = w.id
            JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
            WHERE ss.deleted_at IS NULL 
            AND w.deleted_at IS NULL
            AND cs.is_publicly_visible = true 
            AND cs.is_active = true
        )
    );

CREATE POLICY "Allow authenticated users read access to shops services media" ON public.shops_and_services_media
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND shop_service_id IN (
            SELECT id FROM public.shops_and_services_details WHERE deleted_at IS NULL
        )
    );

CREATE POLICY "Allow content creators to manage shops services media" ON public.shops_and_services_media
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

CREATE POLICY "Allow service role full access to shops services media" ON public.shops_and_services_media
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
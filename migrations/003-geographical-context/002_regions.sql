-- Module 3: Geographical Context
-- 002_regions.sql: Major administrative or geographical regions
-- 
-- Purpose: Store core identifying, geographical, and relational information for regions
-- Dependencies: countries, media, profiles, translations

-- Create regions table
CREATE TABLE IF NOT EXISTS public.regions (
    id SERIAL PRIMARY KEY,
    slug TEXT NOT NULL UNIQUE,
    country_code TEXT NOT NULL DEFAULT 'IT' REFERENCES public.countries(iso_3166_1_alpha_2) ON DELETE RESTRICT ON UPDATE CASCADE,
    iso_3166_2_code TEXT UNIQUE,
    characteristics_tags TEXT[], -- Stores codes from characteristic_tags_master.code
    primary_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    official_tourism_url TEXT,
    map_default_latitude DOUBLE PRECISION CHECK (map_default_latitude >= -90 AND map_default_latitude <= 90),
    map_default_longitude DOUBLE PRECISION CHECK (map_default_longitude >= -180 AND map_default_longitude <= 180),
    map_default_zoom SMALLINT CHECK (map_default_zoom >= 0 AND map_default_zoom <= 22),
    geo_boundary GEOMETRY(Geometry, 4326),
    is_featured BOOLEAN NOT NULL DEFAULT false,
    content_visibility_status content_visibility_status_enum NOT NULL DEFAULT 'draft',
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT check_official_tourism_url_format CHECK (
        official_tourism_url IS NULL OR official_tourism_url ~* '^https?://.+'
    )
);

-- Add table and column comments
COMMENT ON TABLE public.regions IS 'Stores core identifying, geographical, and relational information for major regions. Textual content is in public.translations. Version: 2.0';
COMMENT ON COLUMN public.regions.id IS 'Unique identifier for each region. Used as row_foreign_key in translations table.';
COMMENT ON COLUMN public.regions.slug IS 'URL-friendly identifier (e.g., "tuscany"). Typically derived from the primary language name.';
COMMENT ON COLUMN public.regions.country_code IS '2-letter ISO 3166-1 alpha-2 country code this region belongs to.';
COMMENT ON COLUMN public.regions.iso_3166_2_code IS 'ISO 3166-2 subdivision code for the region (e.g., "IT-52" for Toscana).';
COMMENT ON COLUMN public.regions.characteristics_tags IS 'Array of code values from public.characteristic_tags_master. Describes general features. Translated names via translations linked to characteristic_tags_master.';
COMMENT ON COLUMN public.regions.primary_media_id IS 'FK to media table for the primary representative image. Alt text for this image is in translations via media table.';
COMMENT ON COLUMN public.regions.official_tourism_url IS 'URL to the region''s official tourism website. Validated for basic URL format.';
COMMENT ON COLUMN public.regions.map_default_latitude IS 'Default latitude (WGS 84) for centering maps on this region.';
COMMENT ON COLUMN public.regions.map_default_longitude IS 'Default longitude (WGS 84) for centering maps on this region.';
COMMENT ON COLUMN public.regions.map_default_zoom IS 'Default zoom level for maps when displaying this region.';
COMMENT ON COLUMN public.regions.geo_boundary IS 'Geographical boundary (Polygon/MultiPolygon, SRID 4326) of the region.';
COMMENT ON COLUMN public.regions.is_featured IS 'Flag to highlight the region in UI sections (e.g., homepage).';
COMMENT ON COLUMN public.regions.content_visibility_status IS 'Moderation status of the core region entity (translations have their own status).';
COMMENT ON COLUMN public.regions.created_by_profile_id IS 'Profile ID of the user who created the core region record.';
COMMENT ON COLUMN public.regions.updated_by_profile_id IS 'Profile ID of the user who last updated the core region record.';
COMMENT ON COLUMN public.regions.created_at IS 'Timestamp of core record creation.';
COMMENT ON COLUMN public.regions.updated_at IS 'Timestamp of core record last update. Auto-updated by trigger.';
COMMENT ON COLUMN public.regions.deleted_at IS 'Timestamp for soft deletion. Active records have deleted_at IS NULL. Deleting a region will require deleting its translations via trigger.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_regions_slug ON public.regions(slug);
CREATE INDEX IF NOT EXISTS idx_regions_country_code ON public.regions(country_code);
CREATE INDEX IF NOT EXISTS idx_regions_iso_3166_2_code ON public.regions(iso_3166_2_code) WHERE iso_3166_2_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_regions_geo_boundary ON public.regions USING GIST (geo_boundary);
CREATE INDEX IF NOT EXISTS idx_regions_is_featured ON public.regions(is_featured);
CREATE INDEX IF NOT EXISTS idx_regions_content_visibility_status ON public.regions(content_visibility_status);
CREATE INDEX IF NOT EXISTS idx_regions_characteristics_tags ON public.regions USING GIN (characteristics_tags);
CREATE INDEX IF NOT EXISTS idx_regions_deleted_at ON public.regions(deleted_at);

-- Create triggers
CREATE TRIGGER trigger_regions_set_updated_at
    BEFORE UPDATE ON public.regions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_region_translations
    AFTER DELETE ON public.regions
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Note: We'll add the validate_region_characteristics_tags trigger after creating characteristic_tags_master

-- Enable RLS
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on regions" ON public.regions
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on regions" ON public.regions
    FOR SELECT TO authenticated
    USING (deleted_at IS NULL AND content_visibility_status = 'published');

CREATE POLICY "Allow anonymous users read access on regions" ON public.regions
    FOR SELECT TO anon
    USING (deleted_at IS NULL AND content_visibility_status = 'published');
-- Module 3: Geographical Context
-- 005_towns.sql: Cities, towns, villages, and significant hamlets
-- 
-- Purpose: Store core identifying, geographical, relational, and key non-translatable attribute data for towns
-- Dependencies: regions, provinces, town_types_master, media, profiles, service_tags_master (will be created later)

-- Create towns table
CREATE TABLE IF NOT EXISTS public.towns (
    id SERIAL PRIMARY KEY,
    region_id INTEGER REFERENCES public.regions(id) ON DELETE SET NULL,
    province_id INTEGER REFERENCES public.provinces(id) ON DELETE SET NULL,
    slug TEXT NOT NULL UNIQUE,
    latitude_centroid DOUBLE PRECISION NOT NULL CHECK (latitude_centroid >= -90 AND latitude_centroid <= 90),
    longitude_centroid DOUBLE PRECISION NOT NULL CHECK (longitude_centroid >= -180 AND longitude_centroid <= 180),
    geom_centroid GEOMETRY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude_centroid, latitude_centroid), 4326)) STORED,
    geom_boundary GEOMETRY(MultiPolygon, 4326),
    elevation_meters INTEGER,
    population INTEGER CHECK (population IS NULL OR population >= 0),
    town_type_code TEXT REFERENCES public.town_types_master(code) ON DELETE SET NULL,
    istat_code TEXT UNIQUE,
    wikidata_id TEXT UNIQUE,
    geonames_id INTEGER UNIQUE,
    key_services_summary_tags TEXT[], -- Stores codes from service_tags_master.code
    town_transport_information_urls JSONB,
    has_train_station BOOLEAN NOT NULL DEFAULT false,
    has_bus_services BOOLEAN NOT NULL DEFAULT false,
    primary_media_id INTEGER REFERENCES public.media(id) ON DELETE SET NULL,
    website_url_official_town TEXT,
    is_major_stage_town BOOLEAN NOT NULL DEFAULT false,
    data_last_verified_at TIMESTAMPTZ,
    content_visibility_status content_visibility_status_enum NOT NULL DEFAULT 'draft',
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT check_website_url_official_town_format CHECK (
        website_url_official_town IS NULL OR website_url_official_town ~* '^https?://.+'
    )
);

-- Add table and column comments
COMMENT ON TABLE public.towns IS 'Stores core identifying, geographical, and relational data for towns and settlements. All displayable text content is in public.translations. Version: 2.0';
COMMENT ON COLUMN public.towns.id IS 'Primary Key. Unique identifier for each town/settlement. Used as row_foreign_key in translations.';
COMMENT ON COLUMN public.towns.slug IS 'URL-friendly identifier (e.g., "assisi"). Ideally derived from the primary language name.';
COMMENT ON COLUMN public.towns.geom_centroid IS 'PostGIS Point geometry for the town''s centroid. Auto-generated from latitude_centroid and longitude_centroid. SRID 4326.';
COMMENT ON COLUMN public.towns.key_services_summary_tags IS 'Array of code values from public.service_tags_master. Indicates general availability of key services. Tag display names/icons via service_tags_master and translations.';
COMMENT ON COLUMN public.towns.town_transport_information_urls IS 'JSONB array of objects linking to transport operator websites, e.g., [{"operator_identifier": "trenitalia_official", "url": "..."}]. Operator name translated via translations using operator_identifier.';
COMMENT ON COLUMN public.towns.deleted_at IS 'Timestamp for soft deletion. Requires trigger to delete associated translations.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_towns_slug ON public.towns(slug);
CREATE INDEX IF NOT EXISTS idx_towns_region_id ON public.towns(region_id);
CREATE INDEX IF NOT EXISTS idx_towns_province_id ON public.towns(province_id);
CREATE INDEX IF NOT EXISTS idx_towns_town_type_code ON public.towns(town_type_code);
CREATE INDEX IF NOT EXISTS idx_towns_geom_centroid ON public.towns USING GIST (geom_centroid);
CREATE INDEX IF NOT EXISTS idx_towns_geom_boundary ON public.towns USING GIST (geom_boundary) WHERE geom_boundary IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_towns_is_major_stage_town ON public.towns(is_major_stage_town);
CREATE INDEX IF NOT EXISTS idx_towns_content_visibility_status ON public.towns(content_visibility_status);
CREATE INDEX IF NOT EXISTS idx_towns_key_services_summary_tags ON public.towns USING GIN (key_services_summary_tags);
CREATE INDEX IF NOT EXISTS idx_towns_town_transport_information_urls_gin ON public.towns USING GIN (town_transport_information_urls);
CREATE INDEX IF NOT EXISTS idx_towns_deleted_at ON public.towns(deleted_at);

-- Create triggers
CREATE TRIGGER trigger_towns_set_updated_at
    BEFORE UPDATE ON public.towns
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_town_translations
    AFTER DELETE ON public.towns
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Note: We'll add the validate_town_services_tags trigger after creating service_tags_master

-- Enable RLS
ALTER TABLE public.towns ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on towns" ON public.towns
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on towns" ON public.towns
    FOR SELECT TO authenticated
    USING (deleted_at IS NULL AND content_visibility_status = 'published');

CREATE POLICY "Allow anonymous users read access on towns" ON public.towns
    FOR SELECT TO anon
    USING (deleted_at IS NULL AND content_visibility_status = 'published');
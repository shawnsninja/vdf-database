-- Module 3: Geographical Context
-- 003_provinces.sql: Administrative subdivisions like provinces, states, or counties
-- 
-- Purpose: Store core identifying information, codes, and relational links for provinces
-- Dependencies: regions, countries, profiles, translations

-- Create provinces table
CREATE TABLE IF NOT EXISTS public.provinces (
    id SERIAL PRIMARY KEY,
    region_id INTEGER NOT NULL REFERENCES public.regions(id) ON DELETE RESTRICT,
    country_code TEXT NOT NULL REFERENCES public.countries(iso_3166_1_alpha_2) ON DELETE RESTRICT ON UPDATE CASCADE,
    code TEXT UNIQUE, -- e.g., 'PG' for Perugia. May be specific to country context.
    wikidata_id TEXT UNIQUE,
    geonames_id INTEGER UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.provinces IS 'Stores administrative subdivisions like provinces or states, linking to regions and countries. Names/descriptions are in public.translations. Version: 2.0';
COMMENT ON COLUMN public.provinces.id IS 'Primary Key. Unique identifier for each province. Used as row_foreign_key in translations table.';
COMMENT ON COLUMN public.provinces.region_id IS 'Foreign key to the regions table this province belongs to. A province must belong to a region.';
COMMENT ON COLUMN public.provinces.country_code IS '2-letter ISO 3166-1 alpha-2 country code this province belongs to.';
COMMENT ON COLUMN public.provinces.code IS 'Official abbreviation or code for the province (e.g., "PG" for Perugia). Can be NULL if not applicable/standard for a country.';
COMMENT ON COLUMN public.provinces.wikidata_id IS 'Wikidata item ID for the province (e.g., "Q3862" for Province of Perugia). Highly recommended for interoperability.';
COMMENT ON COLUMN public.provinces.geonames_id IS 'GeoNames ID for the province. Recommended for interoperability.';
COMMENT ON COLUMN public.provinces.is_active IS 'Indicates if the province record is active and available for use.';
COMMENT ON COLUMN public.provinces.created_at IS 'Timestamp of when the province record was created.';
COMMENT ON COLUMN public.provinces.updated_at IS 'Timestamp of when the province record was last updated. Auto-updated by a trigger.';
COMMENT ON COLUMN public.provinces.created_by_profile_id IS 'Profile ID of the user who created the province record.';
COMMENT ON COLUMN public.provinces.updated_by_profile_id IS 'Profile ID of the user who last updated the province record.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_provinces_region_id ON public.provinces(region_id);
CREATE INDEX IF NOT EXISTS idx_provinces_country_code ON public.provinces(country_code);
CREATE INDEX IF NOT EXISTS idx_provinces_code ON public.provinces(code) WHERE code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_provinces_wikidata_id ON public.provinces(wikidata_id) WHERE wikidata_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_provinces_geonames_id ON public.provinces(geonames_id) WHERE geonames_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_provinces_is_active ON public.provinces(is_active);

-- Create triggers
CREATE TRIGGER trigger_provinces_set_updated_at
    BEFORE UPDATE ON public.provinces
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_province_translations
    AFTER DELETE ON public.provinces
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.provinces ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on provinces" ON public.provinces
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on provinces" ON public.provinces
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on provinces" ON public.provinces
    FOR SELECT TO anon
    USING (is_active = true);
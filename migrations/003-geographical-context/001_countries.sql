-- Module 3: Geographical Context
-- 001_countries.sql: Countries lookup table
-- 
-- Purpose: Store country reference data with ISO codes
-- Dependencies: None (base table)

-- Create countries table
CREATE TABLE IF NOT EXISTS public.countries (
    iso_3166_1_alpha_2 TEXT PRIMARY KEY,
    iso_3166_1_alpha_3 TEXT NOT NULL UNIQUE,
    iso_3166_1_numeric TEXT NOT NULL UNIQUE,
    name_en TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add table comments
COMMENT ON TABLE public.countries IS 'ISO 3166-1 country codes and basic data. Names are stored in English only as reference data. Version: 1.0';
COMMENT ON COLUMN public.countries.iso_3166_1_alpha_2 IS 'Primary Key. 2-letter ISO country code (e.g., IT for Italy)';
COMMENT ON COLUMN public.countries.iso_3166_1_alpha_3 IS '3-letter ISO country code (e.g., ITA for Italy)';
COMMENT ON COLUMN public.countries.iso_3166_1_numeric IS '3-digit ISO numeric code (e.g., 380 for Italy)';
COMMENT ON COLUMN public.countries.name_en IS 'English name of the country';
COMMENT ON COLUMN public.countries.is_active IS 'Whether this country is active for use in the system';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_countries_is_active ON public.countries(is_active);

-- Create updated_at trigger
CREATE TRIGGER trigger_countries_set_updated_at
    BEFORE UPDATE ON public.countries
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow all users read access to active countries" ON public.countries
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Allow admin full access to countries" ON public.countries
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

-- Insert initial data for countries relevant to Via di Francesco
INSERT INTO public.countries (
    iso_3166_1_alpha_2,
    iso_3166_1_alpha_3,
    iso_3166_1_numeric,
    name_en,
    is_active
) VALUES 
    ('IT', 'ITA', '380', 'Italy', true),
    ('VA', 'VAT', '336', 'Vatican City', true),
    ('SM', 'SMR', '674', 'San Marino', true)
ON CONFLICT (iso_3166_1_alpha_2) DO NOTHING;
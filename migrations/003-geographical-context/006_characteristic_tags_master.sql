-- Module 3: Geographical Context
-- 006_characteristic_tags_master.sql: Master lookup for region and trail characteristics
-- 
-- Purpose: Provide classification codes for geographical and trail characteristics
-- Dependencies: profiles, translations

-- Create characteristic_tags_master table
CREATE TABLE IF NOT EXISTS public.characteristic_tags_master (
    code TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    icon_identifier TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.characteristic_tags_master IS 'Master lookup for categorizing regional and trail characteristics. Names/descriptions are in public.translations. Version: 2.0';
COMMENT ON COLUMN public.characteristic_tags_master.code IS 'Primary Key. Unique code for the characteristic (e.g., ''mountainous'', ''coastal''). Used as row_foreign_key in translations.';
COMMENT ON COLUMN public.characteristic_tags_master.category IS 'Category grouping for the characteristic (e.g., ''terrain'', ''climate'', ''cultural'').';
COMMENT ON COLUMN public.characteristic_tags_master.icon_identifier IS 'Optional identifier for a UI icon associated with this characteristic.';
COMMENT ON COLUMN public.characteristic_tags_master.display_order IS 'For ordering characteristics in UI. Does not need to be unique across categories.';
COMMENT ON COLUMN public.characteristic_tags_master.is_active IS 'Indicates if the characteristic tag is active and available for use.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_characteristic_tags_master_category ON public.characteristic_tags_master(category);
CREATE INDEX IF NOT EXISTS idx_characteristic_tags_master_is_active ON public.characteristic_tags_master(is_active);
CREATE INDEX IF NOT EXISTS idx_characteristic_tags_master_display_order ON public.characteristic_tags_master(display_order);

-- Create triggers
CREATE TRIGGER trigger_characteristic_tags_master_set_updated_at
    BEFORE UPDATE ON public.characteristic_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_characteristic_tag_translations
    AFTER DELETE ON public.characteristic_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.characteristic_tags_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on characteristic_tags_master" ON public.characteristic_tags_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on characteristic_tags_master" ON public.characteristic_tags_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on characteristic_tags_master" ON public.characteristic_tags_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data for characteristic tags
INSERT INTO public.characteristic_tags_master (
    code,
    category,
    icon_identifier,
    display_order,
    is_active
) VALUES 
    -- Terrain characteristics
    ('mountainous', 'terrain', 'icon-mountain', 10, true),
    ('hilly', 'terrain', 'icon-hills', 20, true),
    ('flat', 'terrain', 'icon-flat', 30, true),
    ('coastal', 'terrain', 'icon-coast', 40, true),
    ('forested', 'terrain', 'icon-forest', 50, true),
    ('agricultural', 'terrain', 'icon-farm', 60, true),
    
    -- Cultural characteristics
    ('medieval', 'cultural', 'icon-castle', 100, true),
    ('renaissance', 'cultural', 'icon-art', 110, true),
    ('religious', 'cultural', 'icon-church', 120, true),
    ('wine_region', 'cultural', 'icon-wine', 130, true),
    ('culinary', 'cultural', 'icon-food', 140, true),
    
    -- Climate characteristics
    ('mediterranean', 'climate', 'icon-sun', 200, true),
    ('continental', 'climate', 'icon-weather', 210, true),
    ('alpine', 'climate', 'icon-snow', 220, true)
ON CONFLICT (code) DO NOTHING;
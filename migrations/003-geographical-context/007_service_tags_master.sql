-- Module 3: Geographical Context
-- 007_service_tags_master.sql: Master lookup for town services and amenities
-- 
-- Purpose: Provide classification codes for services available in towns
-- Dependencies: profiles, translations

-- Create service_tags_master table
CREATE TABLE IF NOT EXISTS public.service_tags_master (
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
COMMENT ON TABLE public.service_tags_master IS 'Master lookup for categorizing town services and amenities. Names/descriptions are in public.translations. Version: 2.0';
COMMENT ON COLUMN public.service_tags_master.code IS 'Primary Key. Unique code for the service (e.g., ''atm'', ''pharmacy''). Used as row_foreign_key in translations.';
COMMENT ON COLUMN public.service_tags_master.category IS 'Category grouping for the service (e.g., ''financial'', ''health'', ''shopping'').';
COMMENT ON COLUMN public.service_tags_master.icon_identifier IS 'Optional identifier for a UI icon associated with this service.';
COMMENT ON COLUMN public.service_tags_master.display_order IS 'For ordering services in UI. Does not need to be unique across categories.';
COMMENT ON COLUMN public.service_tags_master.is_active IS 'Indicates if the service tag is active and available for use.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_service_tags_master_category ON public.service_tags_master(category);
CREATE INDEX IF NOT EXISTS idx_service_tags_master_is_active ON public.service_tags_master(is_active);
CREATE INDEX IF NOT EXISTS idx_service_tags_master_display_order ON public.service_tags_master(display_order);

-- Create triggers
CREATE TRIGGER trigger_service_tags_master_set_updated_at
    BEFORE UPDATE ON public.service_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_service_tag_translations
    AFTER DELETE ON public.service_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.service_tags_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on service_tags_master" ON public.service_tags_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on service_tags_master" ON public.service_tags_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on service_tags_master" ON public.service_tags_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data for service tags
INSERT INTO public.service_tags_master (
    code,
    category,
    icon_identifier,
    display_order,
    is_active
) VALUES 
    -- Financial services
    ('atm', 'financial', 'icon-atm', 10, true),
    ('bank', 'financial', 'icon-bank', 20, true),
    ('currency_exchange', 'financial', 'icon-exchange', 30, true),
    
    -- Health services
    ('pharmacy', 'health', 'icon-pharmacy', 100, true),
    ('hospital', 'health', 'icon-hospital', 110, true),
    ('medical_clinic', 'health', 'icon-clinic', 120, true),
    ('emergency_services', 'health', 'icon-emergency', 130, true),
    
    -- Shopping
    ('grocery_store', 'shopping', 'icon-grocery', 200, true),
    ('market', 'shopping', 'icon-market', 210, true),
    ('bakery', 'shopping', 'icon-bakery', 220, true),
    ('outdoor_gear', 'shopping', 'icon-backpack', 230, true),
    
    -- Communication
    ('wifi', 'communication', 'icon-wifi', 300, true),
    ('post_office', 'communication', 'icon-mail', 310, true),
    ('mobile_coverage', 'communication', 'icon-signal', 320, true),
    
    -- Transportation
    ('taxi', 'transportation', 'icon-taxi', 400, true),
    ('car_rental', 'transportation', 'icon-car', 410, true),
    ('bike_rental', 'transportation', 'icon-bike', 420, true),
    ('parking', 'transportation', 'icon-parking', 430, true),
    
    -- Pilgrim services
    ('pilgrim_office', 'pilgrim', 'icon-credential', 500, true),
    ('laundry', 'pilgrim', 'icon-laundry', 510, true),
    ('luggage_storage', 'pilgrim', 'icon-luggage', 520, true),
    ('pilgrim_mass', 'pilgrim', 'icon-cross', 530, true)
ON CONFLICT (code) DO NOTHING;
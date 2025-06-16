-- Module 3: Geographical Context
-- 004_town_types_master.sql: Master lookup for categorizing towns and settlements
-- 
-- Purpose: Provide classification codes for different types of towns/settlements
-- Dependencies: profiles, translations

-- Create town_types_master table
CREATE TABLE IF NOT EXISTS public.town_types_master (
    code TEXT PRIMARY KEY,
    icon_identifier TEXT,
    display_order INTEGER NOT NULL DEFAULT 0 UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.town_types_master IS 'Master lookup for categorizing towns and settlements. Names/descriptions are in public.translations. Referenced by towns.town_type_code. Version: 2.0';
COMMENT ON COLUMN public.town_types_master.code IS 'Primary Key. Unique code for the town type (e.g., ''city_large'', ''village_paese''). Short, stable, non-changing. Used as row_foreign_key in translations.';
COMMENT ON COLUMN public.town_types_master.icon_identifier IS 'Optional identifier for a UI icon associated with this town type (e.g., ''icon-city'', ''icon-village'').';
COMMENT ON COLUMN public.town_types_master.display_order IS 'Optional: for ordering types in dropdowns or lists. Unique if used for deterministic sorting.';
COMMENT ON COLUMN public.town_types_master.is_active IS 'Indicates if the town type is active and available for use.';
COMMENT ON COLUMN public.town_types_master.created_at IS 'Timestamp of when the town type record was created.';
COMMENT ON COLUMN public.town_types_master.updated_at IS 'Timestamp of when the town type record was last updated. Auto-updated by a trigger.';
COMMENT ON COLUMN public.town_types_master.created_by_profile_id IS 'Profile ID of the user who created the town type record.';
COMMENT ON COLUMN public.town_types_master.updated_by_profile_id IS 'Profile ID of the user who last updated the town type record.';

-- Create indexes
-- PRIMARY KEY on 'code' already creates an index
-- UNIQUE constraint on 'display_order' already creates an index

-- Create triggers
CREATE TRIGGER trigger_town_types_master_set_updated_at
    BEFORE UPDATE ON public.town_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_town_type_translations
    AFTER DELETE ON public.town_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.town_types_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on town_types_master" ON public.town_types_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on town_types_master" ON public.town_types_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on town_types_master" ON public.town_types_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data for town types
INSERT INTO public.town_types_master (
    code,
    icon_identifier,
    display_order,
    is_active
) VALUES 
    ('city_large', 'icon-city-large', 10, true),
    ('city_medium', 'icon-city-medium', 20, true),
    ('city_small', 'icon-city-small', 30, true),
    ('town', 'icon-town', 40, true),
    ('village_paese', 'icon-village', 50, true),
    ('hamlet_frazione', 'icon-hamlet', 60, true),
    ('locality', 'icon-locality', 70, true),
    ('monastery', 'icon-monastery', 80, true),
    ('sanctuary', 'icon-sanctuary', 90, true)
ON CONFLICT (code) DO NOTHING;
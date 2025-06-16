-- Module 2: Core Trail Hierarchy
-- 003_usage_types_master.sql: Master lookup for trail usage types
-- 
-- Purpose: Canonical list of permitted usage types for trails
-- Dependencies: profiles, translations

-- Create usage_types_master table
CREATE TABLE IF NOT EXISTS public.usage_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    icon_identifier TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table and column comments
COMMENT ON TABLE public.usage_types_master IS 'Master lookup for trail usage types (walking, cycling, etc.). Names/descriptions in translations. Version: 2.0';
COMMENT ON COLUMN public.usage_types_master.id IS 'Primary Key. Unique identifier for each usage type.';
COMMENT ON COLUMN public.usage_types_master.code IS 'Unique code for the usage type (e.g., ''walking_only'', ''cycling_allowed''). Lowercase, stable.';
COMMENT ON COLUMN public.usage_types_master.icon_identifier IS 'Optional identifier for UI icon associated with this usage type.';
COMMENT ON COLUMN public.usage_types_master.display_order IS 'For ordering usage types in UI.';
COMMENT ON COLUMN public.usage_types_master.is_active IS 'Whether this usage type is active and available for use.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_usage_types_master_code ON public.usage_types_master(code);
CREATE INDEX IF NOT EXISTS idx_usage_types_master_is_active ON public.usage_types_master(is_active);
CREATE INDEX IF NOT EXISTS idx_usage_types_master_display_order ON public.usage_types_master(display_order);

-- Create triggers
CREATE TRIGGER trigger_usage_types_master_set_updated_at
    BEFORE UPDATE ON public.usage_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_usage_type_translations
    AFTER DELETE ON public.usage_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.usage_types_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on usage_types_master" ON public.usage_types_master
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on usage_types_master" ON public.usage_types_master
    FOR SELECT TO authenticated
    USING (is_active = true);

CREATE POLICY "Allow anonymous users read access on usage_types_master" ON public.usage_types_master
    FOR SELECT TO anon
    USING (is_active = true);

-- Insert seed data
INSERT INTO public.usage_types_master (code, icon_identifier, display_order, is_active) VALUES 
    -- Primary usage types
    ('walking_only', 'icon-walking', 10, true),
    ('cycling_allowed', 'icon-cycling', 20, true),
    ('horse_riding_allowed', 'icon-horse', 30, true),
    
    -- Accessibility
    ('wheelchair_accessible', 'icon-wheelchair', 100, true),
    ('stroller_friendly', 'icon-stroller', 110, true),
    
    -- Restrictions
    ('dogs_allowed', 'icon-dog', 200, true),
    ('mountain_bike_only', 'icon-mtb', 210, true),
    
    -- Special permissions
    ('permit_required', 'icon-permit', 300, true),
    ('guided_tours_only', 'icon-guide', 310, true)
ON CONFLICT (code) DO NOTHING;
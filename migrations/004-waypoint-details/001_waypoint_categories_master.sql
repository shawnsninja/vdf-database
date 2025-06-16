-- Module 4: Waypoint Details
-- 001_waypoint_categories_master.sql: Master list of waypoint categories
-- 
-- Purpose: Define broad classifications for waypoints (accommodation, attraction, etc.)
-- Dependencies: Module 1 (profiles, translations)

-- Create waypoint_categories_master table
CREATE TABLE IF NOT EXISTS public.waypoint_categories_master (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL CHECK (
        length(code) > 0 AND 
        length(code) <= 50 AND 
        code ~ '^[a-z0-9_]+$'
    ),
    label TEXT NOT NULL CHECK (
        length(label) > 0 AND 
        length(label) <= 100
    ),
    description TEXT NULL,
    icon_identifier TEXT NULL CHECK (
        icon_identifier IS NULL OR 
        length(icon_identifier) <= 100
    ),
    requires_detail_table TEXT NULL CHECK (
        requires_detail_table IS NULL OR 
        length(requires_detail_table) <= 100
    ),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add comments
COMMENT ON TABLE public.waypoint_categories_master IS 'Master list of broad waypoint categories (e.g., accommodation, attraction). `label` and `description` are translatable. Version 1.2';
COMMENT ON COLUMN public.waypoint_categories_master.id IS 'Unique identifier for the waypoint category.';
COMMENT ON COLUMN public.waypoint_categories_master.code IS 'Short, stable, machine-readable code (snake_case). Max 50 chars. E.g., ''accommodation_location'', ''attraction''.';
COMMENT ON COLUMN public.waypoint_categories_master.label IS 'Human-readable English label for UI and translation base. Max 100 chars. (Translatable via public.translations).';
COMMENT ON COLUMN public.waypoint_categories_master.description IS 'Optional English description of the category. (Translatable via public.translations).';
COMMENT ON COLUMN public.waypoint_categories_master.icon_identifier IS 'Name, class, or path for a UI icon. Max 100 chars.';
COMMENT ON COLUMN public.waypoint_categories_master.requires_detail_table IS 'Optional: Name of the specific detail table this category implies (e.g., ''accommodations''). For system logic. Max 100 chars.';
COMMENT ON COLUMN public.waypoint_categories_master.sort_order IS 'Determines the display order in UI lists or filters. Lower numbers appear first.';
COMMENT ON COLUMN public.waypoint_categories_master.is_active IS 'True if the category is active and available for use; false if retired. Defaults to true.';
COMMENT ON COLUMN public.waypoint_categories_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.waypoint_categories_master.updated_at IS 'Timestamp of last update (auto-updated by trigger).';
COMMENT ON COLUMN public.waypoint_categories_master.created_by_profile_id IS 'Profile ID of the user who created the record.';
COMMENT ON COLUMN public.waypoint_categories_master.updated_by_profile_id IS 'Profile ID of the user who last updated the record.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_wc_master_created_by ON public.waypoint_categories_master(created_by_profile_id);
CREATE INDEX IF NOT EXISTS idx_wc_master_updated_by ON public.waypoint_categories_master(updated_by_profile_id);
CREATE INDEX IF NOT EXISTS idx_wc_master_sort_order ON public.waypoint_categories_master(sort_order);
CREATE INDEX IF NOT EXISTS idx_wc_master_is_active ON public.waypoint_categories_master(is_active);
CREATE INDEX IF NOT EXISTS idx_wc_master_label ON public.waypoint_categories_master(label);

-- Create updated_at trigger
CREATE TRIGGER trigger_waypoint_categories_master_set_updated_at
    BEFORE UPDATE ON public.waypoint_categories_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create translation cleanup trigger
CREATE TRIGGER trigger_cleanup_waypoint_category_translations
    AFTER DELETE ON public.waypoint_categories_master
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations('waypoint_categories_master');

COMMENT ON TRIGGER trigger_cleanup_waypoint_category_translations ON public.waypoint_categories_master IS 
'Cleans up orphaned translations when a waypoint category is deleted. The trigger function should pass OLD.id::TEXT as the row foreign key.';

-- Enable Row Level Security
ALTER TABLE public.waypoint_categories_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public read access to active categories
CREATE POLICY "Allow public read access to active waypoint categories" ON public.waypoint_categories_master
    FOR SELECT
    USING (is_active = true);

-- Platform admins have full access
CREATE POLICY "Allow platform_admins full access to waypoint categories" ON public.waypoint_categories_master
    FOR ALL
    USING (public.has_role('platform_admin'))
    WITH CHECK (public.has_role('platform_admin'));

-- Admins can read all categories
CREATE POLICY "Allow admins read access to all waypoint categories" ON public.waypoint_categories_master
    FOR SELECT
    USING (public.has_role('admin'));
-- Module 2: Core Trail Hierarchy
-- 005_trail_regions.sql: Links trails to geographical regions
-- 
-- Purpose: Associate trails with the regions they traverse
-- Dependencies: trails, regions (from Module 3)

-- Create trail_regions table
CREATE TABLE IF NOT EXISTS public.trail_regions (
    id BIGSERIAL PRIMARY KEY,
    trail_id BIGINT NOT NULL REFERENCES public.trails(id) ON DELETE CASCADE,
    region_id INTEGER NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
    display_order INTEGER NOT NULL DEFAULT 0,
    regional_significance_notes TEXT,
    created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_trail_region UNIQUE (trail_id, region_id),
    CONSTRAINT unique_trail_display_order UNIQUE (trail_id, display_order)
);

-- Add table and column comments
COMMENT ON TABLE public.trail_regions IS 'Links trails to the geographical regions they traverse. Supports ordering and significance notes. Version: 2.0';
COMMENT ON COLUMN public.trail_regions.id IS 'Primary Key. Surrogate key for translation support.';
COMMENT ON COLUMN public.trail_regions.trail_id IS 'FK to trails table. CASCADE delete.';
COMMENT ON COLUMN public.trail_regions.region_id IS 'FK to regions table. CASCADE delete.';
COMMENT ON COLUMN public.trail_regions.display_order IS 'Order in which regions appear for this trail.';
COMMENT ON COLUMN public.trail_regions.regional_significance_notes IS 'English notes about trail significance in this region. Other languages in translations.';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_trail_regions_trail_id ON public.trail_regions(trail_id);
CREATE INDEX IF NOT EXISTS idx_trail_regions_region_id ON public.trail_regions(region_id);
CREATE INDEX IF NOT EXISTS idx_trail_regions_display_order ON public.trail_regions(trail_id, display_order);

-- Create triggers
CREATE TRIGGER trigger_trail_regions_set_updated_at
    BEFORE UPDATE ON public.trail_regions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_delete_trail_region_translations
    AFTER DELETE ON public.trail_regions
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_related_translations();

-- Enable RLS
ALTER TABLE public.trail_regions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow admin full access on trail_regions" ON public.trail_regions
    FOR ALL
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

CREATE POLICY "Allow authenticated users read access on trail_regions" ON public.trail_regions
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.trails t
            WHERE t.id = trail_regions.trail_id
            AND t.deleted_at IS NULL
            AND t.content_visibility_status = 'published'
        )
    );

CREATE POLICY "Allow anonymous users read access on trail_regions" ON public.trail_regions
    FOR SELECT TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.trails t
            WHERE t.id = trail_regions.trail_id
            AND t.deleted_at IS NULL
            AND t.content_visibility_status = 'published'
        )
    );
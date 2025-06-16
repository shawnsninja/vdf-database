-- Module 4a: Accommodations
-- 003_amenities_master.sql: Master table for accommodation amenities
-- 
-- Purpose: Define amenities available at accommodations

-- Create amenities master table
CREATE TABLE IF NOT EXISTS public.amenities_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    category TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_amenities_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_amenities_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_amenities_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_amenities_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_amenities_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_amenities_category_valid CHECK (
        category IN ('basic', 'comfort', 'technology', 'food_service', 'accessibility', 'pilgrim_specific', 'outdoor', 'business')
    ),
    CONSTRAINT chk_amenities_sort_order CHECK (
        sort_order >= 0
    )
);

-- Add table and column comments
COMMENT ON TABLE public.amenities_master IS 'Master table defining amenities available at accommodations (Wi-Fi, kitchen access, etc.).';
COMMENT ON COLUMN public.amenities_master.id IS 'Unique identifier for the amenity.';
COMMENT ON COLUMN public.amenities_master.code IS 'Unique code for the amenity (e.g., wifi, kitchen_access, laundry).';
COMMENT ON COLUMN public.amenities_master.label IS 'Display label for the amenity in English.';
COMMENT ON COLUMN public.amenities_master.description IS 'Optional description explaining the amenity.';
COMMENT ON COLUMN public.amenities_master.icon_identifier IS 'Optional identifier for UI icons (e.g., wifi, cutlery, washing-machine).';
COMMENT ON COLUMN public.amenities_master.category IS 'Category grouping: basic, comfort, technology, food_service, accessibility, pilgrim_specific, outdoor, business.';
COMMENT ON COLUMN public.amenities_master.sort_order IS 'Order for displaying amenities within category. Lower numbers appear first.';
COMMENT ON COLUMN public.amenities_master.is_active IS 'Whether this amenity is currently active/available.';
COMMENT ON COLUMN public.amenities_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.amenities_master.updated_at IS 'Timestamp of last update.';
COMMENT ON COLUMN public.amenities_master.created_by_profile_id IS 'Profile ID of the user who created this amenity.';
COMMENT ON COLUMN public.amenities_master.updated_by_profile_id IS 'Profile ID of the user who last updated this amenity.';

-- Create indexes
CREATE INDEX idx_amenities_code ON public.amenities_master(code);
CREATE INDEX idx_amenities_category ON public.amenities_master(category) WHERE is_active = true;
CREATE INDEX idx_amenities_sort_order ON public.amenities_master(category, sort_order) WHERE is_active = true;
CREATE INDEX idx_amenities_is_active ON public.amenities_master(is_active);
CREATE INDEX idx_amenities_created_by ON public.amenities_master(created_by_profile_id);
CREATE INDEX idx_amenities_updated_by ON public.amenities_master(updated_by_profile_id);

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_amenities_set_updated_at
    BEFORE UPDATE ON public.amenities_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_amenities_set_updated_at ON public.amenities_master IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Enable Row Level Security
ALTER TABLE public.amenities_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read active amenities
CREATE POLICY "Allow public read access to active amenities" ON public.amenities_master
    FOR SELECT
    USING (is_active = true);

-- Authenticated users can read all amenities
CREATE POLICY "Allow authenticated users read access to amenities" ON public.amenities_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Content managers can manage amenities
CREATE POLICY "Allow content managers to manage amenities" ON public.amenities_master
    FOR ALL
    USING (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    );

-- Service role can perform all operations
CREATE POLICY "Allow service role full access to amenities" ON public.amenities_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
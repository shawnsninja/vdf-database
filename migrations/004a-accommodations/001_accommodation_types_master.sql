-- Module 4a: Accommodations
-- 001_accommodation_types_master.sql: Master table for accommodation types
-- 
-- Purpose: Define different types of accommodations available for pilgrims

-- Create accommodation types master table
CREATE TABLE IF NOT EXISTS public.accommodation_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodation_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodation_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_accommodation_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_accommodation_types_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_accommodation_types_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_accommodation_types_sort_order CHECK (
        sort_order >= 0
    )
);

-- Add table and column comments
COMMENT ON TABLE public.accommodation_types_master IS 'Master table defining types of accommodations (pilgrim hostels, B&Bs, etc.) available along the Via di Francesco.';
COMMENT ON COLUMN public.accommodation_types_master.id IS 'Unique identifier for the accommodation type.';
COMMENT ON COLUMN public.accommodation_types_master.code IS 'Unique code for the accommodation type (e.g., pilgrim_hostel, bed_breakfast).';
COMMENT ON COLUMN public.accommodation_types_master.label IS 'Display label for the accommodation type in English.';
COMMENT ON COLUMN public.accommodation_types_master.description IS 'Optional description explaining the accommodation type.';
COMMENT ON COLUMN public.accommodation_types_master.icon_identifier IS 'Optional identifier for UI icons (e.g., bed, home, tent).';
COMMENT ON COLUMN public.accommodation_types_master.sort_order IS 'Order for displaying types. Lower numbers appear first.';
COMMENT ON COLUMN public.accommodation_types_master.is_active IS 'Whether this accommodation type is currently active/available.';
COMMENT ON COLUMN public.accommodation_types_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.accommodation_types_master.updated_at IS 'Timestamp of last update.';
COMMENT ON COLUMN public.accommodation_types_master.created_by_profile_id IS 'Profile ID of the user who created this type.';
COMMENT ON COLUMN public.accommodation_types_master.updated_by_profile_id IS 'Profile ID of the user who last updated this type.';

-- Create indexes
CREATE INDEX idx_accommodation_types_code ON public.accommodation_types_master(code);
CREATE INDEX idx_accommodation_types_sort_order ON public.accommodation_types_master(sort_order) WHERE is_active = true;
CREATE INDEX idx_accommodation_types_is_active ON public.accommodation_types_master(is_active);
CREATE INDEX idx_accommodation_types_created_by ON public.accommodation_types_master(created_by_profile_id);
CREATE INDEX idx_accommodation_types_updated_by ON public.accommodation_types_master(updated_by_profile_id);

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_accommodation_types_set_updated_at
    BEFORE UPDATE ON public.accommodation_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_accommodation_types_set_updated_at ON public.accommodation_types_master IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Enable Row Level Security
ALTER TABLE public.accommodation_types_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read active accommodation types
CREATE POLICY "Allow public read access to active accommodation types" ON public.accommodation_types_master
    FOR SELECT
    USING (is_active = true);

-- Authenticated users can read all accommodation types
CREATE POLICY "Allow authenticated users read access to accommodation types" ON public.accommodation_types_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Content managers can manage accommodation types
CREATE POLICY "Allow content managers to manage accommodation types" ON public.accommodation_types_master
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
CREATE POLICY "Allow service role full access to accommodation types" ON public.accommodation_types_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
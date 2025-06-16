-- Module 4a: Accommodations
-- 005_booking_statuses_master.sql: Master table for booking statuses
-- 
-- Purpose: Define booking availability statuses for accommodations

-- Create booking statuses master table
CREATE TABLE IF NOT EXISTS public.booking_statuses_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_booking_statuses_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_booking_statuses_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_booking_statuses_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_booking_statuses_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_booking_statuses_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_booking_statuses_sort_order CHECK (
        sort_order >= 0
    )
);

-- Add table and column comments
COMMENT ON TABLE public.booking_statuses_master IS 'Master table defining booking availability statuses for accommodations.';
COMMENT ON COLUMN public.booking_statuses_master.id IS 'Unique identifier for the booking status.';
COMMENT ON COLUMN public.booking_statuses_master.code IS 'Unique code for the booking status (e.g., open, closed, seasonal).';
COMMENT ON COLUMN public.booking_statuses_master.label IS 'Display label for the booking status in English.';
COMMENT ON COLUMN public.booking_statuses_master.description IS 'Optional description explaining the booking status.';
COMMENT ON COLUMN public.booking_statuses_master.icon_identifier IS 'Optional identifier for UI icons (e.g., check, x, calendar).';
COMMENT ON COLUMN public.booking_statuses_master.is_available IS 'Whether this status indicates availability for booking.';
COMMENT ON COLUMN public.booking_statuses_master.sort_order IS 'Order for displaying statuses. Lower numbers appear first.';
COMMENT ON COLUMN public.booking_statuses_master.is_active IS 'Whether this booking status is currently active/available.';
COMMENT ON COLUMN public.booking_statuses_master.created_at IS 'Timestamp of record creation.';
COMMENT ON COLUMN public.booking_statuses_master.updated_at IS 'Timestamp of last update.';
COMMENT ON COLUMN public.booking_statuses_master.created_by_profile_id IS 'Profile ID of the user who created this status.';
COMMENT ON COLUMN public.booking_statuses_master.updated_by_profile_id IS 'Profile ID of the user who last updated this status.';

-- Create indexes
CREATE INDEX idx_booking_statuses_code ON public.booking_statuses_master(code);
CREATE INDEX idx_booking_statuses_is_available ON public.booking_statuses_master(is_available) WHERE is_active = true;
CREATE INDEX idx_booking_statuses_sort_order ON public.booking_statuses_master(sort_order) WHERE is_active = true;
CREATE INDEX idx_booking_statuses_is_active ON public.booking_statuses_master(is_active);
CREATE INDEX idx_booking_statuses_created_by ON public.booking_statuses_master(created_by_profile_id);
CREATE INDEX idx_booking_statuses_updated_by ON public.booking_statuses_master(updated_by_profile_id);

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_booking_statuses_set_updated_at
    BEFORE UPDATE ON public.booking_statuses_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_booking_statuses_set_updated_at ON public.booking_statuses_master IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Insert seed data
INSERT INTO public.booking_statuses_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    is_available,
    sort_order
) VALUES 
    ('open', 'Open/Available', 'Accommodation is currently accepting bookings.', 'check-circle', true, 10),
    ('full', 'Full/Booked', 'Accommodation is currently full with no availability.', 'x-circle', false, 20),
    ('closed_temporarily', 'Temporarily Closed', 'Accommodation is temporarily closed for maintenance or other reasons.', 'pause-circle', false, 30),
    ('closed_seasonal', 'Closed (Seasonal)', 'Accommodation is closed for the season.', 'calendar-x', false, 40),
    ('by_appointment', 'By Appointment Only', 'Accommodation requires advance booking or appointment.', 'calendar-check', true, 50),
    ('limited_availability', 'Limited Availability', 'Accommodation has very limited space available.', 'alert-circle', true, 60),
    ('closed_permanently', 'Permanently Closed', 'Accommodation is no longer operating.', 'x-square', false, 70),
    ('unknown', 'Status Unknown', 'Booking status has not been verified recently.', 'help-circle', false, 80)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    is_available = EXCLUDED.is_available,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Enable Row Level Security
ALTER TABLE public.booking_statuses_master ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read active booking statuses
CREATE POLICY "Allow public read access to active booking statuses" ON public.booking_statuses_master
    FOR SELECT
    USING (is_active = true);

-- Authenticated users can read all booking statuses
CREATE POLICY "Allow authenticated users read access to booking statuses" ON public.booking_statuses_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Content managers can manage booking statuses
CREATE POLICY "Allow content managers to manage booking statuses" ON public.booking_statuses_master
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
CREATE POLICY "Allow service role full access to booking statuses" ON public.booking_statuses_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
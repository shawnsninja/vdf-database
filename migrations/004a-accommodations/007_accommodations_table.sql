-- Module 4a: Accommodations
-- 007_accommodations_table.sql: Main accommodations table
-- 
-- Purpose: Core accommodation details extending waypoints table

-- Create accommodations table (1:1 extension of waypoints)
CREATE TABLE IF NOT EXISTS public.accommodations (
    id BIGINT PRIMARY KEY,
    accommodation_type_id INTEGER NOT NULL,
    booking_status_id INTEGER NOT NULL,
    price_range_id INTEGER NULL,
    
    -- Basic accommodation info
    host_name TEXT NULL,
    host_contact_email TEXT NULL,
    host_contact_phone TEXT NULL,
    website_url TEXT NULL,
    booking_platform_url TEXT NULL,
    
    -- Capacity and availability
    total_beds INTEGER NULL,
    total_rooms INTEGER NULL,
    pilgrim_beds_available INTEGER NULL,
    accepts_reservations BOOLEAN NOT NULL DEFAULT true,
    advance_booking_required BOOLEAN NOT NULL DEFAULT false,
    seasonal_operation BOOLEAN NOT NULL DEFAULT false,
    seasonal_open_date DATE NULL,
    seasonal_close_date DATE NULL,
    
    -- Pricing information
    price_per_night_eur DECIMAL(8,2) NULL,
    price_currency_code TEXT NOT NULL DEFAULT 'EUR',
    price_notes TEXT NULL,
    pilgrim_discount_available BOOLEAN NOT NULL DEFAULT false,
    
    -- Services and policies
    check_in_time TIME NULL,
    check_out_time TIME NULL,
    curfew_time TIME NULL,
    minimum_stay_nights INTEGER NULL DEFAULT 1,
    maximum_stay_nights INTEGER NULL,
    allows_pets BOOLEAN NOT NULL DEFAULT false,
    smoking_policy TEXT NULL,
    
    -- Special notes
    pilgrim_specific_notes TEXT NULL,
    host_languages TEXT[] NULL,
    special_features_notes TEXT NULL,
    accessibility_notes TEXT NULL,
    
    -- Data management
    last_verified_date DATE NULL,
    data_source TEXT NULL,
    data_confidence_score INTEGER NULL,
    
    -- Standard audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodations_waypoint 
        FOREIGN KEY(id) 
        REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodations_type 
        FOREIGN KEY(accommodation_type_id) 
        REFERENCES public.accommodation_types_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_accommodations_booking_status 
        FOREIGN KEY(booking_status_id) 
        REFERENCES public.booking_statuses_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_accommodations_price_range 
        FOREIGN KEY(price_range_id) 
        REFERENCES public.establishment_price_ranges_master(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodations_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodations_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_accommodations_host_email CHECK (
        host_contact_email IS NULL OR host_contact_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    ),
    CONSTRAINT chk_accommodations_website_url CHECK (
        website_url IS NULL OR website_url ~ '^https?://'
    ),
    CONSTRAINT chk_accommodations_booking_url CHECK (
        booking_platform_url IS NULL OR booking_platform_url ~ '^https?://'
    ),
    CONSTRAINT chk_accommodations_capacity_positive CHECK (
        (total_beds IS NULL OR total_beds > 0) AND
        (total_rooms IS NULL OR total_rooms > 0) AND
        (pilgrim_beds_available IS NULL OR pilgrim_beds_available >= 0)
    ),
    CONSTRAINT chk_accommodations_pilgrim_beds_logical CHECK (
        pilgrim_beds_available IS NULL OR total_beds IS NULL OR pilgrim_beds_available <= total_beds
    ),
    CONSTRAINT chk_accommodations_price_positive CHECK (
        price_per_night_eur IS NULL OR price_per_night_eur >= 0
    ),
    CONSTRAINT chk_accommodations_price_currency CHECK (
        price_currency_code IN ('EUR', 'USD', 'GBP', 'CHF')
    ),
    CONSTRAINT chk_accommodations_stay_nights CHECK (
        (minimum_stay_nights IS NULL OR minimum_stay_nights > 0) AND
        (maximum_stay_nights IS NULL OR maximum_stay_nights > 0) AND
        (minimum_stay_nights IS NULL OR maximum_stay_nights IS NULL OR minimum_stay_nights <= maximum_stay_nights)
    ),
    CONSTRAINT chk_accommodations_smoking_policy CHECK (
        smoking_policy IS NULL OR smoking_policy IN ('no_smoking', 'smoking_allowed', 'designated_areas', 'outdoor_only')
    ),
    CONSTRAINT chk_accommodations_seasonal_dates CHECK (
        NOT seasonal_operation OR (seasonal_open_date IS NOT NULL AND seasonal_close_date IS NOT NULL)
    ),
    CONSTRAINT chk_accommodations_data_confidence CHECK (
        data_confidence_score IS NULL OR (data_confidence_score >= 0 AND data_confidence_score <= 100)
    ),
    CONSTRAINT chk_accommodations_host_name_length CHECK (
        host_name IS NULL OR length(host_name) <= 255
    ),
    CONSTRAINT chk_accommodations_price_notes_length CHECK (
        price_notes IS NULL OR length(price_notes) <= 500
    ),
    CONSTRAINT chk_accommodations_pilgrim_notes_length CHECK (
        pilgrim_specific_notes IS NULL OR length(pilgrim_specific_notes) <= 1000
    ),
    CONSTRAINT chk_accommodations_special_features_length CHECK (
        special_features_notes IS NULL OR length(special_features_notes) <= 1000
    ),
    CONSTRAINT chk_accommodations_accessibility_notes_length CHECK (
        accessibility_notes IS NULL OR length(accessibility_notes) <= 1000
    )
);

-- Add table and column comments
COMMENT ON TABLE public.accommodations IS 'Detailed accommodation information extending the waypoints table for lodging facilities.';
COMMENT ON COLUMN public.accommodations.id IS 'FK to waypoints table. This is a 1:1 extension.';
COMMENT ON COLUMN public.accommodations.accommodation_type_id IS 'FK to accommodation_types_master (pilgrim hostel, B&B, etc.).';
COMMENT ON COLUMN public.accommodations.booking_status_id IS 'FK to booking_statuses_master (open, closed, etc.).';
COMMENT ON COLUMN public.accommodations.price_range_id IS 'FK to establishment_price_ranges_master for general pricing category.';
COMMENT ON COLUMN public.accommodations.host_name IS 'Name of the accommodation host/owner.';
COMMENT ON COLUMN public.accommodations.host_contact_email IS 'Email contact for the accommodation.';
COMMENT ON COLUMN public.accommodations.host_contact_phone IS 'Phone contact for the accommodation.';
COMMENT ON COLUMN public.accommodations.website_url IS 'Official website URL.';
COMMENT ON COLUMN public.accommodations.booking_platform_url IS 'URL for online booking (Booking.com, etc.).';
COMMENT ON COLUMN public.accommodations.total_beds IS 'Total number of beds/sleeping spaces available.';
COMMENT ON COLUMN public.accommodations.total_rooms IS 'Total number of rooms available.';
COMMENT ON COLUMN public.accommodations.pilgrim_beds_available IS 'Number of beds specifically reserved for pilgrims.';
COMMENT ON COLUMN public.accommodations.accepts_reservations IS 'Whether the accommodation accepts advance reservations.';
COMMENT ON COLUMN public.accommodations.advance_booking_required IS 'Whether advance booking is required.';
COMMENT ON COLUMN public.accommodations.seasonal_operation IS 'Whether the accommodation operates seasonally.';
COMMENT ON COLUMN public.accommodations.seasonal_open_date IS 'Date when seasonal accommodation opens (if applicable).';
COMMENT ON COLUMN public.accommodations.seasonal_close_date IS 'Date when seasonal accommodation closes (if applicable).';
COMMENT ON COLUMN public.accommodations.price_per_night_eur IS 'Typical price per night in the specified currency.';
COMMENT ON COLUMN public.accommodations.price_currency_code IS 'Currency code for pricing (EUR, USD, etc.).';
COMMENT ON COLUMN public.accommodations.price_notes IS 'Additional notes about pricing, discounts, etc.';
COMMENT ON COLUMN public.accommodations.pilgrim_discount_available IS 'Whether discounts are available for pilgrims.';
COMMENT ON COLUMN public.accommodations.check_in_time IS 'Typical check-in time.';
COMMENT ON COLUMN public.accommodations.check_out_time IS 'Typical check-out time.';
COMMENT ON COLUMN public.accommodations.curfew_time IS 'Curfew time if applicable.';
COMMENT ON COLUMN public.accommodations.minimum_stay_nights IS 'Minimum number of nights for booking.';
COMMENT ON COLUMN public.accommodations.maximum_stay_nights IS 'Maximum number of nights allowed.';
COMMENT ON COLUMN public.accommodations.allows_pets IS 'Whether pets are allowed.';
COMMENT ON COLUMN public.accommodations.smoking_policy IS 'Smoking policy: no_smoking, smoking_allowed, designated_areas, outdoor_only.';
COMMENT ON COLUMN public.accommodations.pilgrim_specific_notes IS 'Special notes for pilgrims.';
COMMENT ON COLUMN public.accommodations.host_languages IS 'Array of languages spoken by hosts.';
COMMENT ON COLUMN public.accommodations.special_features_notes IS 'Description of special features or amenities.';
COMMENT ON COLUMN public.accommodations.accessibility_notes IS 'Detailed accessibility information.';
COMMENT ON COLUMN public.accommodations.last_verified_date IS 'Date when accommodation information was last verified.';
COMMENT ON COLUMN public.accommodations.data_source IS 'Source of accommodation data.';
COMMENT ON COLUMN public.accommodations.data_confidence_score IS 'Confidence score for data accuracy (0-100).';

-- Create indexes for performance
CREATE INDEX idx_accommodations_type_id ON public.accommodations(accommodation_type_id);
CREATE INDEX idx_accommodations_booking_status ON public.accommodations(booking_status_id);
CREATE INDEX idx_accommodations_price_range ON public.accommodations(price_range_id);
CREATE INDEX idx_accommodations_accepts_reservations ON public.accommodations(accepts_reservations) WHERE deleted_at IS NULL;
CREATE INDEX idx_accommodations_seasonal ON public.accommodations(seasonal_operation, seasonal_open_date, seasonal_close_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_accommodations_pilgrim_beds ON public.accommodations(pilgrim_beds_available) WHERE deleted_at IS NULL AND pilgrim_beds_available > 0;
CREATE INDEX idx_accommodations_price ON public.accommodations(price_per_night_eur) WHERE deleted_at IS NULL AND price_per_night_eur IS NOT NULL;
CREATE INDEX idx_accommodations_last_verified ON public.accommodations(last_verified_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_accommodations_deleted_at ON public.accommodations(deleted_at);
CREATE INDEX idx_accommodations_created_by ON public.accommodations(created_by_profile_id);
CREATE INDEX idx_accommodations_updated_by ON public.accommodations(updated_by_profile_id);

-- GIN index for host languages array
CREATE INDEX idx_accommodations_host_languages ON public.accommodations USING GIN(host_languages) WHERE deleted_at IS NULL;

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_accommodations_set_updated_at
    BEFORE UPDATE ON public.accommodations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_accommodations_set_updated_at ON public.accommodations IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Translation cleanup trigger (when accommodation is deleted)
CREATE TRIGGER trigger_accommodations_cleanup_translations
    AFTER UPDATE OF deleted_at ON public.accommodations
    FOR EACH ROW
    WHEN (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL)
    EXECUTE FUNCTION public.cleanup_related_translations();

COMMENT ON TRIGGER trigger_accommodations_cleanup_translations ON public.accommodations IS 
'Trigger to clean up translations when accommodation is soft-deleted.';

-- Enable Row Level Security
ALTER TABLE public.accommodations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read accommodations for published waypoints (non-deleted)
CREATE POLICY "Allow public read access to accommodations for published waypoints" ON public.accommodations
    FOR SELECT
    USING (
        deleted_at IS NULL
        AND id IN (
            SELECT w.id FROM public.waypoints w
            JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
            WHERE w.deleted_at IS NULL 
            AND cs.is_publicly_visible = true 
            AND cs.is_active = true
        )
    );

-- Authenticated users can read all non-deleted accommodations
CREATE POLICY "Allow authenticated users read access to accommodations" ON public.accommodations
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND deleted_at IS NULL
        AND id IN (
            SELECT id FROM public.waypoints WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage accommodations
CREATE POLICY "Allow content creators to manage accommodations" ON public.accommodations
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
CREATE POLICY "Allow service role full access to accommodations" ON public.accommodations
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
-- Module 4b: Attractions
-- 008_shops_and_services_details.sql: Shops and services details table
-- 
-- Purpose: Core shops and services details extending waypoints table

-- Create shops and services details table (1:1 extension of waypoints)
CREATE TABLE IF NOT EXISTS public.shops_and_services_details (
    id BIGINT PRIMARY KEY,
    shop_service_type_ids INTEGER[] NOT NULL,
    price_range_id INTEGER NULL,
    
    -- Operating information
    opening_hours JSONB NULL,
    seasonal_hours JSONB NULL,
    special_closure_dates DATE[] NULL,
    holiday_hours JSONB NULL,
    
    -- Contact and location
    contact_phone TEXT NULL,
    contact_email TEXT NULL,
    website_url TEXT NULL,
    online_ordering_url TEXT NULL,
    
    -- Business information
    business_name TEXT NULL,
    business_registration_number TEXT NULL,
    vat_number TEXT NULL,
    accepts_reservations BOOLEAN NOT NULL DEFAULT false,
    reservation_required BOOLEAN NOT NULL DEFAULT false,
    
    -- Payment and pricing
    payment_method_ids INTEGER[] NULL,
    accepts_credit_cards BOOLEAN NOT NULL DEFAULT true,
    accepts_cash BOOLEAN NOT NULL DEFAULT true,
    currency_accepted TEXT[] NULL DEFAULT ARRAY['EUR'],
    average_price_eur DECIMAL(8,2) NULL,
    pilgrim_discount_available BOOLEAN NOT NULL DEFAULT false,
    pilgrim_discount_percentage DECIMAL(5,2) NULL,
    pilgrim_discount_notes TEXT NULL,
    
    -- Food service specifics (if applicable)
    meal_type_ids INTEGER[] NULL,
    dietary_option_ids INTEGER[] NULL,
    serves_alcohol BOOLEAN NOT NULL DEFAULT false,
    takeaway_available BOOLEAN NOT NULL DEFAULT false,
    delivery_available BOOLEAN NOT NULL DEFAULT false,
    delivery_radius_km DECIMAL(5,2) NULL,
    seating_capacity INTEGER NULL,
    outdoor_seating BOOLEAN NOT NULL DEFAULT false,
    
    -- Services and facilities
    wifi_available BOOLEAN NOT NULL DEFAULT false,
    wifi_password TEXT NULL,
    parking_available BOOLEAN NOT NULL DEFAULT false,
    parking_notes TEXT NULL,
    wheelchair_accessible BOOLEAN NOT NULL DEFAULT false,
    accessibility_notes TEXT NULL,
    luggage_storage BOOLEAN NOT NULL DEFAULT false,
    bicycle_parking BOOLEAN NOT NULL DEFAULT false,
    
    -- Pilgrim-specific services
    credential_stamping BOOLEAN NOT NULL DEFAULT false,
    luggage_transport_service BOOLEAN NOT NULL DEFAULT false,
    equipment_rental BOOLEAN NOT NULL DEFAULT false,
    equipment_repair BOOLEAN NOT NULL DEFAULT false,
    pilgrim_information BOOLEAN NOT NULL DEFAULT false,
    multilingual_staff BOOLEAN NOT NULL DEFAULT false,
    languages_spoken TEXT[] NULL,
    
    -- Quality and ratings
    quality_rating DECIMAL(3,2) NULL,
    service_rating DECIMAL(3,2) NULL,
    value_rating DECIMAL(3,2) NULL,
    overall_rating DECIMAL(3,2) NULL,
    review_count INTEGER NULL DEFAULT 0,
    
    -- Operational details
    staff_count INTEGER NULL,
    established_year INTEGER NULL,
    chain_franchise TEXT NULL,
    local_ownership BOOLEAN NOT NULL DEFAULT true,
    
    -- Seasonal information
    seasonal_business BOOLEAN NOT NULL DEFAULT false,
    peak_season_months INTEGER[] NULL,
    off_season_closure BOOLEAN NOT NULL DEFAULT false,
    
    -- Data management
    last_verified_date DATE NULL,
    data_source TEXT NULL,
    data_confidence_score INTEGER NULL,
    verification_notes TEXT NULL,
    
    -- Standard audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_shops_services_waypoint 
        FOREIGN KEY(id) 
        REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT fk_shops_services_price_range 
        FOREIGN KEY(price_range_id) 
        REFERENCES public.establishment_price_ranges_master(id) ON DELETE SET NULL,
    CONSTRAINT fk_shops_services_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_shops_services_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_shops_services_contact_email CHECK (
        contact_email IS NULL OR contact_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    ),
    CONSTRAINT chk_shops_services_website_url CHECK (
        website_url IS NULL OR website_url ~ '^https?://'
    ),
    CONSTRAINT chk_shops_services_online_ordering_url CHECK (
        online_ordering_url IS NULL OR online_ordering_url ~ '^https?://'
    ),
    CONSTRAINT chk_shops_services_average_price CHECK (
        average_price_eur IS NULL OR average_price_eur >= 0
    ),
    CONSTRAINT chk_shops_services_pilgrim_discount CHECK (
        pilgrim_discount_percentage IS NULL OR (pilgrim_discount_percentage >= 0 AND pilgrim_discount_percentage <= 100)
    ),
    CONSTRAINT chk_shops_services_delivery_radius CHECK (
        delivery_radius_km IS NULL OR delivery_radius_km >= 0
    ),
    CONSTRAINT chk_shops_services_seating_capacity CHECK (
        seating_capacity IS NULL OR seating_capacity > 0
    ),
    CONSTRAINT chk_shops_services_quality_rating CHECK (
        quality_rating IS NULL OR (quality_rating >= 0.0 AND quality_rating <= 5.0)
    ),
    CONSTRAINT chk_shops_services_service_rating CHECK (
        service_rating IS NULL OR (service_rating >= 0.0 AND service_rating <= 5.0)
    ),
    CONSTRAINT chk_shops_services_value_rating CHECK (
        value_rating IS NULL OR (value_rating >= 0.0 AND value_rating <= 5.0)
    ),
    CONSTRAINT chk_shops_services_overall_rating CHECK (
        overall_rating IS NULL OR (overall_rating >= 0.0 AND overall_rating <= 5.0)
    ),
    CONSTRAINT chk_shops_services_review_count CHECK (
        review_count >= 0
    ),
    CONSTRAINT chk_shops_services_staff_count CHECK (
        staff_count IS NULL OR staff_count > 0
    ),
    CONSTRAINT chk_shops_services_established_year CHECK (
        established_year IS NULL OR (established_year >= 1000 AND established_year <= EXTRACT(YEAR FROM CURRENT_DATE))
    ),
    CONSTRAINT chk_shops_services_data_confidence CHECK (
        data_confidence_score IS NULL OR (data_confidence_score >= 0 AND data_confidence_score <= 100)
    ),
    CONSTRAINT chk_shops_services_peak_months CHECK (
        peak_season_months IS NULL OR (
            array_length(peak_season_months, 1) > 0 AND
            NOT EXISTS (
                SELECT 1 FROM unnest(peak_season_months) AS month
                WHERE month < 1 OR month > 12
            )
        )
    ),
    CONSTRAINT chk_shops_services_currency_format CHECK (
        currency_accepted IS NULL OR (
            array_length(currency_accepted, 1) > 0 AND
            NOT EXISTS (
                SELECT 1 FROM unnest(currency_accepted) AS currency
                WHERE currency !~ '^[A-Z]{3}$'
            )
        )
    ),
    CONSTRAINT chk_shops_services_business_name_length CHECK (
        business_name IS NULL OR length(business_name) <= 255
    ),
    CONSTRAINT chk_shops_services_pilgrim_discount_notes_length CHECK (
        pilgrim_discount_notes IS NULL OR length(pilgrim_discount_notes) <= 500
    ),
    CONSTRAINT chk_shops_services_parking_notes_length CHECK (
        parking_notes IS NULL OR length(parking_notes) <= 500
    ),
    CONSTRAINT chk_shops_services_accessibility_notes_length CHECK (
        accessibility_notes IS NULL OR length(accessibility_notes) <= 1000
    ),
    CONSTRAINT chk_shops_services_chain_franchise_length CHECK (
        chain_franchise IS NULL OR length(chain_franchise) <= 255
    ),
    CONSTRAINT chk_shops_services_verification_notes_length CHECK (
        verification_notes IS NULL OR length(verification_notes) <= 1000
    ),
    CONSTRAINT chk_shops_services_reservation_logic CHECK (
        NOT reservation_required OR accepts_reservations = true
    ),
    CONSTRAINT chk_shops_services_delivery_logic CHECK (
        NOT delivery_available OR delivery_radius_km IS NOT NULL
    ),
    CONSTRAINT chk_shops_services_discount_logic CHECK (
        NOT pilgrim_discount_available OR pilgrim_discount_percentage IS NOT NULL
    )
);

-- Add table and column comments
COMMENT ON TABLE public.shops_and_services_details IS 'Detailed information about shops and services extending the waypoints table.';
COMMENT ON COLUMN public.shops_and_services_details.id IS 'FK to waypoints table. This is a 1:1 extension.';
COMMENT ON COLUMN public.shops_and_services_details.shop_service_type_ids IS 'Array of FKs to shop_service_types_master for types of services offered.';
COMMENT ON COLUMN public.shops_and_services_details.price_range_id IS 'FK to establishment_price_ranges_master for general pricing level.';
COMMENT ON COLUMN public.shops_and_services_details.opening_hours IS 'JSONB containing weekly opening hours. Format: {"monday": {"open": "09:00", "close": "17:00"}, ...}';
COMMENT ON COLUMN public.shops_and_services_details.seasonal_hours IS 'JSONB containing seasonal variations in operating hours.';
COMMENT ON COLUMN public.shops_and_services_details.special_closure_dates IS 'Array of dates when business is closed for special reasons.';
COMMENT ON COLUMN public.shops_and_services_details.holiday_hours IS 'JSONB containing holiday operating hours variations.';
COMMENT ON COLUMN public.shops_and_services_details.contact_phone IS 'Primary phone contact for the business.';
COMMENT ON COLUMN public.shops_and_services_details.contact_email IS 'Email contact for the business.';
COMMENT ON COLUMN public.shops_and_services_details.website_url IS 'Official business website URL.';
COMMENT ON COLUMN public.shops_and_services_details.online_ordering_url IS 'URL for online ordering or e-commerce.';
COMMENT ON COLUMN public.shops_and_services_details.business_name IS 'Official registered business name.';
COMMENT ON COLUMN public.shops_and_services_details.business_registration_number IS 'Official business registration number.';
COMMENT ON COLUMN public.shops_and_services_details.vat_number IS 'VAT/tax identification number.';
COMMENT ON COLUMN public.shops_and_services_details.accepts_reservations IS 'Whether the business accepts reservations.';
COMMENT ON COLUMN public.shops_and_services_details.reservation_required IS 'Whether reservations are required.';
COMMENT ON COLUMN public.shops_and_services_details.payment_method_ids IS 'Array of FKs to payment_methods_master for accepted payment types.';
COMMENT ON COLUMN public.shops_and_services_details.accepts_credit_cards IS 'Whether credit cards are accepted.';
COMMENT ON COLUMN public.shops_and_services_details.accepts_cash IS 'Whether cash payments are accepted.';
COMMENT ON COLUMN public.shops_and_services_details.currency_accepted IS 'Array of ISO currency codes accepted.';
COMMENT ON COLUMN public.shops_and_services_details.average_price_eur IS 'Average price per person or item in EUR.';
COMMENT ON COLUMN public.shops_and_services_details.pilgrim_discount_available IS 'Whether discounts are available for pilgrims.';
COMMENT ON COLUMN public.shops_and_services_details.pilgrim_discount_percentage IS 'Percentage discount available to pilgrims.';
COMMENT ON COLUMN public.shops_and_services_details.pilgrim_discount_notes IS 'Details about pilgrim discounts and requirements.';
COMMENT ON COLUMN public.shops_and_services_details.meal_type_ids IS 'Array of FKs to meal_type_tags_master for meal types served.';
COMMENT ON COLUMN public.shops_and_services_details.dietary_option_ids IS 'Array of FKs to dietary_option_tags_master for dietary options available.';
COMMENT ON COLUMN public.shops_and_services_details.serves_alcohol IS 'Whether alcoholic beverages are served.';
COMMENT ON COLUMN public.shops_and_services_details.takeaway_available IS 'Whether takeaway/to-go service is available.';
COMMENT ON COLUMN public.shops_and_services_details.delivery_available IS 'Whether delivery service is offered.';
COMMENT ON COLUMN public.shops_and_services_details.delivery_radius_km IS 'Delivery service radius in kilometers.';
COMMENT ON COLUMN public.shops_and_services_details.seating_capacity IS 'Maximum seating capacity for customers.';
COMMENT ON COLUMN public.shops_and_services_details.outdoor_seating IS 'Whether outdoor seating is available.';
COMMENT ON COLUMN public.shops_and_services_details.wifi_available IS 'Whether Wi-Fi internet access is provided.';
COMMENT ON COLUMN public.shops_and_services_details.wifi_password IS 'Wi-Fi password if publicly shared.';
COMMENT ON COLUMN public.shops_and_services_details.parking_available IS 'Whether parking is available for customers.';
COMMENT ON COLUMN public.shops_and_services_details.parking_notes IS 'Details about parking availability and restrictions.';
COMMENT ON COLUMN public.shops_and_services_details.wheelchair_accessible IS 'Whether the establishment is wheelchair accessible.';
COMMENT ON COLUMN public.shops_and_services_details.accessibility_notes IS 'Detailed accessibility information.';
COMMENT ON COLUMN public.shops_and_services_details.luggage_storage IS 'Whether luggage storage service is available.';
COMMENT ON COLUMN public.shops_and_services_details.bicycle_parking IS 'Whether bicycle parking is available.';
COMMENT ON COLUMN public.shops_and_services_details.credential_stamping IS 'Whether pilgrim credential stamping service is offered.';
COMMENT ON COLUMN public.shops_and_services_details.luggage_transport_service IS 'Whether luggage transport service is available.';
COMMENT ON COLUMN public.shops_and_services_details.equipment_rental IS 'Whether equipment rental service is offered.';
COMMENT ON COLUMN public.shops_and_services_details.equipment_repair IS 'Whether equipment repair service is available.';
COMMENT ON COLUMN public.shops_and_services_details.pilgrim_information IS 'Whether pilgrim information and assistance is provided.';
COMMENT ON COLUMN public.shops_and_services_details.multilingual_staff IS 'Whether multilingual staff are available.';
COMMENT ON COLUMN public.shops_and_services_details.languages_spoken IS 'Array of language codes spoken by staff.';
COMMENT ON COLUMN public.shops_and_services_details.quality_rating IS 'Product/service quality rating (0.0-5.0).';
COMMENT ON COLUMN public.shops_and_services_details.service_rating IS 'Customer service rating (0.0-5.0).';
COMMENT ON COLUMN public.shops_and_services_details.value_rating IS 'Value for money rating (0.0-5.0).';
COMMENT ON COLUMN public.shops_and_services_details.overall_rating IS 'Overall customer rating (0.0-5.0).';
COMMENT ON COLUMN public.shops_and_services_details.review_count IS 'Number of customer reviews collected.';
COMMENT ON COLUMN public.shops_and_services_details.staff_count IS 'Number of staff members employed.';
COMMENT ON COLUMN public.shops_and_services_details.established_year IS 'Year the business was established.';
COMMENT ON COLUMN public.shops_and_services_details.chain_franchise IS 'Chain or franchise name if applicable.';
COMMENT ON COLUMN public.shops_and_services_details.local_ownership IS 'Whether the business is locally owned.';
COMMENT ON COLUMN public.shops_and_services_details.seasonal_business IS 'Whether the business operates seasonally.';
COMMENT ON COLUMN public.shops_and_services_details.peak_season_months IS 'Array of months (1-12) representing peak season.';
COMMENT ON COLUMN public.shops_and_services_details.off_season_closure IS 'Whether the business closes during off-season.';
COMMENT ON COLUMN public.shops_and_services_details.last_verified_date IS 'Date when business information was last verified.';
COMMENT ON COLUMN public.shops_and_services_details.data_source IS 'Source of the business information.';
COMMENT ON COLUMN public.shops_and_services_details.data_confidence_score IS 'Confidence score for data accuracy (0-100).';
COMMENT ON COLUMN public.shops_and_services_details.verification_notes IS 'Notes from verification process.';

-- Create indexes for performance
CREATE INDEX idx_shops_services_price_range ON public.shops_and_services_details(price_range_id);
CREATE INDEX idx_shops_services_accepts_credit_cards ON public.shops_and_services_details(accepts_credit_cards) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_accepts_cash ON public.shops_and_services_details(accepts_cash) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_pilgrim_discount ON public.shops_and_services_details(pilgrim_discount_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_accepts_reservations ON public.shops_and_services_details(accepts_reservations) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_serves_alcohol ON public.shops_and_services_details(serves_alcohol) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_takeaway ON public.shops_and_services_details(takeaway_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_delivery ON public.shops_and_services_details(delivery_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_wifi ON public.shops_and_services_details(wifi_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_parking ON public.shops_and_services_details(parking_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_wheelchair_accessible ON public.shops_and_services_details(wheelchair_accessible) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_credential_stamping ON public.shops_and_services_details(credential_stamping) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_luggage_transport ON public.shops_and_services_details(luggage_transport_service) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_equipment_rental ON public.shops_and_services_details(equipment_rental) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_overall_rating ON public.shops_and_services_details(overall_rating) WHERE deleted_at IS NULL AND overall_rating IS NOT NULL;
CREATE INDEX idx_shops_services_local_ownership ON public.shops_and_services_details(local_ownership) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_seasonal_business ON public.shops_and_services_details(seasonal_business) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_last_verified ON public.shops_and_services_details(last_verified_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_deleted_at ON public.shops_and_services_details(deleted_at);
CREATE INDEX idx_shops_services_created_by ON public.shops_and_services_details(created_by_profile_id);
CREATE INDEX idx_shops_services_updated_by ON public.shops_and_services_details(updated_by_profile_id);

-- GIN indexes for array and JSONB fields
CREATE INDEX idx_shops_services_shop_service_types ON public.shops_and_services_details USING GIN(shop_service_type_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_payment_methods ON public.shops_and_services_details USING GIN(payment_method_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_meal_types ON public.shops_and_services_details USING GIN(meal_type_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_dietary_options ON public.shops_and_services_details USING GIN(dietary_option_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_currency_accepted ON public.shops_and_services_details USING GIN(currency_accepted) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_languages_spoken ON public.shops_and_services_details USING GIN(languages_spoken) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_peak_months ON public.shops_and_services_details USING GIN(peak_season_months) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_opening_hours ON public.shops_and_services_details USING GIN(opening_hours) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_seasonal_hours ON public.shops_and_services_details USING GIN(seasonal_hours) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_holiday_hours ON public.shops_and_services_details USING GIN(holiday_hours) WHERE deleted_at IS NULL;
CREATE INDEX idx_shops_services_closure_dates ON public.shops_and_services_details USING GIN(special_closure_dates) WHERE deleted_at IS NULL;

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_shops_services_set_updated_at
    BEFORE UPDATE ON public.shops_and_services_details
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_shops_services_set_updated_at ON public.shops_and_services_details IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Translation cleanup trigger (when shop/service is deleted)
CREATE TRIGGER trigger_shops_services_cleanup_translations
    AFTER UPDATE OF deleted_at ON public.shops_and_services_details
    FOR EACH ROW
    WHEN (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL)
    EXECUTE FUNCTION public.cleanup_related_translations();

COMMENT ON TRIGGER trigger_shops_services_cleanup_translations ON public.shops_and_services_details IS 
'Trigger to clean up translations when shop/service is soft-deleted.';

-- Enable Row Level Security
ALTER TABLE public.shops_and_services_details ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read shops/services details for published waypoints (non-deleted)
CREATE POLICY "Allow public read access to shops services for published waypoints" ON public.shops_and_services_details
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

-- Authenticated users can read all non-deleted shops/services details
CREATE POLICY "Allow authenticated users read access to shops services" ON public.shops_and_services_details
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND deleted_at IS NULL
        AND id IN (
            SELECT id FROM public.waypoints WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage shops/services details
CREATE POLICY "Allow content creators to manage shops services" ON public.shops_and_services_details
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
CREATE POLICY "Allow service role full access to shops services" ON public.shops_and_services_details
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
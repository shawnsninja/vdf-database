-- Module 4b: Attractions
-- 005_food_water_sources.sql: Food and water sources details table
-- 
-- Purpose: Detailed information about food and water sources at attractions

-- Drop existing table if it exists to recreate with correct schema
DROP TABLE IF EXISTS public.food_water_sources_details CASCADE;

-- Create food water sources details table (1:1 extension of waypoints)
CREATE TABLE IF NOT EXISTS public.food_water_sources_details (
    id BIGINT PRIMARY KEY,
    source_type_ids INTEGER[] NOT NULL,
    water_reliability_type_id INTEGER NULL,
    price_range_id INTEGER NULL,
    
    -- Source characteristics
    is_potable_water BOOLEAN NOT NULL DEFAULT true,
    requires_treatment BOOLEAN NOT NULL DEFAULT false,
    treatment_method TEXT NULL,
    water_quality_notes TEXT NULL,
    
    -- Availability and access
    always_available BOOLEAN NOT NULL DEFAULT true,
    seasonal_availability BOOLEAN NOT NULL DEFAULT false,
    available_seasons TEXT[] NULL,
    operating_hours JSONB NULL,
    access_restrictions TEXT NULL,
    
    -- Capacity and flow
    flow_rate_description TEXT NULL,
    capacity_notes TEXT NULL,
    multiple_taps BOOLEAN NOT NULL DEFAULT false,
    number_of_access_points INTEGER NULL DEFAULT 1,
    
    -- Costs and requirements
    free_access BOOLEAN NOT NULL DEFAULT true,
    cost_eur DECIMAL(8,2) NULL,
    cost_currency TEXT NOT NULL DEFAULT 'EUR',
    cost_notes TEXT NULL,
    bottle_filling_friendly BOOLEAN NOT NULL DEFAULT true,
    
    -- Food services (if applicable)
    food_available BOOLEAN NOT NULL DEFAULT false,
    food_type_description TEXT NULL,
    meal_times JSONB NULL,
    meal_type_ids INTEGER[] NULL,
    dietary_option_ids INTEGER[] NULL,
    payment_method_ids INTEGER[] NULL,
    reservation_required BOOLEAN NOT NULL DEFAULT false,
    
    -- Contact information
    contact_phone TEXT NULL,
    contact_email TEXT NULL,
    
    -- Location and access
    distance_from_trail_meters INTEGER NULL,
    access_difficulty TEXT NULL,
    parking_available BOOLEAN NOT NULL DEFAULT false,
    
    -- Quality and safety
    last_tested_date DATE NULL,
    testing_authority TEXT NULL,
    safety_warnings TEXT NULL,
    
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
    CONSTRAINT fk_food_water_sources_waypoint 
        FOREIGN KEY(id) 
        REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT fk_food_water_sources_price_range 
        FOREIGN KEY(price_range_id) 
        REFERENCES public.establishment_price_ranges_master(id) ON DELETE SET NULL,
    CONSTRAINT fk_food_water_sources_reliability 
        FOREIGN KEY(water_reliability_type_id) 
        REFERENCES public.water_reliability_types_master(id) ON DELETE SET NULL,
    CONSTRAINT fk_food_water_sources_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_food_water_sources_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_food_water_sources_contact_email CHECK (
        contact_email IS NULL OR contact_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    ),
    CONSTRAINT chk_food_water_sources_cost_positive CHECK (
        cost_eur IS NULL OR cost_eur >= 0
    ),
    CONSTRAINT chk_food_water_sources_cost_currency CHECK (
        cost_currency IN ('EUR', 'USD', 'GBP', 'CHF')
    ),
    CONSTRAINT chk_food_water_sources_access_points CHECK (
        number_of_access_points IS NULL OR number_of_access_points > 0
    ),
    CONSTRAINT chk_food_water_sources_distance CHECK (
        distance_from_trail_meters IS NULL OR distance_from_trail_meters >= 0
    ),
    CONSTRAINT chk_food_water_sources_access_difficulty CHECK (
        access_difficulty IS NULL OR access_difficulty IN ('easy', 'moderate', 'difficult')
    ),
    CONSTRAINT chk_food_water_sources_data_confidence CHECK (
        data_confidence_score IS NULL OR (data_confidence_score >= 0 AND data_confidence_score <= 100)
    ),
    CONSTRAINT chk_food_water_sources_seasonal_logic CHECK (
        NOT seasonal_availability OR available_seasons IS NOT NULL
    ),
    CONSTRAINT chk_food_water_sources_cost_logic CHECK (
        free_access OR cost_eur IS NOT NULL
    ),
    CONSTRAINT chk_food_water_sources_treatment_method_length CHECK (
        treatment_method IS NULL OR length(treatment_method) <= 200
    ),
    CONSTRAINT chk_food_water_sources_water_quality_notes_length CHECK (
        water_quality_notes IS NULL OR length(water_quality_notes) <= 500
    ),
    CONSTRAINT chk_food_water_sources_access_restrictions_length CHECK (
        access_restrictions IS NULL OR length(access_restrictions) <= 500
    ),
    CONSTRAINT chk_food_water_sources_flow_rate_length CHECK (
        flow_rate_description IS NULL OR length(flow_rate_description) <= 200
    ),
    CONSTRAINT chk_food_water_sources_capacity_notes_length CHECK (
        capacity_notes IS NULL OR length(capacity_notes) <= 500
    ),
    CONSTRAINT chk_food_water_sources_cost_notes_length CHECK (
        cost_notes IS NULL OR length(cost_notes) <= 500
    ),
    CONSTRAINT chk_food_water_sources_food_type_length CHECK (
        food_type_description IS NULL OR length(food_type_description) <= 500
    ),
    CONSTRAINT chk_food_water_sources_testing_authority_length CHECK (
        testing_authority IS NULL OR length(testing_authority) <= 255
    ),
    CONSTRAINT chk_food_water_sources_safety_warnings_length CHECK (
        safety_warnings IS NULL OR length(safety_warnings) <= 1000
    )
);

-- Add table and column comments
COMMENT ON TABLE public.food_water_sources_details IS 'Detailed information about food and water sources extending the waypoints table.';
COMMENT ON COLUMN public.food_water_sources_details.id IS 'FK to waypoints table. This is a 1:1 extension.';
COMMENT ON COLUMN public.food_water_sources_details.source_type_ids IS 'Array of FKs to food_water_source_types_master (fountain, tap, spring, etc.).';
COMMENT ON COLUMN public.food_water_sources_details.water_reliability_type_id IS 'FK to water_reliability_types_master for reliability level.';
COMMENT ON COLUMN public.food_water_sources_details.price_range_id IS 'FK to establishment_price_ranges_master for food pricing level.';
COMMENT ON COLUMN public.food_water_sources_details.is_potable_water IS 'Whether the water is safe for drinking without treatment.';
COMMENT ON COLUMN public.food_water_sources_details.requires_treatment IS 'Whether water requires treatment before consumption.';
COMMENT ON COLUMN public.food_water_sources_details.treatment_method IS 'Recommended treatment method if required.';
COMMENT ON COLUMN public.food_water_sources_details.water_quality_notes IS 'Additional notes about water quality and characteristics.';
COMMENT ON COLUMN public.food_water_sources_details.always_available IS 'Whether the source is always accessible.';
COMMENT ON COLUMN public.food_water_sources_details.seasonal_availability IS 'Whether availability varies by season.';
COMMENT ON COLUMN public.food_water_sources_details.available_seasons IS 'Array of seasons when source is available.';
COMMENT ON COLUMN public.food_water_sources_details.operating_hours IS 'JSONB containing operating hours if access is limited.';
COMMENT ON COLUMN public.food_water_sources_details.access_restrictions IS 'Any restrictions on access to the source.';
COMMENT ON COLUMN public.food_water_sources_details.flow_rate_description IS 'Description of water flow rate (fast, slow, trickle, etc.).';
COMMENT ON COLUMN public.food_water_sources_details.capacity_notes IS 'Notes about capacity for multiple users.';
COMMENT ON COLUMN public.food_water_sources_details.multiple_taps IS 'Whether there are multiple access points.';
COMMENT ON COLUMN public.food_water_sources_details.number_of_access_points IS 'Number of taps, spigots, or access points.';
COMMENT ON COLUMN public.food_water_sources_details.free_access IS 'Whether access to the source is free.';
COMMENT ON COLUMN public.food_water_sources_details.cost_eur IS 'Cost for access if not free.';
COMMENT ON COLUMN public.food_water_sources_details.cost_currency IS 'Currency for access cost.';
COMMENT ON COLUMN public.food_water_sources_details.cost_notes IS 'Additional notes about costs and payment methods.';
COMMENT ON COLUMN public.food_water_sources_details.bottle_filling_friendly IS 'Whether the source is suitable for filling water bottles.';
COMMENT ON COLUMN public.food_water_sources_details.food_available IS 'Whether food is also available at this location.';
COMMENT ON COLUMN public.food_water_sources_details.food_type_description IS 'Description of food available.';
COMMENT ON COLUMN public.food_water_sources_details.meal_times IS 'JSONB containing meal service times.';
COMMENT ON COLUMN public.food_water_sources_details.meal_type_ids IS 'Array of FKs to meal_type_tags_master for meal types served.';
COMMENT ON COLUMN public.food_water_sources_details.dietary_option_ids IS 'Array of FKs to dietary_option_tags_master for dietary options available.';
COMMENT ON COLUMN public.food_water_sources_details.payment_method_ids IS 'Array of FKs to payment_methods_master for accepted payment types.';
COMMENT ON COLUMN public.food_water_sources_details.reservation_required IS 'Whether reservations are required for food service.';
COMMENT ON COLUMN public.food_water_sources_details.contact_phone IS 'Phone contact for the source location.';
COMMENT ON COLUMN public.food_water_sources_details.contact_email IS 'Email contact for the source location.';
COMMENT ON COLUMN public.food_water_sources_details.distance_from_trail_meters IS 'Distance from main trail in meters.';
COMMENT ON COLUMN public.food_water_sources_details.access_difficulty IS 'Difficulty of accessing the source: easy, moderate, difficult.';
COMMENT ON COLUMN public.food_water_sources_details.parking_available IS 'Whether parking is available near the source.';
COMMENT ON COLUMN public.food_water_sources_details.last_tested_date IS 'Date when water quality was last tested.';
COMMENT ON COLUMN public.food_water_sources_details.testing_authority IS 'Authority or organization that conducted testing.';
COMMENT ON COLUMN public.food_water_sources_details.safety_warnings IS 'Any safety warnings or precautions for users.';
COMMENT ON COLUMN public.food_water_sources_details.last_verified_date IS 'Date when source information was last verified.';
COMMENT ON COLUMN public.food_water_sources_details.data_source IS 'Source of the information.';
COMMENT ON COLUMN public.food_water_sources_details.data_confidence_score IS 'Confidence score for data accuracy (0-100).';

-- Create indexes for performance
CREATE INDEX idx_food_water_sources_price_range ON public.food_water_sources_details(price_range_id);
CREATE INDEX idx_food_water_sources_reliability ON public.food_water_sources_details(water_reliability_type_id);
CREATE INDEX idx_food_water_sources_potable ON public.food_water_sources_details(is_potable_water) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_always_available ON public.food_water_sources_details(always_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_free_access ON public.food_water_sources_details(free_access) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_bottle_friendly ON public.food_water_sources_details(bottle_filling_friendly) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_food_available ON public.food_water_sources_details(food_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_distance ON public.food_water_sources_details(distance_from_trail_meters) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_access_difficulty ON public.food_water_sources_details(access_difficulty) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_last_tested ON public.food_water_sources_details(last_tested_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_last_verified ON public.food_water_sources_details(last_verified_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_deleted_at ON public.food_water_sources_details(deleted_at);
CREATE INDEX idx_food_water_sources_created_by ON public.food_water_sources_details(created_by_profile_id);
CREATE INDEX idx_food_water_sources_updated_by ON public.food_water_sources_details(updated_by_profile_id);

-- GIN indexes for array and JSONB fields
CREATE INDEX idx_food_water_sources_source_types ON public.food_water_sources_details USING GIN(source_type_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_meal_types ON public.food_water_sources_details USING GIN(meal_type_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_dietary_options ON public.food_water_sources_details USING GIN(dietary_option_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_payment_methods ON public.food_water_sources_details USING GIN(payment_method_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_seasons ON public.food_water_sources_details USING GIN(available_seasons) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_operating_hours ON public.food_water_sources_details USING GIN(operating_hours) WHERE deleted_at IS NULL;
CREATE INDEX idx_food_water_sources_meal_times ON public.food_water_sources_details USING GIN(meal_times) WHERE deleted_at IS NULL;

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_food_water_sources_set_updated_at
    BEFORE UPDATE ON public.food_water_sources_details
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_food_water_sources_set_updated_at ON public.food_water_sources_details IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Translation cleanup trigger
CREATE TRIGGER trigger_food_water_sources_cleanup_translations
    AFTER UPDATE OF deleted_at ON public.food_water_sources_details
    FOR EACH ROW
    WHEN (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL)
    EXECUTE FUNCTION public.cleanup_related_translations();

COMMENT ON TRIGGER trigger_food_water_sources_cleanup_translations ON public.food_water_sources_details IS 
'Trigger to clean up translations when food/water source is soft-deleted.';

-- Enable Row Level Security
ALTER TABLE public.food_water_sources_details ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read food/water sources for published waypoints (non-deleted)
CREATE POLICY "Allow public read access to food water sources for published waypoints" ON public.food_water_sources_details
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

-- Authenticated users can read all non-deleted food/water sources
CREATE POLICY "Allow authenticated users read access to food water sources" ON public.food_water_sources_details
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND deleted_at IS NULL
        AND id IN (
            SELECT id FROM public.waypoints WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage food/water sources
CREATE POLICY "Allow content creators to manage food water sources" ON public.food_water_sources_details
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
CREATE POLICY "Allow service role full access to food water sources" ON public.food_water_sources_details
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
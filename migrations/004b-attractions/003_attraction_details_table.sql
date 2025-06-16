-- Module 4b: Attractions
-- 003_attraction_details_table.sql: Main attraction details table
-- 
-- Purpose: Core attraction details extending waypoints table

-- Create attraction details table (1:1 extension of waypoints)
CREATE TABLE IF NOT EXISTS public.attraction_details (
    id BIGINT PRIMARY KEY,
    attraction_type_id INTEGER NOT NULL,
    visitor_amenity_ids INTEGER[] NULL,
    
    -- Opening hours (JSONB for flexible scheduling)
    opening_hours JSONB NULL,
    seasonal_hours JSONB NULL,
    special_closure_dates DATE[] NULL,
    
    -- Entry information
    entry_fee_eur DECIMAL(8,2) NULL,
    entry_fee_currency TEXT NOT NULL DEFAULT 'EUR',
    entry_fee_notes TEXT NULL,
    pilgrim_discount_available BOOLEAN NOT NULL DEFAULT false,
    pilgrim_discount_notes TEXT NULL,
    advance_booking_required BOOLEAN NOT NULL DEFAULT false,
    
    -- Contact and booking
    contact_phone TEXT NULL,
    contact_email TEXT NULL,
    website_url TEXT NULL,
    booking_url TEXT NULL,
    
    -- Visitor information
    typical_visit_duration_minutes INTEGER NULL,
    recommended_seasons TEXT[] NULL,
    difficulty_level TEXT NULL,
    age_restrictions TEXT NULL,
    group_size_limits TEXT NULL,
    
    -- Facilities and services
    guided_tours_available BOOLEAN NOT NULL DEFAULT false,
    audio_guides_available BOOLEAN NOT NULL DEFAULT false,
    multilingual_support BOOLEAN NOT NULL DEFAULT false,
    languages_supported TEXT[] NULL,
    photography_policy TEXT NULL,
    
    -- Accessibility
    wheelchair_accessible BOOLEAN NOT NULL DEFAULT false,
    accessibility_notes TEXT NULL,
    parking_available BOOLEAN NOT NULL DEFAULT false,
    parking_notes TEXT NULL,
    
    -- Cultural and historical information
    historical_period TEXT NULL,
    architectural_style TEXT NULL,
    cultural_significance TEXT NULL,
    unesco_status TEXT NULL,
    
    -- Pilgrim-specific information
    franciscan_connection TEXT NULL,
    pilgrimage_significance TEXT NULL,
    spiritual_practices_offered TEXT NULL,
    
    -- Data management
    last_verified_date DATE NULL,
    data_source TEXT NULL,
    data_confidence_score INTEGER NULL,
    visitor_rating DECIMAL(3,2) NULL,
    visitor_review_count INTEGER NULL DEFAULT 0,
    
    -- Standard audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_attraction_details_waypoint 
        FOREIGN KEY(id) 
        REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT fk_attraction_details_type 
        FOREIGN KEY(attraction_type_id) 
        REFERENCES public.attraction_types_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_attraction_details_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_attraction_details_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_attraction_details_contact_email CHECK (
        contact_email IS NULL OR contact_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    ),
    CONSTRAINT chk_attraction_details_website_url CHECK (
        website_url IS NULL OR website_url ~ '^https?://'
    ),
    CONSTRAINT chk_attraction_details_booking_url CHECK (
        booking_url IS NULL OR booking_url ~ '^https?://'
    ),
    CONSTRAINT chk_attraction_details_entry_fee_positive CHECK (
        entry_fee_eur IS NULL OR entry_fee_eur >= 0
    ),
    CONSTRAINT chk_attraction_details_entry_fee_currency CHECK (
        entry_fee_currency IN ('EUR', 'USD', 'GBP', 'CHF')
    ),
    CONSTRAINT chk_attraction_details_visit_duration CHECK (
        typical_visit_duration_minutes IS NULL OR typical_visit_duration_minutes > 0
    ),
    CONSTRAINT chk_attraction_details_difficulty_level CHECK (
        difficulty_level IS NULL OR difficulty_level IN ('easy', 'moderate', 'difficult', 'expert')
    ),
    CONSTRAINT chk_attraction_details_photography_policy CHECK (
        photography_policy IS NULL OR photography_policy IN ('allowed', 'restricted', 'prohibited', 'fee_required')
    ),
    CONSTRAINT chk_attraction_details_unesco_status CHECK (
        unesco_status IS NULL OR unesco_status IN ('world_heritage', 'tentative_list', 'biosphere_reserve', 'none')
    ),
    CONSTRAINT chk_attraction_details_data_confidence CHECK (
        data_confidence_score IS NULL OR (data_confidence_score >= 0 AND data_confidence_score <= 100)
    ),
    CONSTRAINT chk_attraction_details_visitor_rating CHECK (
        visitor_rating IS NULL OR (visitor_rating >= 0.0 AND visitor_rating <= 5.0)
    ),
    CONSTRAINT chk_attraction_details_review_count CHECK (
        visitor_review_count >= 0
    ),
    CONSTRAINT chk_attraction_details_entry_fee_notes_length CHECK (
        entry_fee_notes IS NULL OR length(entry_fee_notes) <= 500
    ),
    CONSTRAINT chk_attraction_details_pilgrim_discount_notes_length CHECK (
        pilgrim_discount_notes IS NULL OR length(pilgrim_discount_notes) <= 500
    ),
    CONSTRAINT chk_attraction_details_accessibility_notes_length CHECK (
        accessibility_notes IS NULL OR length(accessibility_notes) <= 1000
    ),
    CONSTRAINT chk_attraction_details_parking_notes_length CHECK (
        parking_notes IS NULL OR length(parking_notes) <= 500
    ),
    CONSTRAINT chk_attraction_details_cultural_significance_length CHECK (
        cultural_significance IS NULL OR length(cultural_significance) <= 1000
    ),
    CONSTRAINT chk_attraction_details_franciscan_connection_length CHECK (
        franciscan_connection IS NULL OR length(franciscan_connection) <= 1000
    ),
    CONSTRAINT chk_attraction_details_pilgrimage_significance_length CHECK (
        pilgrimage_significance IS NULL OR length(pilgrimage_significance) <= 1000
    ),
    CONSTRAINT chk_attraction_details_spiritual_practices_length CHECK (
        spiritual_practices_offered IS NULL OR length(spiritual_practices_offered) <= 1000
    )
);

-- Add table and column comments
COMMENT ON TABLE public.attraction_details IS 'Detailed attraction information extending the waypoints table for points of interest.';
COMMENT ON COLUMN public.attraction_details.id IS 'FK to waypoints table. This is a 1:1 extension.';
COMMENT ON COLUMN public.attraction_details.attraction_type_id IS 'FK to attraction_types_master (historical site, museum, etc.).';
COMMENT ON COLUMN public.attraction_details.visitor_amenity_ids IS 'Array of FKs to visitor_amenities_master for available facilities.';
COMMENT ON COLUMN public.attraction_details.opening_hours IS 'JSONB containing weekly opening hours schedule. Format: {"monday": {"open": "09:00", "close": "17:00"}, ...}';
COMMENT ON COLUMN public.attraction_details.seasonal_hours IS 'JSONB containing seasonal variations in opening hours.';
COMMENT ON COLUMN public.attraction_details.special_closure_dates IS 'Array of dates when attraction is closed for special reasons.';
COMMENT ON COLUMN public.attraction_details.entry_fee_eur IS 'Standard entry fee in specified currency.';
COMMENT ON COLUMN public.attraction_details.entry_fee_currency IS 'Currency code for entry fee (EUR, USD, etc.).';
COMMENT ON COLUMN public.attraction_details.entry_fee_notes IS 'Additional notes about entry fees, discounts, etc.';
COMMENT ON COLUMN public.attraction_details.pilgrim_discount_available IS 'Whether discounts are available for pilgrims.';
COMMENT ON COLUMN public.attraction_details.pilgrim_discount_notes IS 'Details about pilgrim discounts and requirements.';
COMMENT ON COLUMN public.attraction_details.advance_booking_required IS 'Whether advance booking is required for visits.';
COMMENT ON COLUMN public.attraction_details.contact_phone IS 'Phone contact for the attraction.';
COMMENT ON COLUMN public.attraction_details.contact_email IS 'Email contact for the attraction.';
COMMENT ON COLUMN public.attraction_details.website_url IS 'Official website URL.';
COMMENT ON COLUMN public.attraction_details.booking_url IS 'URL for online booking or reservations.';
COMMENT ON COLUMN public.attraction_details.typical_visit_duration_minutes IS 'Typical time needed to visit the attraction (in minutes).';
COMMENT ON COLUMN public.attraction_details.recommended_seasons IS 'Array of recommended seasons for visiting.';
COMMENT ON COLUMN public.attraction_details.difficulty_level IS 'Physical difficulty level: easy, moderate, difficult, expert.';
COMMENT ON COLUMN public.attraction_details.age_restrictions IS 'Any age restrictions or recommendations.';
COMMENT ON COLUMN public.attraction_details.group_size_limits IS 'Limitations on group sizes for visits.';
COMMENT ON COLUMN public.attraction_details.guided_tours_available IS 'Whether guided tours are available.';
COMMENT ON COLUMN public.attraction_details.audio_guides_available IS 'Whether audio guides are available.';
COMMENT ON COLUMN public.attraction_details.multilingual_support IS 'Whether multilingual support is available.';
COMMENT ON COLUMN public.attraction_details.languages_supported IS 'Array of languages supported for tours/information.';
COMMENT ON COLUMN public.attraction_details.photography_policy IS 'Photography policy: allowed, restricted, prohibited, fee_required.';
COMMENT ON COLUMN public.attraction_details.wheelchair_accessible IS 'Whether the attraction is wheelchair accessible.';
COMMENT ON COLUMN public.attraction_details.accessibility_notes IS 'Detailed accessibility information.';
COMMENT ON COLUMN public.attraction_details.parking_available IS 'Whether parking is available at or near the attraction.';
COMMENT ON COLUMN public.attraction_details.parking_notes IS 'Details about parking availability and costs.';
COMMENT ON COLUMN public.attraction_details.historical_period IS 'Historical period or era associated with the attraction.';
COMMENT ON COLUMN public.attraction_details.architectural_style IS 'Architectural style or period of buildings.';
COMMENT ON COLUMN public.attraction_details.cultural_significance IS 'Description of cultural importance and significance.';
COMMENT ON COLUMN public.attraction_details.unesco_status IS 'UNESCO designation: world_heritage, tentative_list, biosphere_reserve, none.';
COMMENT ON COLUMN public.attraction_details.franciscan_connection IS 'Connection to Franciscan history and tradition.';
COMMENT ON COLUMN public.attraction_details.pilgrimage_significance IS 'Significance to pilgrimage traditions and practices.';
COMMENT ON COLUMN public.attraction_details.spiritual_practices_offered IS 'Spiritual practices, services, or experiences offered.';
COMMENT ON COLUMN public.attraction_details.last_verified_date IS 'Date when attraction information was last verified.';
COMMENT ON COLUMN public.attraction_details.data_source IS 'Source of attraction data.';
COMMENT ON COLUMN public.attraction_details.data_confidence_score IS 'Confidence score for data accuracy (0-100).';
COMMENT ON COLUMN public.attraction_details.visitor_rating IS 'Average visitor rating (0.0-5.0).';
COMMENT ON COLUMN public.attraction_details.visitor_review_count IS 'Number of visitor reviews collected.';

-- Create indexes for performance
CREATE INDEX idx_attraction_details_type_id ON public.attraction_details(attraction_type_id);
CREATE INDEX idx_attraction_details_entry_fee ON public.attraction_details(entry_fee_eur) WHERE deleted_at IS NULL AND entry_fee_eur IS NOT NULL;
CREATE INDEX idx_attraction_details_pilgrim_discount ON public.attraction_details(pilgrim_discount_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_advance_booking ON public.attraction_details(advance_booking_required) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_guided_tours ON public.attraction_details(guided_tours_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_wheelchair_accessible ON public.attraction_details(wheelchair_accessible) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_parking_available ON public.attraction_details(parking_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_difficulty_level ON public.attraction_details(difficulty_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_unesco_status ON public.attraction_details(unesco_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_visitor_rating ON public.attraction_details(visitor_rating) WHERE deleted_at IS NULL AND visitor_rating IS NOT NULL;
CREATE INDEX idx_attraction_details_last_verified ON public.attraction_details(last_verified_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_deleted_at ON public.attraction_details(deleted_at);
CREATE INDEX idx_attraction_details_created_by ON public.attraction_details(created_by_profile_id);
CREATE INDEX idx_attraction_details_updated_by ON public.attraction_details(updated_by_profile_id);

-- GIN indexes for array and JSONB fields
CREATE INDEX idx_attraction_details_visitor_amenities ON public.attraction_details USING GIN(visitor_amenity_ids) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_opening_hours ON public.attraction_details USING GIN(opening_hours) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_recommended_seasons ON public.attraction_details USING GIN(recommended_seasons) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_languages ON public.attraction_details USING GIN(languages_supported) WHERE deleted_at IS NULL;
CREATE INDEX idx_attraction_details_closure_dates ON public.attraction_details USING GIN(special_closure_dates) WHERE deleted_at IS NULL;

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_attraction_details_set_updated_at
    BEFORE UPDATE ON public.attraction_details
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_attraction_details_set_updated_at ON public.attraction_details IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Translation cleanup trigger (when attraction is deleted)
CREATE TRIGGER trigger_attraction_details_cleanup_translations
    AFTER UPDATE OF deleted_at ON public.attraction_details
    FOR EACH ROW
    WHEN (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL)
    EXECUTE FUNCTION public.cleanup_related_translations();

COMMENT ON TRIGGER trigger_attraction_details_cleanup_translations ON public.attraction_details IS 
'Trigger to clean up translations when attraction is soft-deleted.';

-- Create trigger to validate visitor amenity array foreign keys
CREATE OR REPLACE FUNCTION public.validate_attraction_visitor_amenities()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if visitor_amenity_ids is not null and not empty
    IF NEW.visitor_amenity_ids IS NOT NULL AND array_length(NEW.visitor_amenity_ids, 1) > 0 THEN
        -- Check if all amenity IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.visitor_amenity_ids) AS amenity_id
            WHERE amenity_id NOT IN (
                SELECT id FROM public.visitor_amenities_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more visitor amenity IDs do not exist or are inactive',
                      DETAIL = format('Invalid visitor amenity IDs in array: %L', NEW.visitor_amenity_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_attraction_details_validate_visitor_amenities
    BEFORE INSERT OR UPDATE ON public.attraction_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_attraction_visitor_amenities();

COMMENT ON TRIGGER trigger_attraction_details_validate_visitor_amenities ON public.attraction_details IS 
'Trigger to validate that all visitor amenity IDs in the array exist and are active.';

-- Enable Row Level Security
ALTER TABLE public.attraction_details ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read attraction details for published waypoints (non-deleted)
CREATE POLICY "Allow public read access to attraction details for published waypoints" ON public.attraction_details
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

-- Authenticated users can read all non-deleted attraction details
CREATE POLICY "Allow authenticated users read access to attraction details" ON public.attraction_details
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND deleted_at IS NULL
        AND id IN (
            SELECT id FROM public.waypoints WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage attraction details
CREATE POLICY "Allow content creators to manage attraction details" ON public.attraction_details
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
CREATE POLICY "Allow service role full access to attraction details" ON public.attraction_details
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
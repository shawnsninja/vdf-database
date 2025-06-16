-- Module 4b: Attractions
-- 004_religious_service_schedules.sql: Religious service schedules table
-- 
-- Purpose: Store schedules for religious services at religious attractions

-- Create religious service schedules table (1:M child of attraction_details)
CREATE TABLE IF NOT EXISTS public.religious_service_schedules (
    id BIGSERIAL PRIMARY KEY,
    attraction_id BIGINT NOT NULL,
    service_type_id INTEGER NOT NULL,
    
    -- Service timing
    day_of_week INTEGER NOT NULL, -- 0=Sunday, 1=Monday, ..., 6=Saturday
    service_time TIME NOT NULL,
    duration_minutes INTEGER NULL,
    
    -- Service details
    language_code TEXT NULL,
    celebrant_name TEXT NULL,
    special_notes TEXT NULL,
    
    -- Seasonal variations
    seasonal_schedule BOOLEAN NOT NULL DEFAULT false,
    seasonal_start_date DATE NULL,
    seasonal_end_date DATE NULL,
    
    -- Service status
    is_regular_service BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_verified_date DATE NULL,
    
    -- Standard audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_religious_schedules_attraction 
        FOREIGN KEY(attraction_id) 
        REFERENCES public.attraction_details(id) ON DELETE CASCADE,
    CONSTRAINT fk_religious_schedules_service_type 
        FOREIGN KEY(service_type_id) 
        REFERENCES public.religious_service_types_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_religious_schedules_language 
        FOREIGN KEY(language_code) 
        REFERENCES public.languages_master(code) ON DELETE SET NULL,
    CONSTRAINT fk_religious_schedules_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_religious_schedules_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_religious_schedules_day_of_week CHECK (
        day_of_week >= 0 AND day_of_week <= 6
    ),
    CONSTRAINT chk_religious_schedules_duration CHECK (
        duration_minutes IS NULL OR duration_minutes > 0
    ),
    CONSTRAINT chk_religious_schedules_seasonal_dates CHECK (
        NOT seasonal_schedule OR (seasonal_start_date IS NOT NULL AND seasonal_end_date IS NOT NULL)
    ),
    CONSTRAINT chk_religious_schedules_seasonal_order CHECK (
        seasonal_start_date IS NULL OR seasonal_end_date IS NULL OR seasonal_start_date <= seasonal_end_date
    ),
    CONSTRAINT chk_religious_schedules_celebrant_length CHECK (
        celebrant_name IS NULL OR length(celebrant_name) <= 255
    ),
    CONSTRAINT chk_religious_schedules_notes_length CHECK (
        special_notes IS NULL OR length(special_notes) <= 500
    )
);

-- Add table and column comments
COMMENT ON TABLE public.religious_service_schedules IS 'Schedules for religious services at religious attractions and sites.';
COMMENT ON COLUMN public.religious_service_schedules.id IS 'Unique identifier for the service schedule.';
COMMENT ON COLUMN public.religious_service_schedules.attraction_id IS 'FK to attraction_details table.';
COMMENT ON COLUMN public.religious_service_schedules.service_type_id IS 'FK to religious_service_types_master (Mass, prayer, etc.).';
COMMENT ON COLUMN public.religious_service_schedules.day_of_week IS 'Day of week (0=Sunday, 1=Monday, ..., 6=Saturday).';
COMMENT ON COLUMN public.religious_service_schedules.service_time IS 'Time when the service begins.';
COMMENT ON COLUMN public.religious_service_schedules.duration_minutes IS 'Expected duration of the service in minutes.';
COMMENT ON COLUMN public.religious_service_schedules.language_code IS 'FK to languages_master for the language used in the service.';
COMMENT ON COLUMN public.religious_service_schedules.celebrant_name IS 'Name of the priest, minister, or celebrant (if known).';
COMMENT ON COLUMN public.religious_service_schedules.special_notes IS 'Special notes about the service or requirements.';
COMMENT ON COLUMN public.religious_service_schedules.seasonal_schedule IS 'Whether this schedule is only for specific seasons.';
COMMENT ON COLUMN public.religious_service_schedules.seasonal_start_date IS 'Start date for seasonal schedules.';
COMMENT ON COLUMN public.religious_service_schedules.seasonal_end_date IS 'End date for seasonal schedules.';
COMMENT ON COLUMN public.religious_service_schedules.is_regular_service IS 'Whether this is a regular recurring service.';
COMMENT ON COLUMN public.religious_service_schedules.is_active IS 'Whether this schedule is currently active.';
COMMENT ON COLUMN public.religious_service_schedules.last_verified_date IS 'Date when schedule was last verified.';

-- Create indexes for performance
CREATE INDEX idx_religious_schedules_attraction_id ON public.religious_service_schedules(attraction_id);
CREATE INDEX idx_religious_schedules_service_type ON public.religious_service_schedules(service_type_id);
CREATE INDEX idx_religious_schedules_day_time ON public.religious_service_schedules(day_of_week, service_time) WHERE is_active = true;
CREATE INDEX idx_religious_schedules_language ON public.religious_service_schedules(language_code) WHERE is_active = true;
CREATE INDEX idx_religious_schedules_seasonal ON public.religious_service_schedules(seasonal_schedule, seasonal_start_date, seasonal_end_date) WHERE is_active = true;
CREATE INDEX idx_religious_schedules_regular ON public.religious_service_schedules(is_regular_service) WHERE is_active = true;
CREATE INDEX idx_religious_schedules_is_active ON public.religious_service_schedules(is_active);
CREATE INDEX idx_religious_schedules_last_verified ON public.religious_service_schedules(last_verified_date) WHERE is_active = true;
CREATE INDEX idx_religious_schedules_created_by ON public.religious_service_schedules(created_by_profile_id);
CREATE INDEX idx_religious_schedules_updated_by ON public.religious_service_schedules(updated_by_profile_id);

-- Create triggers
-- Updated timestamp trigger
CREATE TRIGGER trigger_religious_schedules_set_updated_at
    BEFORE UPDATE ON public.religious_service_schedules
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON TRIGGER trigger_religious_schedules_set_updated_at ON public.religious_service_schedules IS 
'Trigger to automatically update updated_at timestamp on row modification.';

-- Enable Row Level Security
ALTER TABLE public.religious_service_schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can read religious schedules for published attractions
CREATE POLICY "Allow public read access to religious schedules for published attractions" ON public.religious_service_schedules
    FOR SELECT
    USING (
        is_active = true
        AND attraction_id IN (
            SELECT ad.id FROM public.attraction_details ad
            JOIN public.waypoints w ON ad.id = w.id
            JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
            WHERE ad.deleted_at IS NULL 
            AND w.deleted_at IS NULL
            AND cs.is_publicly_visible = true 
            AND cs.is_active = true
        )
    );

-- Authenticated users can read all religious schedules for non-deleted attractions
CREATE POLICY "Allow authenticated users read access to religious schedules" ON public.religious_service_schedules
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND attraction_id IN (
            SELECT id FROM public.attraction_details WHERE deleted_at IS NULL
        )
    );

-- Content creators can manage religious schedules
CREATE POLICY "Allow content creators to manage religious schedules" ON public.religious_service_schedules
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
CREATE POLICY "Allow service role full access to religious schedules" ON public.religious_service_schedules
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
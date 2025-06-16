-- Module 5: Dynamic Conditions
-- 003_segment_warnings.sql: Main segment warnings table
-- 
-- Purpose: Create the main transactional table for trail segment warnings

-- Create segment warnings table
CREATE TABLE IF NOT EXISTS public.segment_warnings (
    id BIGSERIAL PRIMARY KEY,
    segment_id BIGINT NOT NULL,
    warning_type_id INTEGER NOT NULL,
    severity_id INTEGER NOT NULL,
    source_type_id INTEGER NOT NULL,
    workflow_status_id INTEGER NOT NULL,
    
    -- Core warning information
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    detailed_description TEXT NULL,
    
    -- Temporal information
    date_warning_effective_from TIMESTAMPTZ NULL,
    date_warning_expected_resolution TIMESTAMPTZ NULL,
    date_warning_resolved_or_expired TIMESTAMPTZ NULL,
    
    -- Computed column for current active status
    is_currently_active BOOLEAN GENERATED ALWAYS AS (
        date_warning_resolved_or_expired IS NULL AND 
        (date_warning_effective_from IS NULL OR date_warning_effective_from <= NOW()) AND 
        (date_warning_expected_resolution IS NULL OR date_warning_expected_resolution >= NOW())
    ) STORED,
    
    -- Spatial information
    location_on_segment_geom GEOMETRY(PointZ, 4326) NULL,
    location_description TEXT NULL,
    affects_entire_segment BOOLEAN NOT NULL DEFAULT false,
    
    -- Source and verification information
    source_contact_info TEXT NULL,
    source_reference_url TEXT NULL,
    verification_date TIMESTAMPTZ NULL,
    verified_by_profile_id UUID NULL,
    verification_notes TEXT NULL,
    
    -- Impact assessment
    estimated_detour_distance_meters INTEGER NULL,
    estimated_delay_minutes INTEGER NULL,
    alternative_route_description TEXT NULL,
    safety_impact_level INTEGER NOT NULL DEFAULT 1,
    accessibility_impact_level INTEGER NOT NULL DEFAULT 1,
    
    -- Media and attachments
    primary_media_id BIGINT NULL,
    supporting_media_ids BIGINT[] NULL,
    
    -- Administrative information
    internal_notes TEXT NULL,
    public_visibility_override BOOLEAN NULL,
    notification_sent_at TIMESTAMPTZ NULL,
    
    -- Standard audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_segment_warnings_segment 
        FOREIGN KEY(segment_id) 
        REFERENCES public.segments(id) ON DELETE CASCADE,
    CONSTRAINT fk_segment_warnings_warning_type 
        FOREIGN KEY(warning_type_id) 
        REFERENCES public.warning_types_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_segment_warnings_severity 
        FOREIGN KEY(severity_id) 
        REFERENCES public.warning_severities_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_segment_warnings_source_type 
        FOREIGN KEY(source_type_id) 
        REFERENCES public.warning_source_types_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_segment_warnings_workflow_status 
        FOREIGN KEY(workflow_status_id) 
        REFERENCES public.workflow_statuses_master(id) ON DELETE RESTRICT,
    CONSTRAINT fk_segment_warnings_verified_by 
        FOREIGN KEY(verified_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_segment_warnings_primary_media 
        FOREIGN KEY(primary_media_id) 
        REFERENCES public.media(id) ON DELETE SET NULL,
    CONSTRAINT fk_segment_warnings_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_segment_warnings_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_segment_warnings_title_length CHECK (
        length(title) >= 3 AND length(title) <= 200
    ),
    CONSTRAINT chk_segment_warnings_description_length CHECK (
        length(description) >= 10 AND length(description) <= 1000
    ),
    CONSTRAINT chk_segment_warnings_detailed_description_length CHECK (
        detailed_description IS NULL OR length(detailed_description) <= 5000
    ),
    CONSTRAINT chk_segment_warnings_location_description_length CHECK (
        location_description IS NULL OR length(location_description) <= 500
    ),
    CONSTRAINT chk_segment_warnings_source_contact_length CHECK (
        source_contact_info IS NULL OR length(source_contact_info) <= 500
    ),
    CONSTRAINT chk_segment_warnings_source_reference_url_format CHECK (
        source_reference_url IS NULL OR source_reference_url ~ '^https?://'
    ),
    CONSTRAINT chk_segment_warnings_verification_notes_length CHECK (
        verification_notes IS NULL OR length(verification_notes) <= 1000
    ),
    CONSTRAINT chk_segment_warnings_detour_distance_positive CHECK (
        estimated_detour_distance_meters IS NULL OR estimated_detour_distance_meters >= 0
    ),
    CONSTRAINT chk_segment_warnings_delay_positive CHECK (
        estimated_delay_minutes IS NULL OR estimated_delay_minutes >= 0
    ),
    CONSTRAINT chk_segment_warnings_alternative_route_length CHECK (
        alternative_route_description IS NULL OR length(alternative_route_description) <= 1000
    ),
    CONSTRAINT chk_segment_warnings_safety_impact_range CHECK (
        safety_impact_level >= 1 AND safety_impact_level <= 10
    ),
    CONSTRAINT chk_segment_warnings_accessibility_impact_range CHECK (
        accessibility_impact_level >= 1 AND accessibility_impact_level <= 10
    ),
    CONSTRAINT chk_segment_warnings_internal_notes_length CHECK (
        internal_notes IS NULL OR length(internal_notes) <= 2000
    ),
    CONSTRAINT chk_segment_warnings_date_logic CHECK (
        date_warning_effective_from IS NULL OR 
        date_warning_expected_resolution IS NULL OR 
        date_warning_effective_from <= date_warning_expected_resolution
    ),
    CONSTRAINT chk_segment_warnings_verification_consistency CHECK (
        (verification_date IS NULL) = (verified_by_profile_id IS NULL)
    ),
    CONSTRAINT chk_segment_warnings_geometry_dimension CHECK (
        location_on_segment_geom IS NULL OR 
        ST_CoordDim(location_on_segment_geom) = 3
    )
);

-- Add table and column comments
COMMENT ON TABLE public.segment_warnings IS 'Main table storing trail segment warnings and hazard reports';
COMMENT ON COLUMN public.segment_warnings.segment_id IS 'FK to segments table - which trail segment this warning affects';
COMMENT ON COLUMN public.segment_warnings.warning_type_id IS 'FK to warning_types_master - type of warning (trail damage, hazard, etc.)';
COMMENT ON COLUMN public.segment_warnings.severity_id IS 'FK to warning_severities_master - severity level of the warning';
COMMENT ON COLUMN public.segment_warnings.source_type_id IS 'FK to warning_source_types_master - source of the warning';
COMMENT ON COLUMN public.segment_warnings.workflow_status_id IS 'FK to workflow_statuses_master - current workflow status';
COMMENT ON COLUMN public.segment_warnings.title IS 'Brief title summarizing the warning';
COMMENT ON COLUMN public.segment_warnings.description IS 'Detailed description of the warning condition';
COMMENT ON COLUMN public.segment_warnings.detailed_description IS 'Additional detailed information about the warning';
COMMENT ON COLUMN public.segment_warnings.date_warning_effective_from IS 'Date/time when the warning becomes effective';
COMMENT ON COLUMN public.segment_warnings.date_warning_expected_resolution IS 'Expected date/time when the condition will be resolved';
COMMENT ON COLUMN public.segment_warnings.date_warning_resolved_or_expired IS 'Actual date/time when the warning was resolved or expired';
COMMENT ON COLUMN public.segment_warnings.is_currently_active IS 'Computed column indicating if warning is currently active';
COMMENT ON COLUMN public.segment_warnings.location_on_segment_geom IS 'PostGIS Point geometry for precise location on segment';
COMMENT ON COLUMN public.segment_warnings.location_description IS 'Human-readable description of the warning location';
COMMENT ON COLUMN public.segment_warnings.affects_entire_segment IS 'Whether the warning affects the entire segment or just a specific location';
COMMENT ON COLUMN public.segment_warnings.source_contact_info IS 'Contact information for the warning source';
COMMENT ON COLUMN public.segment_warnings.source_reference_url IS 'URL reference for additional information about the warning';
COMMENT ON COLUMN public.segment_warnings.verification_date IS 'Date when the warning was verified';
COMMENT ON COLUMN public.segment_warnings.verified_by_profile_id IS 'Profile ID of the person who verified the warning';
COMMENT ON COLUMN public.segment_warnings.verification_notes IS 'Notes from the verification process';
COMMENT ON COLUMN public.segment_warnings.estimated_detour_distance_meters IS 'Estimated additional distance in meters if detour is required';
COMMENT ON COLUMN public.segment_warnings.estimated_delay_minutes IS 'Estimated additional time in minutes due to the condition';
COMMENT ON COLUMN public.segment_warnings.alternative_route_description IS 'Description of alternative routes or workarounds';
COMMENT ON COLUMN public.segment_warnings.safety_impact_level IS 'Safety impact level (1-10, higher = more dangerous)';
COMMENT ON COLUMN public.segment_warnings.accessibility_impact_level IS 'Accessibility impact level (1-10, higher = more impacted)';
COMMENT ON COLUMN public.segment_warnings.primary_media_id IS 'FK to media table - primary image or media for the warning';
COMMENT ON COLUMN public.segment_warnings.supporting_media_ids IS 'Array of media IDs for additional images or documents';
COMMENT ON COLUMN public.segment_warnings.internal_notes IS 'Internal notes for content managers (not publicly visible)';
COMMENT ON COLUMN public.segment_warnings.public_visibility_override IS 'Override for public visibility (overrides workflow status visibility)';
COMMENT ON COLUMN public.segment_warnings.notification_sent_at IS 'Timestamp when notification was sent to users';

-- Create comprehensive indexes for performance
-- Primary access patterns
CREATE INDEX idx_segment_warnings_segment_id ON public.segment_warnings(segment_id);
CREATE INDEX idx_segment_warnings_warning_type_id ON public.segment_warnings(warning_type_id);
CREATE INDEX idx_segment_warnings_severity_id ON public.segment_warnings(severity_id);
CREATE INDEX idx_segment_warnings_source_type_id ON public.segment_warnings(source_type_id);
CREATE INDEX idx_segment_warnings_workflow_status_id ON public.segment_warnings(workflow_status_id);

-- Active warnings (most common query)
CREATE INDEX idx_segment_warnings_currently_active ON public.segment_warnings(is_currently_active, segment_id) 
    WHERE is_currently_active = true;

-- Temporal queries
CREATE INDEX idx_segment_warnings_effective_from ON public.segment_warnings(date_warning_effective_from);
CREATE INDEX idx_segment_warnings_expected_resolution ON public.segment_warnings(date_warning_expected_resolution);
CREATE INDEX idx_segment_warnings_resolved_expired ON public.segment_warnings(date_warning_resolved_or_expired);

-- Spatial index for location queries
CREATE INDEX idx_segment_warnings_location_gist ON public.segment_warnings 
    USING GIST(location_on_segment_geom) WHERE location_on_segment_geom IS NOT NULL;

-- Composite indexes for common query patterns
CREATE INDEX idx_segment_warnings_segment_active_severity ON public.segment_warnings(
    segment_id, is_currently_active, severity_id
) WHERE is_currently_active = true;

CREATE INDEX idx_segment_warnings_type_severity_active ON public.segment_warnings(
    warning_type_id, severity_id, is_currently_active
) WHERE is_currently_active = true;

-- Administrative indexes
CREATE INDEX idx_segment_warnings_created_by ON public.segment_warnings(created_by_profile_id);
CREATE INDEX idx_segment_warnings_updated_by ON public.segment_warnings(updated_by_profile_id);
CREATE INDEX idx_segment_warnings_verified_by ON public.segment_warnings(verified_by_profile_id);
CREATE INDEX idx_segment_warnings_verification_date ON public.segment_warnings(verification_date);
CREATE INDEX idx_segment_warnings_notification_sent ON public.segment_warnings(notification_sent_at);

-- Media indexes
CREATE INDEX idx_segment_warnings_primary_media ON public.segment_warnings(primary_media_id);
CREATE INDEX idx_segment_warnings_supporting_media_gin ON public.segment_warnings 
    USING GIN(supporting_media_ids) WHERE supporting_media_ids IS NOT NULL;

-- Boolean flags
CREATE INDEX idx_segment_warnings_affects_entire_segment ON public.segment_warnings(affects_entire_segment) 
    WHERE affects_entire_segment = true;
CREATE INDEX idx_segment_warnings_public_visibility_override ON public.segment_warnings(public_visibility_override) 
    WHERE public_visibility_override IS NOT NULL;

-- Create update trigger
CREATE TRIGGER trigger_segment_warnings_set_updated_at
    BEFORE UPDATE ON public.segment_warnings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create translation cleanup trigger
CREATE TRIGGER trigger_segment_warnings_cleanup_translations
    AFTER DELETE ON public.segment_warnings
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_translations_for_entity();

-- Enable Row Level Security
ALTER TABLE public.segment_warnings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies

-- Public can read published warnings for publicly visible segments
CREATE POLICY "Allow public read access to published warnings" ON public.segment_warnings
    FOR SELECT
    USING (
        workflow_status_id IN (
            SELECT id FROM public.workflow_statuses_master 
            WHERE is_publicly_visible = true AND is_active = true
        )
        AND (public_visibility_override IS NULL OR public_visibility_override = true)
        AND segment_id IN (
            SELECT s.id FROM public.segments s
            JOIN public.routes r ON s.route_id = r.id
            JOIN public.trails t ON r.trail_id = t.id
            WHERE t.deleted_at IS NULL 
            AND r.deleted_at IS NULL 
            AND s.deleted_at IS NULL
        )
    );

-- Authenticated users can read all warnings for non-deleted segments
CREATE POLICY "Allow authenticated users read access to all warnings" ON public.segment_warnings
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND segment_id IN (
            SELECT s.id FROM public.segments s
            JOIN public.routes r ON s.route_id = r.id
            JOIN public.trails t ON r.trail_id = t.id
            WHERE t.deleted_at IS NULL 
            AND r.deleted_at IS NULL 
            AND s.deleted_at IS NULL
        )
    );

-- Content creators can create and manage warnings
CREATE POLICY "Allow content creators to manage warnings" ON public.segment_warnings
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

-- Users can create warnings they own (for user-generated reports)
CREATE POLICY "Allow users to manage their own warnings" ON public.segment_warnings
    FOR ALL
    USING (
        auth.role() = 'authenticated'
        AND (created_by_profile_id = public.get_current_profile_id() OR created_by_profile_id IS NULL)
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (created_by_profile_id = public.get_current_profile_id() OR created_by_profile_id IS NULL)
    );

-- Service role can perform all operations
CREATE POLICY "Allow service role full access to warnings" ON public.segment_warnings
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
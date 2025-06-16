-- Module 5: Dynamic Conditions
-- 001_master_tables.sql: Master tables for dynamic conditions system
-- 
-- Purpose: Create master/lookup tables for warning system

-- Create warning types master table
CREATE TABLE IF NOT EXISTS public.warning_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    default_severity_id INTEGER NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_warning_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_warning_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_warning_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*[a-z0-9]$'
    ),
    CONSTRAINT chk_warning_types_display_name_length CHECK (
        length(display_name) >= 2 AND length(display_name) <= 100
    ),
    CONSTRAINT chk_warning_types_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_warning_types_sort_order_positive CHECK (
        sort_order > 0
    )
);

-- Create warning severities master table
CREATE TABLE IF NOT EXISTS public.warning_severities_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT NULL,
    color_hex TEXT NULL,
    icon_identifier TEXT NULL,
    urgency_level INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_warning_severities_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_warning_severities_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_warning_severities_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*[a-z0-9]$'
    ),
    CONSTRAINT chk_warning_severities_display_name_length CHECK (
        length(display_name) >= 2 AND length(display_name) <= 100
    ),
    CONSTRAINT chk_warning_severities_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_warning_severities_color_hex_format CHECK (
        color_hex IS NULL OR color_hex ~ '^#[0-9A-Fa-f]{6}$'
    ),
    CONSTRAINT chk_warning_severities_urgency_level_range CHECK (
        urgency_level >= 1 AND urgency_level <= 10
    ),
    CONSTRAINT chk_warning_severities_sort_order_positive CHECK (
        sort_order > 0
    )
);

-- Create warning source types master table
CREATE TABLE IF NOT EXISTS public.warning_source_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT NULL,
    reliability_score INTEGER NOT NULL DEFAULT 5,
    requires_verification BOOLEAN NOT NULL DEFAULT false,
    icon_identifier TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_warning_source_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_warning_source_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_warning_source_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*[a-z0-9]$'
    ),
    CONSTRAINT chk_warning_source_types_display_name_length CHECK (
        length(display_name) >= 2 AND length(display_name) <= 100
    ),
    CONSTRAINT chk_warning_source_types_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_warning_source_types_reliability_score_range CHECK (
        reliability_score >= 1 AND reliability_score <= 10
    ),
    CONSTRAINT chk_warning_source_types_sort_order_positive CHECK (
        sort_order > 0
    )
);

-- Create workflow statuses master table
CREATE TABLE IF NOT EXISTS public.workflow_statuses_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT NULL,
    is_publicly_visible BOOLEAN NOT NULL DEFAULT false,
    is_draft_status BOOLEAN NOT NULL DEFAULT false,
    is_published_status BOOLEAN NOT NULL DEFAULT false,
    is_archived_status BOOLEAN NOT NULL DEFAULT false,
    allows_public_access BOOLEAN NOT NULL DEFAULT false,
    color_hex TEXT NULL,
    icon_identifier TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_workflow_statuses_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_workflow_statuses_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_workflow_statuses_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*[a-z0-9]$'
    ),
    CONSTRAINT chk_workflow_statuses_display_name_length CHECK (
        length(display_name) >= 2 AND length(display_name) <= 100
    ),
    CONSTRAINT chk_workflow_statuses_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_workflow_statuses_color_hex_format CHECK (
        color_hex IS NULL OR color_hex ~ '^#[0-9A-Fa-f]{6}$'
    ),
    CONSTRAINT chk_workflow_statuses_sort_order_positive CHECK (
        sort_order > 0
    )
);

-- Add foreign key from warning types to warning severities (deferred constraint)
ALTER TABLE public.warning_types_master 
ADD CONSTRAINT fk_warning_types_default_severity 
    FOREIGN KEY(default_severity_id) 
    REFERENCES public.warning_severities_master(id) ON DELETE SET NULL
    DEFERRABLE INITIALLY DEFERRED;

-- Add table and column comments
COMMENT ON TABLE public.warning_types_master IS 'Master table for warning types (trail damage, natural hazard, etc.)';
COMMENT ON COLUMN public.warning_types_master.code IS 'Machine-readable identifier for the warning type';
COMMENT ON COLUMN public.warning_types_master.display_name IS 'Human-readable name for the warning type';
COMMENT ON COLUMN public.warning_types_master.description IS 'Detailed description of when this warning type applies';
COMMENT ON COLUMN public.warning_types_master.icon_identifier IS 'Icon identifier for UI display';
COMMENT ON COLUMN public.warning_types_master.default_severity_id IS 'Default severity level for this warning type';
COMMENT ON COLUMN public.warning_types_master.sort_order IS 'Display order in UI lists';

COMMENT ON TABLE public.warning_severities_master IS 'Master table for warning severity levels (info, caution, critical, etc.)';
COMMENT ON COLUMN public.warning_severities_master.code IS 'Machine-readable identifier for the severity level';
COMMENT ON COLUMN public.warning_severities_master.display_name IS 'Human-readable name for the severity level';
COMMENT ON COLUMN public.warning_severities_master.description IS 'Detailed description of the severity level';
COMMENT ON COLUMN public.warning_severities_master.color_hex IS 'Hex color code for UI display';
COMMENT ON COLUMN public.warning_severities_master.urgency_level IS 'Numeric urgency level (1-10, higher = more urgent)';

COMMENT ON TABLE public.warning_source_types_master IS 'Master table for warning source types (official authority, user report, etc.)';
COMMENT ON COLUMN public.warning_source_types_master.code IS 'Machine-readable identifier for the source type';
COMMENT ON COLUMN public.warning_source_types_master.display_name IS 'Human-readable name for the source type';
COMMENT ON COLUMN public.warning_source_types_master.reliability_score IS 'Reliability score (1-10, higher = more reliable)';
COMMENT ON COLUMN public.warning_source_types_master.requires_verification IS 'Whether warnings from this source require verification';

COMMENT ON TABLE public.workflow_statuses_master IS 'Master table for content workflow statuses (draft, published, archived, etc.)';
COMMENT ON COLUMN public.workflow_statuses_master.code IS 'Machine-readable identifier for the workflow status';
COMMENT ON COLUMN public.workflow_statuses_master.display_name IS 'Human-readable name for the workflow status';
COMMENT ON COLUMN public.workflow_statuses_master.is_publicly_visible IS 'Whether content with this status is visible to public';
COMMENT ON COLUMN public.workflow_statuses_master.is_draft_status IS 'Whether this represents a draft state';
COMMENT ON COLUMN public.workflow_statuses_master.is_published_status IS 'Whether this represents a published state';
COMMENT ON COLUMN public.workflow_statuses_master.is_archived_status IS 'Whether this represents an archived state';
COMMENT ON COLUMN public.workflow_statuses_master.allows_public_access IS 'Whether public users can access content in this status';

-- Create indexes for all master tables
-- Warning types indexes
CREATE INDEX idx_warning_types_code ON public.warning_types_master(code);
CREATE INDEX idx_warning_types_active ON public.warning_types_master(is_active) WHERE is_active = true;
CREATE INDEX idx_warning_types_sort_order ON public.warning_types_master(sort_order, display_name);
CREATE INDEX idx_warning_types_default_severity ON public.warning_types_master(default_severity_id);
CREATE INDEX idx_warning_types_created_by ON public.warning_types_master(created_by_profile_id);
CREATE INDEX idx_warning_types_updated_by ON public.warning_types_master(updated_by_profile_id);

-- Warning severities indexes
CREATE INDEX idx_warning_severities_code ON public.warning_severities_master(code);
CREATE INDEX idx_warning_severities_active ON public.warning_severities_master(is_active) WHERE is_active = true;
CREATE INDEX idx_warning_severities_sort_order ON public.warning_severities_master(sort_order, display_name);
CREATE INDEX idx_warning_severities_urgency_level ON public.warning_severities_master(urgency_level DESC);
CREATE INDEX idx_warning_severities_created_by ON public.warning_severities_master(created_by_profile_id);
CREATE INDEX idx_warning_severities_updated_by ON public.warning_severities_master(updated_by_profile_id);

-- Warning source types indexes
CREATE INDEX idx_warning_source_types_code ON public.warning_source_types_master(code);
CREATE INDEX idx_warning_source_types_active ON public.warning_source_types_master(is_active) WHERE is_active = true;
CREATE INDEX idx_warning_source_types_sort_order ON public.warning_source_types_master(sort_order, display_name);
CREATE INDEX idx_warning_source_types_reliability ON public.warning_source_types_master(reliability_score DESC);
CREATE INDEX idx_warning_source_types_verification ON public.warning_source_types_master(requires_verification);
CREATE INDEX idx_warning_source_types_created_by ON public.warning_source_types_master(created_by_profile_id);
CREATE INDEX idx_warning_source_types_updated_by ON public.warning_source_types_master(updated_by_profile_id);

-- Workflow statuses indexes
CREATE INDEX idx_workflow_statuses_code ON public.workflow_statuses_master(code);
CREATE INDEX idx_workflow_statuses_active ON public.workflow_statuses_master(is_active) WHERE is_active = true;
CREATE INDEX idx_workflow_statuses_sort_order ON public.workflow_statuses_master(sort_order, display_name);
CREATE INDEX idx_workflow_statuses_publicly_visible ON public.workflow_statuses_master(is_publicly_visible) WHERE is_publicly_visible = true;
CREATE INDEX idx_workflow_statuses_published ON public.workflow_statuses_master(is_published_status) WHERE is_published_status = true;
CREATE INDEX idx_workflow_statuses_draft ON public.workflow_statuses_master(is_draft_status) WHERE is_draft_status = true;
CREATE INDEX idx_workflow_statuses_archived ON public.workflow_statuses_master(is_archived_status) WHERE is_archived_status = true;
CREATE INDEX idx_workflow_statuses_public_access ON public.workflow_statuses_master(allows_public_access) WHERE allows_public_access = true;
CREATE INDEX idx_workflow_statuses_created_by ON public.workflow_statuses_master(created_by_profile_id);
CREATE INDEX idx_workflow_statuses_updated_by ON public.workflow_statuses_master(updated_by_profile_id);

-- Create update triggers for all master tables
CREATE TRIGGER trigger_warning_types_set_updated_at
    BEFORE UPDATE ON public.warning_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_warning_severities_set_updated_at
    BEFORE UPDATE ON public.warning_severities_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_warning_source_types_set_updated_at
    BEFORE UPDATE ON public.warning_source_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_workflow_statuses_set_updated_at
    BEFORE UPDATE ON public.workflow_statuses_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security on all master tables
ALTER TABLE public.warning_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warning_severities_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warning_source_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workflow_statuses_master ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all master tables (standard pattern)
-- Warning types master policies
CREATE POLICY "Allow public read access to active warning types" ON public.warning_types_master
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Allow authenticated users read access to all warning types" ON public.warning_types_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Allow content creators to manage warning types" ON public.warning_types_master
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

CREATE POLICY "Allow service role full access to warning types" ON public.warning_types_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Warning severities master policies (same pattern)
CREATE POLICY "Allow public read access to active warning severities" ON public.warning_severities_master
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Allow authenticated users read access to all warning severities" ON public.warning_severities_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Allow content creators to manage warning severities" ON public.warning_severities_master
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

CREATE POLICY "Allow service role full access to warning severities" ON public.warning_severities_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Warning source types master policies (same pattern)
CREATE POLICY "Allow public read access to active warning source types" ON public.warning_source_types_master
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Allow authenticated users read access to all warning source types" ON public.warning_source_types_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Allow content creators to manage warning source types" ON public.warning_source_types_master
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

CREATE POLICY "Allow service role full access to warning source types" ON public.warning_source_types_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Workflow statuses master policies (same pattern)
CREATE POLICY "Allow public read access to active workflow statuses" ON public.workflow_statuses_master
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Allow authenticated users read access to all workflow statuses" ON public.workflow_statuses_master
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Allow content creators to manage workflow statuses" ON public.workflow_statuses_master
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

CREATE POLICY "Allow service role full access to workflow statuses" ON public.workflow_statuses_master
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
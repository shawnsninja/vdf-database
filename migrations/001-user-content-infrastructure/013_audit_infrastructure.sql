-- =====================================================================================
-- Module 1: Audit Infrastructure
-- Description: Core audit logging and schema versioning tables
-- =====================================================================================

-- =====================================================================================
-- Schema Migrations Table
-- Tracks which migration files have been applied to the database
-- =====================================================================================
CREATE TABLE IF NOT EXISTS public.schema_migrations (
    version text NOT NULL PRIMARY KEY,
    description text,
    module text,
    applied_at timestamp with time zone NOT NULL DEFAULT now(),
    applied_by text DEFAULT current_user
);

COMMENT ON TABLE public.schema_migrations IS 
    'Tracks database schema versions and migration history';

COMMENT ON COLUMN public.schema_migrations.version IS 
    'Unique version identifier (e.g., "001_001" for module 1, migration 1)';

COMMENT ON COLUMN public.schema_migrations.description IS 
    'Human-readable description of what the migration does';

COMMENT ON COLUMN public.schema_migrations.module IS 
    'Module name this migration belongs to';

-- Insert current migrations as applied
INSERT INTO public.schema_migrations (version, description, module) VALUES
    ('001_001', 'Enable PostgreSQL extensions', 'user_infrastructure'),
    ('001_002', 'Create helper functions', 'user_infrastructure'),
    ('001_003', 'Create profiles table', 'user_infrastructure'),
    ('001_004', 'Create user_roles_master table', 'user_infrastructure'),
    ('001_005', 'Seed user_roles_master data', 'user_infrastructure'),
    ('001_006', 'Create languages_master table', 'user_infrastructure'),
    ('001_007', 'Seed languages_master data', 'user_infrastructure'),
    ('001_008', 'Create translations table', 'user_infrastructure'),
    ('001_009', 'Create translation cleanup triggers', 'user_infrastructure'),
    ('001_010', 'Create media table', 'user_infrastructure'),
    ('001_011', 'Add foreign key constraints', 'user_infrastructure'),
    ('001_012', 'Create RLS policies', 'user_infrastructure'),
    ('001_013', 'Create audit infrastructure', 'user_infrastructure')
ON CONFLICT (version) DO NOTHING;

-- =====================================================================================
-- Audit Log Table
-- Tracks all data modifications for compliance and debugging
-- =====================================================================================
CREATE TABLE IF NOT EXISTS public.audit_log (
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    -- What was changed
    table_schema text NOT NULL DEFAULT 'public',
    table_name text NOT NULL,
    record_id text NOT NULL, -- PK of the record as text
    
    -- What operation
    operation text NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    
    -- Who made the change
    user_id uuid,
    user_email text,
    user_roles text[],
    session_id text,
    
    -- What changed
    old_data jsonb,
    new_data jsonb,
    changed_fields text[], -- Array of field names that changed
    
    -- When it happened
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    
    -- Additional context
    ip_address inet,
    user_agent text,
    application_name text,
    
    -- Indexes
    CONSTRAINT audit_log_check_data CHECK (
        (operation = 'INSERT' AND old_data IS NULL AND new_data IS NOT NULL) OR
        (operation = 'UPDATE' AND old_data IS NOT NULL AND new_data IS NOT NULL) OR
        (operation = 'DELETE' AND old_data IS NOT NULL AND new_data IS NULL)
    )
);

-- Indexes for efficient querying
CREATE INDEX idx_audit_log_table_record ON public.audit_log (table_name, record_id);
CREATE INDEX idx_audit_log_user_id ON public.audit_log (user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_audit_log_created_at ON public.audit_log (created_at DESC);
CREATE INDEX idx_audit_log_operation ON public.audit_log (operation);

-- Comments
COMMENT ON TABLE public.audit_log IS 
    'Comprehensive audit trail of all data modifications in the system';

COMMENT ON COLUMN public.audit_log.record_id IS 
    'Primary key of the affected record, stored as text for flexibility';

COMMENT ON COLUMN public.audit_log.changed_fields IS 
    'Array of field names that were modified in UPDATE operations';

-- =====================================================================================
-- Generic Audit Trigger Function
-- Can be attached to any table to log changes
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    audit_user_id uuid;
    audit_user_email text;
    audit_user_roles text[];
    changed_fields text[];
    old_jsonb jsonb;
    new_jsonb jsonb;
BEGIN
    -- Get current user information
    audit_user_id := auth.uid();
    
    -- Get user details if authenticated
    IF audit_user_id IS NOT NULL THEN
        SELECT email, roles 
        INTO audit_user_email, audit_user_roles
        FROM public.profiles 
        WHERE id = audit_user_id;
    END IF;
    
    -- Convert records to JSONB
    IF TG_OP != 'INSERT' THEN
        old_jsonb := to_jsonb(OLD);
    END IF;
    
    IF TG_OP != 'DELETE' THEN
        new_jsonb := to_jsonb(NEW);
    END IF;
    
    -- Calculate changed fields for UPDATE
    IF TG_OP = 'UPDATE' THEN
        SELECT array_agg(key) 
        INTO changed_fields
        FROM jsonb_each(old_jsonb)
        WHERE old_jsonb->key IS DISTINCT FROM new_jsonb->key;
    END IF;
    
    -- Insert audit record
    INSERT INTO public.audit_log (
        table_schema,
        table_name,
        record_id,
        operation,
        user_id,
        user_email,
        user_roles,
        old_data,
        new_data,
        changed_fields,
        ip_address,
        application_name
    ) VALUES (
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.id::text
            ELSE NEW.id::text
        END,
        TG_OP,
        audit_user_id,
        audit_user_email,
        audit_user_roles,
        old_jsonb,
        new_jsonb,
        changed_fields,
        inet_client_addr(),
        current_setting('application_name', true)
    );
    
    -- Return appropriate value
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

COMMENT ON FUNCTION public.audit_trigger_function() IS 
    'Generic trigger function that logs all data modifications to the audit_log table';

-- =====================================================================================
-- Helper Function: Enable auditing on a table
-- Usage: SELECT enable_audit_logging('table_name');
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.enable_audit_logging(target_table text)
RETURNS void AS $$
BEGIN
    EXECUTE format('
        CREATE TRIGGER audit_trigger
        AFTER INSERT OR UPDATE OR DELETE ON public.%I
        FOR EACH ROW EXECUTE FUNCTION public.audit_trigger_function()',
        target_table
    );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.enable_audit_logging(text) IS 
    'Enables audit logging on the specified table by creating the necessary trigger';

-- =====================================================================================
-- RLS Policies for audit tables
-- =====================================================================================

-- Enable RLS
ALTER TABLE public.schema_migrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Schema migrations: Only super admins can modify
CREATE POLICY "schema_migrations_admin_all" ON public.schema_migrations
    FOR ALL
    TO authenticated
    USING (public.has_role('admin_super'))
    WITH CHECK (public.has_role('admin_super'));

-- Everyone can read schema migrations
CREATE POLICY "schema_migrations_read_all" ON public.schema_migrations
    FOR SELECT
    USING (true);

-- Audit log: Users can see their own audit records
CREATE POLICY "audit_log_own_read" ON public.audit_log
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Admins can see all audit records
CREATE POLICY "audit_log_admin_read" ON public.audit_log
    FOR SELECT
    TO authenticated
    USING (public.has_role('platform_admin') OR public.has_role('admin_super'));

-- Only system can insert audit records (via trigger)
CREATE POLICY "audit_log_system_insert" ON public.audit_log
    FOR INSERT
    WITH CHECK (false); -- Triggers run as security definer

-- Grant permissions
GRANT SELECT ON public.schema_migrations TO authenticated, anon;
GRANT SELECT ON public.audit_log TO authenticated;
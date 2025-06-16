-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 002_helper_functions.sql
-- Description: Create helper functions needed by other tables
-- Version: 1.0
-- =============================================

-- Generic updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.handle_updated_at() IS 
'Sets updated_at to current timestamp on row update. Generic trigger function.';
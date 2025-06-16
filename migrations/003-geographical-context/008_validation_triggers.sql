-- Module 3: Geographical Context
-- 008_validation_triggers.sql: Validation triggers for array foreign keys
-- 
-- Purpose: Ensure array fields reference valid master data
-- Dependencies: regions, towns, characteristic_tags_master, service_tags_master

-- Function to validate region characteristics tags
CREATE OR REPLACE FUNCTION public.validate_region_characteristics_tags()
RETURNS TRIGGER AS $$
DECLARE
    tag_code TEXT;
    tag_record public.characteristic_tags_master;
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.characteristics_tags IS DISTINCT FROM OLD.characteristics_tags) THEN
        IF NEW.characteristics_tags IS NOT NULL THEN
            FOREACH tag_code IN ARRAY NEW.characteristics_tags
            LOOP
                SELECT * INTO tag_record
                FROM public.characteristic_tags_master
                WHERE code = tag_code;
                
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Invalid characteristic_tag_code "%" does not exist in characteristic_tags_master.', tag_code;
                END IF;
                
                IF NOT tag_record.is_active THEN
                    RAISE EXCEPTION 'Characteristic tag "%" is not active.', tag_code;
                END IF;
            END LOOP;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth;

-- Add trigger to regions table
CREATE TRIGGER trigger_validate_characteristics_tags
    BEFORE INSERT OR UPDATE ON public.regions
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_region_characteristics_tags();

-- Function to validate town service tags
CREATE OR REPLACE FUNCTION public.validate_town_services_tags()
RETURNS TRIGGER AS $$
DECLARE
    tag_code TEXT;
    tag_record public.service_tags_master;
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.key_services_summary_tags IS DISTINCT FROM OLD.key_services_summary_tags) THEN
        IF NEW.key_services_summary_tags IS NOT NULL THEN
            FOREACH tag_code IN ARRAY NEW.key_services_summary_tags
            LOOP
                SELECT * INTO tag_record
                FROM public.service_tags_master
                WHERE code = tag_code;
                
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Invalid service_tag_code "%" does not exist in service_tags_master.', tag_code;
                END IF;
                
                IF NOT tag_record.is_active THEN
                    RAISE EXCEPTION 'Service tag "%" is not active.', tag_code;
                END IF;
            END LOOP;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth;

-- Add trigger to towns table
CREATE TRIGGER trigger_validate_key_services_tags
    BEFORE INSERT OR UPDATE ON public.towns
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_town_services_tags();
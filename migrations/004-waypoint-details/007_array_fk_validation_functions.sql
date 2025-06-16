-- Module 4: Waypoint Details
-- 007_array_fk_validation_functions.sql: Array foreign key validation functions
-- 
-- Purpose: Create functions to validate array foreign keys integrity

-- Function to validate waypoint subcategory tag IDs
CREATE OR REPLACE FUNCTION public.check_waypoint_subcategory_tags()
RETURNS TRIGGER AS $$
DECLARE
    invalid_tag_id INTEGER;
BEGIN
    -- Skip validation if array is NULL or empty
    IF NEW.waypoint_subcategory_tag_ids IS NULL OR array_length(NEW.waypoint_subcategory_tag_ids, 1) IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check each tag ID in the array
    SELECT unnest(NEW.waypoint_subcategory_tag_ids) INTO invalid_tag_id
    WHERE unnest(NEW.waypoint_subcategory_tag_ids) NOT IN (
        SELECT id FROM public.tags_master WHERE is_active = true
    )
    LIMIT 1;
    
    -- If we found an invalid ID, raise an exception
    IF invalid_tag_id IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid tag ID % in waypoint_subcategory_tag_ids. Tag must exist in tags_master and be active.', invalid_tag_id
            USING ERRCODE = 'foreign_key_violation',
                  HINT = 'Check that all tag IDs exist in public.tags_master with is_active = true';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON FUNCTION public.check_waypoint_subcategory_tags() IS 
'Validates that all IDs in waypoint_subcategory_tag_ids array reference active tags in tags_master table.';

-- Function to validate characteristic tags (for towns and regions)
CREATE OR REPLACE FUNCTION public.validate_characteristic_tags_array()
RETURNS TRIGGER AS $$
DECLARE
    invalid_tag_code TEXT;
    table_name TEXT;
    column_name TEXT;
    tag_array TEXT[];
BEGIN
    -- Determine which table and column we're validating
    table_name := TG_TABLE_NAME;
    
    IF table_name = 'regions' THEN
        column_name := 'characteristics_tags';
        tag_array := NEW.characteristics_tags;
    ELSIF table_name = 'towns' THEN
        column_name := 'characteristics_tags';
        tag_array := NEW.characteristics_tags;
    ELSE
        RAISE EXCEPTION 'validate_characteristic_tags_array called on unsupported table: %', table_name;
    END IF;
    
    -- Skip validation if array is NULL or empty
    IF tag_array IS NULL OR array_length(tag_array, 1) IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check each tag code in the array
    SELECT unnest(tag_array) INTO invalid_tag_code
    WHERE unnest(tag_array) NOT IN (
        SELECT code FROM public.characteristic_tags_master WHERE is_active = true
    )
    LIMIT 1;
    
    -- If we found an invalid code, raise an exception
    IF invalid_tag_code IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid characteristic tag code ''%'' in %.%. Tag must exist in characteristic_tags_master and be active.', 
            invalid_tag_code, table_name, column_name
            USING ERRCODE = 'foreign_key_violation',
                  HINT = 'Check that all tag codes exist in public.characteristic_tags_master with is_active = true';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON FUNCTION public.validate_characteristic_tags_array() IS 
'Validates that all codes in characteristics_tags arrays reference active tags in characteristic_tags_master table.';

-- Function to validate service tags (for towns)
CREATE OR REPLACE FUNCTION public.validate_service_tags_array()
RETURNS TRIGGER AS $$
DECLARE
    invalid_tag_code TEXT;
BEGIN
    -- Skip validation if array is NULL or empty
    IF NEW.service_tags IS NULL OR array_length(NEW.service_tags, 1) IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check each tag code in the array
    SELECT unnest(NEW.service_tags) INTO invalid_tag_code
    WHERE unnest(NEW.service_tags) NOT IN (
        SELECT code FROM public.service_tags_master WHERE is_active = true
    )
    LIMIT 1;
    
    -- If we found an invalid code, raise an exception
    IF invalid_tag_code IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid service tag code ''%'' in service_tags. Tag must exist in service_tags_master and be active.', 
            invalid_tag_code
            USING ERRCODE = 'foreign_key_violation',
                  HINT = 'Check that all tag codes exist in public.service_tags_master with is_active = true';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON FUNCTION public.validate_service_tags_array() IS 
'Validates that all codes in service_tags arrays reference active tags in service_tags_master table.';
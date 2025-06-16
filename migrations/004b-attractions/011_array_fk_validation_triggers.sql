-- Module 4b: Attractions
-- 011_array_fk_validation_triggers.sql: Array foreign key validation triggers
-- 
-- Purpose: Create triggers to validate array foreign key references for Module 4b tables

-- Create trigger function to validate shop service type array foreign keys
CREATE OR REPLACE FUNCTION public.validate_shops_services_shop_service_types()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if shop_service_type_ids is not null and not empty
    IF NEW.shop_service_type_ids IS NOT NULL AND array_length(NEW.shop_service_type_ids, 1) > 0 THEN
        -- Check if all shop service type IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.shop_service_type_ids) AS type_id
            WHERE type_id NOT IN (
                SELECT id FROM public.shop_service_types_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more shop service type IDs do not exist or are inactive',
                      DETAIL = format('Invalid shop service type IDs in array: %L', NEW.shop_service_type_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to validate payment method array foreign keys
CREATE OR REPLACE FUNCTION public.validate_payment_method_array()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if payment_method_ids is not null and not empty
    IF NEW.payment_method_ids IS NOT NULL AND array_length(NEW.payment_method_ids, 1) > 0 THEN
        -- Check if all payment method IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.payment_method_ids) AS method_id
            WHERE method_id NOT IN (
                SELECT id FROM public.payment_methods_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more payment method IDs do not exist or are inactive',
                      DETAIL = format('Invalid payment method IDs in array: %L', NEW.payment_method_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to validate meal type array foreign keys
CREATE OR REPLACE FUNCTION public.validate_meal_type_array()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if meal_type_ids is not null and not empty
    IF NEW.meal_type_ids IS NOT NULL AND array_length(NEW.meal_type_ids, 1) > 0 THEN
        -- Check if all meal type IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.meal_type_ids) AS meal_type_id
            WHERE meal_type_id NOT IN (
                SELECT id FROM public.meal_type_tags_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more meal type IDs do not exist or are inactive',
                      DETAIL = format('Invalid meal type IDs in array: %L', NEW.meal_type_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to validate dietary option array foreign keys
CREATE OR REPLACE FUNCTION public.validate_dietary_option_array()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if dietary_option_ids is not null and not empty
    IF NEW.dietary_option_ids IS NOT NULL AND array_length(NEW.dietary_option_ids, 1) > 0 THEN
        -- Check if all dietary option IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.dietary_option_ids) AS dietary_option_id
            WHERE dietary_option_id NOT IN (
                SELECT id FROM public.dietary_option_tags_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more dietary option IDs do not exist or are inactive',
                      DETAIL = format('Invalid dietary option IDs in array: %L', NEW.dietary_option_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to validate food water source type array foreign keys
CREATE OR REPLACE FUNCTION public.validate_food_water_source_types()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate if source_type_ids is not null and not empty
    IF NEW.source_type_ids IS NOT NULL AND array_length(NEW.source_type_ids, 1) > 0 THEN
        -- Check if all source type IDs exist and are active
        IF EXISTS (
            SELECT 1 
            FROM unnest(NEW.source_type_ids) AS source_type_id
            WHERE source_type_id NOT IN (
                SELECT id FROM public.food_water_source_types_master WHERE is_active = true
            )
        ) THEN
            RAISE foreign_key_violation 
                USING MESSAGE = 'One or more food/water source type IDs do not exist or are inactive',
                      DETAIL = format('Invalid food/water source type IDs in array: %L', NEW.source_type_ids);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create comprehensive validation function for shops and services details
CREATE OR REPLACE FUNCTION public.validate_shops_services_arrays()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate shop service types
    PERFORM public.validate_shops_services_shop_service_types();
    
    -- Validate payment methods
    PERFORM public.validate_payment_method_array();
    
    -- Validate meal types
    PERFORM public.validate_meal_type_array();
    
    -- Validate dietary options
    PERFORM public.validate_dietary_option_array();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create comprehensive validation function for food water sources details
CREATE OR REPLACE FUNCTION public.validate_food_water_sources_arrays()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate food water source types
    PERFORM public.validate_food_water_source_types();
    
    -- Validate meal types
    PERFORM public.validate_meal_type_array();
    
    -- Validate dietary options
    PERFORM public.validate_dietary_option_array();
    
    -- Validate payment methods
    PERFORM public.validate_payment_method_array();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to shops and services details table
CREATE TRIGGER trigger_shops_services_validate_shop_service_types
    BEFORE INSERT OR UPDATE ON public.shops_and_services_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_shops_services_shop_service_types();

CREATE TRIGGER trigger_shops_services_validate_payment_methods
    BEFORE INSERT OR UPDATE ON public.shops_and_services_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_payment_method_array();

CREATE TRIGGER trigger_shops_services_validate_meal_types
    BEFORE INSERT OR UPDATE ON public.shops_and_services_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_meal_type_array();

CREATE TRIGGER trigger_shops_services_validate_dietary_options
    BEFORE INSERT OR UPDATE ON public.shops_and_services_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_dietary_option_array();

-- Apply triggers to food water sources details table
CREATE TRIGGER trigger_food_water_sources_validate_source_types
    BEFORE INSERT OR UPDATE ON public.food_water_sources_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_food_water_source_types();

CREATE TRIGGER trigger_food_water_sources_validate_meal_types
    BEFORE INSERT OR UPDATE ON public.food_water_sources_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_meal_type_array();

CREATE TRIGGER trigger_food_water_sources_validate_dietary_options
    BEFORE INSERT OR UPDATE ON public.food_water_sources_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_dietary_option_array();

CREATE TRIGGER trigger_food_water_sources_validate_payment_methods
    BEFORE INSERT OR UPDATE ON public.food_water_sources_details
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_payment_method_array();

-- Add comments for all trigger functions
COMMENT ON FUNCTION public.validate_shops_services_shop_service_types() IS 'Validates that all shop service type IDs in array exist and are active.';
COMMENT ON FUNCTION public.validate_payment_method_array() IS 'Validates that all payment method IDs in array exist and are active.';
COMMENT ON FUNCTION public.validate_meal_type_array() IS 'Validates that all meal type IDs in array exist and are active.';
COMMENT ON FUNCTION public.validate_dietary_option_array() IS 'Validates that all dietary option IDs in array exist and are active.';
COMMENT ON FUNCTION public.validate_food_water_source_types() IS 'Validates that all food/water source type IDs in array exist and are active.';
COMMENT ON FUNCTION public.validate_shops_services_arrays() IS 'Comprehensive validation function for all array FKs in shops and services details.';
COMMENT ON FUNCTION public.validate_food_water_sources_arrays() IS 'Comprehensive validation function for all array FKs in food water sources details.';

-- Add comments for triggers
COMMENT ON TRIGGER trigger_shops_services_validate_shop_service_types ON public.shops_and_services_details IS 
'Trigger to validate that all shop service type IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_shops_services_validate_payment_methods ON public.shops_and_services_details IS 
'Trigger to validate that all payment method IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_shops_services_validate_meal_types ON public.shops_and_services_details IS 
'Trigger to validate that all meal type IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_shops_services_validate_dietary_options ON public.shops_and_services_details IS 
'Trigger to validate that all dietary option IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_food_water_sources_validate_source_types ON public.food_water_sources_details IS 
'Trigger to validate that all food/water source type IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_food_water_sources_validate_meal_types ON public.food_water_sources_details IS 
'Trigger to validate that all meal type IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_food_water_sources_validate_dietary_options ON public.food_water_sources_details IS 
'Trigger to validate that all dietary option IDs in the array exist and are active.';

COMMENT ON TRIGGER trigger_food_water_sources_validate_payment_methods ON public.food_water_sources_details IS 
'Trigger to validate that all payment method IDs in the array exist and are active.';
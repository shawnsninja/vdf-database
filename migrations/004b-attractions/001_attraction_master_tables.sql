-- Module 4b: Attractions
-- 001_attraction_master_tables.sql: Master tables for attractions
-- 
-- Purpose: Define master data for attraction types, amenities, and services

-- Create attraction types master table
CREATE TABLE IF NOT EXISTS public.attraction_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_attraction_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_attraction_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_attraction_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_attraction_types_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_attraction_types_description_length CHECK (
        description IS NULL OR length(description) <= 500
    )
);

-- Create visitor amenities master table  
CREATE TABLE IF NOT EXISTS public.visitor_amenities_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    category TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_visitor_amenities_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_visitor_amenities_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_visitor_amenities_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_visitor_amenities_category_valid CHECK (
        category IN ('facilities', 'services', 'accessibility', 'educational', 'spiritual', 'convenience')
    )
);

-- Create religious service types master table
CREATE TABLE IF NOT EXISTS public.religious_service_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_religious_service_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_religious_service_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_religious_service_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    )
);

-- Create food water source types master table
CREATE TABLE IF NOT EXISTS public.food_water_source_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    is_commercial BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_food_water_source_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_food_water_source_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_food_water_source_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    )
);

-- Create water reliability types master table
CREATE TABLE IF NOT EXISTS public.water_reliability_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    advisory_level TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_water_reliability_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_water_reliability_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_water_reliability_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_water_reliability_types_advisory_level CHECK (
        advisory_level IS NULL OR advisory_level IN ('safe', 'caution', 'warning', 'danger', 'unknown')
    )
);

-- Create shop service types master table
CREATE TABLE IF NOT EXISTS public.shop_service_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    category TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_shop_service_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_shop_service_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_shop_service_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_shop_service_types_category_valid CHECK (
        category IN ('food_beverage', 'retail', 'services', 'pilgrim_specific', 'healthcare', 'emergency')
    )
);

-- Add table comments
COMMENT ON TABLE public.attraction_types_master IS 'Master table defining types of attractions (historical sites, museums, etc.).';
COMMENT ON TABLE public.visitor_amenities_master IS 'Master table defining amenities available at attractions for visitors.';
COMMENT ON TABLE public.religious_service_types_master IS 'Master table defining types of religious services offered at religious sites.';
COMMENT ON TABLE public.food_water_source_types_master IS 'Master table defining types of food and water sources.';
COMMENT ON COLUMN public.food_water_source_types_master.is_commercial IS 'Whether this source type is typically commercial (requires payment).';
COMMENT ON TABLE public.water_reliability_types_master IS 'Master table defining water source reliability levels.';
COMMENT ON COLUMN public.water_reliability_types_master.advisory_level IS 'Safety advisory level: safe, caution, warning, danger, unknown.';
COMMENT ON TABLE public.shop_service_types_master IS 'Master table defining types of shops and services available.';

-- Create indexes for all master tables
CREATE INDEX idx_attraction_types_code ON public.attraction_types_master(code);
CREATE INDEX idx_attraction_types_sort_order ON public.attraction_types_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_visitor_amenities_code ON public.visitor_amenities_master(code);
CREATE INDEX idx_visitor_amenities_category ON public.visitor_amenities_master(category) WHERE is_active = true;

CREATE INDEX idx_religious_service_types_code ON public.religious_service_types_master(code);
CREATE INDEX idx_religious_service_types_sort_order ON public.religious_service_types_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_food_water_source_types_code ON public.food_water_source_types_master(code);
CREATE INDEX idx_food_water_source_types_sort_order ON public.food_water_source_types_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_water_reliability_types_code ON public.water_reliability_types_master(code);
CREATE INDEX idx_water_reliability_types_sort_order ON public.water_reliability_types_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_shop_service_types_code ON public.shop_service_types_master(code);
CREATE INDEX idx_shop_service_types_category ON public.shop_service_types_master(category) WHERE is_active = true;

-- Create update triggers for all master tables
CREATE TRIGGER trigger_attraction_types_set_updated_at
    BEFORE UPDATE ON public.attraction_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_visitor_amenities_set_updated_at
    BEFORE UPDATE ON public.visitor_amenities_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_religious_service_types_set_updated_at
    BEFORE UPDATE ON public.religious_service_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_food_water_source_types_set_updated_at
    BEFORE UPDATE ON public.food_water_source_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_water_reliability_types_set_updated_at
    BEFORE UPDATE ON public.water_reliability_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_shop_service_types_set_updated_at
    BEFORE UPDATE ON public.shop_service_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS on all master tables
ALTER TABLE public.attraction_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visitor_amenities_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.religious_service_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_water_source_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_reliability_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_service_types_master ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all master tables (public read, authenticated manage)
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN VALUES ('attraction_types_master'), ('visitor_amenities_master'), ('religious_service_types_master'), ('food_water_source_types_master'), ('water_reliability_types_master'), ('shop_service_types_master') LOOP
        -- Public read access to active records
        EXECUTE format('
            CREATE POLICY "Allow public read access to active %I" ON public.%I
                FOR SELECT
                USING (is_active = true)', table_name, table_name);
        
        -- Authenticated read access to all records
        EXECUTE format('
            CREATE POLICY "Allow authenticated users read access to %I" ON public.%I
                FOR SELECT
                USING (auth.role() = ''authenticated'')', table_name, table_name);
        
        -- Content managers can manage
        EXECUTE format('
            CREATE POLICY "Allow content managers to manage %I" ON public.%I
                FOR ALL
                USING (
                    auth.role() = ''authenticated''
                    AND (
                        public.has_role(''content_creator'') OR
                        public.has_role(''regional_content_manager'') OR
                        public.has_role(''admin'') OR
                        public.has_role(''platform_admin'')
                    )
                )
                WITH CHECK (
                    auth.role() = ''authenticated''
                    AND (
                        public.has_role(''content_creator'') OR
                        public.has_role(''regional_content_manager'') OR
                        public.has_role(''admin'') OR
                        public.has_role(''platform_admin'')
                    )
                )', table_name, table_name);
        
        -- Service role full access
        EXECUTE format('
            CREATE POLICY "Allow service role full access to %I" ON public.%I
                FOR ALL
                USING (auth.role() = ''service_role'')
                WITH CHECK (auth.role() = ''service_role'')', table_name, table_name);
    END LOOP;
END $$;
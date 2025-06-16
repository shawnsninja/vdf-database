-- Module 4b: Attractions
-- 006_additional_master_tables.sql: Additional master tables for attractions
-- 
-- Purpose: Define additional master data for price ranges, meal types, dietary options, and payment methods

-- Create establishment price ranges master table
CREATE TABLE IF NOT EXISTS public.establishment_price_ranges_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    min_price_eur DECIMAL(8,2) NULL,
    max_price_eur DECIMAL(8,2) NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_establishment_price_ranges_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_establishment_price_ranges_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_establishment_price_ranges_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_establishment_price_ranges_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_establishment_price_ranges_description_length CHECK (
        description IS NULL OR length(description) <= 500
    ),
    CONSTRAINT chk_establishment_price_ranges_price_valid CHECK (
        (min_price_eur IS NULL AND max_price_eur IS NULL) OR
        (min_price_eur IS NOT NULL AND max_price_eur IS NOT NULL AND min_price_eur <= max_price_eur) OR
        (min_price_eur IS NOT NULL AND max_price_eur IS NULL AND min_price_eur >= 0) OR
        (min_price_eur IS NULL AND max_price_eur IS NOT NULL AND max_price_eur >= 0)
    )
);

-- Create meal type tags master table
CREATE TABLE IF NOT EXISTS public.meal_type_tags_master (
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
    CONSTRAINT fk_meal_type_tags_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_meal_type_tags_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_meal_type_tags_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_meal_type_tags_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_meal_type_tags_description_length CHECK (
        description IS NULL OR length(description) <= 500
    )
);

-- Create dietary option tags master table
CREATE TABLE IF NOT EXISTS public.dietary_option_tags_master (
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
    CONSTRAINT fk_dietary_option_tags_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_dietary_option_tags_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_dietary_option_tags_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_dietary_option_tags_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_dietary_option_tags_description_length CHECK (
        description IS NULL OR length(description) <= 500
    )
);

-- Create payment methods master table
CREATE TABLE IF NOT EXISTS public.payment_methods_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    is_electronic BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_payment_methods_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_methods_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_payment_methods_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_payment_methods_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_payment_methods_description_length CHECK (
        description IS NULL OR length(description) <= 500
    )
);

-- Add table comments
COMMENT ON TABLE public.establishment_price_ranges_master IS 'Master table defining price ranges for establishments (budget, moderate, expensive, etc.).';
COMMENT ON TABLE public.meal_type_tags_master IS 'Master table defining meal types available at food establishments.';
COMMENT ON TABLE public.dietary_option_tags_master IS 'Master table defining dietary options available (vegetarian, vegan, gluten-free, etc.).';
COMMENT ON TABLE public.payment_methods_master IS 'Master table defining accepted payment methods at establishments.';

-- Add column comments
COMMENT ON COLUMN public.establishment_price_ranges_master.min_price_eur IS 'Minimum price in EUR for this range (optional).';
COMMENT ON COLUMN public.establishment_price_ranges_master.max_price_eur IS 'Maximum price in EUR for this range (optional).';
COMMENT ON COLUMN public.payment_methods_master.is_electronic IS 'Whether this is an electronic payment method (cards, digital wallets, etc.).';

-- Create indexes for all new master tables
CREATE INDEX idx_establishment_price_ranges_code ON public.establishment_price_ranges_master(code);
CREATE INDEX idx_establishment_price_ranges_sort_order ON public.establishment_price_ranges_master(sort_order) WHERE is_active = true;
CREATE INDEX idx_establishment_price_ranges_price_range ON public.establishment_price_ranges_master(min_price_eur, max_price_eur) WHERE is_active = true;

CREATE INDEX idx_meal_type_tags_code ON public.meal_type_tags_master(code);
CREATE INDEX idx_meal_type_tags_sort_order ON public.meal_type_tags_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_dietary_option_tags_code ON public.dietary_option_tags_master(code);
CREATE INDEX idx_dietary_option_tags_sort_order ON public.dietary_option_tags_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_payment_methods_code ON public.payment_methods_master(code);
CREATE INDEX idx_payment_methods_sort_order ON public.payment_methods_master(sort_order) WHERE is_active = true;
CREATE INDEX idx_payment_methods_electronic ON public.payment_methods_master(is_electronic) WHERE is_active = true;

-- Create update triggers for all new master tables
CREATE TRIGGER trigger_establishment_price_ranges_set_updated_at
    BEFORE UPDATE ON public.establishment_price_ranges_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_meal_type_tags_set_updated_at
    BEFORE UPDATE ON public.meal_type_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_dietary_option_tags_set_updated_at
    BEFORE UPDATE ON public.dietary_option_tags_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_payment_methods_set_updated_at
    BEFORE UPDATE ON public.payment_methods_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS on all new master tables
ALTER TABLE public.establishment_price_ranges_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_type_tags_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dietary_option_tags_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods_master ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all new master tables (public read, authenticated manage)
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN VALUES ('establishment_price_ranges_master'), ('meal_type_tags_master'), ('dietary_option_tags_master'), ('payment_methods_master') LOOP
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
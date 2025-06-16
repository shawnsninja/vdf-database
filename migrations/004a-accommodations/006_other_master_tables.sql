-- Module 4a: Accommodations
-- 006_other_master_tables.sql: Additional master tables for accommodations
-- 
-- Purpose: Create remaining master tables for rooms, payments, meals, and pricing

-- Room types master table
CREATE TABLE IF NOT EXISTS public.room_types_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    typical_occupancy INTEGER NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_room_types_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_room_types_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_room_types_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_room_types_label_length CHECK (
        length(label) BETWEEN 1 AND 100
    ),
    CONSTRAINT chk_room_types_typical_occupancy CHECK (
        typical_occupancy IS NULL OR typical_occupancy > 0
    )
);

-- Payment methods master table
CREATE TABLE IF NOT EXISTS public.payment_methods_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    is_digital BOOLEAN NOT NULL DEFAULT false,
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
    )
);

-- Meal services master table
CREATE TABLE IF NOT EXISTS public.meal_services_master (
    id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT NULL,
    icon_identifier TEXT NULL,
    meal_type TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_meal_services_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_meal_services_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_meal_services_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_meal_services_meal_type CHECK (
        meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'all_day')
    )
);

-- Price ranges master table
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
    CONSTRAINT fk_price_ranges_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_price_ranges_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_price_ranges_code_format CHECK (
        code ~ '^[a-z][a-z0-9_]*$' AND length(code) BETWEEN 2 AND 50
    ),
    CONSTRAINT chk_price_ranges_min_max CHECK (
        min_price_eur IS NULL OR max_price_eur IS NULL OR min_price_eur <= max_price_eur
    ),
    CONSTRAINT chk_price_ranges_positive CHECK (
        (min_price_eur IS NULL OR min_price_eur >= 0) AND
        (max_price_eur IS NULL OR max_price_eur >= 0)
    )
);

-- Add comments for all tables
COMMENT ON TABLE public.room_types_master IS 'Master table defining types of rooms available at accommodations.';
COMMENT ON TABLE public.payment_methods_master IS 'Master table defining payment methods accepted at accommodations.';
COMMENT ON TABLE public.meal_services_master IS 'Master table defining meal services available at accommodations.';
COMMENT ON TABLE public.establishment_price_ranges_master IS 'Master table defining price ranges for accommodations.';

-- Create indexes for all tables
CREATE INDEX idx_room_types_code ON public.room_types_master(code);
CREATE INDEX idx_room_types_sort_order ON public.room_types_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_payment_methods_code ON public.payment_methods_master(code);
CREATE INDEX idx_payment_methods_sort_order ON public.payment_methods_master(sort_order) WHERE is_active = true;

CREATE INDEX idx_meal_services_code ON public.meal_services_master(code);
CREATE INDEX idx_meal_services_meal_type ON public.meal_services_master(meal_type) WHERE is_active = true;

CREATE INDEX idx_price_ranges_code ON public.establishment_price_ranges_master(code);
CREATE INDEX idx_price_ranges_sort_order ON public.establishment_price_ranges_master(sort_order) WHERE is_active = true;

-- Create update triggers for all tables
CREATE TRIGGER trigger_room_types_set_updated_at
    BEFORE UPDATE ON public.room_types_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_payment_methods_set_updated_at
    BEFORE UPDATE ON public.payment_methods_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_meal_services_set_updated_at
    BEFORE UPDATE ON public.meal_services_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_price_ranges_set_updated_at
    BEFORE UPDATE ON public.establishment_price_ranges_master
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert seed data for room types
INSERT INTO public.room_types_master (code, label, description, icon_identifier, typical_occupancy, sort_order) VALUES 
    ('private_single', 'Private Single', 'Single occupancy private room', 'bed', 1, 10),
    ('private_double', 'Private Double', 'Double occupancy private room', 'bed-double', 2, 20),
    ('private_twin', 'Private Twin', 'Twin beds in private room', 'bed-twin', 2, 30),
    ('private_family', 'Private Family Room', 'Family room for 3+ people', 'bed-family', 4, 40),
    ('dorm_mixed', 'Mixed Dormitory', 'Shared dormitory for all genders', 'bed-bunk', 8, 50),
    ('dorm_male', 'Male Dormitory', 'Dormitory for male guests only', 'bed-bunk-male', 8, 60),
    ('dorm_female', 'Female Dormitory', 'Dormitory for female guests only', 'bed-bunk-female', 8, 70),
    ('camping_tent', 'Tent Space', 'Space for personal tent', 'tent', 2, 80),
    ('camping_cabin', 'Camping Cabin', 'Basic cabin accommodation', 'home-simple', 4, 90)
ON CONFLICT (code) DO NOTHING;

-- Insert seed data for payment methods
INSERT INTO public.payment_methods_master (code, label, description, icon_identifier, is_digital, sort_order) VALUES 
    ('cash_eur', 'Cash (EUR)', 'Euro cash payments', 'currency-euro', false, 10),
    ('visa', 'Visa', 'Visa credit/debit cards', 'credit-card-visa', true, 20),
    ('mastercard', 'Mastercard', 'Mastercard credit/debit cards', 'credit-card-master', true, 30),
    ('american_express', 'American Express', 'American Express cards', 'credit-card-amex', true, 40),
    ('bank_transfer', 'Bank Transfer', 'Direct bank transfer', 'bank', true, 50),
    ('paypal', 'PayPal', 'PayPal payments', 'paypal', true, 60),
    ('contactless', 'Contactless Payment', 'NFC/contactless payments', 'contactless', true, 70),
    ('check', 'Check/Cheque', 'Personal or travelers checks', 'check', false, 80)
ON CONFLICT (code) DO NOTHING;

-- Insert seed data for meal services
INSERT INTO public.meal_services_master (code, label, description, icon_identifier, meal_type, sort_order) VALUES 
    ('breakfast_included', 'Breakfast Included', 'Complimentary breakfast service', 'coffee', 'breakfast', 10),
    ('breakfast_available', 'Breakfast Available', 'Breakfast can be purchased', 'croissant', 'breakfast', 20),
    ('lunch_available', 'Lunch Available', 'Lunch meals available', 'utensils', 'lunch', 30),
    ('dinner_available', 'Dinner Available', 'Evening meals available', 'plate-utensils', 'dinner', 40),
    ('half_board', 'Half Board', 'Breakfast and one main meal included', 'cutlery', 'all_day', 50),
    ('full_board', 'Full Board', 'All meals included', 'chef-hat', 'all_day', 60),
    ('kitchen_access', 'Self-Catering Kitchen', 'Access to kitchen for cooking', 'stove', 'all_day', 70),
    ('snacks_available', 'Snacks Available', 'Light snacks and beverages', 'cookie', 'snack', 80)
ON CONFLICT (code) DO NOTHING;

-- Insert seed data for price ranges
INSERT INTO public.establishment_price_ranges_master (code, label, description, icon_identifier, min_price_eur, max_price_eur, sort_order) VALUES 
    ('budget', 'Budget (€0-25)', 'Very affordable accommodation', 'euro-1', 0.00, 25.00, 10),
    ('economy', 'Economy (€25-50)', 'Good value accommodation', 'euro-2', 25.00, 50.00, 20),
    ('mid_range', 'Mid-Range (€50-100)', 'Comfortable accommodation', 'euro-3', 50.00, 100.00, 30),
    ('upscale', 'Upscale (€100-200)', 'Higher quality accommodation', 'euro-4', 100.00, 200.00, 40),
    ('luxury', 'Luxury (€200+)', 'Premium accommodation', 'euro-5', 200.00, NULL, 50),
    ('donation_based', 'Donation Based', 'Pay what you can afford', 'hand-heart', NULL, NULL, 60),
    ('free', 'Free', 'No charge accommodation', 'gift', 0.00, 0.00, 70)
ON CONFLICT (code) DO NOTHING;

-- Enable RLS on all tables
ALTER TABLE public.room_types_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_services_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.establishment_price_ranges_master ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all master tables (public read, authenticated manage)
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN VALUES ('room_types_master'), ('payment_methods_master'), ('meal_services_master'), ('establishment_price_ranges_master') LOOP
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
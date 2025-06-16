-- Module 4a: Accommodations
-- 008_accommodation_junction_tables.sql: Junction tables for M:M relationships
-- 
-- Purpose: Link accommodations to amenities, room types, payment methods, and meal services

-- Accommodation amenities junction table
CREATE TABLE IF NOT EXISTS public.accommodation_amenities (
    id BIGSERIAL PRIMARY KEY,
    accommodation_id BIGINT NOT NULL,
    amenity_id INTEGER NOT NULL,
    notes TEXT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodation_amenities_accommodation 
        FOREIGN KEY(accommodation_id) 
        REFERENCES public.accommodations(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_amenities_amenity 
        FOREIGN KEY(amenity_id) 
        REFERENCES public.amenities_master(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_amenities_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodation_amenities_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraint
    CONSTRAINT uk_accommodation_amenities UNIQUE (accommodation_id, amenity_id),
    
    -- Check constraints
    CONSTRAINT chk_accommodation_amenities_notes_length CHECK (
        notes IS NULL OR length(notes) <= 500
    )
);

-- Accommodation room configurations junction table
CREATE TABLE IF NOT EXISTS public.accommodation_room_configurations (
    id BIGSERIAL PRIMARY KEY,
    accommodation_id BIGINT NOT NULL,
    room_type_id INTEGER NOT NULL,
    number_of_rooms INTEGER NOT NULL DEFAULT 1,
    beds_per_room INTEGER NULL,
    max_occupancy INTEGER NULL,
    room_price_eur DECIMAL(8,2) NULL,
    room_notes TEXT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodation_rooms_accommodation 
        FOREIGN KEY(accommodation_id) 
        REFERENCES public.accommodations(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_rooms_room_type 
        FOREIGN KEY(room_type_id) 
        REFERENCES public.room_types_master(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_rooms_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodation_rooms_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraint
    CONSTRAINT uk_accommodation_room_configurations UNIQUE (accommodation_id, room_type_id),
    
    -- Check constraints
    CONSTRAINT chk_accommodation_rooms_positive_numbers CHECK (
        number_of_rooms > 0 AND
        (beds_per_room IS NULL OR beds_per_room > 0) AND
        (max_occupancy IS NULL OR max_occupancy > 0) AND
        (room_price_eur IS NULL OR room_price_eur >= 0)
    ),
    CONSTRAINT chk_accommodation_rooms_notes_length CHECK (
        room_notes IS NULL OR length(room_notes) <= 500
    )
);

-- Accommodation payment methods junction table
CREATE TABLE IF NOT EXISTS public.accommodation_payment_methods (
    id BIGSERIAL PRIMARY KEY,
    accommodation_id BIGINT NOT NULL,
    payment_method_id INTEGER NOT NULL,
    notes TEXT NULL,
    is_preferred BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodation_payments_accommodation 
        FOREIGN KEY(accommodation_id) 
        REFERENCES public.accommodations(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_payments_payment_method 
        FOREIGN KEY(payment_method_id) 
        REFERENCES public.payment_methods_master(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_payments_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodation_payments_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraint
    CONSTRAINT uk_accommodation_payment_methods UNIQUE (accommodation_id, payment_method_id),
    
    -- Check constraints
    CONSTRAINT chk_accommodation_payments_notes_length CHECK (
        notes IS NULL OR length(notes) <= 500
    )
);

-- Accommodation meal services junction table
CREATE TABLE IF NOT EXISTS public.accommodation_meal_services (
    id BIGSERIAL PRIMARY KEY,
    accommodation_id BIGINT NOT NULL,
    meal_service_id INTEGER NOT NULL,
    price_eur DECIMAL(8,2) NULL,
    availability_notes TEXT NULL,
    advance_notice_required BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_profile_id UUID NULL,
    updated_by_profile_id UUID NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_accommodation_meals_accommodation 
        FOREIGN KEY(accommodation_id) 
        REFERENCES public.accommodations(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_meals_meal_service 
        FOREIGN KEY(meal_service_id) 
        REFERENCES public.meal_services_master(id) ON DELETE CASCADE,
    CONSTRAINT fk_accommodation_meals_created_by 
        FOREIGN KEY(created_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT fk_accommodation_meals_updated_by 
        FOREIGN KEY(updated_by_profile_id) 
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Unique constraint
    CONSTRAINT uk_accommodation_meal_services UNIQUE (accommodation_id, meal_service_id),
    
    -- Check constraints
    CONSTRAINT chk_accommodation_meals_price_positive CHECK (
        price_eur IS NULL OR price_eur >= 0
    ),
    CONSTRAINT chk_accommodation_meals_notes_length CHECK (
        availability_notes IS NULL OR length(availability_notes) <= 500
    )
);

-- Add table comments
COMMENT ON TABLE public.accommodation_amenities IS 'Links accommodations to available amenities (Wi-Fi, kitchen, etc.).';
COMMENT ON TABLE public.accommodation_room_configurations IS 'Defines room types and configurations available at each accommodation.';
COMMENT ON TABLE public.accommodation_payment_methods IS 'Links accommodations to accepted payment methods.';
COMMENT ON TABLE public.accommodation_meal_services IS 'Links accommodations to available meal services.';

-- Create indexes for all junction tables
CREATE INDEX idx_accommodation_amenities_accommodation ON public.accommodation_amenities(accommodation_id);
CREATE INDEX idx_accommodation_amenities_amenity ON public.accommodation_amenities(amenity_id);
CREATE INDEX idx_accommodation_amenities_verified ON public.accommodation_amenities(is_verified);

CREATE INDEX idx_accommodation_rooms_accommodation ON public.accommodation_room_configurations(accommodation_id);
CREATE INDEX idx_accommodation_rooms_room_type ON public.accommodation_room_configurations(room_type_id);
CREATE INDEX idx_accommodation_rooms_available ON public.accommodation_room_configurations(is_available);
CREATE INDEX idx_accommodation_rooms_price ON public.accommodation_room_configurations(room_price_eur) WHERE room_price_eur IS NOT NULL;

CREATE INDEX idx_accommodation_payments_accommodation ON public.accommodation_payment_methods(accommodation_id);
CREATE INDEX idx_accommodation_payments_payment_method ON public.accommodation_payment_methods(payment_method_id);
CREATE INDEX idx_accommodation_payments_preferred ON public.accommodation_payment_methods(is_preferred);

CREATE INDEX idx_accommodation_meals_accommodation ON public.accommodation_meal_services(accommodation_id);
CREATE INDEX idx_accommodation_meals_meal_service ON public.accommodation_meal_services(meal_service_id);
CREATE INDEX idx_accommodation_meals_price ON public.accommodation_meal_services(price_eur) WHERE price_eur IS NOT NULL;

-- Create update triggers for all junction tables
CREATE TRIGGER trigger_accommodation_amenities_set_updated_at
    BEFORE UPDATE ON public.accommodation_amenities
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_accommodation_rooms_set_updated_at
    BEFORE UPDATE ON public.accommodation_room_configurations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_accommodation_payments_set_updated_at
    BEFORE UPDATE ON public.accommodation_payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_accommodation_meals_set_updated_at
    BEFORE UPDATE ON public.accommodation_meal_services
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS on all junction tables
ALTER TABLE public.accommodation_amenities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodation_room_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodation_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodation_meal_services ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all junction tables
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN VALUES ('accommodation_amenities'), ('accommodation_room_configurations'), ('accommodation_payment_methods'), ('accommodation_meal_services') LOOP
        -- Public read access for published accommodations
        EXECUTE format('
            CREATE POLICY "Allow public read access to %I for published accommodations" ON public.%I
                FOR SELECT
                USING (
                    accommodation_id IN (
                        SELECT a.id FROM public.accommodations a
                        JOIN public.waypoints w ON a.id = w.id
                        JOIN public.content_statuses_master cs ON w.content_visibility_status_id = cs.id
                        WHERE a.deleted_at IS NULL 
                        AND w.deleted_at IS NULL
                        AND cs.is_publicly_visible = true 
                        AND cs.is_active = true
                    )
                )', table_name, table_name);
        
        -- Authenticated read access for all non-deleted accommodations
        EXECUTE format('
            CREATE POLICY "Allow authenticated users read access to %I" ON public.%I
                FOR SELECT
                USING (
                    auth.role() = ''authenticated''
                    AND accommodation_id IN (
                        SELECT id FROM public.accommodations WHERE deleted_at IS NULL
                    )
                )', table_name, table_name);
        
        -- Content creators can manage
        EXECUTE format('
            CREATE POLICY "Allow content creators to manage %I" ON public.%I
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
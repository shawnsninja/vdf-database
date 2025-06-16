-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 001_master_tables.sql
-- Description: Create master lookup tables for curated itinerary system
-- Dependencies: None
-- Version: 1.0
-- =====================================================================================

-- Table: public.itinerary_categories_master
-- Purpose: Master list of itinerary categories with i18n support
CREATE TABLE public.itinerary_categories_master (
    category_code text NOT NULL,
    default_name text NOT NULL,
    default_description text NULL,
    icon_identifier text NULL,
    is_active boolean NOT NULL DEFAULT true,
    sort_order smallint NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT itinerary_categories_master_pkey PRIMARY KEY (category_code),
    CONSTRAINT itinerary_categories_master_category_code_check 
        CHECK (category_code ~ '^[a-z][a-z0-9_]*$'),
    CONSTRAINT itinerary_categories_master_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT itinerary_categories_master_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.itinerary_categories_master IS 'Master table storing categories of curated itineraries (e.g., spiritual_journey, nature_lover). With support for internationalization. Version 1.0.';
COMMENT ON COLUMN public.itinerary_categories_master.category_code IS 'Unique code identifying the category (e.g., spiritual_journey).';
COMMENT ON COLUMN public.itinerary_categories_master.default_name IS 'Default name in English.';
COMMENT ON COLUMN public.itinerary_categories_master.default_description IS 'Default description in English.';
COMMENT ON COLUMN public.itinerary_categories_master.icon_identifier IS 'Icon identifier for UI display.';
COMMENT ON COLUMN public.itinerary_categories_master.is_active IS 'Whether this category is active and available for use.';
COMMENT ON COLUMN public.itinerary_categories_master.sort_order IS 'Order for display in lists.';

-- Table: public.seasons_master
-- Purpose: Master list of seasons for seasonal recommendations
CREATE TABLE public.seasons_master (
    season_code text NOT NULL,
    default_name text NOT NULL,
    default_description text NULL,
    typical_months text[] NULL,
    is_active boolean NOT NULL DEFAULT true,
    sort_order smallint NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT seasons_master_pkey PRIMARY KEY (season_code),
    CONSTRAINT seasons_master_season_code_check 
        CHECK (season_code ~ '^[a-z][a-z0-9_]*$'),
    CONSTRAINT seasons_master_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT seasons_master_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.seasons_master IS 'Master table storing seasons for itinerary recommendations. Version 1.0.';
COMMENT ON COLUMN public.seasons_master.season_code IS 'Unique code identifying the season (e.g., spring).';
COMMENT ON COLUMN public.seasons_master.default_name IS 'Default name in English.';
COMMENT ON COLUMN public.seasons_master.default_description IS 'Default description of typical weather/conditions in English.';
COMMENT ON COLUMN public.seasons_master.typical_months IS 'Array of month abbreviations typically in this season (e.g., {MAR,APR,MAY}).';
COMMENT ON COLUMN public.seasons_master.is_active IS 'Whether this season is active and available for use.';
COMMENT ON COLUMN public.seasons_master.sort_order IS 'Order for display in lists.';

-- Table: public.trail_difficulty_levels_master
-- Purpose: Master list of trail difficulty levels
CREATE TABLE public.trail_difficulty_levels_master (
    difficulty_code text NOT NULL,
    default_name text NOT NULL,
    default_description text NULL,
    numeric_level smallint NOT NULL,
    daily_distance_km_min numeric(5,2) NULL,
    daily_distance_km_max numeric(5,2) NULL,
    elevation_gain_m_typical numeric(6,0) NULL,
    fitness_requirement_notes text NULL,
    icon_identifier text NULL,
    color_hex text NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    
    CONSTRAINT trail_difficulty_levels_master_pkey PRIMARY KEY (difficulty_code),
    CONSTRAINT trail_difficulty_levels_master_difficulty_code_check 
        CHECK (difficulty_code ~ '^[a-z][a-z0-9_]*$'),
    CONSTRAINT trail_difficulty_levels_master_numeric_level_unique UNIQUE (numeric_level),
    CONSTRAINT trail_difficulty_levels_master_numeric_level_check 
        CHECK (numeric_level BETWEEN 1 AND 10),
    CONSTRAINT trail_difficulty_levels_master_color_hex_check 
        CHECK (color_hex IS NULL OR color_hex ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT trail_difficulty_levels_master_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT trail_difficulty_levels_master_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.trail_difficulty_levels_master IS 'Master table storing difficulty levels for trail assessment. Version 1.0.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.difficulty_code IS 'Unique code identifying the difficulty level (e.g., easy, moderate).';
COMMENT ON COLUMN public.trail_difficulty_levels_master.default_name IS 'Default name in English.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.default_description IS 'Default description of the difficulty level in English.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.numeric_level IS 'Numeric level 1-10 for sorting and comparison.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.daily_distance_km_min IS 'Typical minimum daily distance in kilometers.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.daily_distance_km_max IS 'Typical maximum daily distance in kilometers.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.elevation_gain_m_typical IS 'Typical daily elevation gain in meters.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.fitness_requirement_notes IS 'Notes about fitness requirements.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.icon_identifier IS 'Icon identifier for UI display.';
COMMENT ON COLUMN public.trail_difficulty_levels_master.color_hex IS 'Color for UI display (e.g., #00FF00 for easy).';

-- Table: public.content_statuses_master (if not already created)
-- Purpose: Master list of content statuses for workflow management
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'content_statuses_master' AND schemaname = 'public') THEN
        CREATE TABLE public.content_statuses_master (
            status_code text NOT NULL,
            default_name text NOT NULL,
            default_description text NULL,
            allows_public_visibility boolean NOT NULL DEFAULT false,
            is_active boolean NOT NULL DEFAULT true,
            sort_order smallint NOT NULL DEFAULT 0,
            created_at timestamp with time zone NOT NULL DEFAULT now(),
            updated_at timestamp with time zone NOT NULL DEFAULT now(),
            created_by_profile_id uuid NULL,
            updated_by_profile_id uuid NULL,
            
            CONSTRAINT content_statuses_master_pkey PRIMARY KEY (status_code),
            CONSTRAINT content_statuses_master_status_code_check 
                CHECK (status_code ~ '^[a-z][a-z0-9_]*$'),
            CONSTRAINT content_statuses_master_created_by_profile_id_fkey 
                FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
            CONSTRAINT content_statuses_master_updated_by_profile_id_fkey 
                FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
        );

        -- Comments
        COMMENT ON TABLE public.content_statuses_master IS 'Master table storing content workflow statuses. Version 1.0.';
        COMMENT ON COLUMN public.content_statuses_master.status_code IS 'Unique code identifying the status (e.g., draft, published).';
        COMMENT ON COLUMN public.content_statuses_master.default_name IS 'Default name in English.';
        COMMENT ON COLUMN public.content_statuses_master.default_description IS 'Default description in English.';
        COMMENT ON COLUMN public.content_statuses_master.allows_public_visibility IS 'Whether content with this status is publicly visible.';
    END IF;
END $$;

-- Indexes
CREATE INDEX idx_itinerary_categories_master_active ON public.itinerary_categories_master (is_active, sort_order);
CREATE INDEX idx_seasons_master_active ON public.seasons_master (is_active, sort_order);
CREATE INDEX idx_trail_difficulty_levels_master_active ON public.trail_difficulty_levels_master (is_active, numeric_level);
CREATE INDEX idx_content_statuses_master_active ON public.content_statuses_master (is_active, allows_public_visibility);

-- Triggers for updated_at
CREATE TRIGGER on_itinerary_categories_master_updated_at 
    BEFORE UPDATE ON public.itinerary_categories_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_seasons_master_updated_at 
    BEFORE UPDATE ON public.seasons_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_trail_difficulty_levels_master_updated_at 
    BEFORE UPDATE ON public.trail_difficulty_levels_master 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'on_content_statuses_master_updated_at' 
        AND tgrelid = 'public.content_statuses_master'::regclass
    ) THEN
        CREATE TRIGGER on_content_statuses_master_updated_at 
            BEFORE UPDATE ON public.content_statuses_master 
            FOR EACH ROW 
            EXECUTE FUNCTION public.handle_updated_at();
    END IF;
END $$;

-- RLS Policies
ALTER TABLE public.itinerary_categories_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seasons_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trail_difficulty_levels_master ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN 
    -- Only enable RLS if table exists and doesn't already have it enabled
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'content_statuses_master' AND schemaname = 'public') THEN
        IF NOT EXISTS (
            SELECT 1 FROM pg_class 
            WHERE relname = 'content_statuses_master' 
            AND relrowsecurity = true
        ) THEN
            ALTER TABLE public.content_statuses_master ENABLE ROW LEVEL SECURITY;
        END IF;
    END IF;
END $$;

-- Everyone can read active records
CREATE POLICY "Anyone can read active itinerary categories" ON public.itinerary_categories_master 
    FOR SELECT TO authenticated, anon 
    USING (is_active = true);

CREATE POLICY "Anyone can read active seasons" ON public.seasons_master 
    FOR SELECT TO authenticated, anon 
    USING (is_active = true);

CREATE POLICY "Anyone can read active difficulty levels" ON public.trail_difficulty_levels_master 
    FOR SELECT TO authenticated, anon 
    USING (is_active = true);

DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'content_statuses_master' AND schemaname = 'public') THEN
        IF NOT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'content_statuses_master' 
            AND policyname = 'Anyone can read active content statuses'
        ) THEN
            CREATE POLICY "Anyone can read active content statuses" ON public.content_statuses_master 
                FOR SELECT TO authenticated, anon 
                USING (is_active = true);
        END IF;
    END IF;
END $$;

-- Admins can manage
CREATE POLICY "Admins can manage itinerary categories" ON public.itinerary_categories_master 
    FOR ALL TO authenticated 
    USING (public.has_role('admin_platform')) 
    WITH CHECK (public.has_role('admin_platform'));

CREATE POLICY "Admins can manage seasons" ON public.seasons_master 
    FOR ALL TO authenticated 
    USING (public.has_role('admin_platform')) 
    WITH CHECK (public.has_role('admin_platform'));

CREATE POLICY "Admins can manage difficulty levels" ON public.trail_difficulty_levels_master 
    FOR ALL TO authenticated 
    USING (public.has_role('admin_platform')) 
    WITH CHECK (public.has_role('admin_platform'));

DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'content_statuses_master' AND schemaname = 'public') THEN
        IF NOT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'content_statuses_master' 
            AND policyname = 'Admins can manage content statuses'
        ) THEN
            CREATE POLICY "Admins can manage content statuses" ON public.content_statuses_master 
                FOR ALL TO authenticated 
                USING (public.has_role('admin_platform')) 
                WITH CHECK (public.has_role('admin_platform'));
        END IF;
    END IF;
END $$;
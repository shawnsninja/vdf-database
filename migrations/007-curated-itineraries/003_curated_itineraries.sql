-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 003_curated_itineraries.sql
-- Description: Create curated_itineraries table for pre-planned journey templates
-- Dependencies: 
--   - Module 1 (profiles, languages_master, media)
--   - Module 2 (trails)
--   - 001_master_tables.sql
-- Version: 1.0
-- =====================================================================================

-- Table: public.curated_itineraries
-- Purpose: Stores pre-planned itinerary templates created by content creators
CREATE TABLE public.curated_itineraries (
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    code text NOT NULL,
    trail_id bigint NOT NULL,
    default_title text NOT NULL,
    default_subtitle text NULL,
    default_description text NOT NULL,
    default_highlights text[] NULL,
    total_days smallint NOT NULL,
    total_distance_km numeric(7,2) NOT NULL,
    total_elevation_gain_m numeric(8,0) NULL,
    total_elevation_loss_m numeric(8,0) NULL,
    difficulty_level_code text NOT NULL,
    fitness_level_notes text NULL,
    hero_image_media_id bigint NULL,
    map_image_media_id bigint NULL,
    author_profile_id uuid NOT NULL,
    content_status_code text NOT NULL DEFAULT 'draft',
    is_featured boolean NOT NULL DEFAULT false,
    featured_order smallint NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    updated_by_profile_id uuid NULL,
    published_at timestamp with time zone NULL,
    deleted_at timestamp with time zone NULL,
    
    CONSTRAINT curated_itineraries_pkey PRIMARY KEY (id),
    CONSTRAINT curated_itineraries_code_unique UNIQUE (code),
    CONSTRAINT curated_itineraries_code_check 
        CHECK (code ~ '^[a-z][a-z0-9_-]*$'),
    CONSTRAINT curated_itineraries_trail_id_fkey 
        FOREIGN KEY (trail_id) REFERENCES public.trails(id) ON DELETE RESTRICT,
    CONSTRAINT curated_itineraries_difficulty_level_code_fkey 
        FOREIGN KEY (difficulty_level_code) REFERENCES public.trail_difficulty_levels_master(difficulty_code) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT curated_itineraries_hero_image_media_id_fkey 
        FOREIGN KEY (hero_image_media_id) REFERENCES public.media(id) ON DELETE SET NULL,
    CONSTRAINT curated_itineraries_map_image_media_id_fkey 
        FOREIGN KEY (map_image_media_id) REFERENCES public.media(id) ON DELETE SET NULL,
    CONSTRAINT curated_itineraries_author_profile_id_fkey 
        FOREIGN KEY (author_profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT,
    CONSTRAINT curated_itineraries_content_status_code_fkey 
        FOREIGN KEY (content_status_code) REFERENCES public.content_statuses_master(status_code) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT curated_itineraries_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT curated_itineraries_updated_by_profile_id_fkey 
        FOREIGN KEY (updated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT curated_itineraries_total_days_check 
        CHECK (total_days > 0),
    CONSTRAINT curated_itineraries_total_distance_km_check 
        CHECK (total_distance_km > 0),
    CONSTRAINT curated_itineraries_featured_order_check 
        CHECK (featured_order IS NULL OR (featured_order > 0 AND is_featured = true))
);

-- Comments
COMMENT ON TABLE public.curated_itineraries IS 'Stores pre-planned itinerary templates created by content creators. These serve as journey guides for pilgrims. Version 1.0.';
COMMENT ON COLUMN public.curated_itineraries.id IS 'Unique identifier for the itinerary.';
COMMENT ON COLUMN public.curated_itineraries.code IS 'URL-friendly unique code for the itinerary (e.g., classic-7-day-rieti-to-assisi).';
COMMENT ON COLUMN public.curated_itineraries.trail_id IS 'FK to trails.id - which trail this itinerary covers.';
COMMENT ON COLUMN public.curated_itineraries.default_title IS 'Default title in English (e.g., "Classic 7-Day Journey: Rieti to Assisi").';
COMMENT ON COLUMN public.curated_itineraries.default_subtitle IS 'Optional subtitle in English (e.g., "Through the Heart of Umbria").';
COMMENT ON COLUMN public.curated_itineraries.default_description IS 'Detailed description of the itinerary in English.';
COMMENT ON COLUMN public.curated_itineraries.default_highlights IS 'Array of key highlights in English (e.g., {"Visit Greccio Sanctuary", "Medieval towns"}).';
COMMENT ON COLUMN public.curated_itineraries.total_days IS 'Total number of days for this itinerary.';
COMMENT ON COLUMN public.curated_itineraries.total_distance_km IS 'Total walking distance in kilometers.';
COMMENT ON COLUMN public.curated_itineraries.total_elevation_gain_m IS 'Total elevation gain in meters.';
COMMENT ON COLUMN public.curated_itineraries.total_elevation_loss_m IS 'Total elevation loss in meters.';
COMMENT ON COLUMN public.curated_itineraries.difficulty_level_code IS 'FK to trail_difficulty_levels_master.difficulty_code.';
COMMENT ON COLUMN public.curated_itineraries.fitness_level_notes IS 'Additional notes about fitness requirements.';
COMMENT ON COLUMN public.curated_itineraries.hero_image_media_id IS 'FK to media.id for the main hero image.';
COMMENT ON COLUMN public.curated_itineraries.map_image_media_id IS 'FK to media.id for an overview map image.';
COMMENT ON COLUMN public.curated_itineraries.author_profile_id IS 'FK to profiles.id of the content creator.';
COMMENT ON COLUMN public.curated_itineraries.content_status_code IS 'FK to content_statuses_master.status_code for workflow.';
COMMENT ON COLUMN public.curated_itineraries.is_featured IS 'Whether this itinerary is featured on the homepage.';
COMMENT ON COLUMN public.curated_itineraries.featured_order IS 'Sort order for featured itineraries (must be set if is_featured is true).';
COMMENT ON COLUMN public.curated_itineraries.published_at IS 'Timestamp when the itinerary was first published.';
COMMENT ON COLUMN public.curated_itineraries.deleted_at IS 'Soft delete timestamp.';

-- Indexes
CREATE INDEX idx_curated_itineraries_trail_id ON public.curated_itineraries (trail_id);
CREATE INDEX idx_curated_itineraries_code ON public.curated_itineraries (code) WHERE deleted_at IS NULL;
CREATE INDEX idx_curated_itineraries_status ON public.curated_itineraries (content_status_code, deleted_at);
CREATE INDEX idx_curated_itineraries_featured ON public.curated_itineraries (is_featured, featured_order) 
    WHERE is_featured = true AND deleted_at IS NULL;
CREATE INDEX idx_curated_itineraries_author ON public.curated_itineraries (author_profile_id);
CREATE INDEX idx_curated_itineraries_difficulty ON public.curated_itineraries (difficulty_level_code);

-- Trigger
CREATE TRIGGER on_curated_itineraries_updated_at 
    BEFORE UPDATE ON public.curated_itineraries 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- RLS Policies
ALTER TABLE public.curated_itineraries ENABLE ROW LEVEL SECURITY;

-- Anyone can read published itineraries
CREATE POLICY "Anyone can read published itineraries" ON public.curated_itineraries 
    FOR SELECT TO authenticated, anon 
    USING (
        content_status_code = 'published' 
        AND deleted_at IS NULL
    );

-- Content creators can read their own itineraries
CREATE POLICY "Content creators can read their own itineraries" ON public.curated_itineraries 
    FOR SELECT TO authenticated 
    USING (
        auth.uid() = author_profile_id 
        OR auth.uid() = created_by_profile_id
    );

-- Content creators can create itineraries
CREATE POLICY "Content creators can create itineraries" ON public.curated_itineraries 
    FOR INSERT TO authenticated 
    WITH CHECK (
        public.has_role('content_creator') 
        AND auth.uid() = author_profile_id
    );

-- Content creators can update their own draft itineraries
CREATE POLICY "Content creators can update their own drafts" ON public.curated_itineraries 
    FOR UPDATE TO authenticated 
    USING (
        auth.uid() = author_profile_id 
        AND content_status_code IN ('draft', 'rejected')
    )
    WITH CHECK (
        auth.uid() = author_profile_id 
        AND content_status_code IN ('draft', 'rejected', 'ready_for_review')
    );

-- Editors can manage all itineraries
CREATE POLICY "Editors can manage all itineraries" ON public.curated_itineraries 
    FOR ALL TO authenticated 
    USING (
        public.has_role('content_creator') 
        AND public.has_role('admin_platform')
    )
    WITH CHECK (
        public.has_role('content_creator') 
        AND public.has_role('admin_platform')
    );

-- Table: public.curated_itinerary_to_category
-- Purpose: Many-to-many relationship between itineraries and categories
CREATE TABLE public.curated_itinerary_to_category (
    curated_itinerary_id bigint NOT NULL,
    itinerary_category_code text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    
    CONSTRAINT curated_itinerary_to_category_pkey PRIMARY KEY (curated_itinerary_id, itinerary_category_code),
    CONSTRAINT curated_itinerary_to_category_curated_itinerary_id_fkey 
        FOREIGN KEY (curated_itinerary_id) REFERENCES public.curated_itineraries(id) ON DELETE CASCADE,
    CONSTRAINT curated_itinerary_to_category_itinerary_category_code_fkey 
        FOREIGN KEY (itinerary_category_code) REFERENCES public.itinerary_categories_master(category_code) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT curated_itinerary_to_category_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.curated_itinerary_to_category IS 'Links curated itineraries to their categories (many-to-many). Version 1.0.';

-- Indexes
CREATE INDEX idx_curated_itinerary_to_category_itinerary ON public.curated_itinerary_to_category (curated_itinerary_id);
CREATE INDEX idx_curated_itinerary_to_category_category ON public.curated_itinerary_to_category (itinerary_category_code);

-- RLS Policies
ALTER TABLE public.curated_itinerary_to_category ENABLE ROW LEVEL SECURITY;

-- Inherit read permissions from parent itinerary
CREATE POLICY "Read permissions inherit from itinerary" ON public.curated_itinerary_to_category 
    FOR SELECT TO authenticated, anon 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND ci.content_status_code = 'published'
            AND ci.deleted_at IS NULL
        )
    );

-- Inherit write permissions from parent itinerary
CREATE POLICY "Write permissions inherit from itinerary" ON public.curated_itinerary_to_category 
    FOR ALL TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    );

-- Table: public.curated_itinerary_to_season
-- Purpose: Many-to-many relationship between itineraries and recommended seasons
CREATE TABLE public.curated_itinerary_to_season (
    curated_itinerary_id bigint NOT NULL,
    season_code text NOT NULL,
    is_best_season boolean NOT NULL DEFAULT false,
    season_notes text NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by_profile_id uuid NULL,
    
    CONSTRAINT curated_itinerary_to_season_pkey PRIMARY KEY (curated_itinerary_id, season_code),
    CONSTRAINT curated_itinerary_to_season_curated_itinerary_id_fkey 
        FOREIGN KEY (curated_itinerary_id) REFERENCES public.curated_itineraries(id) ON DELETE CASCADE,
    CONSTRAINT curated_itinerary_to_season_season_code_fkey 
        FOREIGN KEY (season_code) REFERENCES public.seasons_master(season_code) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT curated_itinerary_to_season_created_by_profile_id_fkey 
        FOREIGN KEY (created_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Comments
COMMENT ON TABLE public.curated_itinerary_to_season IS 'Links curated itineraries to recommended seasons (many-to-many). Version 1.0.';
COMMENT ON COLUMN public.curated_itinerary_to_season.is_best_season IS 'Whether this is the optimal season for this itinerary.';
COMMENT ON COLUMN public.curated_itinerary_to_season.season_notes IS 'Optional notes about this season for this itinerary.';

-- Indexes
CREATE INDEX idx_curated_itinerary_to_season_itinerary ON public.curated_itinerary_to_season (curated_itinerary_id);
CREATE INDEX idx_curated_itinerary_to_season_season ON public.curated_itinerary_to_season (season_code);

-- RLS Policies
ALTER TABLE public.curated_itinerary_to_season ENABLE ROW LEVEL SECURITY;

-- Inherit permissions from parent itinerary
CREATE POLICY "Read permissions inherit from itinerary" ON public.curated_itinerary_to_season 
    FOR SELECT TO authenticated, anon 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND ci.content_status_code = 'published'
            AND ci.deleted_at IS NULL
        )
    );

CREATE POLICY "Write permissions inherit from itinerary" ON public.curated_itinerary_to_season 
    FOR ALL TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.curated_itineraries ci
            WHERE ci.id = curated_itinerary_id
            AND (
                (ci.author_profile_id = auth.uid() AND ci.content_status_code IN ('draft', 'rejected'))
                OR (public.has_role('content_creator') AND public.has_role('admin_platform'))
            )
        )
    );
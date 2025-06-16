-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 004_user_waypoint_votes.sql
-- Description: Create user_waypoint_votes table for thumbs up/down voting on waypoints
-- Dependencies: 
--   - Module 1 (profiles)
--   - Module 4 (waypoints)
--   - 003_alter_waypoints_add_vote_counts.sql
-- Version: 2.1.1
-- =====================================================================================

-- ENUM Type Definition (if not already created globally)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vote_type_enum') THEN 
        CREATE TYPE public.vote_type_enum AS ENUM ('up', 'down'); 
    END IF; 
END $$;

-- Table Definition for user_waypoint_votes
CREATE TABLE public.user_waypoint_votes (
    profile_id uuid NOT NULL,
    waypoint_id bigint NOT NULL, -- Matches waypoints.id type
    vote_type public.vote_type_enum NOT NULL,
    vote_source_platform text NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz NULL,
    
    CONSTRAINT user_waypoint_votes_pkey PRIMARY KEY (profile_id, waypoint_id),
    CONSTRAINT user_waypoint_votes_profile_id_fkey 
        FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
    CONSTRAINT user_waypoint_votes_waypoint_id_fkey 
        FOREIGN KEY (waypoint_id) REFERENCES public.waypoints(id) ON DELETE CASCADE
);

-- Comments on Table and Columns
COMMENT ON TABLE public.user_waypoint_votes IS 'Stores user votes (up/down) for specific waypoints. Supports soft deletion for vote retractions. Version 2.1.1.';
COMMENT ON COLUMN public.user_waypoint_votes.profile_id IS 'FK to profiles.id of the user who cast the vote. Part of PK.';
COMMENT ON COLUMN public.user_waypoint_votes.waypoint_id IS 'FK to waypoints.id of the waypoint being voted on. Part of PK.';
COMMENT ON COLUMN public.user_waypoint_votes.vote_type IS 'The type of vote: ''up'' or ''down''. Uses public.vote_type_enum.';
COMMENT ON COLUMN public.user_waypoint_votes.vote_source_platform IS 'Optional: Platform from which the vote was cast (e.g., ''web_app_v1'', ''mobile_ios_v1''). For analytics.';
COMMENT ON COLUMN public.user_waypoint_votes.created_at IS 'Timestamp of when the vote was initially cast.';
COMMENT ON COLUMN public.user_waypoint_votes.updated_at IS 'Timestamp of when the vote record was last updated (vote type changed or soft deleted/restored). Auto-updated by trigger.';
COMMENT ON COLUMN public.user_waypoint_votes.deleted_at IS 'Timestamp for soft deletion. If set, the vote is considered retracted/inactive.';

-- Index for efficient aggregation of active votes
CREATE INDEX idx_user_waypoint_votes_active ON public.user_waypoint_votes (waypoint_id, vote_type) 
    WHERE (deleted_at IS NULL);

-- Trigger for user_waypoint_votes table 'updated_at'
CREATE TRIGGER on_user_waypoint_votes_updated_at 
    BEFORE UPDATE ON public.user_waypoint_votes 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger Function to update aggregated counts on the 'waypoints' table
CREATE OR REPLACE FUNCTION public.update_waypoint_vote_counts() 
RETURNS TRIGGER AS $$
BEGIN
    -- Handle INSERT operations
    IF (TG_OP = 'INSERT') THEN
        IF NEW.deleted_at IS NULL THEN -- Only count active votes
            IF NEW.vote_type = 'up' THEN
                UPDATE public.waypoints 
                SET up_vote_count = up_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            ELSE -- 'down'
                UPDATE public.waypoints 
                SET down_vote_count = down_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            END IF;
        END IF;
    
    -- Handle DELETE operations (Hard Deletes)
    ELSIF (TG_OP = 'DELETE') THEN
        IF OLD.deleted_at IS NULL THEN -- Only reverse active votes
            IF OLD.vote_type = 'up' THEN
                UPDATE public.waypoints 
                SET up_vote_count = GREATEST(0, up_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            ELSE -- 'down'
                UPDATE public.waypoints 
                SET down_vote_count = GREATEST(0, down_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            END IF;
        END IF;
    
    -- Handle UPDATE operations
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Case 1: Vote retracted (deleted_at changed from NULL to NOT NULL)
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
            IF OLD.vote_type = 'up' THEN
                UPDATE public.waypoints 
                SET up_vote_count = GREATEST(0, up_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            ELSE -- 'down'
                UPDATE public.waypoints 
                SET down_vote_count = GREATEST(0, down_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            END IF;
        
        -- Case 2: Vote reinstated (deleted_at changed from NOT NULL to NULL)
        ELSIF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL THEN
            IF NEW.vote_type = 'up' THEN
                UPDATE public.waypoints 
                SET up_vote_count = up_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            ELSE -- 'down'
                UPDATE public.waypoints 
                SET down_vote_count = down_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            END IF;
        
        -- Case 3: Active vote type changed (deleted_at was NULL and remains NULL)
        ELSIF OLD.deleted_at IS NULL AND NEW.deleted_at IS NULL AND OLD.vote_type <> NEW.vote_type THEN
            IF OLD.vote_type = 'up' THEN
                -- Decrement old up-vote
                UPDATE public.waypoints 
                SET up_vote_count = GREATEST(0, up_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            ELSE
                -- Decrement old down-vote
                UPDATE public.waypoints 
                SET down_vote_count = GREATEST(0, down_vote_count - 1) 
                WHERE id = OLD.waypoint_id;
            END IF;
            
            IF NEW.vote_type = 'up' THEN
                -- Increment new up-vote
                UPDATE public.waypoints 
                SET up_vote_count = up_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            ELSE
                -- Increment new down-vote
                UPDATE public.waypoints 
                SET down_vote_count = down_vote_count + 1 
                WHERE id = NEW.waypoint_id;
            END IF;
        END IF;
    END IF;
    
    RETURN NULL; -- Result is ignored since this is an AFTER trigger
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply the vote count trigger
CREATE TRIGGER after_user_waypoint_votes_change 
    AFTER INSERT OR UPDATE OR DELETE ON public.user_waypoint_votes 
    FOR EACH ROW 
    EXECUTE FUNCTION public.update_waypoint_vote_counts();

-- RLS Policies
ALTER TABLE public.user_waypoint_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pilgrims can insert their own votes" ON public.user_waypoint_votes 
    FOR INSERT TO authenticated 
    WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Pilgrims can update their own votes" ON public.user_waypoint_votes 
    FOR UPDATE TO authenticated 
    USING (auth.uid() = profile_id) 
    WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Pilgrims can view their own votes" ON public.user_waypoint_votes 
    FOR SELECT TO authenticated 
    USING (auth.uid() = profile_id);

-- Optional: Policy for viewing aggregated vote data (if needed beyond waypoints counts)
-- CREATE POLICY "Authenticated users can view active public votes" 
-- ON public.user_waypoint_votes FOR SELECT 
-- TO authenticated 
-- USING (deleted_at IS NULL);

COMMENT ON POLICY "Pilgrims can insert their own votes" ON public.user_waypoint_votes IS 
    'Allows authenticated users to insert their own votes.';
COMMENT ON POLICY "Pilgrims can update their own votes" ON public.user_waypoint_votes IS 
    'Allows authenticated users to update their own votes (change type, retract, or reinstate).';
COMMENT ON POLICY "Pilgrims can view their own votes" ON public.user_waypoint_votes IS 
    'Allows authenticated users to view their own vote records.';
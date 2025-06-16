-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 003_alter_waypoints_add_vote_counts.sql
-- Description: Add vote count columns to waypoints table for denormalized performance
-- Dependencies: Module 4 (waypoints table must exist)
-- Version: 1.0
-- =====================================================================================

-- Add vote count columns to waypoints table
ALTER TABLE public.waypoints
    ADD COLUMN up_vote_count INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN down_vote_count INTEGER NOT NULL DEFAULT 0;

-- Add comments for the new columns
COMMENT ON COLUMN public.waypoints.up_vote_count IS 'Denormalized count of up votes. Updated by trigger on user_waypoint_votes table.';
COMMENT ON COLUMN public.waypoints.down_vote_count IS 'Denormalized count of down votes. Updated by trigger on user_waypoint_votes table.';

-- Create index for efficient sorting by vote counts
CREATE INDEX idx_waypoints_vote_counts ON public.waypoints (up_vote_count DESC, down_vote_count ASC) 
    WHERE deleted_at IS NULL;

-- Add check constraint to ensure vote counts are never negative
ALTER TABLE public.waypoints 
    ADD CONSTRAINT waypoints_vote_counts_check 
    CHECK (up_vote_count >= 0 AND down_vote_count >= 0);
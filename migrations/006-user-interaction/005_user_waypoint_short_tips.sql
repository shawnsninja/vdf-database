-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 005_user_waypoint_short_tips.sql
-- Description: Create user_waypoint_short_tips table for user-submitted textual tips
-- Dependencies: 
--   - Module 1 (profiles, languages_master)
--   - Module 4 (waypoints)
--   - 001_tip_categories_master.sql
-- Version: 2.1.1
-- =====================================================================================

-- ENUM Type Definition for Moderation Status (if not already created globally)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'content_moderation_status_enum') THEN 
        CREATE TYPE public.content_moderation_status_enum AS ENUM (
            'pending_approval',
            'approved_visible',
            'rejected_hidden',
            'flagged_for_review_by_admin',
            'archived_by_admin'
        );
    END IF;
END $$;

-- Table Definition for user_waypoint_short_tips
CREATE TABLE public.user_waypoint_short_tips (
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    profile_id uuid NOT NULL,
    waypoint_id bigint NOT NULL, -- Matches waypoints.id type
    tip_text text NOT NULL,
    language_code text NOT NULL,
    tip_category_code text NULL,
    tip_source_platform text NULL,
    moderation_status public.content_moderation_status_enum NOT NULL DEFAULT 'pending_approval',
    is_publicly_visible boolean NOT NULL GENERATED ALWAYS AS 
        (moderation_status = 'approved_visible'::public.content_moderation_status_enum AND deleted_at IS NULL) STORED,
    is_pinned_by_admin boolean NOT NULL DEFAULT false,
    moderated_by_profile_id uuid NULL,
    moderation_timestamp timestamptz NULL,
    moderation_notes_internal text NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz NULL,
    
    CONSTRAINT user_waypoint_short_tips_pkey PRIMARY KEY (id),
    CONSTRAINT user_waypoint_short_tips_profile_id_fkey 
        FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
    CONSTRAINT user_waypoint_short_tips_waypoint_id_fkey 
        FOREIGN KEY (waypoint_id) REFERENCES public.waypoints(id) ON DELETE CASCADE,
    CONSTRAINT user_waypoint_short_tips_language_code_fkey 
        FOREIGN KEY (language_code) REFERENCES public.languages_master(language_code) ON DELETE RESTRICT,
    CONSTRAINT user_waypoint_short_tips_tip_category_code_fkey 
        FOREIGN KEY (tip_category_code) REFERENCES public.tip_categories_master(category_code) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT user_waypoint_short_tips_moderated_by_profile_id_fkey 
        FOREIGN KEY (moderated_by_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL,
    CONSTRAINT user_waypoint_short_tips_tip_text_check 
        CHECK ((char_length(tip_text) > 0 AND char_length(tip_text) <= 500))
);

-- Comments
COMMENT ON TABLE public.user_waypoint_short_tips IS 'Stores brief, user-submitted textual tips (max 500 chars) about specific waypoints, subject to moderation. Version 2.1.1.';
COMMENT ON COLUMN public.user_waypoint_short_tips.id IS 'Unique identifier for the tip.';
COMMENT ON COLUMN public.user_waypoint_short_tips.profile_id IS 'FK to profiles.id of the user who submitted the tip.';
COMMENT ON COLUMN public.user_waypoint_short_tips.waypoint_id IS 'FK to waypoints.id of the waypoint this tip is about.';
COMMENT ON COLUMN public.user_waypoint_short_tips.tip_text IS 'The content of the tip. Max 500 characters.';
COMMENT ON COLUMN public.user_waypoint_short_tips.language_code IS 'Language code of the tip (e.g., ''en'', ''it''), FK to languages_master.';
COMMENT ON COLUMN public.user_waypoint_short_tips.tip_category_code IS 'Optional category code for the tip from tip_categories_master. FK to tip_categories_master.category_code.';
COMMENT ON COLUMN public.user_waypoint_short_tips.tip_source_platform IS 'Optional: Platform from which the tip was submitted (e.g., ''web_app_v1'').';
COMMENT ON COLUMN public.user_waypoint_short_tips.moderation_status IS 'The current moderation status of the tip. Uses public.content_moderation_status_enum.';
COMMENT ON COLUMN public.user_waypoint_short_tips.is_publicly_visible IS 'Computed (STORED): True if moderation_status is ''approved_visible'' AND deleted_at IS NULL. For client queries.';
COMMENT ON COLUMN public.user_waypoint_short_tips.is_pinned_by_admin IS 'If true, administrators have marked this tip as particularly important.';
COMMENT ON COLUMN public.user_waypoint_short_tips.moderated_by_profile_id IS 'FK to profiles.id of the admin/moderator who last took action.';
COMMENT ON COLUMN public.user_waypoint_short_tips.moderation_timestamp IS 'Timestamp of the last moderation action.';
COMMENT ON COLUMN public.user_waypoint_short_tips.moderation_notes_internal IS 'Internal notes from the moderator, not typically public.';
COMMENT ON COLUMN public.user_waypoint_short_tips.created_at IS 'Timestamp of when the tip was submitted by the user.';
COMMENT ON COLUMN public.user_waypoint_short_tips.updated_at IS 'Timestamp of when the tip record was last updated. Auto-updated by trigger.';
COMMENT ON COLUMN public.user_waypoint_short_tips.deleted_at IS 'Timestamp for soft deletion, if a tip is retracted or removed by an admin.';

-- Indexes
CREATE INDEX idx_user_waypoint_short_tips_visibility ON public.user_waypoint_short_tips 
    (waypoint_id, is_publicly_visible, is_pinned_by_admin DESC, created_at DESC);
CREATE INDEX idx_user_waypoint_short_tips_moderation ON public.user_waypoint_short_tips 
    (moderation_status, created_at ASC);
CREATE INDEX idx_user_waypoint_short_tips_profile_id ON public.user_waypoint_short_tips 
    (profile_id);
CREATE INDEX idx_user_waypoint_short_tips_language_code ON public.user_waypoint_short_tips 
    (language_code);
CREATE INDEX idx_user_waypoint_short_tips_tip_category_code ON public.user_waypoint_short_tips 
    (tip_category_code) WHERE tip_category_code IS NOT NULL;

-- Trigger for user_waypoint_short_tips table 'updated_at'
CREATE TRIGGER on_user_waypoint_short_tips_updated_at 
    BEFORE UPDATE ON public.user_waypoint_short_tips 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_updated_at();

-- Create moderator check function
CREATE OR REPLACE FUNCTION public.check_if_user_is_moderator(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if the user has moderator or admin roles
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = user_id 
        AND (
            'moderator_platform' = ANY(roles) OR 
            'admin_platform' = ANY(roles) OR
            'moderator_regional' = ANY(roles)
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.check_if_user_is_moderator IS 'Checks if a user has moderation privileges based on their roles.';

-- RLS Policies
ALTER TABLE public.user_waypoint_short_tips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pilgrims can insert their own tips" ON public.user_waypoint_short_tips 
    FOR INSERT TO authenticated 
    WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Pilgrims can view publicly visible tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated 
    USING (is_publicly_visible = true);

CREATE POLICY "Pilgrims can view their own tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated 
    USING (auth.uid() = profile_id);

CREATE POLICY "Pilgrims can update their own tips" ON public.user_waypoint_short_tips 
    FOR UPDATE TO authenticated 
    USING (auth.uid() = profile_id) 
    WITH CHECK (
        auth.uid() = profile_id AND (
            -- Scenario 1: User is only changing deleted_at (retracting/un-retracting an existing tip)
            (OLD.deleted_at IS DISTINCT FROM NEW.deleted_at 
             AND OLD.tip_text = NEW.tip_text 
             AND OLD.language_code = NEW.language_code 
             AND OLD.tip_category_code IS NOT DISTINCT FROM NEW.tip_category_code 
             AND OLD.moderation_status = NEW.moderation_status
            )
            OR
            -- Scenario 2: Tip is still pending approval, user can edit content fields
            (OLD.moderation_status = 'pending_approval'::public.content_moderation_status_enum 
             AND NEW.moderation_status = 'pending_approval'::public.content_moderation_status_enum)
        )
    );

CREATE POLICY "Moderators can view all tips" ON public.user_waypoint_short_tips 
    FOR SELECT TO authenticated 
    USING (public.check_if_user_is_moderator(auth.uid()));

CREATE POLICY "Moderators can update moderation fields on tips" ON public.user_waypoint_short_tips 
    FOR UPDATE TO authenticated 
    USING (public.check_if_user_is_moderator(auth.uid())) 
    WITH CHECK (public.check_if_user_is_moderator(auth.uid()));

COMMENT ON POLICY "Pilgrims can insert their own tips" ON public.user_waypoint_short_tips IS 
    'Allows authenticated users to submit new tips for waypoints.';
COMMENT ON POLICY "Pilgrims can view publicly visible tips" ON public.user_waypoint_short_tips IS 
    'Allows authenticated users (and potentially anonymous via API) to view tips that are approved and not deleted.';
COMMENT ON POLICY "Pilgrims can view their own tips" ON public.user_waypoint_short_tips IS 
    'Allows authenticated users to view all of their own submitted tips, regardless of moderation status.';
COMMENT ON POLICY "Pilgrims can update their own tips" ON public.user_waypoint_short_tips IS 
    'Allows authenticated users to update their own tips, primarily for retraction (soft delete) or editing content if still pending approval.';
COMMENT ON POLICY "Moderators can view all tips" ON public.user_waypoint_short_tips IS 
    'Allows users with moderator privileges to view all tips for moderation purposes.';
COMMENT ON POLICY "Moderators can update moderation fields on tips" ON public.user_waypoint_short_tips IS 
    'Allows users with moderator privileges to update fields relevant to moderation.';
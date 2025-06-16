-- =====================================================================================
-- Module 1: User & Content Infrastructure - user_roles_master seed data
-- Description: Initial role definitions for the VDF platform
-- =====================================================================================

INSERT INTO public.user_roles_master (
    role_code,
    default_display_name,
    default_description,
    icon_identifier,
    permissions_summary_json,
    role_hierarchy_level,
    is_system_role,
    is_role_active,
    default_for_new_pilgrim_users
) VALUES 
    -- Core User Roles
    (
        'pilgrim_user',
        'Pilgrim User',
        'Standard pilgrim user with access to view trails, waypoints, and basic community features',
        'hiking',
        '{"can_view_trails": true, "can_view_waypoints": true, "can_submit_tips": true, "can_vote": true}'::jsonb,
        10,
        true,
        true,
        true  -- This is the default role for new users
    ),
    
    -- Host Roles
    (
        'accommodation_host',
        'Accommodation Host',
        'Host managing accommodation listings on the platform',
        'bed',
        '{"can_manage_accommodations": true, "can_respond_to_reviews": true}'::jsonb,
        20,
        true,
        true,
        false
    ),
    (
        'service_provider',
        'Service Provider',
        'Provider of services along the trail (restaurants, shops, transport)',
        'storefront',
        '{"can_manage_services": true, "can_update_hours": true}'::jsonb,
        20,
        true,
        true,
        false
    ),
    
    -- Content Management Roles
    (
        'content_moderator',
        'Content Moderator',
        'Reviews and moderates user-generated content',
        'shield_check',
        '{"can_moderate_content": true, "can_hide_content": true, "can_review_flags": true}'::jsonb,
        30,
        true,
        true,
        false
    ),
    (
        'trail_manager',
        'Trail Manager',
        'Manages trail information and conditions for specific regions',
        'map_edit',
        '{"can_update_trails": true, "can_post_warnings": true, "can_update_conditions": true}'::jsonb,
        40,
        true,
        true,
        false
    ),
    (
        'regional_manager',
        'Regional Manager',
        'Manages content and providers for a specific geographical region',
        'location_city',
        '{"can_manage_region": true, "can_approve_providers": true, "can_update_regional_info": true}'::jsonb,
        50,
        true,
        true,
        false
    ),
    
    -- Administrative Roles
    (
        'platform_admin',
        'Platform Administrator',
        'Full administrative access to platform features',
        'admin_panel_settings',
        '{"full_admin_access": true}'::jsonb,
        90,
        true,
        true,
        false
    ),
    (
        'admin_super',
        'Super Administrator',
        'System-level administrative access including user management',
        'security',
        '{"system_admin": true, "can_manage_users": true, "can_manage_roles": true}'::jsonb,
        100,
        true,
        true,
        false
    ),
    
    -- Specialized Roles
    (
        'translator',
        'Translator',
        'Translates platform content into different languages',
        'translate',
        '{"can_translate_content": true, "can_review_translations": true}'::jsonb,
        25,
        true,
        true,
        false
    ),
    (
        'event_organizer',
        'Event Organizer',
        'Organizes and manages events along the pilgrimage routes',
        'event',
        '{"can_create_events": true, "can_manage_events": true}'::jsonb,
        25,
        true,
        true,
        false
    ),
    (
        'verified_contributor',
        'Verified Contributor',
        'Trusted community member with enhanced contribution privileges',
        'verified_user',
        '{"can_instant_publish": true, "can_edit_community_content": true}'::jsonb,
        15,
        true,
        true,
        false
    );

-- Add comments for seed data
COMMENT ON TABLE public.user_roles_master IS 
    'Defines all available user roles, their default names/descriptions (in primary reference language), permission summaries, UI icons, and audit trails for RBAC. Version 2.1. Seeded with 11 initial roles.';

-- Verify the default role is set correctly
DO $$
DECLARE
    default_count integer;
BEGIN
    SELECT COUNT(*) INTO default_count 
    FROM public.user_roles_master 
    WHERE default_for_new_pilgrim_users = true;
    
    IF default_count != 1 THEN
        RAISE EXCEPTION 'Exactly one role must be set as default_for_new_pilgrim_users';
    END IF;
END $$;
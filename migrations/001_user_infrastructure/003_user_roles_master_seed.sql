-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 003_user_roles_master_seed.sql
-- Description: Seed data for user roles
-- Version: 1.0
-- =============================================

-- Insert initial roles
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
    -- Core pilgrim role (default for new users)
    (
        'pilgrim_user',
        'Pilgrim User',
        'Standard user planning or on a pilgrimage.',
        'person',
        '{"can_view_trails": true, "can_create_tips": true, "can_vote": true, "can_save_itineraries": true}'::jsonb,
        10,
        true,
        true,
        true  -- This is the default role for new users
    ),
    
    -- Host role
    (
        'accommodation_host',
        'Accommodation Host',
        'Manages accommodation listings and availability.',
        'hotel',
        '{"can_manage_own_listings": true, "can_respond_to_reviews": true, "can_update_availability": true}'::jsonb,
        20,
        false,
        true,
        false
    ),
    
    -- Content management roles
    (
        'regional_content_manager',
        'Regional Content Manager',
        'Manages content for specific regions including trails, waypoints, and conditions.',
        'edit_location',
        '{"can_edit_regional_content": true, "can_manage_warnings": true, "can_verify_waypoints": true}'::jsonb,
        50,
        false,
        true,
        false
    ),
    
    (
        'content_moderator',
        'Content Moderator',
        'Moderates user-generated content including reviews and tips.',
        'gavel',
        '{"can_moderate_content": true, "can_hide_content": true, "can_warn_users": true}'::jsonb,
        40,
        false,
        true,
        false
    ),
    
    -- Administrative roles
    (
        'admin_platform',
        'Platform Administrator',
        'Manages overall platform settings and user accounts.',
        'admin_panel_settings',
        '{"can_manage_users": true, "can_configure_platform": true, "can_view_analytics": true}'::jsonb,
        90,
        true,
        true,
        false
    ),
    
    (
        'admin_super',
        'Super Administrator',
        'Full system access, manages core data and infrastructure.',
        'security',
        '{"full_system_access": true}'::jsonb,
        100,
        true,
        true,
        false
    )
ON CONFLICT (role_code) DO NOTHING;
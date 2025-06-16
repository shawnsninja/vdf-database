-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 004_languages_master_seed.sql
-- Description: Seed data for languages
-- Version: 1.0
-- =============================================

-- Insert initial languages for Via di Francesco platform
INSERT INTO public.languages_master (
    language_code,
    display_name_native,
    display_name_en,
    icon_identifier,
    is_active_for_platform,
    is_primary_content_language,
    display_order_ui
) VALUES 
    -- English (Primary content language)
    (
        'en',
        'English',
        'English',
        'flag-icon-gb',
        true,
        true,  -- This is the primary content language
        1
    ),
    
    -- Italian (Most important for Via di Francesco)
    (
        'it',
        'Italiano',
        'Italian',
        'flag-icon-it',
        true,
        false,
        2
    ),
    
    -- Spanish
    (
        'es',
        'Español',
        'Spanish',
        'flag-icon-es',
        true,
        false,
        3
    ),
    
    -- German
    (
        'de',
        'Deutsch',
        'German',
        'flag-icon-de',
        true,
        false,
        4
    ),
    
    -- French
    (
        'fr',
        'Français',
        'French',
        'flag-icon-fr',
        true,
        false,
        5
    ),
    
    -- Portuguese (for Brazilian pilgrims)
    (
        'pt',
        'Português',
        'Portuguese',
        'flag-icon-pt',
        false,  -- Not active yet
        false,
        6
    ),
    
    -- Dutch
    (
        'nl',
        'Nederlands',
        'Dutch',
        'flag-icon-nl',
        false,  -- Not active yet
        false,
        7
    ),
    
    -- Polish
    (
        'pl',
        'Polski',
        'Polish',
        'flag-icon-pl',
        false,  -- Not active yet
        false,
        8
    )
ON CONFLICT (language_code) DO NOTHING;
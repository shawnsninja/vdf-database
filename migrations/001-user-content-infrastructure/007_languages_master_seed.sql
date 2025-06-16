-- =====================================================================================
-- Module 1: User & Content Infrastructure - languages_master seed data
-- Description: Initial language definitions for the VDF platform
-- =====================================================================================

INSERT INTO public.languages_master (
    language_code,
    display_name_native,
    display_name_en,
    icon_identifier,
    is_active_for_platform,
    is_primary_content_language,
    display_order_ui
) VALUES 
    -- Primary language (English)
    (
        'en',
        'English',
        'English',
        'flag-icon-gb',
        true,
        true,  -- This is the primary content language
        1
    ),
    
    -- Core supported languages
    (
        'it',
        'Italiano',
        'Italian',
        'flag-icon-it',
        true,
        false,
        2
    ),
    (
        'es',
        'Español',
        'Spanish',
        'flag-icon-es',
        true,
        false,
        3
    ),
    (
        'de',
        'Deutsch',
        'German',
        'flag-icon-de',
        true,
        false,
        4
    ),
    (
        'fr',
        'Français',
        'French',
        'flag-icon-fr',
        true,
        false,
        5
    ),
    (
        'pt',
        'Português',
        'Portuguese',
        'flag-icon-pt',
        true,
        false,
        6
    ),
    (
        'nl',
        'Nederlands',
        'Dutch',
        'flag-icon-nl',
        true,
        false,
        7
    ),
    (
        'pl',
        'Polski',
        'Polish',
        'flag-icon-pl',
        true,
        false,
        8
    ),
    
    -- Additional languages (inactive for now)
    (
        'ja',
        '日本語',
        'Japanese',
        'flag-icon-jp',
        false,
        false,
        9
    ),
    (
        'ko',
        '한국어',
        'Korean',
        'flag-icon-kr',
        false,
        false,
        10
    ),
    (
        'zh',
        '中文',
        'Chinese',
        'flag-icon-cn',
        false,
        false,
        11
    ),
    (
        'ar',
        'العربية',
        'Arabic',
        'flag-icon-sa',
        false,
        false,
        12
    ),
    (
        'he',
        'עברית',
        'Hebrew',
        'flag-icon-il',
        false,
        false,
        13
    ),
    (
        'ru',
        'Русский',
        'Russian',
        'flag-icon-ru',
        false,
        false,
        14
    );

-- Add comments for seed data
COMMENT ON TABLE public.languages_master IS 
    'Defines all languages supported or planned for the platform, including display names, active status, the primary reference language, and optional UI icon identifiers. Authoritative list for translations. Version 2.1. Seeded with 14 languages (8 active, 6 planned).';

-- Verify exactly one primary content language is set
DO $$
DECLARE
    primary_count integer;
    primary_lang text;
BEGIN
    SELECT COUNT(*), MAX(language_code) 
    INTO primary_count, primary_lang
    FROM public.languages_master 
    WHERE is_primary_content_language = true;
    
    IF primary_count != 1 THEN
        RAISE EXCEPTION 'Exactly one language must be set as is_primary_content_language';
    END IF;
    
    IF primary_lang != 'en' THEN
        RAISE EXCEPTION 'English (en) must be the primary content language';
    END IF;
END $$;
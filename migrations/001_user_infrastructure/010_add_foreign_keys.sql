-- =============================================
-- VDF Database - Module 1: User & Content Infrastructure
-- Migration: 010_add_foreign_keys.sql
-- Description: Add foreign key constraints after all tables exist
-- Version: 1.0
-- =============================================

-- Add foreign key constraint for profiles.preferred_language_code
ALTER TABLE public.profiles 
    ADD CONSTRAINT fk_profiles_preferred_language_code 
    FOREIGN KEY (preferred_language_code) 
    REFERENCES public.languages_master(language_code) 
    ON UPDATE CASCADE 
    ON DELETE RESTRICT;

-- Add foreign key constraint for profiles.public_avatar_media_id
ALTER TABLE public.profiles 
    ADD CONSTRAINT fk_profiles_public_avatar_media_id 
    FOREIGN KEY (public_avatar_media_id) 
    REFERENCES public.media(id) 
    ON DELETE SET NULL;
-- =====================================================================================
-- VDF Database - Module 8: Editorial (Platform Content)
-- Migration: 002_media_roles_master_seed.sql
-- Description: Seed initial media roles with translations
-- Dependencies: 001_media_roles_master.sql
-- Version: 1.0
-- =====================================================================================

-- Insert media roles
INSERT INTO public.media_roles_master (role_code, default_display_name, default_description, icon_identifier, is_active, created_by_profile_id, updated_by_profile_id)
VALUES 
    ('gallery_image', 'Gallery Image', 'Image used in a content gallery.', 'image_aspect_ratio', true, NULL, NULL),
    ('inline_image', 'Inline Content Image', 'Image embedded within body text.', 'image', true, NULL, NULL),
    ('featured_image', 'Featured Image', 'Primary representative image.', 'star', true, NULL, NULL),
    ('profile_avatar', 'Profile Avatar', 'User''s public avatar image.', 'person', true, NULL, NULL),
    ('background_image', 'Background Image', 'Image used for backgrounds or banners.', 'landscape', true, NULL, NULL),
    ('thumbnail', 'Thumbnail', 'Small preview image.', 'crop_square', true, NULL, NULL),
    ('cover_photo', 'Cover Photo', 'Cover or hero image for sections.', 'panorama', true, NULL, NULL),
    ('map_image', 'Map Image', 'Map or diagram image.', 'map', true, NULL, NULL);

-- Add Italian translations
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text, created_by_profile_id, updated_by_profile_id)
VALUES 
    -- Gallery Image
    ('media_roles_master', 'gallery_image', 'default_display_name', 'it', 'Immagine della Galleria', NULL, NULL),
    ('media_roles_master', 'gallery_image', 'default_description', 'it', 'Immagine utilizzata in una galleria di contenuti.', NULL, NULL),
    
    -- Inline Content Image
    ('media_roles_master', 'inline_image', 'default_display_name', 'it', 'Immagine Inline', NULL, NULL),
    ('media_roles_master', 'inline_image', 'default_description', 'it', 'Immagine incorporata nel testo del corpo.', NULL, NULL),
    
    -- Featured Image
    ('media_roles_master', 'featured_image', 'default_display_name', 'it', 'Immagine in Evidenza', NULL, NULL),
    ('media_roles_master', 'featured_image', 'default_description', 'it', 'Immagine rappresentativa principale.', NULL, NULL),
    
    -- Profile Avatar
    ('media_roles_master', 'profile_avatar', 'default_display_name', 'it', 'Avatar del Profilo', NULL, NULL),
    ('media_roles_master', 'profile_avatar', 'default_description', 'it', 'Immagine avatar pubblica dell''utente.', NULL, NULL),
    
    -- Background Image
    ('media_roles_master', 'background_image', 'default_display_name', 'it', 'Immagine di Sfondo', NULL, NULL),
    ('media_roles_master', 'background_image', 'default_description', 'it', 'Immagine utilizzata per sfondi o banner.', NULL, NULL),
    
    -- Thumbnail
    ('media_roles_master', 'thumbnail', 'default_display_name', 'it', 'Miniatura', NULL, NULL),
    ('media_roles_master', 'thumbnail', 'default_description', 'it', 'Piccola immagine di anteprima.', NULL, NULL),
    
    -- Cover Photo
    ('media_roles_master', 'cover_photo', 'default_display_name', 'it', 'Foto di Copertina', NULL, NULL),
    ('media_roles_master', 'cover_photo', 'default_description', 'it', 'Immagine di copertina o hero per le sezioni.', NULL, NULL),
    
    -- Map Image
    ('media_roles_master', 'map_image', 'default_display_name', 'it', 'Immagine Mappa', NULL, NULL),
    ('media_roles_master', 'map_image', 'default_description', 'it', 'Immagine di mappa o diagramma.', NULL, NULL);

-- Add German translations
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text, created_by_profile_id, updated_by_profile_id)
VALUES 
    -- Gallery Image
    ('media_roles_master', 'gallery_image', 'default_display_name', 'de', 'Galeriebild', NULL, NULL),
    ('media_roles_master', 'gallery_image', 'default_description', 'de', 'Bild in einer Inhaltsgalerie verwendet.', NULL, NULL),
    
    -- Inline Content Image
    ('media_roles_master', 'inline_image', 'default_display_name', 'de', 'Inline-Bild', NULL, NULL),
    ('media_roles_master', 'inline_image', 'default_description', 'de', 'Bild im Haupttext eingebettet.', NULL, NULL),
    
    -- Featured Image
    ('media_roles_master', 'featured_image', 'default_display_name', 'de', 'Hauptbild', NULL, NULL),
    ('media_roles_master', 'featured_image', 'default_description', 'de', 'Primäres repräsentatives Bild.', NULL, NULL),
    
    -- Profile Avatar
    ('media_roles_master', 'profile_avatar', 'default_display_name', 'de', 'Profilbild', NULL, NULL),
    ('media_roles_master', 'profile_avatar', 'default_description', 'de', 'Öffentliches Avatar-Bild des Benutzers.', NULL, NULL),
    
    -- Background Image
    ('media_roles_master', 'background_image', 'default_display_name', 'de', 'Hintergrundbild', NULL, NULL),
    ('media_roles_master', 'background_image', 'default_description', 'de', 'Bild für Hintergründe oder Banner verwendet.', NULL, NULL),
    
    -- Thumbnail
    ('media_roles_master', 'thumbnail', 'default_display_name', 'de', 'Vorschaubild', NULL, NULL),
    ('media_roles_master', 'thumbnail', 'default_description', 'de', 'Kleines Vorschaubild.', NULL, NULL),
    
    -- Cover Photo
    ('media_roles_master', 'cover_photo', 'default_display_name', 'de', 'Titelbild', NULL, NULL),
    ('media_roles_master', 'cover_photo', 'default_description', 'de', 'Titel- oder Hero-Bild für Abschnitte.', NULL, NULL),
    
    -- Map Image
    ('media_roles_master', 'map_image', 'default_display_name', 'de', 'Kartenbild', NULL, NULL),
    ('media_roles_master', 'map_image', 'default_description', 'de', 'Karten- oder Diagrammbild.', NULL, NULL);
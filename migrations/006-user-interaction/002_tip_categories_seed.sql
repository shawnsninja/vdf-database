-- =====================================================================================
-- VDF Database - Module 6: User Interaction
-- Migration: 002_tip_categories_seed.sql
-- Description: Seed initial tip categories with translations
-- Dependencies: 001_tip_categories_master.sql
-- Version: 1.0
-- =====================================================================================

-- Insert initial tip categories
-- Note: Replace [ADMIN_UUID] with an actual admin profile ID when running
INSERT INTO public.tip_categories_master 
    (category_code, default_name, default_description, icon_identifier, is_active, sort_order, created_by_profile_id, updated_by_profile_id)
VALUES 
    ('practical_advice', 'Practical Advice', 'General tips related to practicality, gear, or general information.', 'icon-lightbulb', true, 10, NULL, NULL),
    ('safety_observation', 'Safety Observation', 'Tips related to safety, warnings, or potential hazards.', 'icon-warning', true, 20, NULL, NULL),
    ('hidden_gem', 'Hidden Gem', 'Tips about lesser-known spots or positive experiences.', 'icon-star', true, 30, NULL, NULL),
    ('poi_correction', 'POI Correction', 'Tips suggesting corrections to Point of Interest information.', 'icon-edit', true, 40, NULL, NULL),
    ('trail_condition', 'Trail Condition', 'Updates about current trail conditions, obstacles, or changes.', 'icon-map', true, 50, NULL, NULL),
    ('pilgrim_etiquette', 'Pilgrim Etiquette', 'Tips about proper behavior and customs on the pilgrimage.', 'icon-users', true, 60, NULL, NULL),
    ('spiritual_insight', 'Spiritual Insight', 'Reflections and spiritual observations along the way.', 'icon-heart', true, 70, NULL, NULL),
    ('local_recommendation', 'Local Recommendation', 'Recommendations for local services, food, or experiences.', 'icon-thumbs-up', true, 80, NULL, NULL);

-- Insert Italian translations for category names
INSERT INTO public.translations 
    (table_identifier, column_identifier, row_foreign_key, language_code, translated_text, created_by_profile_id, updated_by_profile_id)
VALUES 
    ('tip_categories_master', 'default_name', 'practical_advice', 'it', 'Consigli Pratici', NULL, NULL),
    ('tip_categories_master', 'default_name', 'safety_observation', 'it', 'Osservazione di Sicurezza', NULL, NULL),
    ('tip_categories_master', 'default_name', 'hidden_gem', 'it', 'Perla Nascosta', NULL, NULL),
    ('tip_categories_master', 'default_name', 'poi_correction', 'it', 'Correzione POI', NULL, NULL),
    ('tip_categories_master', 'default_name', 'trail_condition', 'it', 'Condizione del Sentiero', NULL, NULL),
    ('tip_categories_master', 'default_name', 'pilgrim_etiquette', 'it', 'Galateo del Pellegrino', NULL, NULL),
    ('tip_categories_master', 'default_name', 'spiritual_insight', 'it', 'Intuizione Spirituale', NULL, NULL),
    ('tip_categories_master', 'default_name', 'local_recommendation', 'it', 'Raccomandazione Locale', NULL, NULL);

-- Insert Italian translations for category descriptions
INSERT INTO public.translations 
    (table_identifier, column_identifier, row_foreign_key, language_code, translated_text, created_by_profile_id, updated_by_profile_id)
VALUES 
    ('tip_categories_master', 'default_description', 'practical_advice', 'it', 'Suggerimenti generali relativi alla praticità, attrezzatura o informazioni generali.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'safety_observation', 'it', 'Consigli relativi alla sicurezza, avvertimenti o potenziali pericoli.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'hidden_gem', 'it', 'Suggerimenti su luoghi poco conosciuti o esperienze positive.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'poi_correction', 'it', 'Suggerimenti per correggere le informazioni sui Punti di Interesse.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'trail_condition', 'it', 'Aggiornamenti sulle condizioni attuali del sentiero, ostacoli o cambiamenti.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'pilgrim_etiquette', 'it', 'Suggerimenti sul comportamento appropriato e le usanze del pellegrinaggio.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'spiritual_insight', 'it', 'Riflessioni e osservazioni spirituali lungo il cammino.', NULL, NULL),
    ('tip_categories_master', 'default_description', 'local_recommendation', 'it', 'Raccomandazioni per servizi locali, cibo o esperienze.', NULL, NULL);

-- Insert German translations for category names
INSERT INTO public.translations 
    (table_identifier, column_identifier, row_foreign_key, language_code, translated_text, created_by_profile_id, updated_by_profile_id)
VALUES 
    ('tip_categories_master', 'default_name', 'practical_advice', 'de', 'Praktische Ratschläge', NULL, NULL),
    ('tip_categories_master', 'default_name', 'safety_observation', 'de', 'Sicherheitsbeobachtung', NULL, NULL),
    ('tip_categories_master', 'default_name', 'hidden_gem', 'de', 'Verstecktes Juwel', NULL, NULL),
    ('tip_categories_master', 'default_name', 'poi_correction', 'de', 'POI-Korrektur', NULL, NULL),
    ('tip_categories_master', 'default_name', 'trail_condition', 'de', 'Wegzustand', NULL, NULL),
    ('tip_categories_master', 'default_name', 'pilgrim_etiquette', 'de', 'Pilger-Etikette', NULL, NULL),
    ('tip_categories_master', 'default_name', 'spiritual_insight', 'de', 'Spirituelle Einsicht', NULL, NULL),
    ('tip_categories_master', 'default_name', 'local_recommendation', 'de', 'Lokale Empfehlung', NULL, NULL);
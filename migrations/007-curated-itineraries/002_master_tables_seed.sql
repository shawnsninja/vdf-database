-- =====================================================================================
-- VDF Database - Module 7: Curated Itineraries
-- Migration: 002_master_tables_seed.sql
-- Description: Seed data for master tables with translations
-- Dependencies: 001_master_tables.sql, Module 1 (translations)
-- Version: 1.0
-- =====================================================================================

-- Seed: Itinerary Categories
INSERT INTO public.itinerary_categories_master (category_code, default_name, default_description, icon_identifier, sort_order)
VALUES 
    ('spiritual_journey', 'Spiritual Journey', 'Focused on prayer, meditation, and religious sites', 'pray', 10),
    ('nature_lover', 'Nature Lover', 'Emphasizing natural beauty and outdoor experiences', 'tree', 20),
    ('cultural_explorer', 'Cultural Explorer', 'Rich in historical sites and local traditions', 'museum', 30),
    ('slow_travel', 'Slow Travel', 'Relaxed pace with time for reflection', 'snail', 40),
    ('fitness_challenge', 'Fitness Challenge', 'For those seeking physical achievement', 'running', 50),
    ('family_friendly', 'Family Friendly', 'Suitable for families with children', 'family', 60),
    ('accessible_route', 'Accessible Route', 'Modified for those with mobility limitations', 'wheelchair', 70),
    ('photographer_special', 'Photographer Special', 'Highlighting the most photogenic spots', 'camera', 80)
ON CONFLICT (category_code) DO NOTHING;

-- Translations for Itinerary Categories
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
VALUES 
    -- Italian translations
    ('itinerary_categories_master', 'spiritual_journey', 'default_name', 'it', 'Viaggio Spirituale'),
    ('itinerary_categories_master', 'spiritual_journey', 'default_description', 'it', 'Incentrato su preghiera, meditazione e siti religiosi'),
    ('itinerary_categories_master', 'nature_lover', 'default_name', 'it', 'Amante della Natura'),
    ('itinerary_categories_master', 'nature_lover', 'default_description', 'it', 'Enfatizza la bellezza naturale e le esperienze all''aperto'),
    ('itinerary_categories_master', 'cultural_explorer', 'default_name', 'it', 'Esploratore Culturale'),
    ('itinerary_categories_master', 'cultural_explorer', 'default_description', 'it', 'Ricco di siti storici e tradizioni locali'),
    ('itinerary_categories_master', 'slow_travel', 'default_name', 'it', 'Viaggio Lento'),
    ('itinerary_categories_master', 'slow_travel', 'default_description', 'it', 'Ritmo rilassato con tempo per la riflessione'),
    ('itinerary_categories_master', 'fitness_challenge', 'default_name', 'it', 'Sfida Fitness'),
    ('itinerary_categories_master', 'fitness_challenge', 'default_description', 'it', 'Per chi cerca risultati fisici'),
    ('itinerary_categories_master', 'family_friendly', 'default_name', 'it', 'Per Famiglie'),
    ('itinerary_categories_master', 'family_friendly', 'default_description', 'it', 'Adatto a famiglie con bambini'),
    ('itinerary_categories_master', 'accessible_route', 'default_name', 'it', 'Percorso Accessibile'),
    ('itinerary_categories_master', 'accessible_route', 'default_description', 'it', 'Modificato per persone con limitazioni di mobilità'),
    ('itinerary_categories_master', 'photographer_special', 'default_name', 'it', 'Speciale Fotografo'),
    ('itinerary_categories_master', 'photographer_special', 'default_description', 'it', 'Evidenzia i luoghi più fotogenici'),
    
    -- German translations
    ('itinerary_categories_master', 'spiritual_journey', 'default_name', 'de', 'Spirituelle Reise'),
    ('itinerary_categories_master', 'spiritual_journey', 'default_description', 'de', 'Fokus auf Gebet, Meditation und religiöse Stätten'),
    ('itinerary_categories_master', 'nature_lover', 'default_name', 'de', 'Naturliebhaber'),
    ('itinerary_categories_master', 'nature_lover', 'default_description', 'de', 'Betont natürliche Schönheit und Outdoor-Erlebnisse'),
    ('itinerary_categories_master', 'cultural_explorer', 'default_name', 'de', 'Kulturentdecker'),
    ('itinerary_categories_master', 'cultural_explorer', 'default_description', 'de', 'Reich an historischen Stätten und lokalen Traditionen'),
    ('itinerary_categories_master', 'slow_travel', 'default_name', 'de', 'Langsames Reisen'),
    ('itinerary_categories_master', 'slow_travel', 'default_description', 'de', 'Entspanntes Tempo mit Zeit zur Reflexion'),
    ('itinerary_categories_master', 'fitness_challenge', 'default_name', 'de', 'Fitness-Herausforderung'),
    ('itinerary_categories_master', 'fitness_challenge', 'default_description', 'de', 'Für diejenigen, die körperliche Leistung suchen'),
    ('itinerary_categories_master', 'family_friendly', 'default_name', 'de', 'Familienfreundlich'),
    ('itinerary_categories_master', 'family_friendly', 'default_description', 'de', 'Geeignet für Familien mit Kindern'),
    ('itinerary_categories_master', 'accessible_route', 'default_name', 'de', 'Barrierefreie Route'),
    ('itinerary_categories_master', 'accessible_route', 'default_description', 'de', 'Angepasst für Menschen mit Mobilitätseinschränkungen'),
    ('itinerary_categories_master', 'photographer_special', 'default_name', 'de', 'Fotografen-Special'),
    ('itinerary_categories_master', 'photographer_special', 'default_description', 'de', 'Hebt die fotogensten Orte hervor')
ON CONFLICT (table_identifier, row_foreign_key, column_identifier, language_code) DO NOTHING;

-- Seed: Seasons
INSERT INTO public.seasons_master (season_code, default_name, default_description, typical_months, sort_order)
VALUES 
    ('spring', 'Spring', 'Mild weather, blooming flowers, occasional rain', ARRAY['MAR', 'APR', 'MAY'], 10),
    ('summer', 'Summer', 'Warm to hot weather, crowded trails, long days', ARRAY['JUN', 'JUL', 'AUG'], 20),
    ('autumn', 'Autumn', 'Cool weather, harvest season, beautiful colors', ARRAY['SEP', 'OCT', 'NOV'], 30),
    ('winter', 'Winter', 'Cold weather, snow possible, fewer pilgrims', ARRAY['DEC', 'JAN', 'FEB'], 40),
    ('year_round', 'Year Round', 'Suitable for any season with proper preparation', NULL, 50)
ON CONFLICT (season_code) DO NOTHING;

-- Translations for Seasons
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
VALUES 
    -- Italian translations
    ('seasons_master', 'spring', 'default_name', 'it', 'Primavera'),
    ('seasons_master', 'spring', 'default_description', 'it', 'Clima mite, fiori in fiore, pioggia occasionale'),
    ('seasons_master', 'summer', 'default_name', 'it', 'Estate'),
    ('seasons_master', 'summer', 'default_description', 'it', 'Clima da caldo a molto caldo, sentieri affollati, giornate lunghe'),
    ('seasons_master', 'autumn', 'default_name', 'it', 'Autunno'),
    ('seasons_master', 'autumn', 'default_description', 'it', 'Clima fresco, stagione del raccolto, colori bellissimi'),
    ('seasons_master', 'winter', 'default_name', 'it', 'Inverno'),
    ('seasons_master', 'winter', 'default_description', 'it', 'Clima freddo, possibile neve, meno pellegrini'),
    ('seasons_master', 'year_round', 'default_name', 'it', 'Tutto l''anno'),
    ('seasons_master', 'year_round', 'default_description', 'it', 'Adatto per qualsiasi stagione con preparazione adeguata'),
    
    -- German translations
    ('seasons_master', 'spring', 'default_name', 'de', 'Frühling'),
    ('seasons_master', 'spring', 'default_description', 'de', 'Mildes Wetter, blühende Blumen, gelegentlicher Regen'),
    ('seasons_master', 'summer', 'default_name', 'de', 'Sommer'),
    ('seasons_master', 'summer', 'default_description', 'de', 'Warmes bis heißes Wetter, überfüllte Wege, lange Tage'),
    ('seasons_master', 'autumn', 'default_name', 'de', 'Herbst'),
    ('seasons_master', 'autumn', 'default_description', 'de', 'Kühles Wetter, Erntezeit, schöne Farben'),
    ('seasons_master', 'winter', 'default_name', 'de', 'Winter'),
    ('seasons_master', 'winter', 'default_description', 'de', 'Kaltes Wetter, Schnee möglich, weniger Pilger'),
    ('seasons_master', 'year_round', 'default_name', 'de', 'Ganzjährig'),
    ('seasons_master', 'year_round', 'default_description', 'de', 'Geeignet für jede Jahreszeit mit angemessener Vorbereitung')
ON CONFLICT (table_identifier, row_foreign_key, column_identifier, language_code) DO NOTHING;

-- Seed: Trail Difficulty Levels
INSERT INTO public.trail_difficulty_levels_master (
    difficulty_code, default_name, default_description, numeric_level,
    daily_distance_km_min, daily_distance_km_max, elevation_gain_m_typical,
    fitness_requirement_notes, icon_identifier, color_hex
)
VALUES 
    ('very_easy', 'Very Easy', 'Suitable for all ages and fitness levels', 1, 
     5, 10, 100, 'No special fitness required', 'easy', '#00FF00'),
    ('easy', 'Easy', 'Comfortable for most people with basic fitness', 2, 
     10, 15, 200, 'Basic walking fitness', 'easy', '#40FF00'),
    ('moderate', 'Moderate', 'Requires regular walking experience', 3, 
     15, 20, 400, 'Regular walking or hiking experience helpful', 'moderate', '#80FF00'),
    ('moderate_challenging', 'Moderate to Challenging', 'For experienced walkers', 4, 
     20, 25, 600, 'Good fitness level required', 'moderate', '#BFFF00'),
    ('challenging', 'Challenging', 'Demanding terrain and distances', 5, 
     25, 30, 800, 'Excellent fitness and hiking experience required', 'challenging', '#FFFF00'),
    ('very_challenging', 'Very Challenging', 'Only for very fit and experienced hikers', 6, 
     30, 35, 1000, 'Very high fitness level and mountain experience', 'challenging', '#FFBF00'),
    ('extreme', 'Extreme', 'Exceptional physical demands', 7, 
     35, 40, 1200, 'Athletic fitness and extensive hiking experience', 'extreme', '#FF8000'),
    ('ultra_extreme', 'Ultra Extreme', 'Professional level difficulty', 8, 
     40, NULL, 1500, 'Professional athlete level fitness', 'extreme', '#FF4000')
ON CONFLICT (difficulty_code) DO NOTHING;

-- Translations for Trail Difficulty Levels
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
VALUES 
    -- Italian translations
    ('trail_difficulty_levels_master', 'very_easy', 'default_name', 'it', 'Molto Facile'),
    ('trail_difficulty_levels_master', 'very_easy', 'default_description', 'it', 'Adatto a tutte le età e livelli di fitness'),
    ('trail_difficulty_levels_master', 'easy', 'default_name', 'it', 'Facile'),
    ('trail_difficulty_levels_master', 'easy', 'default_description', 'it', 'Comodo per la maggior parte delle persone con fitness di base'),
    ('trail_difficulty_levels_master', 'moderate', 'default_name', 'it', 'Moderato'),
    ('trail_difficulty_levels_master', 'moderate', 'default_description', 'it', 'Richiede esperienza di camminata regolare'),
    ('trail_difficulty_levels_master', 'moderate_challenging', 'default_name', 'it', 'Moderato-Impegnativo'),
    ('trail_difficulty_levels_master', 'moderate_challenging', 'default_description', 'it', 'Per camminatori esperti'),
    ('trail_difficulty_levels_master', 'challenging', 'default_name', 'it', 'Impegnativo'),
    ('trail_difficulty_levels_master', 'challenging', 'default_description', 'it', 'Terreno e distanze impegnative'),
    ('trail_difficulty_levels_master', 'very_challenging', 'default_name', 'it', 'Molto Impegnativo'),
    ('trail_difficulty_levels_master', 'very_challenging', 'default_description', 'it', 'Solo per escursionisti molto in forma ed esperti'),
    ('trail_difficulty_levels_master', 'extreme', 'default_name', 'it', 'Estremo'),
    ('trail_difficulty_levels_master', 'extreme', 'default_description', 'it', 'Richieste fisiche eccezionali'),
    ('trail_difficulty_levels_master', 'ultra_extreme', 'default_name', 'it', 'Ultra Estremo'),
    ('trail_difficulty_levels_master', 'ultra_extreme', 'default_description', 'it', 'Difficoltà a livello professionale'),
    
    -- German translations
    ('trail_difficulty_levels_master', 'very_easy', 'default_name', 'de', 'Sehr Leicht'),
    ('trail_difficulty_levels_master', 'very_easy', 'default_description', 'de', 'Geeignet für alle Altersgruppen und Fitnesslevel'),
    ('trail_difficulty_levels_master', 'easy', 'default_name', 'de', 'Leicht'),
    ('trail_difficulty_levels_master', 'easy', 'default_description', 'de', 'Bequem für die meisten Menschen mit Grundfitness'),
    ('trail_difficulty_levels_master', 'moderate', 'default_name', 'de', 'Mittel'),
    ('trail_difficulty_levels_master', 'moderate', 'default_description', 'de', 'Erfordert regelmäßige Wandererfahrung'),
    ('trail_difficulty_levels_master', 'moderate_challenging', 'default_name', 'de', 'Mittel bis Anspruchsvoll'),
    ('trail_difficulty_levels_master', 'moderate_challenging', 'default_description', 'de', 'Für erfahrene Wanderer'),
    ('trail_difficulty_levels_master', 'challenging', 'default_name', 'de', 'Anspruchsvoll'),
    ('trail_difficulty_levels_master', 'challenging', 'default_description', 'de', 'Anspruchsvolles Gelände und Entfernungen'),
    ('trail_difficulty_levels_master', 'very_challenging', 'default_name', 'de', 'Sehr Anspruchsvoll'),
    ('trail_difficulty_levels_master', 'very_challenging', 'default_description', 'de', 'Nur für sehr fitte und erfahrene Wanderer'),
    ('trail_difficulty_levels_master', 'extreme', 'default_name', 'de', 'Extrem'),
    ('trail_difficulty_levels_master', 'extreme', 'default_description', 'de', 'Außergewöhnliche körperliche Anforderungen'),
    ('trail_difficulty_levels_master', 'ultra_extreme', 'default_name', 'de', 'Ultra Extrem'),
    ('trail_difficulty_levels_master', 'ultra_extreme', 'default_description', 'de', 'Schwierigkeit auf Profi-Niveau')
ON CONFLICT (table_identifier, row_foreign_key, column_identifier, language_code) DO NOTHING;

-- Seed: Content Statuses (if not already seeded)
INSERT INTO public.content_statuses_master (status_code, default_name, default_description, allows_public_visibility, sort_order)
VALUES 
    ('draft', 'Draft', 'Work in progress, not ready for review', false, 10),
    ('ready_for_review', 'Ready for Review', 'Completed and awaiting editorial review', false, 20),
    ('in_review', 'In Review', 'Currently being reviewed by editors', false, 30),
    ('approved', 'Approved', 'Approved but not yet published', false, 40),
    ('published', 'Published', 'Live and publicly visible', true, 50),
    ('archived', 'Archived', 'No longer active but retained for reference', false, 60),
    ('rejected', 'Rejected', 'Did not meet publication standards', false, 70)
ON CONFLICT (status_code) DO NOTHING;

-- Translations for Content Statuses
INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
VALUES 
    -- Italian translations
    ('content_statuses_master', 'draft', 'default_name', 'it', 'Bozza'),
    ('content_statuses_master', 'draft', 'default_description', 'it', 'Lavoro in corso, non pronto per la revisione'),
    ('content_statuses_master', 'ready_for_review', 'default_name', 'it', 'Pronto per Revisione'),
    ('content_statuses_master', 'ready_for_review', 'default_description', 'it', 'Completato e in attesa di revisione editoriale'),
    ('content_statuses_master', 'in_review', 'default_name', 'it', 'In Revisione'),
    ('content_statuses_master', 'in_review', 'default_description', 'it', 'Attualmente in fase di revisione da parte degli editori'),
    ('content_statuses_master', 'approved', 'default_name', 'it', 'Approvato'),
    ('content_statuses_master', 'approved', 'default_description', 'it', 'Approvato ma non ancora pubblicato'),
    ('content_statuses_master', 'published', 'default_name', 'it', 'Pubblicato'),
    ('content_statuses_master', 'published', 'default_description', 'it', 'Attivo e visibile pubblicamente'),
    ('content_statuses_master', 'archived', 'default_name', 'it', 'Archiviato'),
    ('content_statuses_master', 'archived', 'default_description', 'it', 'Non più attivo ma conservato per riferimento'),
    ('content_statuses_master', 'rejected', 'default_name', 'it', 'Rifiutato'),
    ('content_statuses_master', 'rejected', 'default_description', 'it', 'Non ha soddisfatto gli standard di pubblicazione'),
    
    -- German translations
    ('content_statuses_master', 'draft', 'default_name', 'de', 'Entwurf'),
    ('content_statuses_master', 'draft', 'default_description', 'de', 'In Bearbeitung, noch nicht zur Überprüfung bereit'),
    ('content_statuses_master', 'ready_for_review', 'default_name', 'de', 'Bereit zur Überprüfung'),
    ('content_statuses_master', 'ready_for_review', 'default_description', 'de', 'Abgeschlossen und wartet auf redaktionelle Überprüfung'),
    ('content_statuses_master', 'in_review', 'default_name', 'de', 'In Überprüfung'),
    ('content_statuses_master', 'in_review', 'default_description', 'de', 'Wird derzeit von Redakteuren überprüft'),
    ('content_statuses_master', 'approved', 'default_name', 'de', 'Genehmigt'),
    ('content_statuses_master', 'approved', 'default_description', 'de', 'Genehmigt, aber noch nicht veröffentlicht'),
    ('content_statuses_master', 'published', 'default_name', 'de', 'Veröffentlicht'),
    ('content_statuses_master', 'published', 'default_description', 'de', 'Live und öffentlich sichtbar'),
    ('content_statuses_master', 'archived', 'default_name', 'de', 'Archiviert'),
    ('content_statuses_master', 'archived', 'default_description', 'de', 'Nicht mehr aktiv, aber zur Referenz aufbewahrt'),
    ('content_statuses_master', 'rejected', 'default_name', 'de', 'Abgelehnt'),
    ('content_statuses_master', 'rejected', 'default_description', 'de', 'Erfüllte nicht die Veröffentlichungsstandards')
ON CONFLICT (table_identifier, row_foreign_key, column_identifier, language_code) DO NOTHING;
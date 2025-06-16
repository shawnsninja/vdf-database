-- Module 4b: Attractions
-- 002_attraction_master_seed.sql: Seed data for attraction master tables
-- 
-- Purpose: Insert standard master data for attractions

-- Insert attraction types
INSERT INTO public.attraction_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    sort_order
) VALUES 
    ('historical_site', 'Historical Site', 'Locations of historical significance, including ancient ruins, archaeological sites, and historical landmarks.', 'castle', 10),
    ('museum', 'Museum', 'Museums showcasing art, history, culture, or specialized collections.', 'bank', 20),
    ('church_cathedral', 'Church/Cathedral', 'Religious buildings including churches, cathedrals, basilicas, and chapels.', 'church', 30),
    ('monastery_convent', 'Monastery/Convent', 'Religious communities and their buildings, often with historical significance.', 'home-group', 40),
    ('shrine_sanctuary', 'Shrine/Sanctuary', 'Sacred sites, shrines, and religious sanctuaries.', 'star', 50),
    ('cultural_center', 'Cultural Center', 'Centers for cultural activities, exhibitions, and community events.', 'theater-masks', 60),
    ('viewpoint_scenic', 'Viewpoint/Scenic Spot', 'Locations offering scenic views, panoramas, or photographic opportunities.', 'mountain', 70),
    ('natural_feature', 'Natural Feature', 'Natural attractions such as waterfalls, caves, unique rock formations.', 'tree', 80),
    ('park_garden', 'Park/Garden', 'Public parks, botanical gardens, and landscaped areas.', 'flower', 90),
    ('archaeological_site', 'Archaeological Site', 'Sites with archaeological significance and excavations.', 'hammer', 100),
    ('monument_memorial', 'Monument/Memorial', 'Monuments, memorials, and commemorative structures.', 'award', 110),
    ('artisan_workshop', 'Artisan Workshop', 'Traditional craft workshops and artisan demonstrations.', 'tools', 120),
    ('market_square', 'Market Square', 'Historic market squares and town centers with cultural significance.', 'store', 130),
    ('pilgrimage_site', 'Pilgrimage Site', 'Locations specifically significant to pilgrimage traditions.', 'route', 140),
    ('educational_center', 'Educational Center', 'Centers for education, interpretation, and learning about local heritage.', 'school', 150)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert visitor amenities
INSERT INTO public.visitor_amenities_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    category,
    sort_order
) VALUES 
    -- Facilities (category: facilities)
    ('restrooms', 'Restrooms/Toilets', 'Public restroom facilities available for visitors.', 'toilet', 'facilities', 10),
    ('parking', 'Parking Available', 'Parking spaces available for visitors.', 'parking', 'facilities', 20),
    ('visitor_center', 'Visitor Center', 'Information center with exhibits and staff assistance.', 'information', 'facilities', 30),
    ('gift_shop', 'Gift Shop', 'Shop selling souvenirs and local products.', 'shopping-bag', 'facilities', 40),
    ('cafe_restaurant', 'Café/Restaurant', 'Food and beverage services on-site.', 'utensils', 'facilities', 50),
    ('picnic_area', 'Picnic Area', 'Designated areas for picnicking and outdoor dining.', 'table', 'facilities', 60),
    ('benches_seating', 'Benches/Seating', 'Seating areas for rest and contemplation.', 'chair', 'facilities', 70),
    
    -- Services (category: services)
    ('guided_tours', 'Guided Tours', 'Professional guided tour services available.', 'users', 'services', 10),
    ('audio_guides', 'Audio Guides', 'Self-guided audio tour equipment available.', 'headphones', 'services', 20),
    ('information_desk', 'Information Desk', 'Staffed information desk for visitor assistance.', 'help-circle', 'services', 30),
    ('luggage_storage', 'Luggage Storage', 'Temporary storage for visitor luggage and bags.', 'briefcase', 'services', 40),
    ('photography_allowed', 'Photography Allowed', 'Photography permitted in designated areas.', 'camera', 'services', 50),
    ('free_entry', 'Free Entry', 'No admission fee required.', 'gift', 'services', 60),
    ('paid_entry', 'Paid Entry', 'Admission fee required for entry.', 'credit-card', 'services', 70),
    
    -- Accessibility (category: accessibility)
    ('wheelchair_accessible', 'Wheelchair Accessible', 'Fully accessible for wheelchair users.', 'wheelchair', 'accessibility', 10),
    ('accessible_restrooms', 'Accessible Restrooms', 'Restroom facilities designed for accessibility.', 'toilet-accessibility', 'accessibility', 20),
    ('elevator_access', 'Elevator Access', 'Elevator available for multi-level access.', 'elevator', 'accessibility', 30),
    ('ramp_access', 'Ramp Access', 'Wheelchair ramps available for entry.', 'ramp-wheelchair', 'accessibility', 40),
    ('large_print_guides', 'Large Print Guides', 'Large print materials available for visually impaired visitors.', 'text-size', 'accessibility', 50),
    
    -- Educational (category: educational)
    ('interpretive_displays', 'Interpretive Displays', 'Educational displays and exhibits about the site.', 'presentation', 'educational', 10),
    ('historical_information', 'Historical Information', 'Detailed historical information and context provided.', 'book-open', 'educational', 20),
    ('multilingual_info', 'Multilingual Information', 'Information available in multiple languages.', 'globe', 'educational', 30),
    ('educational_programs', 'Educational Programs', 'Special educational programs and workshops.', 'graduation-cap', 'educational', 40),
    ('library_archive', 'Library/Archive', 'Research library or archive access available.', 'book', 'educational', 50),
    
    -- Spiritual (category: spiritual)
    ('prayer_meditation', 'Prayer/Meditation Space', 'Designated areas for prayer and meditation.', 'lotus', 'spiritual', 10),
    ('religious_services', 'Religious Services', 'Regular religious services and ceremonies.', 'church', 'spiritual', 20),
    ('confession_available', 'Confession Available', 'Sacrament of confession available for Catholics.', 'shield-check', 'spiritual', 30),
    ('spiritual_guidance', 'Spiritual Guidance', 'Spiritual counseling and guidance available.', 'heart-handshake', 'spiritual', 40),
    ('pilgrimage_blessing', 'Pilgrimage Blessing', 'Special blessings available for pilgrims.', 'sparkles', 'spiritual', 50),
    
    -- Convenience (category: convenience)
    ('wifi_available', 'Wi-Fi Available', 'Wireless internet access provided.', 'wifi', 'convenience', 10),
    ('water_fountain', 'Water Fountain', 'Drinking water fountain or tap available.', 'droplet', 'convenience', 20),
    ('atm_available', 'ATM Available', 'Automated teller machine on-site or nearby.', 'credit-card', 'convenience', 30),
    ('first_aid', 'First Aid Available', 'Basic medical supplies and assistance available.', 'medical-bag', 'convenience', 40),
    ('baby_changing', 'Baby Changing Facilities', 'Changing facilities available for infants.', 'baby', 'convenience', 50)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    category = EXCLUDED.category,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert religious service types
INSERT INTO public.religious_service_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    sort_order
) VALUES 
    ('daily_mass', 'Daily Mass', 'Regular daily Mass services.', 'church', 10),
    ('sunday_mass', 'Sunday Mass', 'Sunday Mass services.', 'calendar-days', 20),
    ('evening_prayer', 'Evening Prayer', 'Vespers and evening prayer services.', 'moon', 30),
    ('morning_prayer', 'Morning Prayer', 'Lauds and morning prayer services.', 'sun', 40),
    ('confession', 'Confession', 'Sacrament of confession available.', 'shield-check', 50),
    ('adoration', 'Eucharistic Adoration', 'Periods of Eucharistic adoration.', 'star', 60),
    ('novena', 'Novena', 'Nine-day prayer devotions.', 'calendar', 70),
    ('rosary', 'Rosary', 'Group rosary prayer services.', 'circle-dot', 80),
    ('stations_cross', 'Stations of the Cross', 'Way of the Cross devotion.', 'route', 90),
    ('pilgrimage_mass', 'Pilgrimage Mass', 'Special Mass services for pilgrims.', 'users', 100),
    ('feast_celebrations', 'Feast Day Celebrations', 'Special celebrations for religious feast days.', 'calendar-star', 110),
    ('weddings', 'Wedding Ceremonies', 'Wedding ceremonies performed at the site.', 'heart', 120),
    ('baptisms', 'Baptism Services', 'Baptism ceremonies available.', 'droplet', 130),
    ('funerals', 'Funeral Services', 'Funeral and memorial services.', 'flower', 140)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert food water source types
INSERT INTO public.food_water_source_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    is_commercial,
    sort_order
) VALUES 
    ('drinking_fountain', 'Drinking Fountain', 'Public drinking water fountain.', 'droplet', false, 10),
    ('water_tap', 'Water Tap', 'Water tap or spigot for filling bottles.', 'faucet', false, 20),
    ('natural_spring', 'Natural Spring', 'Natural spring water source.', 'mountain', false, 30),
    ('well_water', 'Well Water', 'Traditional well or pump water source.', 'circle', false, 40),
    ('cafe_restaurant', 'Café/Restaurant', 'Commercial food and beverage establishment.', 'utensils', true, 50),
    ('snack_bar', 'Snack Bar', 'Light refreshments and snacks available.', 'cookie', true, 60),
    ('vending_machine', 'Vending Machine', 'Automated food and beverage dispensers.', 'box', true, 70),
    ('grocery_store', 'Grocery Store', 'Store selling food supplies and provisions.', 'shopping-cart', true, 80),
    ('bakery', 'Bakery', 'Fresh baked goods and bread available.', 'croissant', true, 90),
    ('market_stall', 'Market Stall', 'Local market stalls selling fresh produce.', 'store', true, 100),
    ('food_truck', 'Food Truck', 'Mobile food vendor.', 'truck', true, 110),
    ('monastery_kitchen', 'Monastery Kitchen', 'Meals provided by religious communities.', 'home-group', false, 120)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    is_commercial = EXCLUDED.is_commercial,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert water reliability types
INSERT INTO public.water_reliability_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    advisory_level,
    sort_order
) VALUES 
    ('always_available', 'Always Available', 'Water source is consistently available year-round.', 'check-circle', 'safe', 10),
    ('usually_available', 'Usually Available', 'Water source is available most of the time with rare interruptions.', 'check', 'safe', 20),
    ('seasonal_available', 'Seasonally Available', 'Water source availability varies by season.', 'calendar', 'caution', 30),
    ('intermittent', 'Intermittent', 'Water source availability is unpredictable or irregular.', 'clock', 'caution', 40),
    ('dry_periods', 'May Be Dry', 'Water source may be dry during certain periods.', 'alert-triangle', 'warning', 50),
    ('unreliable', 'Unreliable', 'Water source is frequently unavailable or unreliable.', 'x-circle', 'warning', 60),
    ('treat_before_use', 'Treat Before Use', 'Water should be treated or purified before consumption.', 'filter', 'caution', 70),
    ('not_potable', 'Not for Drinking', 'Water source is not suitable for human consumption.', 'x-octagon', 'danger', 80)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    advisory_level = EXCLUDED.advisory_level,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert shop service types
INSERT INTO public.shop_service_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    category,
    sort_order
) VALUES 
    -- Food & Beverage (category: food_beverage)
    ('restaurant', 'Restaurant', 'Full-service restaurant.', 'utensils', 'food_beverage', 10),
    ('cafe_bar', 'Café/Bar', 'Café or bar serving beverages and light meals.', 'coffee', 'food_beverage', 20),
    ('pizzeria', 'Pizzeria', 'Restaurant specializing in pizza.', 'pizza', 'food_beverage', 30),
    ('gelato_shop', 'Gelato Shop', 'Ice cream and gelato shop.', 'ice-cream', 'food_beverage', 40),
    ('bakery', 'Bakery', 'Fresh baked goods and bread.', 'croissant', 'food_beverage', 50),
    ('grocery_store', 'Grocery Store', 'General grocery and food supplies.', 'shopping-cart', 'food_beverage', 60),
    ('specialty_food', 'Specialty Food Shop', 'Local specialties and gourmet foods.', 'store', 'food_beverage', 70),
    
    -- Retail (category: retail)
    ('souvenir_shop', 'Souvenir Shop', 'Tourist souvenirs and gifts.', 'shopping-bag', 'retail', 10),
    ('bookstore', 'Bookstore', 'Books, maps, and printed materials.', 'book', 'retail', 20),
    ('clothing_store', 'Clothing Store', 'Clothing and apparel.', 'shirt', 'retail', 30),
    ('outdoor_gear', 'Outdoor Gear Shop', 'Hiking and outdoor equipment.', 'backpack', 'retail', 40),
    ('religious_articles', 'Religious Articles', 'Religious items and devotional objects.', 'cross', 'retail', 50),
    ('local_crafts', 'Local Crafts', 'Handmade local crafts and artisan products.', 'palette', 'retail', 60),
    ('antique_shop', 'Antique Shop', 'Antiques and vintage items.', 'clock', 'retail', 70),
    
    -- Services (category: services)
    ('bank_atm', 'Bank/ATM', 'Banking services and automated teller machines.', 'credit-card', 'services', 10),
    ('post_office', 'Post Office', 'Postal services and mail.', 'mail', 'services', 20),
    ('internet_cafe', 'Internet Café', 'Internet access and computer services.', 'wifi', 'services', 30),
    ('laundry_service', 'Laundry Service', 'Washing and cleaning services.', 'washing-machine', 'services', 40),
    ('tourist_information', 'Tourist Information', 'Tourist information and assistance.', 'help-circle', 'services', 50),
    ('currency_exchange', 'Currency Exchange', 'Money exchange services.', 'arrow-left-right', 'services', 60),
    
    -- Pilgrim Specific (category: pilgrim_specific)
    ('credential_stamping', 'Credential Stamping', 'Official pilgrim credential stamping service.', 'stamp', 'pilgrim_specific', 10),
    ('luggage_transport', 'Luggage Transport', 'Luggage forwarding and transport services.', 'truck-delivery', 'pilgrim_specific', 20),
    ('pilgrim_supplies', 'Pilgrim Supplies', 'Equipment and supplies specifically for pilgrims.', 'hiking', 'pilgrim_specific', 30),
    ('walking_gear_repair', 'Walking Gear Repair', 'Repair services for hiking equipment.', 'tools', 'pilgrim_specific', 40),
    
    -- Healthcare (category: healthcare)
    ('pharmacy', 'Pharmacy', 'Pharmaceutical supplies and medications.', 'pill', 'healthcare', 10),
    ('medical_clinic', 'Medical Clinic', 'Basic medical services and consultation.', 'stethoscope', 'healthcare', 20),
    ('physiotherapy', 'Physiotherapy', 'Physical therapy and rehabilitation services.', 'activity', 'healthcare', 30),
    ('massage_therapy', 'Massage Therapy', 'Therapeutic massage services.', 'hand', 'healthcare', 40),
    
    -- Emergency (category: emergency)
    ('police_station', 'Police Station', 'Law enforcement services.', 'shield', 'emergency', 10),
    ('fire_station', 'Fire Station', 'Fire and emergency services.', 'flame', 'emergency', 20),
    ('hospital', 'Hospital', 'Full hospital and emergency medical services.', 'hospital', 'emergency', 30),
    ('emergency_phone', 'Emergency Phone', 'Emergency communication services.', 'phone', 'emergency', 40)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    category = EXCLUDED.category,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Verify all seed data insertion
DO $$
DECLARE
    attraction_types_count INTEGER;
    visitor_amenities_count INTEGER;
    religious_services_count INTEGER;
    food_water_sources_count INTEGER;
    water_reliability_count INTEGER;
    shop_services_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO attraction_types_count FROM public.attraction_types_master;
    SELECT COUNT(*) INTO visitor_amenities_count FROM public.visitor_amenities_master;
    SELECT COUNT(*) INTO religious_services_count FROM public.religious_service_types_master;
    SELECT COUNT(*) INTO food_water_sources_count FROM public.food_water_source_types_master;
    SELECT COUNT(*) INTO water_reliability_count FROM public.water_reliability_types_master;
    SELECT COUNT(*) INTO shop_services_count FROM public.shop_service_types_master;
    
    RAISE NOTICE 'Seed data inserted successfully:';
    RAISE NOTICE '- Attraction Types: %', attraction_types_count;
    RAISE NOTICE '- Visitor Amenities: %', visitor_amenities_count;
    RAISE NOTICE '- Religious Service Types: %', religious_services_count;
    RAISE NOTICE '- Food/Water Source Types: %', food_water_sources_count;
    RAISE NOTICE '- Water Reliability Types: %', water_reliability_count;
    RAISE NOTICE '- Shop/Service Types: %', shop_services_count;
    
    ASSERT attraction_types_count >= 15, 'Should have at least 15 attraction types';
    ASSERT visitor_amenities_count >= 30, 'Should have at least 30 visitor amenities';
    ASSERT religious_services_count >= 14, 'Should have at least 14 religious service types';
    ASSERT food_water_sources_count >= 12, 'Should have at least 12 food/water source types';
    ASSERT water_reliability_count >= 8, 'Should have at least 8 water reliability types';
    ASSERT shop_services_count >= 30, 'Should have at least 30 shop/service types';
END $$;
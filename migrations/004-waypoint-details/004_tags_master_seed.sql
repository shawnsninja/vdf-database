-- Module 4: Waypoint Details
-- 004_tags_master_seed.sql: Initial tag definitions
-- 
-- Purpose: Seed essential tags for waypoint classification

-- Insert initial tags organized by type
INSERT INTO public.tags_master (
    tag_code,
    label,
    description,
    tag_type,
    icon_identifier,
    sort_order,
    is_active
) VALUES 
    -- Franciscan/Spiritual tags
    ('franciscan_site', 'Franciscan Site', 'Location directly related to St. Francis or Franciscan history', 'spiritual', 'mdi-cross', 10, true),
    ('pilgrimage_highlight', 'Pilgrimage Highlight', 'Key location of special significance to pilgrims', 'spiritual', 'mdi-star', 20, true),
    ('meditation_spot', 'Meditation Spot', 'Quiet place suitable for reflection and prayer', 'spiritual', 'mdi-meditation', 30, true),
    ('saint_connection', 'Saint Connection', 'Associated with saints other than St. Francis', 'spiritual', 'mdi-account-heart', 40, true),
    
    -- Accessibility tags
    ('wheelchair_accessible', 'Wheelchair Accessible', 'Fully accessible for wheelchair users', 'accessibility', 'mdi-wheelchair-accessibility', 50, true),
    ('limited_mobility_friendly', 'Limited Mobility Friendly', 'Suitable for those with walking difficulties', 'accessibility', 'mdi-human-walker', 60, true),
    ('visual_impairment_support', 'Visual Impairment Support', 'Has features to assist visually impaired visitors', 'accessibility', 'mdi-eye-off', 70, true),
    ('hearing_impairment_support', 'Hearing Impairment Support', 'Has features to assist hearing impaired visitors', 'accessibility', 'mdi-ear-hearing-off', 80, true),
    
    -- Pilgrim amenities
    ('pilgrim_menu', 'Pilgrim Menu Available', 'Offers special menu for pilgrims', 'amenity', 'mdi-silverware-fork-knife', 90, true),
    ('pilgrim_discount', 'Pilgrim Discount', 'Offers discounts to pilgrims with credentials', 'amenity', 'mdi-percent', 100, true),
    ('credential_stamping', 'Credential Stamping', 'Provides stamps for pilgrim credentials', 'amenity', 'mdi-stamp', 110, true),
    ('luggage_transfer', 'Luggage Transfer', 'Offers luggage transfer services', 'amenity', 'mdi-bag-suitcase', 120, true),
    ('laundry_service', 'Laundry Service', 'Provides laundry facilities or service', 'amenity', 'mdi-washing-machine', 130, true),
    ('bike_storage', 'Bike Storage', 'Secure storage available for bicycles', 'amenity', 'mdi-bike', 140, true),
    
    -- Trail features
    ('water_refill', 'Water Refill', 'Public fountain or tap for water bottles', 'trail_feature', 'mdi-water', 150, true),
    ('shelter_available', 'Shelter Available', 'Weather protection or emergency shelter', 'trail_feature', 'mdi-home-variant', 160, true),
    ('scenic_viewpoint', 'Scenic Viewpoint', 'Notable views or photo opportunities', 'trail_feature', 'mdi-camera', 170, true),
    ('rest_benches', 'Rest Benches', 'Benches or seating areas available', 'trail_feature', 'mdi-bench', 180, true),
    ('trail_information', 'Trail Information', 'Maps, signs, or trail information available', 'trail_feature', 'mdi-information', 190, true),
    
    -- Services
    ('wifi_available', 'WiFi Available', 'Free or paid WiFi internet access', 'service', 'mdi-wifi', 200, true),
    ('parking_available', 'Parking Available', 'Car parking facilities', 'service', 'mdi-parking', 210, true),
    ('restrooms', 'Restrooms', 'Public toilets available', 'service', 'mdi-human-male-female', 220, true),
    ('atm_cash', 'ATM/Cash', 'ATM or cash withdrawal services', 'service', 'mdi-cash', 230, true),
    ('medical_services', 'Medical Services', 'First aid, pharmacy, or medical assistance', 'service', 'mdi-medical-bag', 240, true),
    
    -- Accommodation features
    ('shared_kitchen', 'Shared Kitchen', 'Kitchen facilities for guest use', 'accommodation', 'mdi-chef-hat', 250, true),
    ('private_bathroom', 'Private Bathroom', 'Rooms with private bathroom facilities', 'accommodation', 'mdi-shower', 260, true),
    ('air_conditioning', 'Air Conditioning', 'Climate controlled rooms', 'accommodation', 'mdi-air-conditioner', 270, true),
    ('breakfast_included', 'Breakfast Included', 'Breakfast meal included in price', 'accommodation', 'mdi-coffee', 280, true),
    ('pet_friendly', 'Pet Friendly', 'Pets welcome with advance notice', 'accommodation', 'mdi-dog', 290, true),
    
    -- Dietary options
    ('vegetarian_options', 'Vegetarian Options', 'Vegetarian meals available', 'dietary', 'mdi-leaf', 300, true),
    ('vegan_options', 'Vegan Options', 'Vegan meals available', 'dietary', 'mdi-seed', 310, true),
    ('gluten_free', 'Gluten Free', 'Gluten-free options available', 'dietary', 'mdi-barley-off', 320, true),
    ('halal_food', 'Halal Food', 'Halal food preparation and options', 'dietary', 'mdi-food-halal', 330, true),
    ('kosher_food', 'Kosher Food', 'Kosher food preparation and options', 'dietary', 'mdi-food-kosher', 340, true),
    
    -- Seasonal tags
    ('seasonal_closure', 'Seasonal Closure', 'Closed during certain seasons', 'seasonal', 'mdi-calendar-remove', 350, true),
    ('summer_only', 'Summer Only', 'Only open during summer months', 'seasonal', 'mdi-weather-sunny', 360, true),
    ('winter_closure', 'Winter Closure', 'Closed during winter months', 'seasonal', 'mdi-snowflake', 370, true),
    ('reservation_required', 'Reservation Required', 'Advance booking necessary', 'booking', 'mdi-calendar-check', 380, true),
    
    -- Emergency/Safety
    ('emergency_phone', 'Emergency Phone', 'Emergency communication available', 'safety', 'mdi-phone-alert', 390, true),
    ('first_aid_station', 'First Aid Station', 'First aid supplies or trained personnel', 'safety', 'mdi-bandage', 400, true),
    ('caution_required', 'Caution Required', 'Extra care needed due to conditions', 'safety', 'mdi-alert-triangle', 410, true)
ON CONFLICT (tag_code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    tag_type = EXCLUDED.tag_type,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();
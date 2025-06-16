-- Module 4: Waypoint Details
-- 002_waypoint_categories_master_seed.sql: Initial waypoint categories
-- 
-- Purpose: Seed essential waypoint categories for the pilgrimage platform

-- Insert initial waypoint categories
INSERT INTO public.waypoint_categories_master (
    code,
    label,
    description,
    icon_identifier,
    requires_detail_table,
    sort_order,
    is_active
) VALUES 
    -- Core POI categories
    ('accommodation_location', 'Accommodation', 'Places to stay including hotels, hostels, B&Bs, and pilgrim-specific lodging', 'mdi-bed', 'accommodations', 10, true),
    ('attraction', 'Attraction', 'Points of interest including monuments, viewpoints, and cultural sites', 'mdi-castle', 'attractions_details', 20, true),
    ('religious_site', 'Religious Site', 'Churches, monasteries, shrines, and other religious locations', 'mdi-church', 'attractions_details', 30, true),
    ('food_water_source', 'Food & Water', 'Restaurants, cafes, fountains, and other sustenance locations', 'mdi-food-fork-drink', 'food_water_sources_details', 40, true),
    ('shop_service', 'Shop & Service', 'Stores, pharmacies, banks, and other services', 'mdi-store', 'shops_and_services_details', 50, true),
    ('transport_stop', 'Transport Stop', 'Bus stops, train stations, and other public transport locations', 'mdi-bus', 'transport_stops_details', 60, true),
    ('event_location', 'Event Location', 'Venues for pilgrim events, festivals, and gatherings', 'mdi-calendar-star', 'events_details', 70, true),
    
    -- Navigation and trail-specific
    ('trail_access_point', 'Trail Access Point', 'Official starting points or major access points to the trail', 'mdi-hiking', NULL, 80, true),
    ('trail_junction', 'Trail Junction', 'Significant trail intersections and decision points', 'mdi-sign-direction', NULL, 90, true),
    ('segment_delimiter', 'Segment Delimiter', 'Technical waypoints marking segment boundaries', 'mdi-map-marker-path', NULL, 100, true),
    
    -- Emergency and support
    ('emergency_service', 'Emergency Service', 'Hospitals, medical centers, and emergency facilities', 'mdi-hospital-box', NULL, 110, true),
    ('pilgrim_support', 'Pilgrim Support', 'Information centers, credential offices, and pilgrim-specific services', 'mdi-information', NULL, 120, true),
    
    -- Natural features
    ('natural_feature', 'Natural Feature', 'Notable natural landmarks, viewpoints, and geographical features', 'mdi-nature', NULL, 130, true),
    ('rest_area', 'Rest Area', 'Designated rest spots, picnic areas, and shelters', 'mdi-bench', NULL, 140, true),
    
    -- Hazards and warnings
    ('hazard_point', 'Hazard Point', 'Locations requiring special caution or awareness', 'mdi-alert', NULL, 150, true)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    requires_detail_table = EXCLUDED.requires_detail_table,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();
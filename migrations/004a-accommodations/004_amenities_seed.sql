-- Module 4a: Accommodations
-- 004_amenities_seed.sql: Seed data for amenities
-- 
-- Purpose: Insert standard amenities available at accommodations

-- Insert amenities organized by category
INSERT INTO public.amenities_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    category,
    sort_order
) VALUES 
    -- Basic amenities (category: basic)
    ('private_bathroom', 'Private Bathroom', 'En-suite bathroom facilities for exclusive use.', 'shower', 'basic', 10),
    ('shared_bathroom', 'Shared Bathroom', 'Bathroom facilities shared with other guests.', 'shower-head', 'basic', 20),
    ('hot_water', 'Hot Water', 'Reliable hot water availability.', 'thermometer-warm', 'basic', 30),
    ('heating', 'Heating', 'Climate control for colder weather.', 'radiator', 'basic', 40),
    ('air_conditioning', 'Air Conditioning', 'Climate control for warmer weather.', 'snowflake', 'basic', 50),
    ('towels_provided', 'Towels Provided', 'Clean towels supplied for guests.', 'hand-paper', 'basic', 60),
    ('bed_linens', 'Bed Linens', 'Clean sheets and pillowcases provided.', 'bed', 'basic', 70),
    
    -- Comfort amenities (category: comfort)
    ('private_room', 'Private Room', 'Individual room for exclusive use.', 'door-closed', 'comfort', 10),
    ('shared_dormitory', 'Shared Dormitory', 'Dormitory-style accommodation with multiple beds.', 'bed-bunk', 'comfort', 20),
    ('reading_light', 'Reading Light', 'Individual lighting for each bed or room.', 'lamp', 'comfort', 30),
    ('storage_locker', 'Storage Locker', 'Secure storage for personal belongings.', 'locker', 'comfort', 40),
    ('common_area', 'Common Area', 'Shared social space for guests.', 'sofa', 'comfort', 50),
    ('garden_outdoor_space', 'Garden/Outdoor Space', 'Outdoor areas for relaxation.', 'tree', 'comfort', 60),
    
    -- Technology amenities (category: technology)
    ('wifi_free', 'Free Wi-Fi', 'Complimentary wireless internet access.', 'wifi', 'technology', 10),
    ('wifi_paid', 'Paid Wi-Fi', 'Wireless internet access for a fee.', 'wifi-strength-1', 'technology', 20),
    ('computer_internet', 'Computer/Internet Access', 'Shared computer or internet terminal.', 'desktop-computer', 'technology', 30),
    ('tv_common_area', 'TV in Common Area', 'Television in shared spaces.', 'television', 'technology', 40),
    ('tv_room', 'TV in Room', 'Television in individual rooms.', 'television-simple', 'technology', 50),
    
    -- Food service amenities (category: food_service)
    ('kitchen_access', 'Kitchen Access', 'Shared kitchen facilities for meal preparation.', 'chef-hat', 'food_service', 10),
    ('kitchenette', 'Kitchenette', 'Basic cooking facilities in room.', 'stove', 'food_service', 20),
    ('refrigerator', 'Refrigerator', 'Food storage facilities.', 'fridge', 'food_service', 30),
    ('microwave', 'Microwave', 'Microwave oven access.', 'microwave', 'food_service', 40),
    ('breakfast_included', 'Breakfast Included', 'Complimentary breakfast service.', 'coffee', 'food_service', 50),
    ('meals_available', 'Meals Available', 'Other meals available for purchase.', 'cutlery', 'food_service', 60),
    ('dining_area', 'Dining Area', 'Designated space for eating meals.', 'silverware', 'food_service', 70),
    
    -- Accessibility amenities (category: accessibility)
    ('wheelchair_accessible', 'Wheelchair Accessible', 'Fully accessible for wheelchair users.', 'wheelchair', 'accessibility', 10),
    ('accessible_bathroom', 'Accessible Bathroom', 'Bathroom facilities designed for accessibility.', 'shower-accessibility', 'accessibility', 20),
    ('elevator_access', 'Elevator Access', 'Elevator available for upper floors.', 'elevator', 'accessibility', 30),
    ('ramp_access', 'Ramp Access', 'Wheelchair ramp available for entry.', 'ramp-wheelchair', 'accessibility', 40),
    
    -- Pilgrim-specific amenities (category: pilgrim_specific)
    ('credential_stamping', 'Credential Stamping', 'Official pilgrim credential stamping service.', 'stamp', 'pilgrim_specific', 10),
    ('laundry_facilities', 'Laundry Facilities', 'Washing machines or laundry service available.', 'washing-machine', 'pilgrim_specific', 20),
    ('drying_area', 'Drying Area', 'Dedicated space for drying clothes and equipment.', 'tshirt', 'pilgrim_specific', 30),
    ('luggage_storage', 'Luggage Storage', 'Secure storage for luggage and backpacks.', 'briefcase', 'pilgrim_specific', 40),
    ('luggage_transfer', 'Luggage Transfer Service', 'Service to transport luggage to next accommodation.', 'truck-delivery', 'pilgrim_specific', 50),
    ('walking_equipment', 'Walking Equipment Available', 'Walking poles, rain gear, or other equipment for loan.', 'hiking', 'pilgrim_specific', 60),
    ('first_aid', 'First Aid Available', 'Basic medical supplies and assistance.', 'medical-bag', 'pilgrim_specific', 70),
    
    -- Outdoor amenities (category: outdoor)
    ('parking_free', 'Free Parking', 'Complimentary parking facilities.', 'parking', 'outdoor', 10),
    ('parking_paid', 'Paid Parking', 'Parking available for a fee.', 'parking-circle', 'outdoor', 20),
    ('bicycle_storage', 'Bicycle Storage', 'Secure storage for bicycles.', 'bicycle', 'outdoor', 30),
    ('terrace_balcony', 'Terrace/Balcony', 'Outdoor terrace or balcony access.', 'balcony', 'outdoor', 40),
    
    -- Business amenities (category: business)
    ('business_center', 'Business Center', 'Business facilities and services.', 'office-building', 'business', 10),
    ('meeting_room', 'Meeting Room', 'Space available for meetings or events.', 'presentation-chart', 'business', 20),
    ('printing_services', 'Printing Services', 'Printing and copying facilities.', 'printer', 'business', 30)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    category = EXCLUDED.category,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Verify insertion
DO $$
DECLARE
    amenity_count INTEGER;
    category_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO amenity_count FROM public.amenities_master;
    SELECT COUNT(DISTINCT category) INTO category_count FROM public.amenities_master;
    
    IF amenity_count < 40 THEN
        RAISE EXCEPTION 'Failed to insert amenities. Expected at least 40, got %', amenity_count;
    END IF;
    
    IF category_count < 7 THEN
        RAISE EXCEPTION 'Failed to insert amenity categories. Expected at least 7, got %', category_count;
    END IF;
    
    RAISE NOTICE 'Successfully inserted % amenities across % categories', amenity_count, category_count;
END $$;
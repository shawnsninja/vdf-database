-- Module 4a: Accommodations
-- 002_accommodation_types_seed.sql: Seed data for accommodation types
-- 
-- Purpose: Insert standard accommodation types used in the Via di Francesco

-- Insert accommodation types
INSERT INTO public.accommodation_types_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    sort_order
) VALUES 
    ('pilgrim_hostel', 'Pilgrim Hostel', 'Budget accommodation specifically for pilgrims, typically dormitory-style with shared facilities.', 'bed-bunk', 10),
    ('bed_breakfast', 'Bed & Breakfast', 'Family-run accommodations offering private rooms with breakfast included.', 'home-heart', 20),
    ('guesthouse', 'Guesthouse', 'Small commercial accommodations, typically family-operated with personal service.', 'home', 30),
    ('hotel', 'Hotel', 'Commercial hotels with standardized services and amenities.', 'building', 40),
    ('agriturismo', 'Agriturismo', 'Farm-based accommodations offering rural experiences and local food.', 'barn', 50),
    ('monastery_convent', 'Monastery/Convent', 'Religious accommodations offering simple lodging in spiritual settings.', 'church', 60),
    ('camping', 'Camping', 'Campgrounds and camping areas for tent or RV accommodation.', 'tent', 70),
    ('apartment_rental', 'Apartment Rental', 'Self-contained apartments available for short-term rental.', 'home-modern', 80),
    ('hostel_general', 'Hostel (General)', 'General hostels not specifically oriented toward pilgrims.', 'bed', 90),
    ('private_home', 'Private Home', 'Private residences offering accommodation to pilgrims.', 'home-circle', 100),
    ('refuge_hut', 'Mountain Refuge/Hut', 'Mountain huts and refuges in remote areas, typically basic accommodation.', 'home-mountain', 110),
    ('emergency_shelter', 'Emergency Shelter', 'Basic emergency accommodations for adverse conditions.', 'shield-home', 120)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Verify insertion
DO $$
DECLARE
    accommodation_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO accommodation_count FROM public.accommodation_types_master;
    
    IF accommodation_count < 12 THEN
        RAISE EXCEPTION 'Failed to insert accommodation types. Expected at least 12, got %', accommodation_count;
    END IF;
    
    RAISE NOTICE 'Successfully inserted % accommodation types', accommodation_count;
END $$;
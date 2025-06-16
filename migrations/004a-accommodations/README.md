# Module 4a: Accommodations

## Overview
This module implements comprehensive accommodation management for the VDF database, extending the core waypoints system with detailed lodging information, amenities, room configurations, and booking management.

## Tables Created

### Master Tables
1. **accommodation_types_master** - Types of accommodations (pilgrim hostels, B&Bs, etc.)
2. **amenities_master** - Available amenities with categories (basic, comfort, technology, etc.)
3. **booking_statuses_master** - Booking availability statuses
4. **room_types_master** - Room configurations and types
5. **payment_methods_master** - Accepted payment methods
6. **meal_services_master** - Available meal services
7. **establishment_price_ranges_master** - Price range categories

### Core Tables
8. **accommodations** - Main accommodation details (1:1 extension of waypoints)

### Junction Tables
9. **accommodation_amenities** - Links accommodations to amenities
10. **accommodation_room_configurations** - Room types and configurations per accommodation
11. **accommodation_payment_methods** - Payment methods accepted per accommodation
12. **accommodation_meal_services** - Meal services available per accommodation

### Views
13. **v_accommodation_types_localized** - Accommodation types with translations
14. **v_amenities_localized** - Amenities with translations grouped by category
15. **v_booking_statuses_localized** - Booking statuses with translations
16. **v_accommodations_enriched** - Comprehensive accommodation view with all related data

## Migration Order
Run migrations in this order:
```bash
001_accommodation_types_master.sql
002_accommodation_types_seed.sql
003_amenities_master.sql
004_amenities_seed.sql
005_booking_statuses_master.sql
006_other_master_tables.sql
007_accommodations_table.sql
008_accommodation_junction_tables.sql
009_accommodation_views.sql
```

## Key Features

### Comprehensive Accommodation Management
- **12 accommodation types**: Pilgrim hostels, B&Bs, hotels, agriturismi, monasteries, etc.
- **40+ amenities** organized in 8 categories: basic, comfort, technology, food_service, accessibility, pilgrim_specific, outdoor, business
- **Rich pricing system**: Price ranges, per-night pricing, pilgrim discounts
- **Detailed capacity tracking**: Total beds, rooms, pilgrim-specific beds
- **Seasonal operation support**: Open/close dates for seasonal accommodations
- **Host information**: Contact details, languages spoken, website links

### Advanced Room Management
- **Flexible room configurations**: Mixed/gender dormitories, private rooms, family rooms, camping
- **Per-room pricing**: Individual pricing for different room types
- **Occupancy tracking**: Beds per room, maximum occupancy, availability status
- **Room-specific notes**: Special features or restrictions per room type

### Payment & Service Integration
- **Multiple payment methods**: Cash, cards, digital payments, bank transfers
- **Meal service options**: Breakfast, dinner, half-board, full-board, kitchen access
- **Service pricing**: Individual pricing for optional services
- **Advance booking management**: Reservation policies and requirements

### Guest Experience Features
- **Pilgrim-specific services**: Credential stamping, luggage transfer, equipment loans
- **Accessibility support**: Detailed accessibility notes and features
- **Policy management**: Check-in/out times, curfew, pet policies, smoking policies
- **Multi-language support**: Host languages and full translation system

## Sample Data Included

### Accommodation Types (12 types)
- pilgrim_hostel, bed_breakfast, guesthouse, hotel
- agriturismo, monastery_convent, camping, apartment_rental
- hostel_general, private_home, refuge_hut, emergency_shelter

### Amenities (40+ types organized by category)
- **Basic**: Private/shared bathrooms, hot water, heating, A/C, towels, linens
- **Comfort**: Private rooms, dormitories, reading lights, lockers, common areas
- **Technology**: Free/paid Wi-Fi, computers, TV access
- **Food Service**: Kitchen access, kitchenette, refrigerator, meals, dining areas
- **Accessibility**: Wheelchair accessible, accessible bathrooms, elevators, ramps
- **Pilgrim-Specific**: Credential stamping, laundry, luggage storage/transfer, first aid
- **Outdoor**: Free/paid parking, bicycle storage, terraces, gardens
- **Business**: Business centers, meeting rooms, printing services

### Room Types (9 types)
- private_single, private_double, private_twin, private_family
- dorm_mixed, dorm_male, dorm_female, camping_tent, camping_cabin

### Payment Methods (8 types)
- cash_eur, visa, mastercard, american_express
- bank_transfer, paypal, contactless, check

### Meal Services (8 types)
- breakfast_included, breakfast_available, lunch_available, dinner_available
- half_board, full_board, kitchen_access, snacks_available

### Price Ranges (7 categories)
- budget (€0-25), economy (€25-50), mid_range (€50-100)
- upscale (€100-200), luxury (€200+), donation_based, free

## Dependencies
- Module 1 (User & Content Infrastructure) - required for profiles, translations, media
- Module 2 (Core Trail Hierarchy) - required for media_roles_master  
- Module 3 (Geographical Context) - required for towns table
- Module 4 (Waypoint Details Core) - required for waypoints table

## Performance Features
- **Optimized indexes**: Spatial, GIN for arrays, partial indexes for common queries
- **Localized views**: Pre-aggregated translations for API efficiency
- **Comprehensive enriched view**: Single query for all accommodation data
- **Array field indexing**: GIN indexes for language arrays and amenities

## Security
- **Row Level Security**: Comprehensive RLS policies for all user roles
- **Content visibility**: Public access limited to published accommodations
- **Role-based management**: Content creators can manage, public can read
- **Data integrity**: Foreign key constraints and check constraints

## Test Suite
Run the comprehensive test suite:
```bash
psql $DATABASE_URL -f 010_test_module_4a.sql
```

Tests cover:
- Table and view creation (16 database objects)
- Seed data validation (100+ master records)
- Full accommodation creation with all features
- Junction table relationships (amenities, rooms, payments, meals)
- RLS policy functionality
- Constraint validations (email, pricing, logical constraints)
- Translation system integration
- Localized view functionality

## Sample Queries

### Get accommodations by type with amenities
```sql
SELECT 
    name,
    accommodation_type_label,
    price_per_night_eur,
    total_beds,
    pilgrim_beds_available,
    jsonb_pretty(amenities) AS amenities_list
FROM public.v_accommodations_enriched
WHERE accommodation_type_code = 'pilgrim_hostel'
    AND booking_is_available = true
ORDER BY price_per_night_eur;
```

### Find accommodations with specific amenities
```sql
SELECT 
    ve.name,
    ve.price_per_night_eur,
    ve.host_contact_email,
    array_agg(a.label) AS amenity_labels
FROM public.v_accommodations_enriched ve,
     jsonb_to_recordset(ve.amenities) AS a(code text, label text, category text)
WHERE a.code IN ('wifi_free', 'kitchen_access', 'laundry_facilities')
GROUP BY ve.id, ve.name, ve.price_per_night_eur, ve.host_contact_email
HAVING COUNT(DISTINCT a.code) = 3;
```

### Get accommodations near a location with availability
```sql
SELECT 
    w.name,
    a.price_per_night_eur,
    a.pilgrim_beds_available,
    bs.label AS booking_status,
    ST_Distance(w.geom, ST_GeogFromText('POINT(12.6074 43.0642)')) / 1000 AS distance_km
FROM public.accommodations a
JOIN public.waypoints w ON a.id = w.id
JOIN public.booking_statuses_master bs ON a.booking_status_id = bs.id
WHERE ST_DWithin(w.geom, ST_GeogFromText('POINT(12.6074 43.0642)'), 20000) -- 20km radius
    AND bs.is_available = true
    AND a.deleted_at IS NULL
    AND w.deleted_at IS NULL
ORDER BY distance_km
LIMIT 10;
```

### Get localized accommodation types for API
```sql
SELECT 
    code,
    label,
    icon_identifier,
    COALESCE(all_translations->>'it'->>'label', label) AS label_it,
    COALESCE(all_translations->>'it'->>'description', description) AS description_it
FROM public.v_accommodation_types_localized
WHERE is_active = true
ORDER BY sort_order;
```

### Get accommodation with full details
```sql
SELECT 
    name,
    description,
    accommodation_type_label,
    booking_status_label,
    price_per_night_eur,
    host_name,
    host_contact_email,
    website_url,
    total_beds,
    pilgrim_beds_available,
    check_in_time,
    check_out_time,
    pilgrim_specific_notes,
    jsonb_pretty(amenities) AS amenities,
    jsonb_pretty(room_configurations) AS rooms,
    jsonb_pretty(payment_methods) AS payments,
    jsonb_pretty(meal_services) AS meals
FROM public.v_accommodations_enriched
WHERE slug = 'pilgrim-hostel-san-francesco-assisi';
```

## Next Steps
With Module 4a complete, you can now:
1. Import real accommodation data from official sources
2. Build accommodation search and booking APIs
3. Implement Module 4b (Attractions) for POI details
4. Add accommodation reviews and rating system
5. Create reservation management functionality

The accommodation system provides a comprehensive foundation for managing all types of lodging along the Via di Francesco pilgrimage routes.
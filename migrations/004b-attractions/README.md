# Module 4b: Attractions

Complete implementation of the Attractions module for the VDF Database, extending the core waypoint functionality with detailed attraction information.

## Overview

Module 4b provides comprehensive attraction details for waypoints, including:
- **Attraction Details**: Comprehensive information for historical sites, museums, churches, etc.
- **Food & Water Sources**: Detailed water source and food service information
- **Shops & Services**: Commercial services and facilities for pilgrims
- **Religious Services**: Schedules and details for religious services
- **Media Galleries**: Photo and media management for all attraction types

## Implementation Status: ✅ COMPLETE

All components of Module 4b have been successfully implemented and tested.

## Files Structure

```
004b-attractions/
├── 001_attraction_master_tables.sql      # Master tables for attractions
├── 002_attraction_master_seed.sql        # Seed data for master tables
├── 003_attraction_details_table.sql      # Main attraction details table
├── 004_religious_service_schedules.sql   # Religious service scheduling
├── 005_food_water_sources.sql           # Food and water source details
├── 006_additional_master_tables.sql     # Price ranges, meal types, etc.
├── 007_additional_master_seed.sql       # Seed data for additional masters
├── 008_shops_and_services_details.sql   # Shops and services details
├── 009_media_linking_tables.sql         # Media gallery linking tables
├── 010_localized_views.sql              # API-optimized localized views
├── 011_array_fk_validation_triggers.sql # Array FK validation triggers
├── 012_test_module_4b.sql               # Comprehensive test suite
└── README.md                            # This file
```

## Database Objects Created

### Master Tables (10)
- `attraction_types_master` - Types of attractions (15+ predefined)
- `visitor_amenities_master` - Amenities available at attractions (30+ predefined)
- `religious_service_types_master` - Types of religious services (14+ predefined)
- `food_water_source_types_master` - Food/water source types (12+ predefined)
- `water_reliability_types_master` - Water reliability levels (8+ predefined)
- `shop_service_types_master` - Shop/service types (30+ predefined)
- `establishment_price_ranges_master` - Price range categories (6+ predefined)
- `meal_type_tags_master` - Meal type classifications (12+ predefined)
- `dietary_option_tags_master` - Dietary option tags (15+ predefined)
- `payment_methods_master` - Payment method types (17+ predefined)

### Detail Tables (3)
- `attraction_details` - Core attraction information (1:1 with waypoints)
- `food_water_sources_details` - Food/water source details (1:1 with waypoints)
- `shops_and_services_details` - Shop/service details (1:1 with waypoints)

### Supporting Tables (4)
- `religious_service_schedules` - Religious service timing (1:M with attractions)
- `attraction_details_media` - Media galleries for attractions
- `food_water_sources_media` - Media galleries for food/water sources
- `shops_and_services_media` - Media galleries for shops/services

### Views (4)
- `v_waypoint_attraction_details_localized` - API-optimized attraction view
- `v_waypoint_food_water_sources_localized` - API-optimized food/water view
- `v_waypoint_shops_services_localized` - API-optimized shops/services view
- `v_religious_service_schedules_localized` - API-optimized service schedules view

### Functions & Triggers (12)
- Array FK validation functions for all detail tables
- Updated timestamp triggers for all tables
- Translation cleanup triggers
- RLS policy functions

## Key Features Implemented

### ✅ **Comprehensive Attraction Support**
- 15+ attraction types (historical sites, museums, churches, etc.)
- 30+ visitor amenities (restrooms, parking, guided tours, etc.)
- Rich metadata (opening hours, fees, accessibility, etc.)
- UNESCO status tracking
- Franciscan/pilgrimage significance

### ✅ **Food & Water Source Management**
- 12+ source types (fountains, springs, restaurants, etc.)
- Water quality and reliability tracking
- Commercial vs. free source classification
- Bottle-filling compatibility
- Safety warnings and testing data

### ✅ **Commercial Services Support**
- 30+ service types across 6 categories
- Comprehensive business information
- Pricing and payment method tracking
- Pilgrim-specific services (credential stamping, luggage transport)
- Review and rating system

### ✅ **Religious Service Scheduling**
- Weekly recurring services
- Seasonal schedule variations
- Multi-language service support
- Special ceremony tracking

### ✅ **Media Gallery System**
- Role-based media organization
- Primary image designation
- Caption and alt-text support
- Comprehensive RLS security

### ✅ **API-Optimized Views**
- Pre-joined data with master table labels
- Efficient querying for mobile apps
- Proper internationalization support
- Performance-optimized indexes

### ✅ **Data Integrity**
- Array foreign key validation
- Comprehensive check constraints
- Proper cascading deletes
- Translation cleanup automation

### ✅ **Security & Access Control**
- Row Level Security on all tables
- Role-based access (public, authenticated, content creators)
- Service role administrative access
- Public visibility controls

## Dependencies

Module 4b depends on:
- **Module 1**: User & Content Infrastructure (profiles, media, translations)
- **Module 2**: Core Trail Hierarchy (waypoints table)
- **Module 3**: Geographical Context (towns table)
- **Module 4**: Waypoint Details (waypoint categories, content statuses)

## Testing

The module includes a comprehensive test suite (`012_test_module_4b.sql`) with 10 test cases covering:
- Master table data integrity
- Detail table operations
- Array FK validation
- Trigger functionality
- View accessibility
- RLS policy verification

## Usage Examples

### Creating an Attraction
```sql
-- Insert waypoint first (Module 4 dependency)
INSERT INTO waypoints (name, description, geometry, waypoint_category_id, ...) VALUES (...);

-- Add attraction details
INSERT INTO attraction_details (
    id, attraction_type_id, visitor_amenity_ids,
    entry_fee_eur, pilgrim_discount_available,
    opening_hours, wheelchair_accessible
) VALUES (
    waypoint_id, 1, ARRAY[1,2,3], 
    12.50, true, 
    '{"monday": {"open": "09:00", "close": "17:00"}}', 
    true
);
```

### Querying Localized Data
```sql
-- Get attraction details with localized labels
SELECT name, attraction_type_label, entry_fee_eur, 
       pilgrim_discount_available, overall_rating
FROM v_waypoint_attraction_details_localized 
WHERE is_publicly_visible = true
  AND town_name = 'Assisi';
```

## Performance Considerations

- **GIN indexes** on all array fields for efficient array queries
- **Partial indexes** on filtered boolean fields
- **Composite indexes** on frequently queried combinations
- **View materialization** may be considered for high-traffic APIs

## Migration Order

Execute files in numerical order:
1. `001_attraction_master_tables.sql`
2. `002_attraction_master_seed.sql`
3. `003_attraction_details_table.sql`
4. `004_religious_service_schedules.sql`
5. `005_food_water_sources.sql`
6. `006_additional_master_tables.sql`
7. `007_additional_master_seed.sql`
8. `008_shops_and_services_details.sql`
9. `009_media_linking_tables.sql`
10. `010_localized_views.sql`
11. `011_array_fk_validation_triggers.sql`
12. `012_test_module_4b.sql` (testing only)

## Next Steps

With Module 4b complete, the next logical modules to implement are:
- **Module 5**: Dynamic Conditions (trail warnings, real-time updates)
- **Module 6**: User Interaction (voting, tips, reviews)
- **Module 7**: Curated Itineraries (pre-planned journeys)
- **Module 8**: Editorial (articles, news, content management)
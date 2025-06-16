# Module 4: Waypoint Details

## Overview
This module implements the comprehensive waypoint system for the VDF database, replacing the stub from Module 2 with a full-featured implementation supporting detailed POI management, categorization, tagging, and media galleries.

## Tables Created

### Master Tables
1. **waypoint_categories_master** - Broad classifications (accommodation, attraction, etc.)
2. **tags_master** - Granular descriptive tags for filtering and categorization  
3. **content_statuses_master** - Publication lifecycle management

### Core Tables
4. **waypoints** - Enhanced central waypoint repository with full features
5. **waypoint_media** - Media galleries and associations for waypoints

### Views
6. **v_waypoint_categories_localized** - Categories with aggregated translations
7. **v_tags_localized** - Tags with aggregated translations  
8. **v_content_statuses_localized** - Statuses with aggregated translations
9. **v_waypoints_enriched** - Comprehensive waypoint view with all related data

## Migration Order
Run migrations in this order:
```bash
001_waypoint_categories_master.sql
002_waypoint_categories_master_seed.sql
003_tags_master.sql
004_tags_master_seed.sql
005_content_statuses_master.sql
006_content_statuses_master_seed.sql
007_array_fk_validation_functions.sql
008_waypoints_enhanced.sql
009_waypoints_rls_policies.sql
010_waypoint_media.sql
011_localized_views.sql
```

## Key Features

### Enhanced Waypoint Management
- PostGIS 3D geometry with auto-generated lat/lon/elevation
- Rich categorization with 15+ predefined categories
- Flexible tagging system with 35+ predefined tags
- Content publication workflow with 14 status types
- Media galleries with role-based associations
- Hierarchical waypoints (parent-child relationships)
- Full translation support via Module 1 infrastructure

### Data Integrity
- Array foreign key validation for tag references
- Comprehensive constraint validation (names, slugs, scores)
- Soft deletion with audit trails
- Standardized master table patterns

### Performance Optimizations
- GIST indexes for spatial queries
- GIN indexes for array fields and text search
- Partial indexes for boolean flags
- Optimized views for API consumption

### Security
- Comprehensive RLS policies for all user roles
- Content visibility controls
- Role-based access to creation/editing
- Public access to published content only

## Sample Data Included

### Categories (15 types)
- accommodation_location, attraction, religious_site
- food_water_source, shop_service, transport_stop
- event_location, trail_access_point, trail_junction
- emergency_service, pilgrim_support, natural_feature
- rest_area, hazard_point, segment_delimiter

### Tags (35+ types organized by)
- **Spiritual**: franciscan_site, pilgrimage_highlight, meditation_spot
- **Accessibility**: wheelchair_accessible, limited_mobility_friendly
- **Amenities**: pilgrim_menu, credential_stamping, luggage_transfer
- **Services**: wifi_available, parking_available, medical_services
- **Dietary**: vegetarian_options, gluten_free, halal_food
- **Safety**: emergency_phone, first_aid_station, caution_required

### Content Statuses (14 states)
- Workflow: draft, pending_review, in_review, approved, published
- Special: featured, seasonal_inactive, maintenance, imported
- Administrative: archived, deprecated, suspended, deleted

## Dependencies
- Module 1 (User & Content Infrastructure) - required
- Module 2 (Core Trail Hierarchy) - required for media_roles_master
- Module 3 (Geographical Context) - required for towns table
- PostGIS extension for spatial features

## Test Suite
Run the comprehensive test suite:
```bash
psql $DATABASE_URL -f test_module_4.sql
```

Tests cover:
- Table and view creation
- Seed data validation
- Array FK integrity enforcement
- RLS policy functionality
- Constraint validations
- PostGIS geometry features
- Translation integration
- Media associations

## Sample Queries

### Get waypoints by category with tags
```sql
SELECT 
    w.name,
    w.latitude,
    w.longitude,
    wc.label AS category,
    jsonb_pretty(we.tags) AS tags
FROM public.v_waypoints_enriched we
JOIN public.waypoints w ON we.id = w.id
JOIN public.waypoint_categories_master wc ON w.waypoint_primary_category_id = wc.id
WHERE wc.code = 'religious_site'
    AND w.is_franciscan_highlight_site = true
    AND w.deleted_at IS NULL;
```

### Find waypoints with specific tags
```sql
SELECT 
    w.name,
    w.description,
    array_agg(tm.label) AS tag_labels
FROM public.waypoints w
JOIN public.tags_master tm ON tm.id = ANY(w.waypoint_subcategory_tag_ids)
WHERE tm.tag_code IN ('franciscan_site', 'wheelchair_accessible')
    AND w.deleted_at IS NULL
GROUP BY w.id, w.name, w.description;
```

### Get waypoints near a location with media
```sql
SELECT 
    w.name,
    w.latitude,
    w.longitude,
    ST_Distance(w.geom, ST_GeogFromText('POINT(11.9267 43.7072)')) / 1000 AS distance_km,
    we.media_count,
    we.primary_image_path
FROM public.v_waypoints_enriched we
JOIN public.waypoints w ON we.id = w.id
WHERE ST_DWithin(w.geom, ST_GeogFromText('POINT(11.9267 43.7072)'), 10000) -- 10km radius
    AND w.content_visibility_status_id IN (
        SELECT id FROM public.content_statuses_master WHERE is_publicly_visible = true
    )
    AND w.deleted_at IS NULL
ORDER BY distance_km
LIMIT 20;
```

### Get localized categories for API
```sql
SELECT 
    code,
    label,
    icon_identifier,
    COALESCE(all_translations->>'it'->>'label', label) AS label_it,
    COALESCE(all_translations->>'it'->>'description', description) AS description_it
FROM public.v_waypoint_categories_localized
WHERE is_active = true
ORDER BY sort_order;
```

### Get waypoint with full media gallery
```sql
SELECT 
    w.name,
    w.description,
    jsonb_agg(
        jsonb_build_object(
            'media_id', wm.media_id,
            'role', wm.media_role_code,
            'caption', wm.caption,
            'file_path', m.file_path,
            'display_order', wm.display_order
        ) ORDER BY wm.display_order
    ) AS media_gallery
FROM public.waypoints w
LEFT JOIN public.waypoint_media wm ON w.id = wm.waypoint_id
LEFT JOIN public.media m ON wm.media_id = m.id
WHERE w.slug = 'sanctuary-la-verna'
    AND w.deleted_at IS NULL
GROUP BY w.id, w.name, w.description;
```

## Next Steps
With Module 4 core complete, you can now:
1. Implement Module 4 sub-modules:
   - 4a: Accommodations (detailed lodging information)
   - 4b: Attractions (POI details, opening hours, etc.)
   - 4c: Transportation (schedules, facilities)
   - 4d: Events (pilgrim events, festivals)
2. Begin populating real waypoint data
3. Build API endpoints for waypoint browsing and search
4. Implement Module 5 (Dynamic Conditions) for trail warnings

The enhanced waypoint system provides a solid foundation for all pilgrimage platform functionality.
# Module 2: Core Trail Hierarchy

## Overview
This module implements the foundational trail structure for the VDF database, including trails, routes, and segments with full PostGIS 3D geometry support and automatic distance/elevation calculations.

## Tables Created

### Core Tables
1. **trails** - Main pilgrimage trails (e.g., Via di Francesco)
2. **routes** - Named paths within trails (e.g., Northern Route)
3. **segments** - Granular trail sections with 3D geometry
4. **waypoints** - Start/end points for segments (stub, enhanced in Module 4)

### Master Tables
5. **terrain_types_master** - Terrain classifications (forest, paved, etc.)
6. **usage_types_master** - Permitted activities (walking, cycling, etc.)
7. **media_roles_master** - Media purposes (hero, gallery, map, etc.)

### Linking Tables
8. **trail_regions** - Links trails to geographical regions
9. **route_segments** - Links segments to routes in order
10. **trail_terrain_types** - Trail terrain type associations
11. **trail_usage_types** - Trail usage permissions
12. **segment_additional_terrain_types** - Additional terrain for segments
13. **segment_media** - Media galleries for segments

## Migration Order
Run migrations in this order:
```bash
001_enums.sql
002_terrain_types_master.sql
003_usage_types_master.sql
004_trails.sql
005_trail_regions.sql
006_routes.sql
007_waypoints_stub.sql
008_segments.sql
009_route_segments.sql
010_trail_terrain_types.sql
011_trail_usage_types.sql
012_segment_additional_terrain_types.sql
013_media_roles_master.sql
014_segment_media.sql
```

## Key Features

### PostGIS 3D Geometry
- Segments use LineStringZ geometry for elevation data
- Auto-calculates distance, elevation gain/loss, and profiles
- Supports complex trail analysis and visualization

### Automatic Aggregation
- Routes automatically sum distances and elevation from segments
- Triggers maintain consistency when segments change
- No manual calculation needed

### Flexible Media System
- Direct media references for logos/banners
- Gallery support through segment_media with roles
- Supports hero images, maps, elevation profiles, etc.

### Comprehensive Metadata
- ENUMs for operational status, difficulty, sun exposure
- Master tables for terrain and usage types
- Full translation support via Module 1 infrastructure

## Dependencies
- Module 1 (User & Content Infrastructure) - required
- Module 3 (Geographical Context) - required for regions/towns
- PostGIS extension for spatial features

## Test Suite
Run the comprehensive test suite:
```bash
psql $DATABASE_URL -f test_module_2.sql
```

## Sample Queries

### Get trail with all routes
```sql
SELECT 
    t.name AS trail_name,
    t.slug AS trail_slug,
    r.name AS route_name,
    r.total_distance_km,
    r.estimated_total_elevation_gain_meters AS elevation_gain
FROM public.trails t
JOIN public.routes r ON r.trail_id = t.id
WHERE t.content_visibility_status = 'published'
    AND t.deleted_at IS NULL
    AND r.deleted_at IS NULL
ORDER BY t.name, r.is_primary_route_for_trail DESC, r.name;
```

### Get route with ordered segments
```sql
SELECT 
    r.name AS route_name,
    rs.order_in_route,
    s.name AS segment_name,
    s.distance_km,
    s.segment_difficulty,
    tt.code AS terrain_type,
    wp_start.name AS start_point,
    wp_end.name AS end_point
FROM public.routes r
JOIN public.route_segments rs ON rs.route_id = r.id
JOIN public.segments s ON rs.segment_id = s.id
LEFT JOIN public.terrain_types_master tt ON s.dominant_terrain_type_id = tt.id
JOIN public.waypoints wp_start ON s.start_waypoint_id = wp_start.id
JOIN public.waypoints wp_end ON s.end_waypoint_id = wp_end.id
WHERE r.slug = 'northern-route'
ORDER BY rs.order_in_route;
```

### Find segments by difficulty and terrain
```sql
SELECT 
    s.name,
    s.distance_km,
    s.elevation_gain_meters,
    s.segment_difficulty,
    array_agg(DISTINCT tt.code) AS terrain_types
FROM public.segments s
LEFT JOIN public.terrain_types_master tt ON s.dominant_terrain_type_id = tt.id
LEFT JOIN public.segment_additional_terrain_types sat ON sat.segment_id = s.id
LEFT JOIN public.terrain_types_master tt2 ON sat.terrain_type_id = tt2.id
WHERE s.segment_difficulty IN ('easy', 'moderate')
    AND s.content_visibility_status = 'published'
    AND s.deleted_at IS NULL
GROUP BY s.id, s.name, s.distance_km, s.elevation_gain_meters, s.segment_difficulty
HAVING 'forest_path' = ANY(array_agg(DISTINCT COALESCE(tt.code, tt2.code)));
```

### Get elevation profile for a segment
```sql
SELECT 
    s.name,
    s.distance_km,
    s.min_elevation_meters,
    s.max_elevation_meters,
    s.elevation_gain_meters,
    s.elevation_loss_meters,
    jsonb_pretty(s.elevation_profile_data) AS elevation_profile
FROM public.segments s
WHERE s.slug = 'assisi-to-spello';
```

### Calculate total trail statistics
```sql
WITH trail_stats AS (
    SELECT 
        t.id,
        t.name,
        COUNT(DISTINCT r.id) AS route_count,
        COUNT(DISTINCT rs.segment_id) AS total_segments,
        SUM(r.total_distance_km) AS total_distance_all_routes,
        MAX(r.total_distance_km) AS longest_route_km,
        array_agg(DISTINCT tt.code ORDER BY tt.code) AS terrain_types,
        array_agg(DISTINCT ut.code ORDER BY ut.code) AS usage_types
    FROM public.trails t
    LEFT JOIN public.routes r ON r.trail_id = t.id AND r.deleted_at IS NULL
    LEFT JOIN public.route_segments rs ON rs.route_id = r.id
    LEFT JOIN public.trail_terrain_types ttt ON ttt.trail_id = t.id
    LEFT JOIN public.terrain_types_master tt ON ttt.terrain_type_id = tt.id
    LEFT JOIN public.trail_usage_types tut ON tut.trail_id = t.id
    LEFT JOIN public.usage_types_master ut ON tut.usage_type_id = ut.id
    WHERE t.content_visibility_status = 'published'
        AND t.deleted_at IS NULL
    GROUP BY t.id, t.name
)
SELECT * FROM trail_stats;
```

## Next Steps
With Module 2 complete, you can now:
1. Begin populating real trail data
2. Implement Module 4 (Waypoints) to enhance the waypoint stub
3. Add Module 5 (Dynamic Conditions) for trail warnings
4. Build API endpoints for trail browsing and navigation
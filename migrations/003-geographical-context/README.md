# Module 3: Geographical Context

## Overview
This module implements the geographical foundation for the VDF database, providing hierarchical organization of regions, provinces, and towns with PostGIS support for spatial queries.

## Tables Created
1. **countries** - ISO country codes reference table
2. **regions** - Major administrative regions (e.g., Umbria, Toscana)
3. **provinces** - Administrative subdivisions within regions
4. **town_types_master** - Classification codes for town types
5. **towns** - Cities, towns, villages with detailed geographical data
6. **characteristic_tags_master** - Tags for regional characteristics
7. **service_tags_master** - Tags for town services and amenities

## Migration Order
Run migrations in this order:
```bash
001_countries.sql
002_regions.sql
003_provinces.sql
004_town_types_master.sql
005_towns.sql
006_characteristic_tags_master.sql
007_service_tags_master.sql
008_validation_triggers.sql
```

## Key Features
- **PostGIS Integration**: Full spatial support with geometry columns
- **Hierarchical Structure**: Country → Region → Province → Town
- **Tag System**: Flexible tagging for characteristics and services
- **Validation Triggers**: Ensure referential integrity for array fields
- **Soft Deletes**: Support for deleted_at timestamps
- **RLS Policies**: Row-level security for all tables

## Dependencies
- Module 1 (User & Content Infrastructure) must be implemented first
- Requires PostGIS extension (enabled in Module 1)

## Test Suite
Run the comprehensive test suite:
```bash
psql $DATABASE_URL -f test_module_3.sql
```

## Sample Queries

### Find towns within a region with specific services
```sql
SELECT 
    t.slug,
    t.latitude_centroid,
    t.longitude_centroid,
    t.key_services_summary_tags
FROM public.towns t
JOIN public.regions r ON t.region_id = r.id
WHERE r.slug = 'umbria'
    AND t.key_services_summary_tags && ARRAY['pilgrim_office', 'wifi']
    AND t.content_visibility_status = 'published'
    AND t.deleted_at IS NULL;
```

### Calculate distances between towns
```sql
SELECT 
    t1.slug AS from_town,
    t2.slug AS to_town,
    ST_Distance(t1.geom_centroid::geography, t2.geom_centroid::geography) / 1000.0 AS distance_km
FROM public.towns t1
CROSS JOIN public.towns t2
WHERE t1.id != t2.id
    AND t1.slug = 'assisi'
ORDER BY distance_km;
```

### Get region with translated name
```sql
SELECT 
    r.slug,
    r.map_default_latitude,
    r.map_default_longitude,
    tr.translated_text AS name
FROM public.regions r
LEFT JOIN public.translations tr ON 
    tr.table_identifier = 'regions' 
    AND tr.row_foreign_key = r.id::text
    AND tr.column_identifier = 'name'
    AND tr.language_code = 'en'
WHERE r.content_visibility_status = 'published'
    AND r.deleted_at IS NULL;
```

## Next Steps
With Module 3 basic tables complete, you can now:
1. Implement Module 2 (Core Trail Hierarchy) which references these geographical entities
2. Add remaining Module 3 features as needed
3. Begin populating real geographical data
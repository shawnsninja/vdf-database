# Module 5: Dynamic Conditions

Complete implementation of the Dynamic Conditions module for the VDF Database, providing real-time trail warnings and hazard reporting system.

## Overview

Module 5 provides comprehensive trail condition management including:
- **Warning Types**: Categorized warning types (trail damage, natural hazards, closures, etc.)
- **Severity Levels**: Graduated severity system from info to critical
- **Source Management**: Tracking and reliability scoring of warning sources
- **Workflow Management**: Complete content lifecycle from draft to published
- **Spatial Integration**: Precise PostGIS 3D location support
- **Temporal Control**: Active/inactive status based on effective dates

## Implementation Status: ✅ COMPLETE

All components of Module 5 have been successfully implemented and tested.

## Files Structure

```
005-dynamic-conditions/
├── 001_master_tables.sql           # Master tables for warning system
├── 002_master_seed.sql            # Comprehensive seed data
├── 003_segment_warnings.sql       # Main warnings table with PostGIS
├── 004_localized_views.sql        # API-optimized views
├── 005_test_module_5.sql          # Comprehensive test suite
└── README.md                      # This file
```

## Database Objects Created

### Master Tables (4)
- `warning_types_master` - Warning categories (15+ predefined types)
- `warning_severities_master` - Severity levels (6 levels: info → critical)
- `warning_source_types_master` - Warning sources (12+ types with reliability scoring)
- `workflow_statuses_master` - Content workflow states (12+ statuses)

### Main Table (1)
- `segment_warnings` - Core warnings table with spatial and temporal features

### Views (4)
- `v_segment_warnings_localized` - Complete administrative view with all master labels
- `v_public_active_segment_warnings` - Public-facing API view for active warnings
- `v_segment_warnings_summary` - Statistical summary by warning type
- `v_segment_warnings_geographic` - Geographic summary optimized for map displays

### Functions & Triggers (8)
- Update timestamp triggers for all tables
- Translation cleanup automation
- RLS policy functions
- Comprehensive data validation

## Key Features Implemented

### ✅ **Comprehensive Warning System**
- 15+ warning types covering all common trail conditions
- 6-level severity system with color coding and urgency levels
- 12+ source types with reliability scoring (1-10 scale)
- Automatic verification requirements based on source type

### ✅ **Advanced Spatial Features**
- PostGIS 3D PointZ geometry for precise warning locations
- Support for segment-wide or location-specific warnings
- Spatial indexing with GIST for efficient geographic queries
- Integration with existing trail/route/segment geometry

### ✅ **Temporal Management**
- Computed `is_currently_active` column for real-time status
- Flexible effective date ranges
- Expected resolution tracking
- Automatic expiration handling

### ✅ **Content Workflow**
- 12-state workflow from draft to archived
- Public visibility controls
- Verification and approval processes
- Override capabilities for emergency situations

### ✅ **Impact Assessment**
- Safety and accessibility impact levels (1-10 scale)
- Estimated detour distances and delays
- Alternative route descriptions
- Severity-based urgency prioritization

### ✅ **Media Integration**
- Primary media support for warning images
- Supporting media arrays for additional documentation
- Full integration with Module 1 media system
- Caption and alt-text support

### ✅ **API-Optimized Views**
- Pre-joined data with master table labels
- Public vs. administrative data filtering
- Geographic summaries for map interfaces
- Statistical aggregations for dashboards

### ✅ **Performance Optimization**
- Comprehensive indexing strategy
- Partial indexes for boolean filtering
- GIST spatial indexes for geometry queries
- Composite indexes for common query patterns

### ✅ **Security & Access Control**
- Row Level Security on all tables
- Role-based access (public, authenticated, content creators)
- Public visibility controls with override capabilities
- Service role administrative access

## Dependencies

Module 5 depends on:
- **Module 1**: User & Content Infrastructure (profiles, media, translations)
- **Module 2**: Core Trail Hierarchy (segments table)
- **PostGIS Extension**: For 3D geometry support

## Testing

The module includes a comprehensive test suite (`005_test_module_5.sql`) with 10 test cases covering:
- Master table data integrity and relationships
- Segment warnings table operations
- PostGIS 3D geometry functionality
- Constraint validations
- Localized views accessibility
- RLS policy verification
- Data quality checks
- Performance index verification
- Workflow logic validation
- Media array functionality

## Usage Examples

### Creating a Warning
```sql
-- Insert a new trail damage warning
INSERT INTO segment_warnings (
    segment_id, warning_type_id, severity_id, source_type_id, workflow_status_id,
    title, description,
    date_warning_effective_from, date_warning_expected_resolution,
    location_on_segment_geom, location_description,
    affects_entire_segment, safety_impact_level
) VALUES (
    123, -- segment_id
    (SELECT id FROM warning_types_master WHERE code = 'trail_damage'),
    (SELECT id FROM warning_severities_master WHERE code = 'caution'),
    (SELECT id FROM warning_source_types_master WHERE code = 'official_authority'),
    (SELECT id FROM workflow_statuses_master WHERE code = 'published'),
    'Bridge Damage on Via di Francesco',
    'Wooden bridge has damaged planks. Passable with caution but requires careful footing.',
    NOW(), NOW() + INTERVAL '14 days',
    ST_SetSRID(ST_MakePoint(12.123456, 43.123456, 850.5), 4326),
    'Wooden bridge crossing over stream, 2km from Assisi',
    false, 4
);
```

### Querying Active Warnings
```sql
-- Get all active warnings for public API
SELECT 
    title, description, warning_type_label, severity_label, severity_color,
    location_description, estimated_delay_minutes,
    segment_name, route_name, trail_name
FROM v_public_active_segment_warnings 
WHERE trail_name = 'Via di Francesco'
ORDER BY severity_urgency_level DESC, created_at DESC;
```

### Geographic Warning Search
```sql
-- Find warnings within bounding box
SELECT 
    segment_id, segment_name, active_warning_count, 
    max_severity_level, most_severe_warning_title
FROM v_segment_warnings_geographic
WHERE ST_Intersects(
    segment_geometry,
    ST_MakeEnvelope(12.0, 43.0, 12.5, 43.5, 4326)
)
ORDER BY max_severity_level DESC;
```

## Performance Considerations

- **Computed Columns**: `is_currently_active` is stored for fast queries
- **Spatial Indexing**: GIST indexes enable efficient geographic searches
- **Partial Indexes**: Boolean fields use partial indexes for filtered queries
- **Composite Indexes**: Optimized for common query patterns
- **View Materialization**: May be considered for high-traffic APIs

## Migration Order

Execute files in numerical order:
1. `001_master_tables.sql`
2. `002_master_seed.sql`
3. `003_segment_warnings.sql`
4. `004_localized_views.sql`
5. `005_test_module_5.sql` (testing only)

## API Integration

The module supports key API endpoints:
- `GET /warnings/active` - Currently active warnings
- `GET /segments/{id}/warnings` - Warnings for specific segment
- `GET /warnings/search/geo` - Geographic bounding box search
- `GET /warnings/summary` - Statistical summary by type
- Full translation support via language parameters

## Data Model Highlights

### Warning Severity Levels
1. **Info** (1) - General information, blue
2. **Advisory** (2) - Awareness required, green  
3. **Caution** (4) - Extra care needed, orange
4. **Warning** (6) - Significant condition, red
5. **Danger** (8) - Serious safety hazard, dark red
6. **Critical** (10) - Extreme danger/closure, darkest red

### Source Reliability Scoring
- **Official Authority** (10) - Government/trail management
- **Trail Organization** (9) - Recognized pilgrim associations
- **Emergency Services** (10) - Rescue/medical services
- **Verified Pilgrim** (6) - Established reporting history
- **Community Report** (5) - General pilgrim reports
- **Anonymous Report** (3) - Unverified sources

### Workflow States
- **Draft** → **Pending Review** → **Under Review** → **Approved** → **Published**
- **Published** → **Updated** → **Resolved** → **Expired**
- **Rejected**, **Superseded**, **Archived**, **Deleted**

## Next Steps

With Module 5 complete, the next logical modules to implement are:
- **Module 6**: User Interaction (voting, tips, reviews)
- **Module 7**: Curated Itineraries (pre-planned journeys)
- **Module 8**: Editorial (articles, news, content management)
- **Remaining Module 4 sub-modules**: 4a (Accommodations), 4c (Transportation), 4d (Events)
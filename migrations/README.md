# VDF Database Migrations

This directory contains all database migrations for the Via di Francesco platform, organized by module.

## Directory Structure

```
migrations/
├── 001_user_infrastructure/    # Module 1: User profiles, roles, media, translations
├── 002_trail_hierarchy/        # Module 2: Trails, routes, segments, terrain
├── 003_geographical_context/   # Module 3: Regions, provinces, towns
├── 004_waypoints/             # Module 4: Waypoints and all sub-modules (4a-4d)
├── 005_dynamic_conditions/    # Module 5: Warnings, hazards, closures
├── 006_user_interaction/      # Module 6: Votes, tips, moderation
├── 007_curated_itineraries/   # Module 7: Pre-planned journeys
└── 008_editorial/             # Module 8: Articles, news, blog posts
```

## Migration Naming Convention

Each migration file follows this pattern:
```
XXX_description.sql
```

Where:
- `XXX` is a three-digit sequence number (001, 002, etc.)
- `description` is a brief description of what the migration does

Example: `001_extensions.sql`, `002_profiles.sql`, `003_roles.sql`

## Execution Order

Migrations must be executed in order:
1. Within each module directory, run files in numerical order
2. Modules should be run in numerical order (001 before 002, etc.)

## Migration Components

Each module typically includes:
1. Extension enabling (if needed)
2. Table creation
3. Master data / seed data
4. Functions and triggers
5. Row Level Security (RLS) policies
6. Views for API access
7. Indexes for performance

## Running Migrations

### Using Supabase CLI:
```bash
supabase db reset  # Reset database and run all migrations
```

### Manual execution:
```bash
psql $DATABASE_URL -f migrations/001_user_infrastructure/001_extensions.sql
```

## Testing

After each module's migrations:
1. Verify all tables created successfully
2. Check that seed data loaded
3. Test RLS policies work as expected
4. Verify triggers fire correctly
5. Test API views return expected data
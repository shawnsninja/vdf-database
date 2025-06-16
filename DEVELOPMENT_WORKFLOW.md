# VDF Database Development Workflow

## Overview

This document outlines the development workflow for implementing the Via di Francesco database schema.

## Prerequisites

1. **Supabase Account**: Create at [supabase.com](https://supabase.com)
2. **Supabase CLI**: Install via npm or brew
3. **PostgreSQL Client**: psql or similar
4. **Environment Setup**: .env file with credentials

## Development Cycle

### 1. Planning Phase
- Review module documentation in `docs/markdown/`
- Check GitHub issues for requirements
- Update todo list using TodoWrite tool

### 2. Implementation Phase

#### For each table:
1. **Create Migration File**
   ```bash
   touch migrations/001_user_infrastructure/002_profiles.sql
   ```

2. **Write Table Definition**
   - Follow conventions from `database-checklist.md`
   - Include all columns with proper types
   - Add constraints (NOT NULL, CHECK, etc.)
   - Add indexes for foreign keys
   - Add COMMENT statements

3. **Add Audit Columns**
   ```sql
   created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
   updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
   created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
   updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
   ```

4. **Add Lifecycle Management**
   - Transactional tables: `deleted_at TIMESTAMPTZ NULL`
   - Master tables: `is_active BOOLEAN NOT NULL DEFAULT true`

### 3. Testing Phase

#### Local Testing:
```bash
# Reset database and run all migrations
supabase db reset

# Test specific migration
psql $DATABASE_URL -f migrations/001_user_infrastructure/002_profiles.sql

# Run test suite
psql $DATABASE_URL -f scripts/test-migration.sql
```

#### Validation Checklist:
- [ ] Table created successfully
- [ ] All constraints working
- [ ] Indexes created
- [ ] RLS policies active
- [ ] Triggers firing
- [ ] Seed data loaded
- [ ] Views accessible

### 4. Documentation Phase

1. **Update Migration README**
   - Document any deviations from spec
   - Note dependencies between tables
   - Add troubleshooting tips

2. **Update GitHub Issues**
   - Mark completed tasks
   - Note any blockers
   - Add implementation notes

## Module Implementation Order

1. **Module 1: User Infrastructure** (Foundation)
   - Extensions
   - Profiles
   - Roles
   - Languages
   - Media
   - Translations
   - Helper functions
   - RLS policies

2. **Module 2: Trail Hierarchy**
   - Trails
   - Routes
   - Segments
   - Junction tables
   - Master data

3. **Module 3: Geographical**
   - Regions
   - Provinces
   - Towns
   - Service tags

4. **Module 4: Waypoints**
   - Core waypoints
   - Accommodations (4a)
   - Attractions (4b)
   - Transportation (4c)
   - Events (4d)

5. **Modules 5-8**
   - Dynamic conditions
   - User interaction
   - Itineraries
   - Editorial

## Common Commands

### Supabase CLI
```bash
supabase start          # Start local development
supabase db reset       # Reset and re-run migrations
supabase db diff        # See schema changes
supabase gen types      # Generate TypeScript types
```

### PostgreSQL
```bash
# Connect to database
psql $DATABASE_URL

# Run migration
\i migrations/001_user_infrastructure/001_extensions.sql

# Check tables
\dt public.*

# Describe table
\d public.profiles
```

### Git Workflow
```bash
# Create feature branch
git checkout -b module-1-implementation

# Commit with conventional commits
git add migrations/
git commit -m "feat(db): implement profiles table with audit columns"

# Push and create PR
git push -u origin module-1-implementation
```

## Troubleshooting

### Common Issues:

1. **RLS Policy Errors**
   - Ensure auth.uid() is available
   - Check role helper functions exist
   - Verify JWT contains roles claim

2. **Foreign Key Violations**
   - Run migrations in correct order
   - Ensure referenced tables exist
   - Check for circular dependencies

3. **Trigger Errors**
   - Verify trigger functions created first
   - Check for syntax in function body
   - Test with simple INSERT/UPDATE

### Debug Queries:
```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- Check triggers
SELECT * FROM pg_trigger WHERE tgrelid = 'public.profiles'::regclass;

-- Check functions
\df public.has_role
```

## Best Practices

1. **Always Test Locally First**
2. **Use Transactions for Complex Migrations**
3. **Document Deviations from Spec**
4. **Keep Migrations Idempotent When Possible**
5. **Test RLS with Different Roles**
6. **Verify Performance with EXPLAIN**

## Resources

- [Supabase Docs](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostGIS Documentation](https://postgis.net/docs/)
- Project Specs in `docs/markdown/`
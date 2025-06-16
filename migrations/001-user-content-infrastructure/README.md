# Module 1: User & Content Infrastructure

This module provides the foundational tables for user management, internationalization, and media handling.

## Migration Files (Execute in Order)

1. **001_extensions.sql** - PostgreSQL extensions (uuid-ossp, moddatetime, pgcrypto, citext, postgis, pg_trgm)
2. **002_helper_functions.sql** - Core utility functions:
   - `handle_updated_at()` - Auto-update timestamps
   - `has_role()` - Check current user roles
   - `has_role_on_profile()` - Check specific profile roles
   - `check_profile_roles()` - Validate role assignments
   - `handle_new_user()` - Auto-create profiles for new auth users
   - `sync_profile_roles_to_auth_user()` - Sync roles to JWT
   - `get_user_language()` - Get user's preferred language
   - `cleanup_related_translations()` - Remove orphaned translations

3. **003_profiles.sql** - User profiles table extending auth.users
4. **004_user_roles_master.sql** - Role definitions table
5. **005_user_roles_master_seed.sql** - Initial role data (11 roles)
6. **006_languages_master.sql** - Supported languages table
7. **007_languages_master_seed.sql** - Initial language data (14 languages: 8 active, 6 inactive)
8. **008_translations.sql** - Translation system table
9. **009_translation_cleanup_triggers.sql** - Cleanup triggers for translations
10. **010_media.sql** - Media metadata table
11. **011_add_foreign_keys.sql** - Deferred FK constraints (currently empty)
12. **012_rls_policies.sql** - Row Level Security policies
13. **013_audit_infrastructure.sql** - Audit logging and schema migrations

## Tables Created

### profiles
- Extends Supabase auth.users with application-specific data
- Manages roles, preferences, and user metadata
- 1:1 relationship with auth.users

### user_roles_master
- Defines all available roles in the system
- Includes permissions summaries and UI metadata
- Seeded with 11 initial roles

### languages_master
- Defines supported and planned languages
- English (en) is the primary content language
- Seeded with 11 languages (5 active)

### media
- Central repository for all media file metadata
- References files in Supabase Storage
- Supports image variants and accessibility features

### translations
- Stores all translated content for the platform
- Supports workflow states (draft, review, published)
- Automatic cleanup when parent records deleted

### schema_migrations
- Tracks applied database migrations
- Version control for database schema
- Audit trail of when migrations were applied

### audit_log
- Comprehensive audit trail of all data changes
- Tracks INSERT, UPDATE, DELETE operations
- Records user, timestamp, and before/after data

## Key Features

1. **Role-Based Access Control (RBAC)**
   - Roles stored in profiles.roles array
   - Synced to JWT for immediate effect
   - Helper functions for role checking

2. **Internationalization (i18n)**
   - English content in main tables
   - Other languages via translations table
   - User language preferences

3. **Media Management**
   - Centralized media metadata
   - Support for image variants
   - Soft delete with cleanup tracking

4. **Audit Trail**
   - Standard audit columns on all tables
   - created_at/updated_at timestamps
   - created_by/updated_by profile references

5. **Row Level Security**
   - Comprehensive RLS policies
   - Role-based access control
   - Public/private visibility controls

## Testing Checklist

- [ ] Create test user via Supabase Auth
- [ ] Verify profile auto-creation with default role
- [ ] Test role assignment and JWT sync
- [ ] Upload test media file
- [ ] Create test translations
- [ ] Verify RLS policies work correctly
- [ ] Test soft delete functionality
- [ ] Verify translation cleanup triggers

## Dependencies for Other Modules

This module must be fully implemented before proceeding with:
- Module 2: Core Trail Hierarchy
- Module 3: Geographical Context
- Module 4: Waypoint Details
- All subsequent modules

## Notes

- All tables use UUID primary keys
- Soft deletes preferred over hard deletes
- English is stored directly, other languages via translations
- Media files stored in Supabase Storage, metadata in database

## Recent Fixes and Improvements (2025-06-15)

### Critical Issues Resolved:

1. **Dependency Ordering**: 
   - Moved `cleanup_related_translations()` function from translations.sql to helper_functions.sql
   - This resolved a circular dependency where translation cleanup triggers referenced a function not yet created

2. **Missing Seed Data**:
   - Added comprehensive languages_master seed data (14 languages)
   - Prevents `handle_new_user()` trigger failures due to missing default language

3. **Security Enhancements**:
   - Added `SET search_path = public, auth` to all SECURITY DEFINER functions
   - Prevents potential security vulnerabilities from search_path manipulation

4. **Extended Extensions**:
   - Added PostGIS for future geographical data support (Modules 2 & 3)
   - Added pg_trgm for fuzzy text search capabilities
   - Added citext for case-insensitive text handling

5. **Audit Infrastructure**:
   - New schema_migrations table for tracking database version
   - Comprehensive audit_log table with trigger function
   - Helper function `enable_audit_logging()` to easily add auditing to any table

### Best Practices Established:

1. **Translation Pattern**: All tables with translatable content must have AFTER DELETE trigger calling `cleanup_related_translations()`
2. **Function Security**: All SECURITY DEFINER functions must set search_path
3. **Migration Tracking**: All migrations are recorded in schema_migrations table
4. **Audit Trail**: Any table can be audited by calling `SELECT enable_audit_logging('table_name')`
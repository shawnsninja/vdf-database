# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Via di Francesco (VDF) Database is a comprehensive PostgreSQL database system for a pilgrimage platform supporting travelers on the Way of St. Francis in Italy. It manages trails, accommodations, points of interest, real-time conditions, and community features across 8 functional modules with 80+ tables.

## Repository Status

**Current State**: Documentation-only repository transitioning to implementation phase. All database schemas are documented in DOCX format. Migration directories exist but are empty pending implementation.

## Commands

### Setup & Configuration
```bash
# Set up Supabase project (interactive)
./scripts/setup-supabase.sh

# Convert DOCX documentation to Markdown
./scripts/convert-docx-to-markdown.sh

# Run tests (once implemented)
./scripts/run-tests.sh

# Extract text from DOCX files
unzip -p "filename.docx" word/document.xml | sed 's/<[^>]*>/ /g'

# Test database connection
psql $DATABASE_URL -c 'SELECT 1'
```

### Development Workflow
```bash
# Run migrations (in order by module number)
supabase db push

# Generate TypeScript types
supabase gen types typescript --local > types/database.types.ts

# Reset local database
supabase db reset
```

## Architecture

### Module Dependencies (Must implement in order)
1. **User & Content Infrastructure** → Base for all modules (profiles, roles, media, translations)
2. **Core Trail Hierarchy** → Depends on Module 1 (trails, routes, segments)
3. **Geographical Context** → Depends on Module 1 (regions, provinces, towns)
4. **Waypoint Details** → Depends on Modules 1-3 (accommodations, attractions, transport, events)
5. **Dynamic Conditions** → Depends on Modules 1-4 (warnings, hazards)
6. **User Interaction** → Depends on Modules 1-4 (voting, tips)
7. **Curated Itineraries** → Depends on Modules 1-4 (journey templates)
8. **Editorial** → Depends on Module 1 (articles, news)

### Key Design Patterns

**Standard Audit Columns** (all tables):
```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT now()
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
created_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
updated_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
```

**Lifecycle Management**:
- Transactional data: `deleted_at TIMESTAMPTZ NULL` (soft delete)
- Master/lookup data: `is_active BOOLEAN NOT NULL DEFAULT true`

**Internationalization**:
- English content in main tables
- Translations via `public.translations` table with cleanup triggers
- API pattern: `{field: "English", field_translations: {it: "Italian", ...}}`

**Security**:
- RLS enabled on all tables
- Role-based access via `public.profiles.roles[]`
- Helper functions: `public.has_role(TEXT)`, `public.has_role_on_profile(UUID, TEXT)`

**Media Management**:
- Files in Supabase Storage buckets
- Metadata in `public.media` table
- Single images: direct FK to `media_id`
- Galleries: `[entity]_media` linking tables with `media_role_code`

### Database Conventions

- Tables: plural `snake_case` (e.g., `trails`, `waypoints`)
- Columns: `snake_case` 
- ENUM types: `*_enum` suffix
- Foreign keys: match referenced column type exactly
- CHECK constraints for validation (e.g., URL format)
- COMMENT ON TABLE/COLUMN for documentation

## Key Reference Documents

- `2025-05-17 - checklist.docx` - Authoritative database design checklist
- `0. VDF Database Overview.docx` - Complete project overview
- `DEVELOPMENT_PLAN.md` - Implementation roadmap
- `DEVELOPMENT_WORKFLOW.md` - Step-by-step workflow
- `tasks/tasks-prd-vdf-database-implementation.md` - Detailed task breakdown

## Current Focus

The immediate priority is implementing Module 1 (User & Content Infrastructure) which includes:
1. User profiles with role management
2. Media storage integration
3. Translation system foundation
4. Base security policies

Follow the task list in `tasks/tasks-prd-vdf-database-implementation.md` systematically.
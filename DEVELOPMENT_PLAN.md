# Via di Francesco Database Development Plan

## Overview

This document outlines our structured approach to implementing the VDF database using the AI Dev Tasks methodology. We have ~80+ tables across 8 modules, requiring a systematic implementation approach.

## Project Understanding

### What We're Building
- **Purpose**: Comprehensive database for Via di Francesco pilgrimage platform
- **Scale**: 8 modules, 80+ tables, multilingual support
- **Technology**: PostgreSQL via Supabase
- **Users**: Pilgrims, hosts, content managers, administrators

### Key Technical Decisions Made
1. **Database**: Supabase (PostgreSQL with Auth, Storage, Realtime)
2. **Primary Language**: English (stored directly in tables)
3. **Translations**: Separate translations table for i18n
4. **Security**: Row Level Security (RLS) on all tables
5. **Media**: Supabase Storage with metadata in database
6. **Audit**: Standard audit columns on all tables

## Development Workflow

We're using the AI Dev Tasks methodology with these documents:
- `tasks/prd-vdf-database-implementation.md` - Product Requirements
- `tasks/tasks-prd-vdf-database-implementation.md` - Task breakdown
- GitHub Issues #2 and #3 - Progress tracking

### Phase 1: Foundation (Current Phase)
**Goal**: Set up project infrastructure and implement Module 1

**Immediate Actions**:
1. ✅ Project structure created
2. ✅ Documentation downloaded
3. ✅ PRD and task list created
4. ⏳ Create Supabase project
5. ⏳ Convert DOCX to Markdown
6. ⏳ Implement Module 1 (User & Content Infrastructure)

### Phase 2: Core Data Models
**Goal**: Implement the geographical and trail hierarchy

**Modules**:
- Module 2: Core Trail Hierarchy
- Module 3: Geographical Context

**Key Challenges**:
- PostGIS setup for geographical data
- Efficient segment/route relationships
- Media galleries for locations

### Phase 3: Waypoint System
**Goal**: Implement the complex waypoint and POI system

**Modules**:
- Module 4: Waypoints (core)
- Module 4a: Accommodations
- Module 4b: Attractions
- Module 4c: Transportation
- Module 4d: Events

**Key Challenges**:
- Complex relationships between waypoints and sub-types
- Extensive master data tables
- Multiple media relationships

### Phase 4: Dynamic Features
**Goal**: Add user interaction and dynamic content

**Modules**:
- Module 5: Dynamic Conditions
- Module 6: User Interaction
- Module 7: Curated Itineraries
- Module 8: Editorial

**Key Challenges**:
- Moderation workflows
- Real-time updates
- Content versioning

## Implementation Standards

### Database Conventions (from checklist)
- Tables: plural `snake_case`
- Columns: `snake_case`
- ENUMs: `*_enum` suffix
- Primary keys: appropriate type
- Foreign keys: exact type match
- Constraints: NOT NULL, CHECK, defaults

### Standard Patterns
```sql
-- Audit columns (all tables)
created_at TIMESTAMPTZ NOT NULL DEFAULT now()
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
created_by_profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL
updated_by_profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL

-- Lifecycle (transactional data)
deleted_at TIMESTAMPTZ NULL

-- Lifecycle (master data)
is_active BOOLEAN NOT NULL DEFAULT true
```

### Migration Structure
```
migrations/
├── 001_user_infrastructure/
│   ├── 001_extensions.sql
│   ├── 002_profiles.sql
│   ├── 003_roles.sql
│   └── ...
├── 002_trail_hierarchy/
└── ...
```

## Current Status & Next Steps

### Completed ✅
1. Project setup and structure
2. Documentation review and analysis
3. PRD and task list creation
4. GitHub issue tracking setup

### Immediate Next Steps 🎯
1. **Restart Claude Code** to load MCP servers
2. **Create Supabase Project**
   - Go to supabase.com
   - Create project "vdf-database" 
   - Copy credentials to .env
3. **Convert Documentation**
   - Use markdownify MCP to convert DOCX files
   - Store in docs/markdown/
4. **Start Module 1 Implementation**
   - Follow task 2.0 in task list
   - One sub-task at a time
   - Test thoroughly

### How to Proceed
1. Complete immediate next steps above
2. Use `@process-task-list.mdc` to work through tasks
3. Start with task 1.1 (Supabase setup)
4. Mark tasks complete as you go
5. Update GitHub issues with progress

## Success Criteria

### For Each Module
- [ ] All tables created with correct schema
- [ ] All constraints and indexes in place
- [ ] RLS policies implemented and tested
- [ ] Seed data loaded for master tables
- [ ] Views created for API access
- [ ] Documentation updated

### For Overall Project
- [ ] All 8 modules implemented
- [ ] Comprehensive test coverage
- [ ] Performance benchmarks met
- [ ] Security audit passed
- [ ] Import tools functional
- [ ] Ready for API development

## Resources

### Documentation
- `/docs/` - Original DOCX specifications
- `/docs/markdown/` - Converted specifications
- `CLAUDE.md` - Development guidelines
- `2025-05-17 - checklist.docx` - Database standards

### Tools
- Supabase CLI
- MCP servers (markdownify, supabase)
- GitHub CLI for issue tracking
- PostgreSQL client

### References
- [Supabase Docs](https://supabase.com/docs)
- [PostGIS Documentation](https://postgis.net/docs/)
- Via di Francesco official routes

## Questions to Resolve

Before proceeding too far, we should clarify:
1. PostGIS installation approach
2. Media CDN strategy
3. Backup/recovery plan
4. Monitoring approach
5. API versioning strategy

---

**Ready to proceed?** Start with the immediate next steps above, then work through the task list systematically using the process-task-list approach.
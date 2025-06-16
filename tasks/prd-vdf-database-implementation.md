# Product Requirements Document: Via di Francesco Database Implementation

## Introduction/Overview

The Via di Francesco (VDF) Database is a comprehensive data management system for a pilgrimage platform serving travelers on the Way of St. Francis in Italy. This PRD outlines the implementation of a PostgreSQL database using Supabase that will store and manage trail information, accommodations, points of interest, user interactions, and multilingual content for the pilgrimage routes.

The database will serve as the backend for web and mobile applications, providing reliable, scalable, and secure data access for pilgrims, accommodation hosts, content managers, and platform administrators.

## Goals

1. **Implement a complete database schema** following the documented 8-module architecture
2. **Ensure data integrity** through proper constraints, triggers, and validation
3. **Enable multilingual support** with English as primary language and translations for Italian, Spanish, German, and French
4. **Implement comprehensive security** using Row Level Security (RLS) policies
5. **Create efficient data access patterns** through views and indexes
6. **Establish audit trails** for all data modifications
7. **Support media management** for images, GPX files, and documents
8. **Enable scalable architecture** that can handle thousands of waypoints and millions of user interactions

## User Stories

1. **As a pilgrim**, I want to search for accommodations along my route so that I can plan where to stay each night
2. **As a pilgrim**, I want to see real-time trail conditions and warnings so that I can adjust my journey safely
3. **As an accommodation host**, I want to manage my listing details and availability so that pilgrims can find and book my property
4. **As a content manager**, I want to update trail information and POI details in multiple languages so that international pilgrims have accurate information
5. **As a platform administrator**, I want to moderate user-generated content and manage system-wide settings so that the platform remains high-quality
6. **As a pilgrim**, I want to vote on waypoints and leave tips so that I can help other travelers
7. **As a pilgrim**, I want to follow curated itineraries so that I can have a well-planned journey

## Functional Requirements

### Module 1: User & Content Infrastructure
1. The system must extend Supabase Auth with profile data including roles, preferences, and activity tracking
2. The system must synchronize user roles to JWT tokens for API authentication
3. The system must store media metadata with support for image variants and responsive images
4. The system must provide a centralized translation system for all multilingual content
5. The system must track audit information (created/updated by/at) for all records

### Module 2: Core Trail Hierarchy
6. The system must store trail definitions with multiple routes and segments
7. The system must support GPX data storage and geometry calculations
8. The system must categorize terrain types and usage types for trails
9. The system must link trails to geographical regions

### Module 3: Geographical Context
10. The system must organize locations hierarchically (regions → provinces → towns)
11. The system must tag locations with characteristics and available services
12. The system must support media galleries for regions and towns

### Module 4: Waypoint Details
13. The system must store waypoints with categories, tags, and lifecycle status
14. The system must store detailed accommodation information including amenities, pricing, and availability
15. The system must store attraction details, food/water sources, shops, and services
16. The system must store public transportation information
17. The system must store event information with recurrence patterns

### Module 5: Dynamic Conditions
18. The system must track real-time warnings and hazards for trail segments
19. The system must support workflow for verifying and publishing warnings
20. The system must categorize warnings by type, severity, and source

### Module 6: User Interaction
21. The system must allow users to vote on waypoints (helpful/not helpful)
22. The system must allow users to submit short tips with moderation workflow
23. The system must categorize tips and track moderation status

### Module 7: Curated Itineraries
24. The system must store pre-planned itineraries with daily segments
25. The system must categorize itineraries by difficulty, season, and theme
26. The system must track publishing status and versioning

### Module 8: Editorial Content
27. The system must store articles with rich text content
28. The system must support featured images and media galleries for articles
29. The system must track author attribution and publishing workflow

## Non-Goals (Out of Scope)

1. **User authentication implementation** - We'll use Supabase Auth as-is, only extending with profiles
2. **Payment processing** - No financial transactions in initial version
3. **Real-time messaging** - No chat or messaging features
4. **Mobile offline sync** - Database is online-only initially
5. **Advanced routing algorithms** - Simple segment connections only
6. **Automated content generation** - All content is manually curated
7. **Third-party integrations** - No external API connections in V1

## Design Considerations

- **Database**: PostgreSQL via Supabase
- **Naming Conventions**: 
  - Tables: plural snake_case
  - Columns: snake_case
  - ENUMs: end with _enum suffix
- **Standard Patterns**:
  - Audit columns on all tables
  - Soft delete (deleted_at) for transactional data
  - is_active flag for master/lookup data
  - English content stored directly, translations in separate table
- **Performance**: Indexes on all foreign keys and frequently queried columns
- **Security**: RLS policies on all tables with helper functions

## Technical Considerations

1. **Dependencies**: Supabase project with Auth enabled
2. **Extensions Required**: 
   - PostGIS for geographical data
   - pg_trgm for text search
   - moddatetime for updated_at triggers
3. **Storage**: Supabase Storage for media files
4. **Migrations**: Sequential numbered migrations by module
5. **Seed Data**: Required for all master tables
6. **Testing**: Comprehensive test suite for RLS policies and data integrity

## Success Metrics

1. **Data Integrity**: 0% orphaned records, 100% foreign key compliance
2. **Performance**: <100ms query time for common operations
3. **Security**: 100% tables have RLS policies, 0 unauthorized data access
4. **Internationalization**: 100% user-facing text available in 5 languages
5. **Audit Compliance**: 100% data modifications tracked with user attribution
6. **Media Management**: <1% broken media links after 6 months
7. **Scalability**: Support 10,000+ waypoints, 100,000+ users

## Open Questions

1. Should we implement PostGIS immediately or defer geographical features?
2. What is the preferred approach for handling media CDN and caching?
3. Should we version the API endpoints from the start?
4. How should we handle GDPR compliance for user data?
5. What monitoring and alerting should be implemented?
6. Should we implement database-level full-text search or use external service?
7. What is the backup and disaster recovery strategy?
# Via di Francesco (VDF) Database

A comprehensive database system for the Via di Francesco pilgrimage platform, providing trail information, accommodations, points of interest, and community features for pilgrims traveling the Way of St. Francis in Italy.

## Project Structure

```
vdf-database/
├── migrations/          # SQL migration files organized by module
│   ├── 001_user_infrastructure/
│   ├── 002_trail_hierarchy/
│   ├── 003_geographical/
│   ├── 004_waypoints/
│   ├── 005_dynamic_conditions/
│   ├── 006_user_interaction/
│   ├── 007_curated_itineraries/
│   └── 008_editorial/
├── scripts/            # Data import/export and utility scripts
│   ├── import/
│   ├── export/
│   └── utils/
├── docs/              # Documentation
│   └── markdown/      # Converted markdown versions of docs
└── *.docx files       # Original documentation

## Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Copy `.env.example` to `.env` and fill in your Supabase credentials
3. Run migrations in order (001, 002, 003, etc.)

## Database Modules

1. **User & Content Infrastructure** - Core user management, roles, media, translations
2. **Core Trail Hierarchy** - Trails, routes, segments with terrain data
3. **Geographical Context** - Regions, provinces, towns
4. **Waypoint Details** - POIs, accommodations, attractions, transport, events
5. **Dynamic Conditions** - Trail warnings, hazards, closures
6. **User Interaction** - Voting, tips, community features
7. **Curated Itineraries** - Pre-planned journey templates
8. **Editorial** - Articles, news, blog posts

## Development Standards

See `CLAUDE.md` for detailed development guidelines and database design standards.

## MCP Configuration

This project uses Claude Code MCP servers. After adding the `mcp.json` file, restart Claude Code to enable:
- `markdownify` - Convert DOCX files to Markdown

## Data Sources

- GPX files for trail geometry
- OpenStreetMap for geographical data
- Manual curation for accommodations and POIs
- Community contributions for tips and conditions
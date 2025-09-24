# Via di Francesco API & Admin Contract (Draft — 2025-09-22)

## Context
- Schema validated most recently via `out/logs/migrations_2025-09-22T220201Z.log` (Modules 001–009 plus waypoint variant column).
- Importer dry-run/apply succeed locally (most recent pass 2025-09-24T00-02Z: `out/logs/importer_2025-09-24T000842Z_dry.log`, `out/logs/importer_2025-09-24T002554Z_apply.log`, QA `out/qa/importer_2025-09-24T002700Z.md`). Staging apply is still blocked pending real service-role credentials; see earlier failures `out/logs/importer_2025-09-22T211015Z_dry.log`, `out/logs/importer_2025-09-22T211038Z_apply.log`, and `out/qa/importer_2025-09-22T211015Z.md`.
- Module 7–9 specs (versions 2.2 / 1.2 / 1.0) already cite these artefacts; update after the next importer run or schema change.
- REST contract exported to `docs/api/openapi-v1.yaml` on 2025-09-23.
- Latest EXPLAIN ANALYZE snapshots (local, 2025-09-24T11:56Z):
  - `out/logs/explain_curated_itineraries_list_2025-09-24T115628Z.txt`
  - `out/logs/explain_curated_itinerary_detail_2025-09-24T115628Z.txt`
  - `out/logs/explain_curated_itinerary_segments_2025-09-24T115628Z.txt`
  - `out/logs/explain_published_articles_2025-09-24T115628Z.txt`
  - QA: `out/qa/importer_2025-09-24T004906Z.md`
- Latest EXPLAIN ANALYZE snapshots (staging, 2025-09-24T17:36Z):
  - `out/logs/explain_curated_itineraries_list_2025-09-24T173617Z_staging.txt`
  - `out/logs/explain_curated_itinerary_detail_2025-09-24T173617Z_staging.txt`
  - `out/logs/explain_curated_itinerary_segments_2025-09-24T173617Z_staging.txt`
  - `out/logs/explain_published_articles_2025-09-24T173617Z_staging.txt`
  - QA: `out/qa/importer_2025-09-24T173617Z_staging.md`

## OpenAPI 3.1 Draft (public + admin)
```yaml
openapi: 3.1.0
info:
  title: Via di Francesco API
  version: 0.3.0-draft
servers:
  - url: https://api.viadifrancesco.org/v1
paths:
  /itineraries:
    get:
      summary: List published curated itineraries
      parameters:
        - in: query
          name: difficulty_level_code
          schema: { type: string, maxLength: 32 }
        - in: query
          name: category_code
          schema: { type: string, maxLength: 32 }
        - in: query
          name: season_code
          schema: { type: string, maxLength: 32 }
        - in: query
          name: is_featured
          schema: { type: boolean }
        - in: query
          name: lang
          schema: { type: string, enum: [en,it,es,nl,de,ko], default: en }
        - in: query
          name: cursor
          schema: { type: string, description: "Opaque pagination token" }
        - in: query
          name: limit
          schema: { type: integer, minimum: 1, maximum: 50, default: 25 }
      responses:
        '200':
          description: Paginated itinerary list
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/CuratedItinerarySummary'
                  next_cursor:
                    type: string
                    nullable: true
  /itineraries/{code}:
    get:
      summary: Fetch localized itinerary detail
      parameters:
        - in: path
          name: code
          required: true
          schema: { type: string }
        - in: query
          name: lang
          schema: { type: string, enum: [en,it,es,nl,de,ko], default: en }
      responses:
        '200':
          description: Localized itinerary detail
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CuratedItineraryDetail'
        '404': { description: Itinerary not found }
  /itineraries/{code}/segments:
    get:
      summary: Day-by-day segments derived from importer output
      parameters:
        - in: path
          name: code
          required: true
          schema: { type: string }
        - in: query
          name: lang
          schema: { type: string, enum: [en,it,es,nl,de,ko], default: en }
      responses:
        '200':
          description: Ordered segment list for itinerary
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/ItinerarySegment'
  /articles:
    get:
      summary: List published editorial articles
      parameters:
        - in: query
          name: lang
          schema: { type: string, enum: [en,it,es,nl,de,ko], default: en }
        - in: query
          name: tag
          schema: { type: string }
        - in: query
          name: author_id
          schema: { type: string, format: uuid }
        - in: query
          name: published_after
          schema: { type: string, format: date-time }
        - in: query
          name: cursor
          schema: { type: string }
        - in: query
          name: limit
          schema: { type: integer, minimum: 1, maximum: 50, default: 25 }
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/ArticleSummary'
                  next_cursor: { type: string, nullable: true }
  /articles/{slug}:
    get:
      summary: Fetch localized article detail with media gallery
      parameters:
        - in: path
          name: slug
          required: true
          schema: { type: string }
        - in: query
          name: lang
          schema: { type: string, enum: [en,it,es,nl,de,ko], default: en }
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ArticleDetail'
        '404': { description: Article not found }
  /segments/{slug}:
    get:
      summary: Segment detail sourced from importer
      parameters:
        - in: path
          name: slug
          required: true
          schema: { type: string }
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SegmentDetail'
  /ingestion-runs:
    get:
      summary: Admin-only ingestion run audit trail
      parameters:
        - in: query
          name: status
          schema: { type: string, enum: [pending,completed,failed] }
        - in: query
          name: since
          schema: { type: string, format: date-time }
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/IngestionRun'
```

### Components (excerpt)
- `CuratedItinerarySummary`: `id`, `code`, `localized_title`, `hero_image_path`, `difficulty_code`, `category_codes[]`, `season_codes[]`, `published_at`.
- `CuratedItineraryDetail`: extends summary with `localized_subtitle`, `localized_description`, `highlights[]`, `day_count`, `total_distance_km`, `seo`, `media`.
- `ItinerarySegment`: `day_number`, `segment_id`, `segment_slug`, `start_town_name`, `end_town_name`, `suggested_accommodation`, `distance_km`, `elevation_gain_m`, `notes`.
- `ArticleSummary`: `slug`, `localized_title`, `excerpt`, `hero_image`, `author`, `publication_date`.
- `ArticleDetail`: summary fields + `localized_body`, `media_gallery[]`, `tags[]`, `translation_status_by_locale`.
- `SegmentDetail`: `name`, `slug`, `start_waypoint`, `end_waypoint`, `variant_group`, `branch_direction`, `primary_gpx_source`, `is_dutch_only`, ordered `segment_waypoints[]`, `nearby_options{accommodations[], attractions[]}`.
- `IngestionRun`: `id`, `source_path`, `stage_name`, `gpx_source`, `organization_code`, `started_at`, `completed_at`, `status`, `segments_written`, `anchors_found`, `waypoints_found`, `operator_notes`.

### Admin Mutations (future draft)
- `POST /admin/itineraries` (create draft itinerary) with audit + translation placeholders.
- `PATCH /admin/itineraries/{id}` (update metadata, statuses, translations).
- `POST /admin/articles` / `PATCH /admin/articles/{id}` (content workflow with translation status enforcement).
- `POST /admin/ingestion-runs/{id}/retry` (enqueue importer rerun).

## GraphQL Contract Outline
```graphql
type Query {
  itineraries(filter: ItineraryFilter, first: Int = 25, after: String): ItineraryConnection!
  itinerary(code: String!, lang: LanguageCode = EN): ItineraryDetail
  itinerarySegments(code: String!, lang: LanguageCode = EN): [ItinerarySegment!]!
  articles(filter: ArticleFilter, first: Int = 25, after: String): ArticleConnection!
  article(slug: String!, lang: LanguageCode = EN): ArticleDetail
  segment(slug: String!): SegmentDetail
  ingestionRuns(filter: IngestionRunFilter, first: Int = 50, after: String): IngestionRunConnection!
}

enum LanguageCode { EN IT ES NL DE KO }

type Mutation {
  upsertItinerary(input: UpsertItineraryInput!): ItineraryDetail!
  setItineraryTranslationStatus(code: String!, locale: LanguageCode!, status: TranslationStatus!): ItineraryDetail!
  upsertArticle(input: UpsertArticleInput!): ArticleDetail!
  setArticleTranslationStatus(slug: String!, locale: LanguageCode!, status: TranslationStatus!): ArticleDetail!
  triggerIngestionRun(input: TriggerIngestionRunInput!): IngestionRun!
}
```
- Relay-style connections expose `edges { node, cursor }` and `pageInfo { hasNextPage, endCursor }`.
- Translation status enum aligns with automation plan: `DRAFT`, `MACHINE_PENDING`, `IN_REVIEW`, `PUBLISHED_LIVE`, `ARCHIVED`.
- GraphQL resolvers back `segment_waypoints`, `segment_nearby_options`, and `view_curated_itinerary_segments` using search_path `public`.

## Required Database Views & Materializations
- `public.view_curated_itineraries_list` now surfaces `translation_status_map` via `public.build_translation_status_map(...)` alongside the existing metadata. Still add/verify covering index on `(content_status_code, published_at DESC)`.
  - Latest EXPLAIN (local 2025-09-24T11:56Z): Planning 6.172 ms; Execution 0.335 ms.
  - Latest EXPLAIN (staging 2025-09-24T17:36Z): Planning 43.973 ms; Execution 1.304 ms.
- `public.view_curated_itinerary_detail` now includes `translation_status_map`; ensure JSON aggregations for `highlights`, `media`, `seo`. Consider materializing if EXPLAIN exceeds 150 ms.
  - Latest EXPLAIN (local 2025-09-24T11:56Z): Planning 2.261 ms; Execution 0.198 ms.
  - Latest EXPLAIN (staging 2025-09-24T17:36Z): Planning 6.504 ms; Execution 0.243 ms.
- `public.view_curated_itinerary_segments` exposes importer-aligned data plus `translation_status_map`. Index underlying `curated_itinerary_segments` on `(curated_itinerary_id, day_number)` and `(segment_id)`.
  - Latest EXPLAIN (local 2025-09-24T11:56Z): Planning 4.087 ms; Execution 0.151 ms.
  - Latest EXPLAIN (staging 2025-09-24T17:36Z): Planning 8.558 ms; Execution 0.227 ms.
- `public.published_articles_view` now returns `translation_status_map` using `public.build_translation_status_map('articles', id::text)`.
  - Latest EXPLAIN (local 2025-09-24T11:56Z): Planning 3.728 ms; Execution 0.153 ms (measured on `public.view_published_articles`).
  - Latest EXPLAIN (staging 2025-09-24T17:36Z): Planning 18.865 ms; Execution 0.888 ms.
- `public.segment_detail_view` (new) → join `segments`, `segment_waypoints`, `segment_nearby_options`, `segment_sources`, `waypoint_sources`, `ingestion_runs` for API consumption. Index `segment_waypoints(segment_id, sequence)` (already PK) plus btree on `segment_sources(segment_id, is_primary)`.

## Index Requirements & Performance Budgets
- `public.curated_itineraries`:
  - `UNIQUE (code)` maintained.
  - Composite index `(content_status_code, published_at DESC)` for list endpoint.
  - GIN index on `category_codes` array in materialized list view if filter volume grows.
- `public.curated_itinerary_segments`:
  - `(curated_itinerary_id, day_number)` btree already in spec; add `(segment_id)` index for segment lookups.
- `public.articles`:
  - Unique index on `slug` (existing) + `(publication_status, publication_date DESC)`.
  - Optional trigram index on `slug` for admin search.
- `public.article_media`:
  - `(article_id, display_order)` index to support gallery ordering.
- `public.segment_waypoints`:
  - Primary key `(segment_id, sequence)`.
  - Additional partial index on `(variant_group)` WHERE `variant_group IS NOT NULL` for variant queries.
- `public.segment_nearby_options`:
  - GIST index on `geom` (PostGIS) + `(segment_id, option_type)` btree.
- `public.ingestion_runs`:
  - `(stage_name, started_at DESC)` index + `(status)` index for dashboard filters.
- Enforce analyser target: <150 ms p95 for itinerary list/detail; <200 ms for segment detail when joined with waypoints; <100 ms for article endpoints.

## Admin Interface Responsibilities
- **Regional Directors / Researchers:**
  - Manage waypoint metadata, run importer retries, review Dutch-only flags, download QA reports.
  - Need UI to diff importer runs and attach operator notes, writing to `ingestion_runs.operator_notes`.
- **Editorial Team:**
  - Manage article lifecycle, translation statuses, media gallery ordering; enforce `translation_status_map` updates via GraphQL mutations.
  - Provide translation status dashboards per locale.
- **Platform Admin:**
  - Configure itinerary publication windows, feature flags, and translation automation overrides.

## Monitoring & QA Hooks
- Log ingestion metrics to Supabase `app.log_importer_run()` function (to be defined) to track runtime and error categories.
- Define pg_cron job to flag importer runs stuck in `pending` > 30 minutes.
- Provide canned SQL diagnostics (stored in docs) for verifying:
  - `segment_waypoints` counts per segment vs importer summary.
  - Primary source recalculation (official vs Dutch precedence).
  - Translation coverage per itinerary/article locale.

## Next Actions
1. Obtain valid staging `DATABASE_URL` (or start local Supabase stack) and re-run importer dry-run + apply; attach resulting metrics to Module 7–9 change logs.
2. Convert OpenAPI excerpt into machine-readable `docs/api/openapi-v1.yaml` for future tooling integration.
3. Implement GraphQL resolvers backed by PostgREST or Hasura layer; ensure RLS helper functions align with admin roles.
4. Benchmark critical views with `EXPLAIN ANALYZE`, update index plan as needed, and document results in module specs.
5. Coordinate with translation automation plan (see forthcoming doc) to surface status fields in both REST and GraphQL responses.

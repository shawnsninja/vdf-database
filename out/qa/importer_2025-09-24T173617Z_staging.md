# Importer QA Note (Staging)

Date (UTC): 2025-09-24T17:36:17Z
Environment: staging (Supabase pooler)
Stage: badia-prataglia
Importer JSON: out/test_import_branch.json

Commands executed
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/psql-local -f migrations/004-waypoint-details/002_waypoint_categories_master_seed.sql
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/psql-local -f migrations/004-waypoint-details/006_content_statuses_master_seed.sql
- python3 scripts/importer_v1.py out/test_import_branch.json --stage-name "badia-prataglia" --gpx-source official --db-url "$REMOTE_DATABASE_URL" --dry-run
- python3 scripts/importer_v1.py out/test_import_branch.json --stage-name "badia-prataglia" --gpx-source official --db-url "$REMOTE_DATABASE_URL" --apply

Results
- Dry-run summary: segments=3, anchors=4, waypoints=1
- Apply summary: segments=3, anchors=4, waypoints=1
- Ingestion run IDs: 1

Logs (EXPLAIN ANALYZE)
- out/logs/explain_curated_itineraries_list_2025-09-24T173617Z_staging.txt
- out/logs/explain_curated_itinerary_detail_2025-09-24T173617Z_staging.txt
- out/logs/explain_curated_itinerary_segments_2025-09-24T173617Z_staging.txt
- out/logs/explain_published_articles_2025-09-24T173617Z_staging.txt

EXPLAIN timings (Planning / Execution)
- Itineraries list: 43.973 ms / 1.304 ms
- Itinerary detail: 6.504 ms / 0.243 ms
- Itinerary segments: 8.558 ms / 0.227 ms
- Published articles: 18.865 ms / 0.888 ms

Notes
- Required seeds applied on staging before importer apply to satisfy waypoint_categories_master and content statuses.
- Connection used Supabase connection pooler (aws-0-us-east-1.pooler.supabase.com:6543).
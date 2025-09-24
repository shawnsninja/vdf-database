# Database Reset & Regression Playbook

## Goals
- Provide a repeatable way to reset either the local Supabase stack or the staging
  pooler without leaving duplicate schema objects.
- Capture importer + performance evidence after every significant schema change.

---

## Local environment (Supabase CLI)

1. Ensure Docker Desktop is running.
2. From the repo root:
   ```bash
   supabase db reset      # loads supabase/migrations baseline
   supabase start         # starts local services if not already running
   source scripts/load-env.sh
   scripts/psql-local -c "select version();"  # sanity check
   ```
3. **Top-off seeds** that are not part of the Supabase baseline:
   ```bash
   scripts/psql-local -f migrations/004-waypoint-details/002_waypoint_categories_master_seed.sql
   scripts/psql-local -f migrations/004-waypoint-details/006_content_statuses_master_seed.sql
   ```
4. Avoid running `./scripts/run-migrations.sh` immediately after the reset unless you
   first drop and recreate the `public` schema. The Supabase dump and repo migrations
   overlap and will trigger duplicate-object errors.

---

## Staging environment (Supabase pooler)

1. Source the project env so `REMOTE_DATABASE_URL` is available:
   ```bash
   source scripts/load-env.sh
   DATABASE_URL="$REMOTE_DATABASE_URL" scripts/psql-local -c "select version();"
   ```
2. Apply the required seed files (same as local) before running the importer.
3. Always connect via the pooler host (format `aws-0-<region>.pooler.supabase.com:6543`
   with username `postgres.<project_ref>`). Direct `db.<ref>.supabase.co:5432` hosts are
   not routable for this project.

---

## Importer regression checklist

Run after each schema/importer change for both local and staging targets:

```bash
python3 scripts/importer_v1.py out/test_import_branch.json   --stage-name "badia-prataglia"   --gpx-source official   --db-url "$DATABASE_URL"   --dry-run

python3 scripts/importer_v1.py out/test_import_branch.json   --stage-name "badia-prataglia"   --gpx-source official   --db-url "$DATABASE_URL"   --apply
```

- Archive logs under `out/logs/` (dry + apply) and create a QA summary in
  `out/qa/` noting counts, ingestion_run id, and validation queries executed.
- Update `docs/importer/handoff-next-agent.md` with a dated entry referencing the
  new artefacts.

---

## Performance snapshots (EXPLAIN ANALYZE)

After importer runs, capture timings with the 10s timeout guard:

```bash
scripts/psql-local -c "EXPLAIN ANALYZE SELECT * FROM public.view_curated_itineraries_list ORDER BY is_featured DESC, published_at DESC LIMIT 25;"

scripts/psql-local -c "EXPLAIN ANALYZE SELECT * FROM public.view_curated_itinerary_detail WHERE code = '<itinerary_code>';"

scripts/psql-local -c "EXPLAIN ANALYZE SELECT * FROM public.view_curated_itinerary_segments WHERE curated_itinerary_id = <id> ORDER BY day_number, sort_order;"

scripts/psql-local -c "EXPLAIN ANALYZE SELECT * FROM public.view_published_articles ORDER BY publication_date DESC NULLS LAST LIMIT 25;"
```

- Save outputs to `out/logs/explain_*.txt` (timestamped) and reference them in the
  API/admin requirements doc.
- For staging, prefix commands with `DATABASE_URL="$REMOTE_DATABASE_URL"`.

---

## Translation automation queue sanity checks

1. Enqueue targets:
```bash
scripts/translation_automation/translation_automation.py scan
```
2. Inspect queue counts:
```bash
scripts/translation_automation/translation_automation.py stats
```
3. Optionally clear jobs with no-op completion during testing:
```bash
scripts/translation_automation/translation_automation.py process --limit 5 --strategy complete
```

Recent artefacts (2025-09-24):
- Local log: out/logs/translation_automation_2025-09-24T191756Z_local.txt
- Staging log: out/logs/translation_automation_2025-09-24T192712Z_staging.txt
- QA notes: out/qa/translation_automation_2025-09-24T191756Z_local.md, out/qa/translation_automation_2025-09-24T192712Z_staging.md

Document any anomalies and append them to the handoff file before wrapping up the
session.

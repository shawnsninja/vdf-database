# Translation Automation Plan — 2025-09-22

## Scope & Goals
- Guarantee English (`en`) remains the canonical authoring language for itineraries, articles, waypoint highlights, and importer-generated strings.
- Automate secondary locale generation for Italian (`it`), Spanish (`es`), Dutch (`nl`), German (`de`), and Korean (`ko`) while preserving editorial control and audit trails.
- Surface translation status in both documentation (Module specs), API responses, and admin tooling to satisfy the checklist requirements.

## Locale Coverage & Priorities
| Locale | Priority | Driver |
| --- | --- | --- |
| en | Canonical | Editorial team authoring baseline content. |
| it | Tier 1 | Primary audience in Italy; manual review mandatory. |
| es | Tier 1 | Pilgrim growth market; manual review mandatory. |
| nl | Tier 1 | Dutch pilgrim association partnership. |
| de | Tier 2 | Tourism board syndication. |
| ko | Tier 2 | Emerging long-haul audience; slower review cadence. |

## Status Taxonomy (aligns with API/GraphQL contract)
- `draft`: Content exists only in English; translation not yet requested.
- `machine_pending`: Machine translated (LLM) content stored in `public.translations`, awaiting human review.
- `in_review`: Regional reviewer actively editing; changes tracked in admin UI with diff against machine suggestion.
- `published_live`: Approved translation; exposed to public consumers.
- `archived`: Retired translation (kept for audit but excluded from delivery views).

## Workflow Overview
1. **Authoring (EN)**
   - Editors create/update base content in the respective tables (`curated_itineraries`, `articles`, importer-managed tables).
   - `public.translations` entries for EN remain blank; fallback handled by default_* columns.
2. **Machine Seed**
   - Nightly job queries for rows where translation status is `draft` and pushes payloads to OpenAI GPT-4o mini (or approved LLM) via secure worker.
   - LLM output stored directly in `public.translations` with `translation_status = 'machine_pending'` and metadata JSON containing `model`, `prompt_version`, `timestamp`.
3. **Human Review**
   - Regional reviewers work in admin UI filtered by locale/status.
   - UI surfaces source English text, machine suggestion, and diff editing area.
   - Saving moves status to `in_review`; final approval toggles to `published_live` and captures reviewer profile + timestamp.
4. **QA & Publication**
   - Publication triggers revalidation of `view_curated_itinerary_detail`, `view_curated_itinerary_segments`, and `published_articles_view` to ensure fallback logic honors updated translations.
   - Translation coverage dashboards highlight any locale still in `draft`/`machine_pending` for flagship itineraries and articles.
5. **Maintenance**
   - Content updates in English automatically flag linked translations back to `in_review` (trigger `public.mark_translations_stale()` to implement) to avoid stale localized copy.

## Automation Components
- **Background Worker**: `scripts/translation_automation/translation_automation.py` now provides scan/process/stats commands around the queue; convert it into a cron-friendly worker once LLM integration is approved.
- **Queue Storage**: `public.translation_jobs` + helper functions (`enqueue_translation_job`, `dequeue_translation_jobs`, `complete_translation_job`) defined in migration 015 handle deduping and lifecycle.
- **Triggers**: Table-specific triggers call `public.mark_translations_stale()` when base text changes.
- **Admin UI Hooks**: GraphQL mutation `set[Entity]TranslationStatus` enforces allowed transitions and writes to audit tables.
- **Notifications**: Optional integration with Slack/email for reviewers when new machine-pending translations exceed threshold.

## Data Model Touchpoints
- `public.translations`: ensure composite index `(table_identifier, column_identifier, row_foreign_key, language_code)` remains; add columns `last_reviewed_at`, `last_reviewed_by_profile_id`, `status`.
- `curated_itineraries`, `articles`, importer views: include `translation_status_map` JSON via `public.build_translation_status_map(...)` to summarize per-locale status for API clients.
- `ingestion_runs`: store translation hydration summary after importer apply (counts per locale) for segment names sourced from GPX metadata.

## QA & Monitoring
- Weekly report (SQL) listing:
  - Percent coverage per module per locale.
  - Entries stuck in `machine_pending` > 7 days.
  - Entries reverted from `published_live` → `in_review` for audit.
- Automated tests to verify triggers set statuses appropriately when base text changes.
- Manual spot-check instructions documented in Module 7–9 specs (change log to reference machine vs human translation samples).

## Tooling Requirements
- Secure storage of LLM API keys (`OPENAI_API_KEY`); pipeline runs with service role bypassing RLS but writes audit metadata.
- Rate limiting guard (max 30 requests/min) to avoid hitting vendor limits.
- Translation editor UI must support diff view and fallback to previously published copy if translation review is delayed.

## Risks & Mitigations
| Risk | Mitigation |
| --- | --- |
| LLM hallucination or incorrect proper nouns | Provide glossary in prompt, enforce reviewer approval before `published_live`. |
| Drift between importer-sourced names and editorial overrides | Importer flag `is_llm_seeded` to prompt manual review for segments with machine translations. |
| Volume spikes (e.g., batch itinerary imports) | Queue worker supports per-locale throttling; backlog dashboard ensures transparency. |
| Lost audit trail | Persist changes in `public.translation_audits` table (entity, locale, old_value, new_value, reviewer, timestamp). |

## Next Steps
1. ✅ Columns/triggers wired for Modules 7–9 via migration 014; audit remaining tables after future schema additions.
2. ✅ Queue smoke-tested on 2025-09-24 (local + staging). Artefacts:
   - Local log: `out/logs/translation_automation_2025-09-24T191756Z_local.txt`
   - Staging log: `out/logs/translation_automation_2025-09-24T192712Z_staging.txt`
   - QA notes: `out/qa/translation_automation_2025-09-24T191756Z_local.md`, `out/qa/translation_automation_2025-09-24T192712Z_staging.md`
   - Fix applied: `migrations/001-user-content-infrastructure/015_fix_dequeue_translation_jobs.sql`
3. Build cron-compatible worker prototype and document deployment in `scripts/translation_automation/`.
4. Wire GraphQL/REST mutations to enforce status transitions and expose `translation_status_map`.
5. Prepare reviewer playbook (checklist, glossary, QA queries) and attach to module change logs.
6. Integrate metrics into admin dashboard (Supabase or external) for coverage tracking.

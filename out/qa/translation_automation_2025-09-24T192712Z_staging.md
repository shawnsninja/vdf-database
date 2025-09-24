# Translation Automation QA — Staging

Date (UTC): 2025-09-24T19:27:12Z
Environment: staging (pooler)

Commands
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/psql-local -f migrations/001-user-content-infrastructure/015_translation_jobs.sql
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/psql-local -f migrations/001-user-content-infrastructure/015_fix_dequeue_translation_jobs.sql
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/translation_automation/translation_automation.py scan
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/translation_automation/translation_automation.py stats
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/translation_automation/translation_automation.py process --limit 5 --strategy skip
- DATABASE_URL="$REMOTE_DATABASE_URL" scripts/translation_automation/translation_automation.py stats

Results summary
- scan: Enqueued or refreshed 0 job(s) (no eligible translations at this time)
- stats (before): No translation jobs present
- process: No pending jobs
- stats (after): No translation jobs present

Logs
- out/logs/translation_automation_2025-09-24T192712Z_staging.txt
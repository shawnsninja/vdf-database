# Translation Automation QA — Local

Date (UTC): 2025-09-24T19:17:56Z
Environment: local

Commands
- source scripts/load-env.sh
- scripts/psql-local -f migrations/001-user-content-infrastructure/015_translation_jobs.sql
- scripts/translation_automation/translation_automation.py scan
- scripts/translation_automation/translation_automation.py stats
- scripts/translation_automation/translation_automation.py process --limit 5 --strategy skip
- scripts/translation_automation/translation_automation.py stats

Follow-up fix
- Replaced dequeue function to avoid PL/pgSQL ambiguity (id/priority/requested_at) and enum label quoting issues:
  - migrations/001-user-content-infrastructure/015_fix_dequeue_translation_jobs.sql

Results summary
- scan: Enqueued or refreshed 0 job(s) (no eligible translations: statuses 'draft' or 'machine_pending')
- stats (before): No translation jobs present
- process: No pending jobs
- stats (after): No translation jobs present

Logs
- out/logs/translation_automation_2025-09-24T191756Z_local.txt

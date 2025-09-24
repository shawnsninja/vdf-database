-- Fix for dequeue function: qualify candidate id and use quoted enum labels
CREATE OR REPLACE FUNCTION public.dequeue_translation_jobs(
  p_limit integer DEFAULT 10
) RETURNS TABLE (
  id bigint,
  table_identifier text,
  column_identifier text,
  row_foreign_key text,
  language_code text,
  priority smallint,
  requested_at timestamptz,
  requested_by text,
  translation_id bigint,
  notes text
)
LANGUAGE plpgsql
AS $FN$
BEGIN
  RETURN QUERY
  WITH candidates AS (
    SELECT j.id AS job_id
    FROM public.translation_jobs j
    WHERE job_status = 'pending'
    ORDER BY j.priority ASC, j.requested_at ASC
    FOR UPDATE SKIP LOCKED
    LIMIT p_limit
  )
  UPDATE public.translation_jobs jobs
  SET job_status = 'processing',
      started_at = now()
  FROM candidates c
  WHERE jobs.id = c.job_id
  RETURNING jobs.id,
            jobs.table_identifier,
            jobs.column_identifier,
            jobs.row_foreign_key,
            jobs.language_code,
            jobs.priority,
            jobs.requested_at,
            jobs.requested_by,
            jobs.translation_id,
            jobs.notes;
END;
$FN$;

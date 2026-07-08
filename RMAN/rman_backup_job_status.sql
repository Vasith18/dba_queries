SELECT
    session_key,
    input_type,
    status,
    TO_CHAR(start_time, 'DD-MON-YYYY HH24:MI') AS start_time,
    TO_CHAR(end_time, 'DD-MON-YYYY HH24:MI') AS end_time,
    ROUND(elapsed_seconds / 60, 2) AS duration_minutes
FROM v$rman_backup_job_details
ORDER BY start_time DESC;

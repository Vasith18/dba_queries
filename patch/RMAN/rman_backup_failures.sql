SELECT
    session_key,
    input_type,
    status,
    start_time,
    end_time
FROM v$rman_backup_job_details
WHERE status <> 'COMPLETED'
ORDER BY start_time DESC;

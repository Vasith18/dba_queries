SELECT
    input_type,
    ROUND(SUM(output_bytes) / 1024 / 1024 / 1024, 2) AS backup_size_gb
FROM v$rman_backup_job_details
GROUP BY input_type
ORDER BY backup_size_gb DESC;

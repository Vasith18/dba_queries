SELECT
    handle,
    completion_time,
    status
FROM v$backup_controlfile
ORDER BY completion_time DESC;

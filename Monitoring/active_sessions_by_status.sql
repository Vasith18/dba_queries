SELECT
    status,
    COUNT(*) AS session_count
FROM v$session
GROUP BY status;

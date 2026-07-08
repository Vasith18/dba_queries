SELECT
    df.file#,
    df.name,
    MAX(bp.completion_time) AS last_backup_time
FROM v$datafile df
JOIN v$backup_piece bp ON bp.status = 'A'
GROUP BY df.file#, df.name
ORDER BY last_backup_time DESC;

SELECT
    instance_name,
    host_name,
    status,
    startup_time,
    ROUND((SYSDATE - startup_time) * 24, 2) AS uptime_hours
FROM v$instance;

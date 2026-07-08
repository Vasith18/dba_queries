SELECT
    s.sid,
    s.serial#,
    s.username,
    s.blocking_session,
    s.status,
    s.event
FROM v$session s
WHERE s.blocking_session IS NOT NULL;

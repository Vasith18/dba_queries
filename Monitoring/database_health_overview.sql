SELECT
    d.name AS db_name,
    d.open_mode,
    d.database_role,
    d.log_mode,
    d.force_logging,
    d.flashback_on,
    d.dataguard_broker
FROM v$database d;

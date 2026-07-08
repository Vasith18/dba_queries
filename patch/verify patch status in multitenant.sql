SELECT con_id,
       patch_id,
       action,
       status,
       source_version,
       target_version,
       action_time
FROM cdb_registry_sqlpatch
ORDER BY action_time;

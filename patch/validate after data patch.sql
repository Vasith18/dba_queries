SELECT c.name AS pdb_name,
       s.patch_id,
       s.action,
       s.status,
       s.target_version
FROM cdb_registry_sqlpatch s
JOIN v$containers c
ON s.con_id = c.con_id
ORDER BY c.name, s.action_time;

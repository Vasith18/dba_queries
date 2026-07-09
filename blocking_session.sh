#!/bin/bash

# Oracle Environment
export ORACLE_SID=YOUR_DB
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

sqlplus -s / as sysdba <<EOF

set lines 200 pages 100
col blocker format a20
col blocked format a20
col username format a15
col machine format a25
col program format a25
col sql_id format a15

PROMPT ===============================================
PROMPT        BLOCKING SESSION REPORT
PROMPT ===============================================

SELECT
    bs.sid||','||bs.serial#        AS blocker,
    ws.sid||','||ws.serial#        AS blocked,
    bs.username,
    bs.machine,
    bs.program,
    bs.sql_id,
    ROUND((SYSDATE - bs.logon_time) * 24,2) AS blocking_hours,
    bs.logon_time
FROM v\$session bs,
     v\$session ws
WHERE ws.blocking_session = bs.sid
ORDER BY blocking_hours DESC;

EXIT;
EOF

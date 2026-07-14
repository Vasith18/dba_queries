#!/bin/bash
###############################################################################
# Script Name : oracle_health_check.sh
# Description : Oracle Database Daily Health Check Report
# Author      : Mohammed Vashid A
###############################################################################

# Oracle Environment
export ORACLE_SID=YOUR_DB
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

REPORT=/tmp/oracle_health_check_$(date +%F).log

sqlplus -s / as sysdba <<EOF > $REPORT

set pages 500
set lines 200
set feedback off
set verify off

prompt ======================================================
prompt         ORACLE DATABASE HEALTH CHECK REPORT
prompt ======================================================
prompt Report Generated : &&_DATE
prompt

prompt ======================================================
prompt DATABASE STATUS
prompt ======================================================

select name,
       open_mode,
       database_role,
       log_mode
from v\$database;

prompt

prompt ======================================================
prompt INSTANCE STATUS
prompt ======================================================

select instance_name,
       host_name,
       version,
       startup_time,
       status
from v\$instance;

prompt

prompt ======================================================
prompt TABLESPACE USAGE (>80%)
prompt ======================================================

SELECT
    df.tablespace_name,
    ROUND((df.total-mb.free)/df.total*100,2) pct_used
FROM
(
SELECT tablespace_name,
SUM(bytes)/1024/1024 total
FROM dba_data_files
GROUP BY tablespace_name
) df,
(
SELECT tablespace_name,
SUM(bytes)/1024/1024 free
FROM dba_free_space
GROUP BY tablespace_name
) mb
WHERE df.tablespace_name=mb.tablespace_name
AND ROUND((df.total-mb.free)/df.total*100,2) >80
ORDER BY 2 DESC;

prompt

prompt ======================================================
prompt INVALID OBJECTS
prompt ======================================================

SELECT owner,
       object_type,
       COUNT(*) total
FROM dba_objects
WHERE status='INVALID'
GROUP BY owner,object_type
ORDER BY owner;

prompt

prompt ======================================================
prompt BLOCKING SESSIONS
prompt ======================================================

SELECT
    s1.sid||','||s1.serial# blocker,
    s2.sid||','||s2.serial# blocked,
    s1.username,
    s1.machine,
    s1.program,
    ROUND((SYSDATE-s1.logon_time)*24,2) blocking_hours
FROM v\$session s1,
     v\$session s2
WHERE s2.blocking_session=s1.sid;

prompt

prompt ======================================================
prompt LONG RUNNING SESSIONS (>30 Minutes)
prompt ======================================================

SELECT sid,
       serial#,
       username,
       status,
       ROUND(last_call_et/60,2) minutes_running
FROM v\$session
WHERE status='ACTIVE'
AND last_call_et>1800;

prompt

prompt ======================================================
prompt ARCHIVE DESTINATION USAGE
prompt ======================================================

SELECT
name,
space_limit/1024/1024 "LIMIT_MB",
space_used/1024/1024 "USED_MB",
ROUND((space_used/space_limit)*100,2) "%USED"
FROM v\$recovery_file_dest;

prompt

prompt ======================================================
prompt LAST RMAN BACKUP
prompt ======================================================

SELECT
INPUT_TYPE,
STATUS,
START_TIME,
END_TIME
FROM v\$rman_backup_job_details
ORDER BY END_TIME DESC FETCH FIRST 5 ROWS ONLY;

prompt

prompt ======================================================
prompt DATABASE SIZE
prompt ======================================================

SELECT ROUND(SUM(bytes)/1024/1024/1024,2) "DB_SIZE_GB"
FROM dba_data_files;

exit
EOF

echo "=========================================="
echo "Oracle Health Check Completed Successfully"
echo "Report Location : $REPORT"
echo "=========================================="

cat $REPORT

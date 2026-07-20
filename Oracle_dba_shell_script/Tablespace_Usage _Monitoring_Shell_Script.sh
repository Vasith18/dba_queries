#!/bin/bash

###############################################################################
# Script Name : check_tablespace_usage.sh
# Description : Oracle Tablespace Usage Monitoring Script
# Purpose     : Monitor tablespace utilization and identify high usage
###############################################################################

# Oracle Environment
export ORACLE_SID=YOUR_DB
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Threshold
THRESHOLD=80

echo "======================================================"
echo "       ORACLE TABLESPACE USAGE MONITORING"
echo "======================================================"
echo "Database   : $ORACLE_SID"
echo "Threshold  : $THRESHOLD%"
echo "Date       : $(date)"
echo "======================================================"

sqlplus -s / as sysdba <<EOF

SET LINESIZE 200
SET PAGESIZE 100
SET FEEDBACK OFF
SET HEADING ON

COLUMN TABLESPACE_NAME FORMAT A25
COLUMN TOTAL_MB FORMAT 999,999,999
COLUMN USED_MB FORMAT 999,999,999
COLUMN FREE_MB FORMAT 999,999,999
COLUMN USED_PERCENT FORMAT 990.99

PROMPT
PROMPT ======================================================
PROMPT TABLESPACE USAGE REPORT
PROMPT ======================================================

SELECT
    df.tablespace_name,
    ROUND(df.total_mb,2) total_mb,
    ROUND(df.total_mb - NVL(fs.free_mb,0),2) used_mb,
    ROUND(NVL(fs.free_mb,0),2) free_mb,
    ROUND(
        ((df.total_mb - NVL(fs.free_mb,0)) / df.total_mb) * 100,
        2
    ) used_percent
FROM
(
    SELECT
        tablespace_name,
        SUM(bytes)/1024/1024 total_mb
    FROM dba_data_files
    GROUP BY tablespace_name
) df
LEFT JOIN
(
    SELECT
        tablespace_name,
        SUM(bytes)/1024/1024 free_mb
    FROM dba_free_space
    GROUP BY tablespace_name
) fs
ON df.tablespace_name = fs.tablespace_name
WHERE
    ((df.total_mb - NVL(fs.free_mb,0)) / df.total_mb) * 100 >= $THRESHOLD
ORDER BY used_percent DESC;

PROMPT
PROMPT ======================================================
PROMPT TEMPORARY TABLESPACE USAGE
PROMPT ======================================================

SELECT
    tablespace_name,
    ROUND(
        (used_blocks / total_blocks) * 100,
        2
    ) used_percent
FROM v\\$temp_space_header
WHERE
    (used_blocks / total_blocks) * 100 >= $THRESHOLD;

PROMPT
PROMPT ======================================================
PROMPT DATAFILE AUTOEXTEND STATUS
PROMPT ======================================================

SELECT
    tablespace_name,
    file_name,
    autoextensible,
    ROUND(bytes/1024/1024,2) current_size_mb,
    ROUND(maxbytes/1024/1024,2) max_size_mb
FROM dba_data_files
ORDER BY tablespace_name;

EXIT;
EOF

echo
echo "======================================================"
echo "Tablespace monitoring completed successfully."
echo "======================================================"

# Oracle Environment
export ORACLE_SID=PROD
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

THRESHOLD=85
DATE=$(date +"%Y-%m-%d_%H-%M")
LOG=tablespace_alert_$DATE.log

EMAIL="dba_team@company.com"

echo "Tablespace Alert Report" > $LOG
echo "Generated on $(date)" >> $LOG
echo "===================================" >> $LOG

sqlplus -s / as sysdba <<EOF >> $LOG

set linesize 200
set pagesize 100
set feedback off

SELECT 
tablespace_name,
ROUND((used_space/tablespace_size)*100,2) USED_PERCENT
FROM 
dba_tablespace_usage_metrics
WHERE 
ROUND((used_space/tablespace_size)*100,2) > $THRESHOLD
AND tablespace_name NOT IN ('SYSTEM','SYSAUX')
ORDER BY 2 DESC;

EXIT;
EOF

echo "===================================" >> $LOG

ALERT_COUNT=$(grep -i "%" $LOG | wc -l)

if [ $ALERT_COUNT -gt 0 ]
then
    echo "Tablespace threshold exceeded" >> $LOG
    mail -s "Oracle Tablespace Alert - $ORACLE_SID" $EMAIL < $LOG
    echo "Alert Email Sent"
else
    echo "Tablespace usage is normal" >> $LOG
fi

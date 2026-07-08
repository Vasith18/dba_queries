SELECT
    df.tablespace_name,
    ROUND(df.total_mb) AS total_mb,
    ROUND(fs.free_mb) AS free_mb,
    ROUND((df.total_mb - fs.free_mb)) AS used_mb,
    ROUND(((df.total_mb - fs.free_mb) / df.total_mb) * 100, 2) AS used_pct
FROM
    (SELECT tablespace_name, SUM(bytes) / 1024 / 1024 AS total_mb
     FROM dba_data_files
     GROUP BY tablespace_name) df
JOIN
    (SELECT tablespace_name, SUM(bytes) / 1024 / 1024 AS free_mb
     FROM dba_free_space
     GROUP BY tablespace_name) fs
ON df.tablespace_name = fs.tablespace_name
ORDER BY used_pct DESC;

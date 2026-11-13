SELECT
    queryid,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_exec_time_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
    rows,
    LEFT(query, 1000) AS query_text
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 100;

#!/usr/bin/env bash
set -Eeuo pipefail

# Update these settings for your database.
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="${REPORT_DIR:-${PROJECT_DIR}/reports}"
LOG_DIR="${PROJECT_DIR}/logs"
REPORT_FILE="${REPORT_DIR}/perf_$(date +%Y%m%d).csv"
LOG_FILE="${LOG_DIR}/export.log"

mkdir -p "$REPORT_DIR" "$LOG_DIR"
echo "[$(date '+%F %T')] Starting export" >> "$LOG_FILE"

if psql -X -v ON_ERROR_STOP=1 \
    --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" --dbname="$DB_NAME" <<SQL
\\copy (
    SELECT queryid, calls,
           ROUND(total_exec_time::numeric, 2) AS total_exec_time_ms,
           ROUND(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
           rows, LEFT(query, 1000) AS query_text
    FROM pg_stat_statements
    ORDER BY total_exec_time DESC
    LIMIT 100
) TO '${REPORT_FILE}' WITH (FORMAT CSV, HEADER TRUE)
SQL
then
    echo "[$(date '+%F %T')] SUCCESS: $REPORT_FILE" >> "$LOG_FILE"
    echo "Created: $REPORT_FILE"
else
    status=$?
    echo "[$(date '+%F %T')] ERROR: export failed ($status)" >> "$LOG_FILE"
    exit "$status"
fi

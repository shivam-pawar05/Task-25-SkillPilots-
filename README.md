# PostgreSQL Daily Performance Report
Exports the top 100 statements from `pg_stat_statements` to a dated CSV each day.

## Setup
1. Configure PostgreSQL `shared_preload_libraries` to include `pg_stat_statements` (preserve any existing entries), then restart PostgreSQL.
2. Run `CREATE EXTENSION IF NOT EXISTS pg_stat_statements;` in the target database (see `sql/enable_extension.sql`).
3. Edit the database settings in `scripts/export_performance_report.sh`.
4. Ensure the script's operating-system user can write to the report and log folders.
5. Configure authentication with a protected `~/.pgpass`; do not put passwords in the script.

## Run
```bash
chmod +x scripts/export_performance_report.sh
./scripts/export_performance_report.sh
```
A file named `perf_YYYYMMDD.csv` is created in `reports/`.

## Schedule daily at 1:00 AM
Use `crontab -e` and add the absolute path:
```cron
0 1 * * * /bin/bash /absolute/path/postgres-daily-performance-report/scripts/export_performance_report.sh
```

## Verify
Check the CSV in `reports/` and messages in `logs/export.log`.

Note: this is a daily snapshot of cumulative `pg_stat_statements` counters, not a daily difference. Query text may contain sensitive information; protect the CSV files. The script uses psql client-side `\\copy`, so the script account writes the file.

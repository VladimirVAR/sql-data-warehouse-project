"""
Local pipeline runner for the SQL Server data warehouse.

Executes DDL, stored procedure definitions, and ETL loads
in the correct order against a target SQL Server instance.

Usage:
    python scripts/run_pipeline.py
    python scripts/run_pipeline.py --server .\\SQLEXPRESS --dataset-root datasets
"""

import argparse
import re
import sys
from pathlib import Path

import pyodbc

REPO_ROOT = Path(__file__).resolve().parent.parent

PREFERRED_DRIVERS = [
    "ODBC Driver 18 for SQL Server",
    "ODBC Driver 17 for SQL Server",
    "SQL Server",
]

SQL_FILES = [
    "scripts/init_database.sql",
    "scripts/bronze/ddl_bronze.sql",
    "scripts/silver/ddl_silver.sql",
    "scripts/gold/ddl_gold.sql",
    "scripts/bronze/proc_load_bronze.sql",
    "scripts/silver/proc_load_silver.sql",
]

GO_PATTERN = re.compile(r"^\s*GO\s*(?:--[^\n]*)?\s*$", re.IGNORECASE | re.MULTILINE)


def find_odbc_driver():
    installed = pyodbc.drivers()
    for driver in PREFERRED_DRIVERS:
        if driver in installed:
            return driver
    raise RuntimeError(
        "No supported SQL Server ODBC driver found.\n"
        "Install 'ODBC Driver 18 for SQL Server' or 'ODBC Driver 17 for SQL Server'.\n"
        "Available drivers: " + ", ".join(installed or ["(none)"])
    )


def build_connection_string(server, driver):
    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE=master;"
        f"Trusted_Connection=yes;"
        f"TrustServerCertificate=yes;"
    )


def split_sql_batches(sql_text):
    batches = GO_PATTERN.split(sql_text)
    return [b.strip() for b in batches if b.strip()]


def execute_sql_file(conn, sql_path):
    path = REPO_ROOT / sql_path
    if not path.exists():
        raise FileNotFoundError(f"SQL file not found: {path}")

    print(f"  Executing {sql_path} ...", flush=True)
    sql_text = path.read_text(encoding="utf-8")
    batches = split_sql_batches(sql_text)

    cursor = conn.cursor()
    for batch in batches:
        cursor.execute(batch)
    cursor.close()
    print(f"  OK", flush=True)


def main():
    parser = argparse.ArgumentParser(
        description="Bootstrap and load the SQL Server data warehouse."
    )
    parser.add_argument(
        "--server",
        default=r".\SQLEXPRESS",
        help="SQL Server instance (default: .\\SQLEXPRESS)",
    )
    parser.add_argument(
        "--dataset-root",
        default="datasets",
        help="Path to the datasets folder (default: datasets)",
    )
    args = parser.parse_args()

    dataset_root = Path(args.dataset_root)
    if not dataset_root.is_absolute():
        dataset_root = REPO_ROOT / dataset_root
    dataset_root = dataset_root.resolve()

    if not dataset_root.exists():
        print(f"ERROR: dataset root not found: {dataset_root}", file=sys.stderr)
        sys.exit(1)

    print(f"Dataset root : {dataset_root}")
    print(f"Server       : {args.server}")

    try:
        driver = find_odbc_driver()
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"ODBC driver  : {driver}")

    conn_str = build_connection_string(args.server, driver)

    try:
        conn = pyodbc.connect(conn_str, autocommit=True)
    except pyodbc.Error as exc:
        print(f"ERROR: Could not connect to {args.server}\n{exc}", file=sys.stderr)
        sys.exit(1)

    print()
    print("--- Schema setup ---")
    try:
        for sql_file in SQL_FILES:
            execute_sql_file(conn, sql_file)
    except (FileNotFoundError, pyodbc.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        conn.close()
        sys.exit(1)

    print()
    print("--- ETL load ---")
    cursor = conn.cursor()
    try:
        print("  EXEC bronze.load_bronze ...", flush=True)
        cursor.execute(
            "EXEC bronze.load_bronze @dataset_root = ?",
            str(dataset_root),
        )
        cursor.close()
        print("  OK", flush=True)
    except pyodbc.Error as exc:
        print(f"ERROR: bronze.load_bronze failed\n{exc}", file=sys.stderr)
        conn.close()
        sys.exit(1)

    cursor = conn.cursor()
    try:
        print("  EXEC silver.load_silver ...", flush=True)
        cursor.execute("EXEC silver.load_silver")
        cursor.close()
        print("  OK", flush=True)
    except pyodbc.Error as exc:
        print(f"ERROR: silver.load_silver failed\n{exc}", file=sys.stderr)
        conn.close()
        sys.exit(1)

    conn.close()
    print()
    print("Pipeline complete.")


if __name__ == "__main__":
    main()

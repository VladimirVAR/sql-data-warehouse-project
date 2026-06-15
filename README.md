# SQL Server Data Warehouse

SQL Server data warehouse integrating CRM and ERP source data through a three-layer pipeline.
Bronze ingestion loads raw CSVs into staging tables via BULK INSERT.
Silver applies cleaning, normalization, and deduplication rules.
Gold exposes a star schema as analytics-ready views.

---

## Architecture

![Data Architecture](docs/data_architecture.png)

```
CSV Sources (CRM + ERP)
        |
        v
Bronze  -- raw ingestion into staging tables
        |
        v
Silver  -- cleaned, standardized, deduplicated
        |
        v
Gold    -- dimensional model (dim_customers, dim_products, fact_sales)
```

![Data Model](docs/data_model.png)

The Gold layer contains:

- `gold.dim_customers` -- customer records enriched with demographic and location data
- `gold.dim_products` -- product records enriched with category data
- `gold.fact_sales` -- sales transactions joined to customer and product dimensions

---

## Repository Structure

```
sql-data-warehouse-project/
|-- datasets/               # Local CSV inputs (not committed -- see datasets/README.md)
|-- docs/                   # Architecture diagrams, data catalog, naming conventions
|-- scripts/
|   |-- init_database.sql   # Creates DataWarehouse database and schemas
|   |-- run_pipeline.py     # Python runner: full local rebuild in one command
|   |-- bronze/             # Bronze DDL and load procedure
|   |-- silver/             # Silver DDL and transformation procedure
|   `-- gold/               # Gold analytical views
|-- tests/                  # Data quality checks
|-- requirements.txt        # Python dependency (pyodbc)
`-- README.md
```

---

## Prerequisites

- SQL Server or SQL Server Express
- ODBC Driver 17 or 18 for SQL Server
- Python 3
- pyodbc (`pip install -r requirements.txt`)
- Local CSV source files placed under `datasets/source_crm/` and `datasets/source_erp/`

---

## Dataset Layout

```
datasets/
|-- source_crm/
|   |-- cust_info.csv
|   |-- prd_info.csv
|   `-- sales_details.csv
`-- source_erp/
    |-- cust_country.csv
    |-- cust_demographics.csv
    `-- prod_category.csv
```

Source files are excluded from version control.
See `datasets/README.md` for the expected column layout.

---

## Quickstart

Install the Python dependency:

```
python -m pip install -r requirements.txt
```

Run the full pipeline:

```
python scripts\run_pipeline.py --server .\SQLEXPRESS --dataset-root datasets
```

The runner connects to the specified SQL Server instance, recreates the DataWarehouse database,
applies DDL for all three layers, registers stored procedures, and executes Bronze and Silver loads.

Adjust `--server` for a different local instance (for example `localhost` or `.\SQLEXPRESS2022`).
`--dataset-root` is resolved to an absolute path from the repository root before being passed to SQL Server.

---

## Manual Execution

Individual steps can be run through SSMS or sqlcmd in this order:

```
scripts/init_database.sql
scripts/bronze/ddl_bronze.sql
scripts/silver/ddl_silver.sql
scripts/gold/ddl_gold.sql
scripts/bronze/proc_load_bronze.sql
scripts/silver/proc_load_silver.sql
```

Then execute the ETL procedures:

```sql
EXEC bronze.load_bronze @dataset_root = 'C:\path\to\datasets';
EXEC silver.load_silver;
```

---

## Data Quality Checks

Run after pipeline execution to validate the Silver and Gold layers:

```
tests/quality_checks_silver.sql
tests/quality_checks_gold.sql
```

---

## What This Project Covers

- SQL Server data warehouse design with Bronze / Silver / Gold layers
- CSV ingestion using T-SQL BULK INSERT with a parameterized dataset root
- Data cleaning, normalization, and deduplication in stored procedures
- Dimensional modeling: customer, product, and sales entities
- Star schema exposed as analytical views
- Data quality validation at Silver and Gold layers
- Local pipeline reproducibility through a Python runner

---

## License

MIT License

# sql-data-warehouse-project
Building a modern data warehouse with SQL Server, including ETL processes, data modeling, and analytics.
Project that demonstrates how to build a small data warehouse from raw CSV files to analytics-ready data using a **Bronze / Silver / Gold** architecture.

The project integrates CRM and ERP data, cleans and standardizes it, and exposes a final star schema for reporting.

---

## Architecture

![Data Architecture](docs/data_architecture.png)

```text
CSV Sources
   ↓
Bronze  → raw data loaded from CRM and ERP files
   ↓
Silver  → cleaned, standardized, and transformed data
   ↓
Gold    → business-ready views using a star schema
```

---

## Data Model

![Data Model](docs/data_model.png)

The Gold layer contains:

* `gold.dim_customers` — customer information enriched with demographic and location data.
* `gold.dim_products` — product information enriched with category data.
* `gold.fact_sales` — sales transactions connected to customers and products.

---

## Repository Structure

```text
sql-data-warehouse-project/
|
|-- datasets/                 # Expected local CSV structure documented in datasets/README.md
|-- docs/                     # Diagrams, data catalog, naming conventions
|-- scripts/
|   |-- init_database.sql     # Creates database and schemas
|   |-- bronze/               # Bronze tables and load procedure
|   |-- silver/               # Silver tables and transformation procedure
|   |-- gold/                 # Gold analytical views
|-- tests/                    # Data quality checks
|-- README.md
|-- LICENSE
```

---

## Technologies

* SQL Server
* T-SQL
* Stored Procedures
* CSV source files
* Draw.io diagrams
* Git / GitHub

---

## How to Run

1. Clone the repository:

```bash
git clone https://github.com/VladimirVAR/sql-data-warehouse-project.git
```

2. Run the database setup script:

```text
scripts/init_database.sql
```

3. Create Bronze tables:

```text
scripts/bronze/ddl_bronze.sql
```

4. Place the source CSV files in the expected local folders described in `datasets/README.md`, or update the paths inside:

```text
scripts/bronze/proc_load_bronze.sql
```

5. Load the Bronze layer:

```sql
EXEC bronze.load_bronze;
```

6. Create and load the Silver layer:

```text
scripts/silver/ddl_silver.sql
scripts/silver/proc_load_silver.sql
```

```sql
EXEC silver.load_silver;
```

7. Create the Gold views:

```text
scripts/gold/ddl_gold.sql
```

8. Run quality checks:

```text
tests/quality_checks_silver.sql
tests/quality_checks_gold.sql
```

---

## What This Project Demonstrates

* Data warehouse design using Bronze, Silver, and Gold layers.
* Loading raw CSV data with `BULK INSERT`.
* Building repeatable ETL processes with stored procedures.
* Cleaning and standardizing raw data.
* Handling duplicates, invalid dates, missing values, and inconsistent business rules.
* Creating analytical dimension and fact views.
* Validating data quality with SQL checks.
* Documenting architecture, data flow, naming conventions, and data catalog.

---

## Documentation

The `docs/` folder contains:

* Data architecture diagram
* Data flow diagram
* Data integration diagram
* Data model diagram
* ETL overview
* Data catalog
* Naming conventions

---

## Purpose

This is a learning and portfolio project focused on core data engineering skills: SQL development, ETL logic, data modeling, data quality, and technical documentation.

---

## License

This project is licensed under the MIT License.

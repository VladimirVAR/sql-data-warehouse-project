# Datasets

Source CSV files are **not** included in this repository. They are local execution inputs
loaded via BULK INSERT and must not be committed to Git.

## Where to place source files

Two layouts are supported.

**Option 1 - Neutral default path**

Place source files at `C:\sql\dwh_project\datasets\` and run without arguments:

```sql
EXEC bronze.load_bronze;
```

**Option 2 - Project-local path**

Place source files inside the project folder:

```
<project_root>\datasets\
|-- source_crm\
|   |-- cust_info.csv
|   |-- prd_info.csv
|   `-- sales_details.csv
`-- source_erp\
    |-- cust_country.csv
    |-- cust_demographics.csv
    `-- prod_category.csv
```

The `datasets/source_crm/` and `datasets/source_erp/` folders are listed in `.gitignore`
and will not be committed regardless of their contents.

Supply the path at execution time:

```sql
EXEC bronze.load_bronze
    @dataset_root = 'C:\Users\<you>\Desktop\sql-data-warehouse-project-github\datasets';
```

The personal path stays in your SSMS session only - it is never committed.

## Expected source file layout

Applies to both options above. File names must match exactly:

```
{dataset_root}\
|-- source_crm\
|   |-- cust_info.csv
|   |-- prd_info.csv
|   `-- sales_details.csv
`-- source_erp\
    |-- cust_country.csv
    |-- cust_demographics.csv
    `-- prod_category.csv
```

## Synthetic sample dataset

A small tracked synthetic dataset is planned for `datasets/sample/` to allow
demo runs without private source files. Not yet available.

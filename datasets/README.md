# Datasets

Source CSV files are **not** included in this repository. They are local execution inputs
loaded via BULK INSERT and must not be committed to Git.

Before running `bronze.load_bronze`, place source files under the path configured in the
procedure (default: `C:\sql\dwh_project\datasets\`):

```
C:\sql\dwh_project\datasets\
|-- source_crm\
|   |-- cust_info.csv
|   |-- prd_info.csv
|   `-- sales_details.csv
`-- source_erp\
    |-- cust_country.csv
    |-- cust_demographics.csv
    `-- prod_category.csv
```

The `datasets/` folder in this repository is a reference placeholder only.
To use a different base path, update the hardcoded paths in
`scripts/bronze/proc_load_bronze.sql` before deploying.

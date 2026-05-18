# Datasets

This folder is reserved for local source CSV files used by the data warehouse project.

The original source CSV files are not included in this repository.

To run the project locally, place the source files in the following structure:

```
datasets/
├── source_crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
└── source_erp/
    ├── CUST_AZ12.csv
    ├── LOC_A101.csv
    └── PX_CAT_G1V2.csv
```
These files are loaded by the Bronze layer procedure:

scripts/bronze/proc_load_bronze.sql

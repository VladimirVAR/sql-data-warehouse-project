/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    Loads data into the 'bronze' schema from external CSV files.
    Truncates each target table before inserting to ensure a clean full reload.

Parameters:
    None.

Usage Example:
    EXEC bronze.load_bronze;

-------------------------------------------------------------------------------
DEPLOYMENT CONFIGURATION — update file paths before executing
-------------------------------------------------------------------------------
BULK INSERT requires a literal string path; T-SQL does not allow a variable
in the FROM clause, so paths cannot be parameterised within the procedure.
Manage the base path at the deployment level:
  - To change the base path: edit the hardcoded paths in this procedure body
    before deploying (T-SQL BULK INSERT requires literal strings; there is no
    runtime injection point for callers or SQL Server Agent)
  - Alternative: store the path in a configuration table and call this
    procedure from a wrapper that builds the path (may move to a config
    table in a future iteration)

Expected source layout:
    {base_path}\source_crm\cust_info.csv
    {base_path}\source_crm\prd_info.csv
    {base_path}\source_crm\sales_details.csv
    {base_path}\source_erp\cust_country.csv
    {base_path}\source_erp\cust_demographics.csv
    {base_path}\source_erp\prod_category.csv

Current configured path: C:\sql\dwh_project\datasets\
-------------------------------------------------------------------------------
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_country';
		TRUNCATE TABLE bronze.erp_cust_country;
		PRINT '>> Inserting Data Into: bronze.erp_cust_country';
		BULK INSERT bronze.erp_cust_country
		FROM 'C:\sql\dwh_project\datasets\source_erp\cust_country.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_demographics';
		TRUNCATE TABLE bronze.erp_cust_demographics;
		PRINT '>> Inserting Data Into: bronze.erp_cust_demographics';
		BULK INSERT bronze.erp_cust_demographics
		FROM 'C:\sql\dwh_project\datasets\source_erp\cust_demographics.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_prod_category';
		TRUNCATE TABLE bronze.erp_prod_category;
		PRINT '>> Inserting Data Into: bronze.erp_prod_category';
		BULK INSERT bronze.erp_prod_category
		FROM 'C:\sql\dwh_project\datasets\source_erp\prod_category.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR);
		PRINT '==========================================' ;
		THROW;
	END CATCH
END

/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    Loads data into the 'bronze' schema from external CSV files.
    Truncates each target table before inserting to ensure a clean full reload.

Parameters:
    @dataset_root  NVARCHAR(500)
        Root path of the local CSV dataset directory.
        Default: 'C:\sql\dwh_project\datasets'
        Override at call time to point to any local path.
        The personal path is supplied at execution time and is never committed.

Usage:
    -- Default neutral path (files at C:\sql\dwh_project\datasets\)
    EXEC bronze.load_bronze;

    -- Project-local path (personal path, not committed to Git)
    EXEC bronze.load_bronze
        @dataset_root = 'C:\Users\<you>\Desktop\sql-data-warehouse-project-github\datasets';

    -- Synthetic sample data (planned, not yet available)
    EXEC bronze.load_bronze
        @dataset_root = '<project_root>\datasets\sample';

-------------------------------------------------------------------------------
BULK INSERT path strategy
-------------------------------------------------------------------------------
BULK INSERT requires a path string literal at execution time.
This procedure builds each path from @dataset_root using dynamic SQL
and executes it via sp_executesql with an OUTPUT parameter to capture @@ROWCOUNT.
Single quotes in @dataset_root are escaped before concatenation.

Real CSV files are local execution inputs and must not be committed to Git.
Place source files under the configured dataset root:

    {dataset_root}\source_crm\cust_info.csv
    {dataset_root}\source_crm\prd_info.csv
    {dataset_root}\source_crm\sales_details.csv
    {dataset_root}\source_erp\cust_country.csv
    {dataset_root}\source_erp\cust_demographics.csv
    {dataset_root}\source_erp\prod_category.csv

Default path: C:\sql\dwh_project\datasets
-------------------------------------------------------------------------------
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
	@dataset_root NVARCHAR(500) = 'C:\sql\dwh_project\datasets'
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @row_count INT;
	DECLARE @safe_root  NVARCHAR(500);
	DECLARE @sql        NVARCHAR(MAX);
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		SET @safe_root = REPLACE(@dataset_root, '''', '''''');

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
		SET @sql =
		    N'BULK INSERT bronze.crm_cust_info'
		  + N' FROM ''' + @safe_root + N'\source_crm\cust_info.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
		PRINT '>> -------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		SET @sql =
		    N'BULK INSERT bronze.crm_prd_info'
		  + N' FROM ''' + @safe_root + N'\source_crm\prd_info.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
		PRINT '>> -------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		SET @sql =
		    N'BULK INSERT bronze.crm_sales_details'
		  + N' FROM ''' + @safe_root + N'\source_crm\sales_details.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_country';
		TRUNCATE TABLE bronze.erp_cust_country;
		PRINT '>> Inserting Data Into: bronze.erp_cust_country';
		SET @sql =
		    N'BULK INSERT bronze.erp_cust_country'
		  + N' FROM ''' + @safe_root + N'\source_erp\cust_country.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_demographics';
		TRUNCATE TABLE bronze.erp_cust_demographics;
		PRINT '>> Inserting Data Into: bronze.erp_cust_demographics';
		SET @sql =
		    N'BULK INSERT bronze.erp_cust_demographics'
		  + N' FROM ''' + @safe_root + N'\source_erp\cust_demographics.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_prod_category';
		TRUNCATE TABLE bronze.erp_prod_category;
		PRINT '>> Inserting Data Into: bronze.erp_prod_category';
		SET @sql =
		    N'BULK INSERT bronze.erp_prod_category'
		  + N' FROM ''' + @safe_root + N'\source_erp\prod_category.csv'''
		  + N' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		  + N' SET @rc = @@ROWCOUNT;';
		EXEC sp_executesql
		    @sql,
		    N'@rc INT OUTPUT',
		    @rc = @row_count OUTPUT;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> Rows inserted: ' + CAST(@row_count AS NVARCHAR);
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

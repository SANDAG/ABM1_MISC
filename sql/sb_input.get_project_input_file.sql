USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sb_input].[get_project_input_file]    Script Date: 4/23/2019 8:40:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO















CREATE PROCEDURE [sb_input].[get_project_input_file]
	@lu_version_id smallint -- Need to specify [lu_version_id] located in [ref].[lu_version]
	,@file_path nvarchar(200) -- location of lu.csv file
AS
BEGIN

SET NOCOUNT ON
DECLARE @error_message nvarchar(200)
SET @file_path = REPLACE(LOWER(@file_path), 't:', '\\TNASA8')


CREATE TABLE
	#get_project_input_file_tt
(
	[mgra] int NOT NULL
	,[lu_type_id] tinyint NOT NULL
	,[lu_code] smallint NOT NULL
	,[amount] float NOT NULL
	,PRIMARY KEY ([mgra],[lu_type_id],[lu_code])
)

-- bulk insert csv file into temporary table
DECLARE @dynamic_sql nvarchar(max) = N'
BULK INSERT #get_project_input_file_tt
FROM ''' + @file_path + N'''
WITH
(
	FIELDTERMINATOR = '',''
	,FIRSTROW = 2
	,ROWTERMINATOR = ''\n''
)'
EXEC(@dynamic_sql)

-- condition check on [lu_type_id]
IF EXISTS(SELECT [lu_type_id] FROM #get_project_input_file_tt WHERE [lu_type_id] NOT IN (SELECT [lu_type_id] FROM [ref].[lu_type]))
BEGIN
    
	SET @error_message = '[lu_type_id] in file not found in [ref].[lu_type]'
	SELECT [lu_type_id] FROM #get_project_input_file_tt WHERE [lu_type_id] NOT IN (SELECT [lu_type_id] FROM [ref].[lu_type])
	RAISERROR(@error_message, 11, 1)
	RETURN
END

-- condition check on [lu_code]  -- added on 11/17/2015, yma
IF EXISTS(SELECT [lu_code] FROM #get_project_input_file_tt WHERE [lu_code] NOT IN (SELECT DISTINCT [lu_code] FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]()))
BEGIN
	SET @error_message = '[lu_code] in file not found in [sb_input].[lu_emp_enroll_density_sr13final_revised]()'
	RAISERROR(@error_message, 11, 1)
	SELECT [lu_code] FROM #get_project_input_file_tt WHERE [lu_code] NOT IN (SELECT [lu_code] FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
	RETURN
END


-- condition check on [mgra]
IF EXISTS(SELECT [mgra] FROM #get_project_input_file_tt WHERE [mgra] NOT IN (
																			SELECT
																				[mgra]
																			FROM
																				[abm_input].[lu_mgra_input]
																			WHERE
																				[lu_mgra_input].[lu_version_id] = @lu_version_id
																			))
BEGIN
	SET @error_message = '[mgra] in file not found in [abm_input].[lu_mgra_input] for [lu_version_id] = ' + CAST(@lu_version_id AS nvarchar(5))	
	RAISERROR(@error_message, 11, 1)
	SELECT [mgra] FROM #get_project_input_file_tt WHERE [mgra] NOT IN (
																			SELECT
																				[mgra]
																			FROM
																				[abm_input].[lu_mgra_input]
																			WHERE
																				[lu_mgra_input].[lu_version_id] = @lu_version_id
																			)
	RETURN
END

-- return contents of the temporary table
SELECT
	[mgra]
	,[lu_type_id]
	,[lu_code]
	,[amount]
FROM
	#get_project_input_file_tt
END










GO


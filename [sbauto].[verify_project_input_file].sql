USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[verify_project_input_file]    Script Date: 4/23/2019 8:44:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<YMA>
-- Create date: <6/4/2018>
-- Description:	<This procedure is modified to verify input file for sb landsue override automating>
-- =============================================


CREATE PROCEDURE [sbauto].[verify_project_input_file]

AS
BEGIN

SET NOCOUNT ON
DECLARE @error_message nvarchar(200)
TRUNCATE TABLE [sbauto].[temp_lucsv_error]  
TRUNCATE TABLE [sbauto].[temp_lucsv_mgra_error]

-- condition check on [lu_type_id] & [lu_code]  -- added on 4/16/2018, yma

IF EXISTS(
          SELECT distinct lu_type_id,lu_code,CONCAT(lu_type_id,'_',lu_code) as com_code
          FROM sbauto.get_project_input_file_tt
          WHERE CONCAT(lu_type_id,'_',lu_code) not in  (SELECT distinct CONCAT(lu_type_id,'_',lu_code) as com_code   FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
          )
BEGIN
	INSERT INTO [sbauto].[temp_lucsv_error]
	    SELECT distinct lu_type_id,lu_code,CONCAT(lu_type_id,'_',lu_code) as com_code
        FROM sbauto.get_project_input_file_tt
        WHERE CONCAT(lu_type_id,'_',lu_code) not in  (SELECT distinct CONCAT(lu_type_id,'_',lu_code) as com_code   FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
	SET @error_message =N'[lu_type_id]_n_[lu_code] not found in density table, check the lu_input_error.csv file'
	RAISERROR(@error_message, 11, 1)
	--RETURN
END

-- condition check on [mgra]
 
IF EXISTS(SELECT [mgra] FROM sbauto.get_project_input_file_tt WHERE [mgra] > 23002) 
BEGIN
	    INSERT INTO [sbauto].[temp_lucsv_mgra_error]
	    SELECT [mgra] FROM sbauto.get_project_input_file_tt WHERE [mgra] > 23002 
	SET @error_message = N'[mgra] out of scope, check the lu_input_error_mgra.csv file' 	
	RAISERROR(@error_message, 11, 1)
	--RETURN
END


END

GO



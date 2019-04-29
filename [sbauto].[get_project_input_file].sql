USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[get_project_input_file]    Script Date: 4/23/2019 8:43:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<YMA>
-- Create date: <4/16/2018>
-- Description:	<This procedure is modified to verify input file for sb landsue override automating>
-- =============================================


CREATE PROCEDURE [sbauto].[get_project_input_file]


AS
BEGIN

SET NOCOUNT ON
DECLARE @error_message nvarchar(200)

BEGIN TRANSACTION service_bureau_job_override_auto WITH mark

BEGIN TRY

-- condition check on [lu_type_id]
IF EXISTS(SELECT [lu_type_id] FROM sbauto.get_project_input_file_tt WHERE [lu_type_id] NOT IN (SELECT [lu_type_id] FROM [ref].[lu_type]))
BEGIN
   	SELECT [lu_type_id] FROM sbauto.get_project_input_file_tt WHERE [lu_type_id] NOT IN (SELECT [lu_type_id] FROM [ref].[lu_type])
	SET @error_message = '          [lu_type_id] in file not found in [ref].[lu_type]'
	RAISERROR(@error_message, 11, 1)
	RETURN
END

-- condition check on [lu_code]  -- added on 11/17/2015, yma
IF EXISTS(SELECT [lu_code] FROM sbauto.get_project_input_file_tt WHERE [lu_code] NOT IN (SELECT DISTINCT [lu_code] FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]()))
BEGIN
	SELECT [lu_code] FROM sbauto.get_project_input_file_tt WHERE [lu_code] NOT IN (SELECT [lu_code] FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
	SET @error_message = '          [lu_code] in file not found in [sb_input].[lu_emp_enroll_density_sr13final_revised]()'
	RAISERROR(@error_message, 11, 1)
	RETURN
END


-- condition check on [lu_type_id] & [lu_code]  -- added on 4/16/2018, yma
IF EXISTS(
          SELECT distinct lu_type_id,lu_code,CONCAT(lu_type_id,'_',lu_code) as com_code
          FROM sbauto.get_project_input_file_tt
          WHERE CONCAT(lu_type_id,'_',lu_code) not in  (SELECT distinct CONCAT(lu_type_id,'_',lu_code) as com_code   FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
          )
BEGIN
	SELECT distinct lu_type_id,lu_code,CONCAT(lu_type_id,'_',lu_code) as com_code
          FROM sbauto.get_project_input_file_tt
          WHERE CONCAT(lu_type_id,'_',lu_code) not in  (SELECT distinct CONCAT(lu_type_id,'_',lu_code) as com_code   FROM [sb_input].[lu_emp_enroll_density_sr13final_revised]())
	SET @error_message =N'[         lu_type_id]_n_[lu_code] not found in [sb_input].[lu_emp_enroll_density_sr13final_revised]()'
	RAISERROR(@error_message, 11, 1)
	RETURN
END


-- condition check on [mgra]
IF EXISTS(SELECT [mgra] FROM sbauto.get_project_input_file_tt WHERE [mgra] > 23002) 
BEGIN
	SELECT [mgra] FROM sbauto.get_project_input_file_tt WHERE [mgra] > 23002 
	SET @error_message = '          [mgra] in file out of scope ' 	
	RAISERROR(@error_message, 11, 1)
	RETURN
END

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH

COMMIT TRANSACTION
END

GO



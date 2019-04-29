USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[save_4d_output]    Script Date: 4/23/2019 8:44:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <4/26/2018>
-- Description:	<save 4d output file>
-- =============================================


CREATE PROCEDURE [sbauto].[save_4d_output]
 @lu_scenario_desc nvarchar(200)
,@new_lu_version_id int

AS
BEGIN

BEGIN TRY
INSERT INTO
	[sbauto].[lu_mgra_4d_output_keep](
	[lu_scenario_desc],
	[lu_version_id],
	[mgra], 
	[totint], 
	[duden], 
	[empden], 
	[popden],
	[retempden], 
	[totintbin], 
	[empdenbin], 
	[dudenbin])
SELECT 
    @lu_scenario_desc as [lu_scenario_desc],
	@new_lu_version_id as lu_version_id,
	[mgra], 
	[totint], 
	[duden], 
	[empden], 
	[popden],
	[retempden], 
	[totintbin], 
	[empdenbin], 
	[dudenbin]	
	FROM sbauto.lu_mgra_4d_output

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH

END
GO



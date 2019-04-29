USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn_input].[control_targets_region]    Script Date: 4/23/2019 9:02:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION 
	[popsyn_input].[control_targets_region] 
(
	@lu_version_id smallint
)
RETURNS TABLE AS

RETURN
(
SELECT
	tt2.[lu_version_id]
	,[zone] AS [region]
	,tt2.[pop_non_gq]
	,tt2.[gq_noninst]
FROM (
	SELECT 
		[lu_version_id]
		,[zone]
		,[target_category].[target_category_col_nm]
		,[value]
	FROM 
		[popsyn_input].[control_targets]
	INNER JOIN
		[data_cafe].[ref].[geography_zone]
	ON
		[control_targets].[geography_zone_id] = [geography_zone].[geography_zone_id]
	INNER JOIN
		[ref].[target_category]
	ON
		[control_targets].[target_category_id] = [target_category].[target_category_id]
	WHERE 
		[geography_type_id] = 4 -- San Diego Region harcoded
		AND [lu_version_id] = @lu_version_id
) tt1
PIVOT (
	SUM([value])
	FOR 
		[target_category_col_nm] 
	IN (
		[pop_non_gq]
		,[gq_noninst]
		)
) tt2
)
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to create wide form region control targets for java program' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_region'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_region'
GO



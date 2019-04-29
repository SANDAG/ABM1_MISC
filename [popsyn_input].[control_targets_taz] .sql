USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn_input].[control_targets_taz]    Script Date: 4/23/2019 9:03:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION 
	[popsyn_input].[control_targets_taz] 
(
	@lu_version_id smallint
)

RETURNS @ret_controltargetstaz TABLE
(
	[lu_version_id] smallint
	,[taz] int
	,[puma] int
	,[region] int
	,[hhwoc] int
	,[hhwc] int
	,[hhworkers0] int
	,[hhworkers1] int
	,[hhworkers2] int
	,[hhworkers3] int
	,[hh_income_cat_1] int
	,[hh_income_cat_2] int
	,[hh_income_cat_3] int
	,[hh_income_cat_4] int
	,[hh_income_cat_5] int
	,[male] int
	,[female] int
	,[age_0_17] int
	,[age_18_24] int
	,[age_25_34] int
	,[age_35_49] int
	,[age_50_64] int
	,[age_65_79] int
	,[age_80plus] int
	,[hisp] int
	,[nhw] int
	,[nhb] int
	,[nho_popsyn] int
	,[nha] int
	,PRIMARY KEY ([lu_version_id], [taz])
)

BEGIN

DECLARE @mid_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)

INSERT INTO @ret_controltargetstaz
SELECT
	tt2.[lu_version_id]
	,[taz]
	,[puma]
	,[region]
	,tt2.[hhwoc]
	,tt2.[hhwc]
	,tt2.[hhworkers0]
	,tt2.[hhworkers1]
	,tt2.[hhworkers2]
	,tt2.[hhworkers3]
	,tt2.[hh_income_cat_1]
	,tt2.[hh_income_cat_2]
	,tt2.[hh_income_cat_3]
	,tt2.[hh_income_cat_4]
	,tt2.[hh_income_cat_5]
	,ISNULL(tt2.[male], 0) AS [male]
	,ISNULL(tt2.[female], 0) AS [female]
	,ISNULL(tt2.[age_0_17], 0) AS [age_0_17]
	,ISNULL(tt2.[age_18_24], 0) AS [age_18_24]
	,ISNULL(tt2.[age_25_34], 0) AS [age_25_34]
	,ISNULL(tt2.[age_35_49], 0) AS [age_35_49]
	,ISNULL(tt2.[age_50_64], 0) AS [age_50_64]
	,ISNULL(tt2.[age_65_79], 0) AS [age_65_79]
	,ISNULL(tt2.[age_80plus], 0) AS [age_80plus]
	,ISNULL(tt2.[hisp], 0) AS [hisp]
	,ISNULL(tt2.[nhw], 0) AS [nhw]
	,ISNULL(tt2.[nhb], 0) AS [nhb]
	,ISNULL(tt2.[nho_popsyn], 0) AS [nho_popsyn]
	,ISNULL(tt2.[nha], 0) AS [nha]
FROM (
	SELECT 
		[lu_version_id]
		,[mid_puma_xref].[child_zone] AS [taz]
		,[mid_puma_xref].[parent_zone] AS [puma]
		,[mid_region_xref].[parent_zone] AS [region]
		,[target_category].[target_category_col_nm]
		,[value]
	FROM 
		[popsyn_input].[control_targets]
	INNER JOIN (
		SELECT
			[child_geography_zone_id]
			,[child_zone].[zone] AS [child_zone]
		    ,[parent_geography_zone_id]
			,[parent_zone].[zone] AS [parent_zone]
		FROM 
			[data_cafe].[ref].[geography_xref]
		INNER JOIN
			[data_cafe].[ref].[geography_zone] AS [child_zone]
		ON
			[geography_xref].[child_geography_zone_id] = [child_zone].[geography_zone_id]
		INNER JOIN
			[data_cafe].[ref].[geography_zone] AS [parent_zone]
		ON
			[geography_xref].[parent_geography_zone_id] = [parent_zone].[geography_zone_id]
		WHERE
			[child_zone].[geography_type_id] = @mid_geography_type_id
			AND [parent_zone].[geography_type_id] = 69 -- hardcoded puma_2000 geography_type_id
		) AS [mid_puma_xref]
	ON
		[control_targets].[geography_zone_id] = [mid_puma_xref].[child_geography_zone_id]
	INNER JOIN (
		SELECT
			[child_geography_zone_id]
			,[child_zone].[zone] AS [child_zone]
		    ,[parent_geography_zone_id]
			,[parent_zone].[zone] AS [parent_zone]
		FROM 
			[data_cafe].[ref].[geography_xref]
		INNER JOIN
			[data_cafe].[ref].[geography_zone] AS [child_zone]
		ON
			[geography_xref].[child_geography_zone_id] = [child_zone].[geography_zone_id]
		INNER JOIN
			[data_cafe].[ref].[geography_zone] AS [parent_zone]
		ON
			[geography_xref].[parent_geography_zone_id] = [parent_zone].[geography_zone_id]
		WHERE
			[child_zone].[geography_type_id] = @mid_geography_type_id
			AND [parent_zone].[geography_type_id] = 4 -- hardcoded region_2004 geography_type_id
		) AS [mid_region_xref]
	ON
		[control_targets].[geography_zone_id] = [mid_region_xref].[child_geography_zone_id]
	INNER JOIN
		[ref].[target_category]
	ON
		[control_targets].[target_category_id] = [target_category].[target_category_id]
	WHERE 
		[lu_version_id] = @lu_version_id
) tt1
PIVOT (
	SUM([value])
	FOR 
		[target_category_col_nm] 
	IN (
		[hhwoc]
		,[hhwc]
		,[hhworkers0]
		,[hhworkers1]
		,[hhworkers2]
		,[hhworkers3]
		,[hh_income_cat_1]
		,[hh_income_cat_2]
		,[hh_income_cat_3]
		,[hh_income_cat_4]
		,[hh_income_cat_5]
		,[male]
		,[female]
		,[age_0_17]
		,[age_18_24]
		,[age_25_34]
		,[age_35_49]
		,[age_50_64]
		,[age_65_79]
		,[age_80plus]
		,[hisp]
		,[nhw]
		,[nhb]
		,[nho_popsyn]
		,[nha]
		)
) tt2

RETURN
END 
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to create wide form taz control targets for java program' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_taz'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_taz'
GO



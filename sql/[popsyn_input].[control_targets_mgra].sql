USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn_input].[control_targets_mgra]    Script Date: 4/23/2019 9:02:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION 
	[popsyn_input].[control_targets_mgra] 
(
	@lu_version_id smallint
)

RETURNS @ret_controltargetsmgra TABLE
(
	[lu_version_id] smallint
	,[mgra] int
	,[taz] int
	,[puma] int
	,[region] int
	,[hh_sf] int
	,[hh_mf] int
	,[hh_mh] int
	,[hh] int
	,[gq_noninst] int
	,[gq_civ_college] int
	,[gq_mil] int
	,[pop_non_gq] int
	,PRIMARY KEY ([lu_version_id],[mgra])
)

BEGIN

DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
DECLARE @mid_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)

INSERT INTO @ret_controltargetsmgra
SELECT
	tt2.[lu_version_id]
	,[mgra]
	,[taz]
	,[puma]
	,[region]
	,tt2.[hh_sf]
	,tt2.[hh_mf]
	,tt2.[hh_mh]
	,tt2.[hh]
	,tt2.[gq_noninst]
	,tt2.[gq_civ_college]
	,tt2.[gq_mil]
	,tt2.[pop_non_gq]
FROM (
	SELECT 
		[lu_version_id]
		,[minor_mid_xref].[child_zone] AS [mgra]
		,[minor_mid_xref].[parent_zone] AS [taz]
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
			[child_zone].[geography_type_id] = @minor_geography_type_id
			AND [parent_zone].[geography_type_id] = @mid_geography_type_id
		) AS [minor_mid_xref]
	ON
		[control_targets].[geography_zone_id] = [minor_mid_xref].[child_geography_zone_id]
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
		[minor_mid_xref].[parent_geography_zone_id] = [mid_puma_xref].[child_geography_zone_id]
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
		[minor_mid_xref].[parent_geography_zone_id] = [mid_region_xref].[child_geography_zone_id]
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
		[hh_sf]
		,[hh_mf]
		,[hh_mh]
		,[hh]
		,[gq_noninst]
		,[gq_civ_college]
		,[gq_mil]
		,[pop_non_gq]
		)
) tt2
RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to create wide form mgra control targets for java program' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_mgra'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'FUNCTION',@level1name=N'control_targets_mgra'
GO



USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn].[synpop_target_category_results]    Script Date: 4/23/2019 9:01:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION
	[popsyn].[synpop_target_category_results]
(
	@popsyn_run_id smallint
	,@geography_type_id int
)
RETURNS @ret_synpop_target_category_results TABLE
(
	[lu_version_id] [smallint] NOT NULL
	,[target_category_id] [smallint] NOT NULL
	,[geography_zone_id] [int] NOT NULL
	,[value] [int] NOT NULL
	,PRIMARY KEY ([lu_version_id],[target_category_id],[geography_zone_id])
)
AS
BEGIN

DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id]  WHERE [popsyn_run_id] = @popsyn_run_id)

INSERT INTO @ret_synpop_target_category_results
-- household results
SELECT
	[lu_version_id]
	,[target_category_id]
	,[parent_geography_zone_id]
	,[value]
FROM (
	SELECT
		[lu_version_id]
		,[parent_geography_zone_id]
		,SUM([final_weight]) AS [hh]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_sf]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_mf]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_mh]
		,SUM([final_weight] * CASE WHEN [hh_child] = 0 THEN 1 ELSE 0 END) AS [hhwoc]
		,SUM([final_weight] * CASE WHEN [hh_child] = 1 THEN 1 ELSE 0 END) AS [hhwc]
		,SUM([final_weight] * CASE WHEN [workers] = 0 THEN 1 ELSE 0 END) AS [hhworkers0]
		,SUM([final_weight] * CASE WHEN [workers] = 1 THEN 1 ELSE 0 END) AS [hhworkers1]
		,SUM([final_weight] * CASE WHEN [workers] = 2 THEN 1 ELSE 0 END) AS [hhworkers2]
		,SUM([final_weight] * CASE WHEN [workers] >= 3 THEN 1 ELSE 0 END) AS [hhworkers3]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] < 30000 THEN 1 ELSE 0 END) AS [hh_income_cat_1]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 30000 AND [hh_income_adj] < 60000 THEN 1 ELSE 0 END) AS [hh_income_cat_2]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 60000 AND [hh_income_adj] < 100000 THEN 1 ELSE 0 END) AS [hh_income_cat_3]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 100000 AND [hh_income_adj] < 150000 THEN 1 ELSE 0 END) AS [hh_income_cat_4]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 150000 THEN 1 ELSE 0 END) AS [hh_income_cat_5]
	FROM
		[popsyn].[synpop_hh]
	INNER JOIN
		[ref].[popsyn_run]
	ON
		[synpop_hh].[popsyn_run_id] = [popsyn_run].[popsyn_run_id]
	INNER JOIN
		[popsyn_input].[hh]
	ON
		[popsyn_run].[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
		AND [synpop_hh].[hh_id] = [hh].[hh_id]
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
			AND [parent_zone].[geography_type_id] = @geography_type_id
	) AS [minor_geotype_xref]
	ON
		[synpop_hh].[mgra] = [minor_geotype_xref].[child_zone]
	WHERE
		[synpop_hh].[popsyn_run_id] = @popsyn_run_id
		AND [popsyn_run].[popsyn_run_id] = @popsyn_run_id
		AND [gq_type_id] = 0
	GROUP BY
		[lu_version_id]
		,[parent_geography_zone_id]
	) AS hh_popsyn
UNPIVOT (
	[value]
	FOR [target_col_nm] IN (
		[hh]
		,[hh_sf]
		,[hh_mf]
		,[hh_mh]
		,[hhwoc]
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
		)
	) tt1
INNER JOIN
	[ref].[target_category]
ON
	tt1.[target_col_nm] = [target_category].[target_category_col_nm]

UNION ALL

-- person results
SELECT
	[lu_version_id]
	,[target_category_id]
	,[parent_geography_zone_id]
	,[value]
FROM (
	SELECT
		[lu_version_id]
		,[parent_geography_zone_id]
		,SUM([synpop_hh].[final_weight]) AS [pop_non_gq]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 1 THEN 1 ELSE 0 END) AS [male]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 2 THEN 1 ELSE 0 END) AS [female]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] <= 17 THEN 1 ELSE 0 END) AS [age_0_17]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 18 AND 24 THEN 1 ELSE 0 END) AS [age_18_24]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 25 AND 34 THEN 1 ELSE 0 END) AS [age_25_34]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 35 AND 49 THEN 1 ELSE 0 END) AS [age_35_49]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 50 AND 64 THEN 1 ELSE 0 END) AS [age_50_64]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 65 AND 79 THEN 1 ELSE 0 END) AS [age_65_79]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] >= 80 THEN 1 ELSE 0 END) AS [age_80plus]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 1 THEN 1 ELSE 0 END) AS [hisp]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 2 THEN 1 ELSE 0 END) AS [nhw]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 3 THEN 1 ELSE 0 END) AS [nhb]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 4 THEN 1 ELSE 0 END) AS [nho_popsyn]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 5 THEN 1 ELSE 0 END) AS [nha]
	FROM
		[popsyn].[synpop_person]
	INNER JOIN
		[ref].[popsyn_run]
	ON
		[synpop_person].[popsyn_run_id] = [popsyn_run].[popsyn_run_id]
	INNER JOIN
		[popsyn].[synpop_hh]
	ON
		[synpop_person].[popsyn_run_id] = [synpop_hh].[popsyn_run_id]
		AND [synpop_person].[synpop_hh_id] = [synpop_hh].[synpop_hh_id]
	INNER JOIN
		[popsyn_input].[person]
	ON
		[popsyn_run].[popsyn_data_source_id] = [person].[popsyn_data_source_id]
		AND [synpop_person].[person_id] = [person].[person_id]
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
			AND [parent_zone].[geography_type_id] = @geography_type_id
	) AS [minor_geotype_xref]
	ON
		[synpop_hh].[mgra] = [minor_geotype_xref].[child_zone]
	WHERE
		[synpop_person].[popsyn_run_id] = @popsyn_run_id
		AND [synpop_hh].[popsyn_run_id] = @popsyn_run_id
		AND [popsyn_run].[popsyn_run_id] = @popsyn_run_id
		AND [gq_type_id] = 0
	GROUP BY
		[lu_version_id]
		,[parent_geography_zone_id]
	) AS person_popsyn
UNPIVOT (
	[value]
	FOR [target_col_nm] IN (
		[pop_non_gq]
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
INNER JOIN
	[ref].[target_category]
ON
	tt2.[target_col_nm] = [target_category].[target_category_col_nm]

UNION ALL

-- gq results
SELECT
	[lu_version_id]
	,[target_category_id]
	,[parent_geography_zone_id]
	,[value]
FROM (
	SELECT
		[lu_version_id]
		,[parent_geography_zone_id]
		,SUM([final_weight]) AS [gq_noninst]
		,SUM([final_weight] * CASE WHEN [gq_type_id] = 1 THEN 1 ELSE 0 END) AS [gq_civ_college]
		,SUM([final_weight] * CASE WHEN [gq_type_id] = 2 THEN 1 ELSE 0 END) AS [gq_mil]
	FROM
		[popsyn].[synpop_hh]
	INNER JOIN
		[ref].[popsyn_run]
	ON
		[synpop_hh].[popsyn_run_id] = [popsyn_run].[popsyn_run_id]
	INNER JOIN
		[popsyn_input].[hh]
	ON
		[popsyn_run].[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
		AND [synpop_hh].[hh_id] = [hh].[hh_id]
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
			AND [parent_zone].[geography_type_id] = @geography_type_id
	) AS [minor_geotype_xref]
	ON
		[synpop_hh].[mgra] = [minor_geotype_xref].[child_zone]
	WHERE
		[synpop_hh].[popsyn_run_id] = @popsyn_run_id
		AND [popsyn_run].[popsyn_run_id] = @popsyn_run_id
		AND [gq_type_id] > 0 -- group quarter households
	GROUP BY
		[lu_version_id]
		,[parent_geography_zone_id]
	) AS hh_popsyn
UNPIVOT (
	[value]
	FOR [target_col_nm] IN (
		[gq_noninst]
		,[gq_civ_college]
		,[gq_mil]
		)
	) tt1
INNER JOIN
	[ref].[target_category]
ON
	tt1.[target_col_nm] = [target_category].[target_category_col_nm]

RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to output popsyn results by target category at a specified geography' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'synpop_target_category_results'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'synpop_target_category_results'
GO



USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sb_input].[calculate_project_popsyn_control_targets]    Script Date: 4/23/2019 9:04:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION
	[sb_input].[calculate_project_popsyn_control_targets] 
(
	@popsyn_run_id int -- need to specify [popsyn_run_id] in [ref].[popsyn_run] of the base scenario 
	,@project_input_table AS project_input_table_type READONLY
	
)
RETURNS @calculate_project_popsyn_control_targets TABLE 
(
	[target_category_id] smallint NOT NULL
    ,[geography_zone_id] int NOT NULL
	,[value] int NOT NULL
)
AS
BEGIN


DECLARE @major_geography_type_id smallint = 
						(
							SELECT 
								[major_geography_type_id] 
							FROM
								[ref].[lu_version]
							INNER JOIN
								[ref].[popsyn_run]
							ON 
								[lu_version].[lu_version_id] = [popsyn_run].[lu_version_id] 
							WHERE 
								[popsyn_run_id] = @popsyn_run_id
						)


-- mgra level control targets
INSERT INTO @calculate_project_popsyn_control_targets
SELECT
	[target_category_id]
    ,[mgra_geography_zone_id]
	,[value]
FROM
(
	SELECT
		[mgra_geography_zone_id]
		,[hh]
		,[hh_sf]
		,[hh_mf]
		,[hh_mh]
		,([gq_mil] + [gq_civ]) AS [gq_noninst]
		,[gq_civ] AS [gq_civ_college]
		,[gq_mil]
		,[hhp] AS [pop_non_gq]
	FROM
		[sb_input].[calculate_project_mgra_based_inputs] (@popsyn_run_id ,@project_input_table)
) AS [p]
UNPIVOT
(
	[value]
	FOR [target_category_col_nm] IN 
		(
			[hh]
			,[hh_sf]
			,[hh_mf]
			,[hh_mh]
			,[gq_noninst]
			,[gq_civ_college]
			,[gq_mil]
			,[pop_non_gq]
		)
) AS [pvt]
INNER JOIN
	[ref].[target_category]
ON
	[pvt].[target_category_col_nm] = [target_category].[target_category_col_nm]


-- taz level control targets generated from luz if they exist else regional distributions
INSERT INTO @calculate_project_popsyn_control_targets
SELECT
	[target_category_id]
    ,[taz_geography_zone_id]
	,CAST([value] AS int) AS [value]
FROM
(
	SELECT 
		[taz_level_override].[taz_geography_zone_id]
		,[hhwoc] = CAST(ROUND
					(
						CASE 
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhwoc_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhwoc_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END +
						CASE 
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhwoc_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhwoc_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE 
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhwoc_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhwoc_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hhwc] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhwc_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhwc_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhwc_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhwc_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhwc_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhwc_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hhworkers0] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers0_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers0_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers0_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers0_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers0_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers0_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hhworkers1] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers1_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers1_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers1_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers1_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers1_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers1_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hhworkers2] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers2_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers2_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers2_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers2_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers2_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers2_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hhworkers3] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers3_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers3_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers3_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers3_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hhworkers3_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hhworkers3_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hh_income_cat_1] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_1_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_1_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_1_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_1_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_1_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_1_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hh_income_cat_2] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_2_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_2_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_2_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_2_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_2_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_2_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hh_income_cat_3] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_3_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_3_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_3_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_3_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_3_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_3_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hh_income_cat_4] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_4_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_4_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_4_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_4_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_4_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_4_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[hh_income_cat_5] = CAST(ROUND
					(
						CASE
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_5_sf] / [major_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_5_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_5_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_5_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hh_income_cat_5_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hh_income_cat_5_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh]
						ELSE NULL END
					, 0) AS int)
		,[male] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[male_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[male_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[male_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[male_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[male_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[male_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[female] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[female_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[female_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[female_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[female_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[female_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[female_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_0_17] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_0_17_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_0_17_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_0_17_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_0_17_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_0_17_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_0_17_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_18_24] =	CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_18_24_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_18_24_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_18_24_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_18_24_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_18_24_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_18_24_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_25_34] =	CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_25_34_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_25_34_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_25_34_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_25_34_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_25_34_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_25_34_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_35_49] =	CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_35_49_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_35_49_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_35_49_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_35_49_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_35_49_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_35_49_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_50_64] =	CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_50_64_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_50_64_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_50_64_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_50_64_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_50_64_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_50_64_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_65_79] =	CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_65_79_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_65_79_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_65_79_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_65_79_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_65_79_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_65_79_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[age_80plus] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[age_80plus_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[age_80plus_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[age_80plus_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[age_80plus_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[age_80plus_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[age_80plus_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[hisp] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[hisp_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[hisp_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[hisp_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[hisp_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[hisp_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[hisp_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[nhw] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[nhw_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[nhw_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[nhw_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[nhw_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[nhw_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[nhw_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[nhb] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[nhb_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[nhb_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[nhb_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[nhb_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[nhb_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[nhb_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[nho_popsyn] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[nho_popsyn_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[nho_popsyn_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[nho_popsyn_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[nho_popsyn_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[nho_popsyn_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[nho_popsyn_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
		,[nha] = CAST(ROUND
					(
						CASE	
						WHEN [major_controls_distribution].[hh_sf] > 0 THEN (1.0 * [major_controls_distribution].[nha_sf] / [major_controls_distribution].[pop_non_gq_sf]) * [taz_level_override].[hh_sf] * [major_controls_distribution].[hhs_sf]
						WHEN [region_controls_distribution].[hh_sf] > 0 THEN (1.0 * [region_controls_distribution].[nha_sf] / [region_controls_distribution].[hh_sf]) * [taz_level_override].[hh_sf] * [region_controls_distribution].[hhs_sf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mf] > 0 THEN (1.0 * [major_controls_distribution].[nha_mf] / [major_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [major_controls_distribution].[hhs_mf]
						WHEN [region_controls_distribution].[hh_mf] > 0 THEN (1.0 * [region_controls_distribution].[nha_mf] / [region_controls_distribution].[hh_mf]) * [taz_level_override].[hh_mf] * [region_controls_distribution].[hhs_mf]
						ELSE NULL END + 
						CASE	
						WHEN [major_controls_distribution].[hh_mh] > 0 THEN (1.0 * [major_controls_distribution].[nha_mh] / [major_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [major_controls_distribution].[hhs_mh]
						WHEN [region_controls_distribution].[hh_mh] > 0 THEN (1.0 * [region_controls_distribution].[nha_mh] / [region_controls_distribution].[hh_mh]) * [taz_level_override].[hh_mh] * [region_controls_distribution].[hhs_mh]
						ELSE NULL END
					, 0) AS int)
	FROM 
	(
		SELECT 
			[taz_geography_zone_id]
			,MIN([luz_geography_zone_id]) AS [luz_geography_zone_id]
			,SUM([hh_sf]) AS [hh_sf]
			,SUM([hh_mf]) AS [hh_mf]
			,SUM([hh_mh]) AS [hh_mh]
		FROM
			[sb_input].[calculate_project_mgra_based_inputs] (@popsyn_run_id ,@project_input_table)
		GROUP BY
			[taz_geography_zone_id]
	) AS [taz_level_override]
	INNER JOIN
		[sb_input].[synpop_controls_aggregator](@popsyn_run_id, @major_geography_type_id) AS [major_controls_distribution]
	ON
		[taz_level_override].[luz_geography_zone_id] = [major_controls_distribution].[parent_geography_zone_id]
	CROSS JOIN
		[sb_input].[synpop_controls_aggregator](@popsyn_run_id, 4) AS [region_controls_distribution] --NOTE: regional geography type id is hard coded; unlikely that this will change
) AS [p]
UNPIVOT
(
	[value]
	FOR [target_category_col_nm] IN 
		(
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
) AS [pvt]
INNER JOIN
	[ref].[target_category]
ON
	[pvt].[target_category_col_nm] = [target_category].[target_category_col_nm]


-- region level control targets
INSERT INTO @calculate_project_popsyn_control_targets
SELECT
	[target_category_id]
    ,[region_geography_zone_id]
	,[value]
FROM
(
	SELECT
		1 AS [region_geography_zone_id] --NOTE: regional geography zone id is hard coded; unlikely that this will change
		,SUM([gq_mil] + [gq_civ]) AS [gq_noninst]
		,SUM([hhp]) AS [pop_non_gq]
	FROM
		[sb_input].[calculate_project_mgra_based_inputs] (@popsyn_run_id ,@project_input_table)
) AS [p]
UNPIVOT
(
	[value]
	FOR [target_category_col_nm] IN 
		(
			[gq_noninst]
			,[pop_non_gq]
		)
) AS [pvt]
INNER JOIN
	[ref].[target_category]
ON
	[pvt].[target_category_col_nm] = [target_category].[target_category_col_nm]

RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'calculates project inputs for popsyn control targets' , @level0type=N'SCHEMA',@level0name=N'sb_input', @level1type=N'FUNCTION',@level1name=N'calculate_project_popsyn_control_targets'
GO



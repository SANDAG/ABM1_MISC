USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sb_input].[synpop_controls_aggregator]    Script Date: 4/23/2019 9:06:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION
	[sb_input].[synpop_controls_aggregator]
(
	/*
	    [sb_input].[synpop_controls_agrregator] - Function returns a table with aggregate control totals segmented by housing type from a target synthetic population 
		specified by @popsyn_run_id aggregated to the geography that is specified by @geography_type_id.
	    
	    Parameters
	    ----------
		popsyn_run_id - Synthetic population vintage to use indicated by the id of the run
		geography_type_id - geography at which the run should be agrgregated. Refer to table [data_cafe].[ref].[geography_type] for details
	    
	    @authors: Sriram Narayanamoorthy (sn); Gregor Schroeder (gs)
	    @date: 2015-05-20

		version_notes
		sn (5/20): initial function commit
		gs (5/28): function updated to accomodate smaller hh income categories
	*/

	@popsyn_run_id smallint
	,@geography_type_id int
)
RETURNS @ret_synpop_aggregated_targets TABLE
(
	[lu_version_id] [smallint] NOT NULL
	,[parent_geography_zone_id] [int] NOT NULL
	,[hh_sf] [int] NOT NULL
	,[hh_mf] [int] NOT NULL
	,[hh_mh] [int] NOT NULL
	,[hhwoc_sf] [int] NOT NULL
	,[hhwoc_mf] [int] NOT NULL
	,[hhwoc_mh] [int] NOT NULL	
	,[hhwc_sf] [int] NOT NULL
	,[hhwc_mf] [int] NOT NULL	
	,[hhwc_mh] [int] NOT NULL	
	,[hhworkers0_sf] [int] NOT NULL 
	,[hhworkers0_mf] [int] NOT NULL 		
	,[hhworkers0_mh] [int] NOT NULL 		
	,[hhworkers1_sf] [int] NOT NULL 
	,[hhworkers1_mf] [int] NOT NULL 		
	,[hhworkers1_mh] [int] NOT NULL 		
	,[hhworkers2_sf] [int] NOT NULL 
	,[hhworkers2_mf] [int] NOT NULL 		
	,[hhworkers2_mh] [int] NOT NULL 		
	,[hhworkers3_sf] [int] NOT NULL 
	,[hhworkers3_mf] [int] NOT NULL 	
	,[hhworkers3_mh] [int] NOT NULL 
	,[pop_non_gq_sf] [int] NOT NULL
	,[pop_non_gq_mf] [int] NOT NULL
	,[pop_non_gq_mh] [int] NOT NULL
	,[male_sf] [int] NOT NULL
	,[male_mf] [int] NOT NULL
	,[male_mh] [int] NOT NULL
	,[female_sf] [int] NOT NULL
	,[female_mf] [int] NOT NULL
	,[female_mh] [int] NOT NULL
	,[age_0_17_sf] [int] NOT NULL
	,[age_0_17_mf] [int] NOT NULL
	,[age_0_17_mh] [int] NOT NULL
	,[age_18_24_sf] [int] NOT NULL
	,[age_18_24_mf] [int] NOT NULL
	,[age_18_24_mh] [int] NOT NULL
	,[age_25_34_sf] [int] NOT NULL
	,[age_25_34_mf] [int] NOT NULL
	,[age_25_34_mh] [int] NOT NULL
	,[age_35_49_sf] [int] NOT NULL
	,[age_35_49_mf] [int] NOT NULL
	,[age_35_49_mh] [int] NOT NULL
	,[age_50_64_sf] [int] NOT NULL
	,[age_50_64_mf] [int] NOT NULL
	,[age_50_64_mh] [int] NOT NULL
	,[age_65_79_sf] [int] NOT NULL
	,[age_65_79_mf] [int] NOT NULL
	,[age_65_79_mh] [int] NOT NULL
	,[age_80plus_sf] [int] NOT NULL
	,[age_80plus_mf] [int] NOT NULL
	,[age_80plus_mh] [int] NOT NULL
	,[hisp_sf] [int] NOT NULL
	,[hisp_mf] [int] NOT NULL
	,[hisp_mh] [int] NOT NULL
	,[nhw_sf] [int] NOT NULL
	,[nhw_mf] [int] NOT NULL
	,[nhw_mh] [int] NOT NULL
	,[nhb_sf] [int] NOT NULL
	,[nhb_mf] [int] NOT NULL
	,[nhb_mh] [int] NOT NULL
	,[nho_popsyn_sf] [int] NOT NULL
	,[nho_popsyn_mf] [int] NOT NULL
	,[nho_popsyn_mh] [int] NOT NULL
	,[nha_sf] [int] NOT NULL
	,[nha_mf] [int] NOT NULL
	,[nha_mh] [int] NOT NULL
	,[hh_i1_sf] [int] NOT NULL
	,[hh_i1_mf] [int] NOT NULL
	,[hh_i1_mh] [int] NOT NULL
	,[hh_i2_sf] [int] NOT NULL
	,[hh_i2_mf] [int] NOT NULL
	,[hh_i2_mh] [int] NOT NULL
	,[hh_i3_sf] [int] NOT NULL
	,[hh_i3_mf] [int] NOT NULL
	,[hh_i3_mh] [int] NOT NULL
	,[hh_i4_sf] [int] NOT NULL
	,[hh_i4_mf] [int] NOT NULL
	,[hh_i4_mh] [int] NOT NULL
	,[hh_i5_sf] [int] NOT NULL
	,[hh_i5_mf] [int] NOT NULL
	,[hh_i5_mh] [int] NOT NULL
	,[hh_i6_sf] [int] NOT NULL
	,[hh_i6_mf] [int] NOT NULL
	,[hh_i6_mh] [int] NOT NULL
	,[hh_i7_sf] [int] NOT NULL
	,[hh_i7_mf] [int] NOT NULL
	,[hh_i7_mh] [int] NOT NULL
	,[hh_i8_sf] [int] NOT NULL
	,[hh_i8_mf] [int] NOT NULL
	,[hh_i8_mh] [int] NOT NULL
	,[hh_i9_sf] [int] NOT NULL
	,[hh_i9_mf] [int] NOT NULL
	,[hh_i9_mh] [int] NOT NULL
	,[hh_i10_sf] [int] NOT NULL
	,[hh_i10_mf] [int] NOT NULL
	,[hh_i10_mh] [int] NOT NULL
	,[hhs_sf] AS CAST(ROUND(CASE WHEN [hh_sf] > 0 THEN (([pop_non_gq_sf]*1.0)/ ([hh_sf]*1.0)) ELSE 0 END, 4) AS decimal(6,4)) 
	,[hhs_mf] AS CAST(ROUND(CASE WHEN [hh_mf] > 0 THEN (([pop_non_gq_mf]*1.0)/ ([hh_mf]*1.0)) ELSE 0 END, 4) AS decimal(6,4)) 
	,[hhs_mh] AS CAST(ROUND(CASE WHEN [hh_mh] > 0 THEN (([pop_non_gq_mh]*1.0)/ ([hh_mh]*1.0)) ELSE 0 END, 4) AS decimal(6,4))
	,[hh_income_cat_1_sf] AS [hh_i1_sf] + [hh_i2_sf]
	,[hh_income_cat_1_mf] AS [hh_i1_mf] + [hh_i2_mf]
	,[hh_income_cat_1_mh] AS [hh_i1_mh] + [hh_i2_mh]
	,[hh_income_cat_2_sf] AS [hh_i3_sf] + [hh_i4_sf]
	,[hh_income_cat_2_mf] AS [hh_i3_mf] + [hh_i4_mf]
	,[hh_income_cat_2_mh] AS [hh_i3_mh] + [hh_i4_mh]
	,[hh_income_cat_3_sf] AS [hh_i5_sf] + [hh_i6_sf]
	,[hh_income_cat_3_mf] AS [hh_i5_mf] + [hh_i6_mf]
	,[hh_income_cat_3_mh] AS [hh_i5_mh] + [hh_i6_mh]
	,[hh_income_cat_4_sf] AS [hh_i7_sf] + [hh_i8_sf]
	,[hh_income_cat_4_mf] AS [hh_i7_mf] + [hh_i8_mf]
	,[hh_income_cat_4_mh] AS [hh_i7_mh] + [hh_i8_mh]
	,[hh_income_cat_5_sf] AS [hh_i9_sf] + [hh_i10_sf]
	,[hh_income_cat_5_mf] AS [hh_i9_mf] + [hh_i10_mf]
	,[hh_income_cat_5_mh] AS [hh_i9_mh] + [hh_i10_mh]
	,PRIMARY KEY ([lu_version_id],[parent_geography_zone_id])
)
AS
BEGIN

DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id]  WHERE [popsyn_run_id] = @popsyn_run_id)

INSERT INTO @ret_synpop_aggregated_targets
--household results
SELECT
	[hh_popsyn].[lu_version_id]
	,[hh_popsyn].[parent_geography_zone_id]
	,[hh_sf]
	,[hh_mf]
	,[hh_mh]
	,[hhwoc_sf]
	,[hhwoc_mf]		
	,[hhwoc_mh]		
	,[hhwc_sf]
	,[hhwc_mf]		
	,[hhwc_mh]		
	,[hhworkers0_sf]
	,[hhworkers0_mf]		
	,[hhworkers0_mh]		
	,[hhworkers1_sf]
	,[hhworkers1_mf]		
	,[hhworkers1_mh]		
	,[hhworkers2_sf]
	,[hhworkers2_mf]		
	,[hhworkers2_mh]		
	,[hhworkers3_sf]
	,[hhworkers3_mf]	
	,[hhworkers3_mh]
	,[pop_non_gq_sf]
	,[pop_non_gq_mf]
	,[pop_non_gq_mh]
	,[male_sf]
	,[male_mf]
	,[male_mh]
	,[female_sf]
	,[female_mf]
	,[female_mh]
	,[age_0_17_sf]
	,[age_0_17_mf]
	,[age_0_17_mh]
	,[age_18_24_sf]
	,[age_18_24_mf]
	,[age_18_24_mh]
	,[age_25_34_sf]
	,[age_25_34_mf]
	,[age_25_34_mh]
	,[age_35_49_sf]
	,[age_35_49_mf]
	,[age_35_49_mh]
	,[age_50_64_sf]
	,[age_50_64_mf]
	,[age_50_64_mh]
	,[age_65_79_sf]
	,[age_65_79_mf]
	,[age_65_79_mh]
	,[age_80plus_sf]
	,[age_80plus_mf]
	,[age_80plus_mh]
	,[hisp_sf]
	,[hisp_mf]
	,[hisp_mh]
	,[nhw_sf]
	,[nhw_mf]
	,[nhw_mh]
	,[nhb_sf]
	,[nhb_mf]
	,[nhb_mh]
	,[nho_popsyn_sf]
	,[nho_popsyn_mf]
	,[nho_popsyn_mh]
	,[nha_sf]
	,[nha_mf]
	,[nha_mh]
	,[hh_i1_sf]
	,[hh_i1_mf]
	,[hh_i1_mh]
	,[hh_i2_sf]
	,[hh_i2_mf]
	,[hh_i2_mh]
	,[hh_i3_sf]
	,[hh_i3_mf]
	,[hh_i3_mh]
	,[hh_i4_sf]
	,[hh_i4_mf]
	,[hh_i4_mh]
	,[hh_i5_sf]
	,[hh_i5_mf]
	,[hh_i5_mh]
	,[hh_i6_sf]
	,[hh_i6_mf]
	,[hh_i6_mh]
	,[hh_i7_sf]
	,[hh_i7_mf]
	,[hh_i7_mh]
	,[hh_i8_sf]
	,[hh_i8_mf]
	,[hh_i8_mh]
	,[hh_i9_sf]
	,[hh_i9_mf]
	,[hh_i9_mh]
	,[hh_i10_sf]
	,[hh_i10_mf]
	,[hh_i10_mh]
FROM (
	SELECT
		[lu_version_id]
		,[parent_geography_zone_id]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_sf]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_mf]
		,SUM([final_weight] * CASE WHEN [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_mh]
		,SUM([final_weight] * CASE WHEN [hh_child] = 0 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhwoc_sf]
		,SUM([final_weight] * CASE WHEN [hh_child] = 0 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhwoc_mf]		
		,SUM([final_weight] * CASE WHEN [hh_child] = 0 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhwoc_mh]		
		,SUM([final_weight] * CASE WHEN [hh_child] = 1 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhwc_sf]
		,SUM([final_weight] * CASE WHEN [hh_child] = 1 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhwc_mf]		
		,SUM([final_weight] * CASE WHEN [hh_child] = 1 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhwc_mh]		
		,SUM([final_weight] * CASE WHEN [workers] = 0 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhworkers0_sf]
		,SUM([final_weight] * CASE WHEN [workers] = 0 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhworkers0_mf]		
		,SUM([final_weight] * CASE WHEN [workers] = 0 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhworkers0_mh]		
		,SUM([final_weight] * CASE WHEN [workers] = 1 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhworkers1_sf]
		,SUM([final_weight] * CASE WHEN [workers] = 1 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhworkers1_mf]		
		,SUM([final_weight] * CASE WHEN [workers] = 1 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhworkers1_mh]		
		,SUM([final_weight] * CASE WHEN [workers] = 2 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhworkers2_sf]
		,SUM([final_weight] * CASE WHEN [workers] = 2 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhworkers2_mf]		
		,SUM([final_weight] * CASE WHEN [workers] = 2 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhworkers2_mh]		
		,SUM([final_weight] * CASE WHEN [workers] >= 3 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hhworkers3_sf]
		,SUM([final_weight] * CASE WHEN [workers] >= 3 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hhworkers3_mf]	
		,SUM([final_weight] * CASE WHEN [workers] >= 3 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hhworkers3_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] < 15000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i1_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] < 15000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i1_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] < 15000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i1_mh]	
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 15000 AND [hh_income_adj] < 30000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i2_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 15000 AND [hh_income_adj] < 30000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i2_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 15000 AND [hh_income_adj] < 30000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i2_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 30000 AND [hh_income_adj] < 45000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i3_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 30000 AND [hh_income_adj] < 45000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i3_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 30000 AND [hh_income_adj] < 45000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i3_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 45000 AND [hh_income_adj] < 60000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i4_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 45000 AND [hh_income_adj] < 60000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i4_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 45000 AND [hh_income_adj] < 60000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i4_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 60000 AND [hh_income_adj] < 75000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i5_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 60000 AND [hh_income_adj] < 75000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i5_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 60000 AND [hh_income_adj] < 75000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i5_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 75000 AND [hh_income_adj] < 100000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i6_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 75000 AND [hh_income_adj] < 100000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i6_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 75000 AND [hh_income_adj] < 100000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i6_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 100000 AND [hh_income_adj] < 125000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i7_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 100000 AND [hh_income_adj] < 125000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i7_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 100000 AND [hh_income_adj] < 125000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i7_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 125000 AND [hh_income_adj] < 150000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i8_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 125000 AND [hh_income_adj] < 150000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i8_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 125000 AND [hh_income_adj] < 150000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i8_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 150000 AND [hh_income_adj] < 200000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i9_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 150000 AND [hh_income_adj] < 200000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i9_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 150000 AND [hh_income_adj] < 200000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i9_mh]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 200000 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hh_i10_sf]
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 200000 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hh_i10_mf]		
		,SUM([final_weight] * CASE WHEN [hh_income_adj] >= 200000 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hh_i10_mh]
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
	INNER JOIN 
		[data_cafe].[ref].[get_prepopulated_geography_xref](@minor_geography_type_id, @geography_type_id) AS [minor_geotype_xref]
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
INNER JOIN
(-- person results
	SELECT
		[lu_version_id]
		,[parent_geography_zone_id]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [pop_non_gq_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [pop_non_gq_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [pop_non_gq_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 1 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [male_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 1 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [male_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 1 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [male_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 2 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [female_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 2 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [female_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [sex] = 2 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [female_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] <= 17 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_0_17_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] <= 17 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_0_17_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] <= 17 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_0_17_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 18 AND 24 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_18_24_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 18 AND 24 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_18_24_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 18 AND 24 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_18_24_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 25 AND 34 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_25_34_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 25 AND 34 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_25_34_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 25 AND 34 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_25_34_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 35 AND 49 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_35_49_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 35 AND 49 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_35_49_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 35 AND 49 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_35_49_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 50 AND 64 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_50_64_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 50 AND 64 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_50_64_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 50 AND 64 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_50_64_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 65 AND 79 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_65_79_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 65 AND 79 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_65_79_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] BETWEEN 65 AND 79 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_65_79_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] >= 80 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [age_80plus_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] >= 80 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [age_80plus_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [agep] >= 80 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [age_80plus_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 1 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [hisp_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 1 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [hisp_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 1 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [hisp_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 2 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [nhw_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 2 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [nhw_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 2 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [nhw_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 3 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [nhb_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 3 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [nhb_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 3 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [nhb_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 4 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [nho_popsyn_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 4 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [nho_popsyn_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 4 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [nho_popsyn_mh]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 5 AND [hh_type_id] = 1 THEN 1 ELSE 0 END) AS [nha_sf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 5 AND [hh_type_id] = 2 THEN 1 ELSE 0 END) AS [nha_mf]
		,SUM([synpop_hh].[final_weight] * CASE WHEN [popsyn_race_id] = 5 AND [hh_type_id] = 3 THEN 1 ELSE 0 END) AS [nha_mh]
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
	INNER JOIN
		[popsyn_input].[hh]
	ON
		[popsyn_run].[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
		AND [synpop_hh].[hh_id] = [hh].[hh_id]
	INNER JOIN 
		[data_cafe].[ref].[get_prepopulated_geography_xref](@minor_geography_type_id, @geography_type_id) AS [minor_geotype_xref]
	ON
		[synpop_hh].[mgra] = [minor_geotype_xref].[child_zone]
	WHERE
		[synpop_person].[popsyn_run_id] = @popsyn_run_id
		AND [synpop_hh].[popsyn_run_id] = @popsyn_run_id
		AND [popsyn_run].[popsyn_run_id] = @popsyn_run_id
		AND [popsyn_input].[person].[gq_type_id] = 0
		AND [popsyn_input].[hh].[gq_type_id] = 0
	GROUP BY
		[lu_version_id]
		,[parent_geography_zone_id]
	) AS person_popsyn
ON
	[hh_popsyn].[lu_version_id] = [person_popsyn].[lu_version_id]
	AND [hh_popsyn].[parent_geography_zone_id] = [person_popsyn].[parent_geography_zone_id]

RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'returns control totals segmented by housing type from a target synthetic population at a specified geography' , @level0type=N'SCHEMA',@level0name=N'sb_input', @level1type=N'FUNCTION',@level1name=N'synpop_controls_aggregator'
GO



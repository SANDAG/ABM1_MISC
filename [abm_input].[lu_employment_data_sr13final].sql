USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [abm_input].[lu_employment_data_sr13final]    Script Date: 4/23/2019 8:58:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION
	[abm_input].[lu_employment_data_sr13final]
(
	@lu_version_id [smallint]
)
RETURNS @ret_lu_employment_data_sr13final TABLE
(
	[lu_version_id] [smallint] NOT NULL
	,[mgra_13] [smallint] NOT NULL
	,[emp_ag] [int] NOT NULL
	,[emp_const_non_bldg_prod] [int] NOT NULL
	,[emp_const_non_bldg_office] [int] NOT NULL
	,[emp_utilities_prod] [int] NOT NULL
	,[emp_utilities_office] [int] NOT NULL
	,[emp_const_bldg_prod] [int] NOT NULL
	,[emp_const_bldg_office] [int] NOT NULL
	,[emp_mfg_prod] [int] NOT NULL
	,[emp_mfg_office] [int] NOT NULL
	,[emp_whsle_whs] [int] NOT NULL
	,[emp_trans] [int] NOT NULL
	,[emp_retail] [int] NOT NULL
	,[emp_prof_bus_svcs] [int] NOT NULL
	,[emp_prof_bus_svcs_bldg_maint] [int] NOT NULL
	,[emp_pvt_ed_k12] [int] NOT NULL
	,[emp_pvt_ed_post_k12_oth] [int] NOT NULL
	,[emp_health] [int] NOT NULL
	,[emp_personal_svcs_office] [int] NOT NULL
	,[emp_amusement] [int] NOT NULL
	,[emp_hotel] [int] NOT NULL
	,[emp_restaurant_bar] [int] NOT NULL
	,[emp_personal_svcs_retail] [int] NOT NULL
	,[emp_religious] [int] NOT NULL
	,[emp_pvt_hh] [int] NOT NULL
	,[emp_state_local_gov_ent] [int] NOT NULL
	,[emp_fed_non_mil] [int] NOT NULL
	,[emp_fed_mil] [int] NOT NULL
	,[emp_state_local_gov_blue] [int] NOT NULL
	,[emp_state_local_gov_white] [int] NOT NULL
	,[emp_public_ed] [int] NOT NULL
	,[emp_own_occ_dwell_mgmt] [int] NOT NULL
	,[emp_fed_gov_accts] [int] NOT NULL
	,[emp_st_lcl_gov_accts] [int] NOT NULL
	,[emp_cap_accts] [int] NOT NULL
	,PRIMARY KEY ([lu_version_id], [mgra_13])
)
AS
BEGIN
/* mgrabase employment grabbed for every year and scenario
converted to pecas activity types and adjusted via pecas output 
and controlled back to original mgrabase totals and
converted to abm employment categories

Written by:
Gregor Schroeder
Matt Keating
Daniel Flyte
Yun Ma - previously the total emp was about 39 million, bugs were found and fixed in the section of adjusted_controlled_total_mgrabase
*/

-- mrgrabase_emp from wide to long
with mgrabase_emp AS (
	SELECT
		[mgra]
		,[emp_category_sr13]
		,SUM([value]) AS [value]
	FROM (
		SELECT 
			[mgra]
			,[emp_mil]
			,[emp_agmin]
			,[emp_cons]
			,[emp_mfg]
			,[emp_whtrade]
			,[emp_retrade]
			,[emp_twu]
			,[emp_info]
			,[emp_fre]
			,[emp_pbs]
			,[emp_edhs_oth]
			,[emp_edhs_health]
			,[emp_lh_amuse]
			,[emp_lh_hotel]
			,[emp_lh_restaur]
			,[emp_osv_oth]
			,[emp_osv_rel]
			,[emp_gov_fed]
			,[emp_gov_sloth]
			,[emp_gov_sled]
			,[emp_sedw]
		FROM 
			regional_forecast.[sr13_final].[mgrabase]
		INNER JOIN
			[ref].[lu_version] -- this join means a scenario needs to be in this table to appear
		ON
			[mgrabase].[scenario] = [lu_version].[lu_scenario_id]
			AND [mgrabase].[increment] = [lu_version].[increment]
			AND [lu_version].[lu_version_id] = @lu_version_id
		) tt1
	UNPIVOT  -- pivot mgrabase employment categories from wide to long
	(
		[value]
		FOR [emp_category_sr13] IN (
			[emp_mil]
			,[emp_agmin]
			,[emp_cons]
			,[emp_mfg]
			,[emp_whtrade]
			,[emp_retrade]
			,[emp_twu]
			,[emp_info]
			,[emp_fre]
			,[emp_pbs]
			,[emp_edhs_oth]
			,[emp_edhs_health]
			,[emp_lh_amuse]
			,[emp_lh_hotel]
			,[emp_lh_restaur]
			,[emp_osv_oth]
			,[emp_osv_rel]
			,[emp_gov_fed]
			,[emp_gov_sloth]
			,[emp_gov_sled]
			,[emp_sedw]
		  )
	) tt2
	GROUP BY
		[mgra]
		,[emp_category_sr13]
),

-- total up long format mgrabase emp for each category
total_mgrabase_emp AS (
	SELECT
		[emp_category_sr13]
		,SUM([value]) AS [total]
	FROM
		mgrabase_emp
	GROUP BY
		[emp_category_sr13]
),

-- table used to control final employment to regional forecast/mgrabase totals
mgrabase_control_totals AS (
	SELECT
		SUM([emp_civ]) AS [emp_civ_control_total]
		,SUM([emp_mil]) AS [emp_mil_control_total]
	FROM 
		[regional_forecast].[sr13_final].[mgrabase]
	INNER JOIN
		[ref].[lu_version] -- this join means a scenario needs to be in this table to appear
	ON
		[mgrabase].[scenario] = [lu_version].[lu_scenario_id]
		AND [mgrabase].[increment] = [lu_version].[increment]
		AND [lu_version].[lu_version_id] = @lu_version_id
),
	
-- pecas activity totals, dollars of activity, abm name, and proportion assigned to mgrabase employment type
pecas_activity_totals AS (
	SELECT
		[emp_category_sr13]
		,[abm_name]
		,[size] * [prop] * [emp_per_dollar] AS [pecas_adjustment_term]
	FROM
		[pecas_sr13].[aa].[activity_total]
	INNER JOIN
		[pecas_sr13].[xref].[defm_emp_category_activity_sr13]
	ON
		[activity_total].[activity_id] = [defm_emp_category_activity_sr13].[activity_id]
	INNER JOIN
		[pecas_sr13].[staging].[activity_output_employment_edd]
	ON
		[activity_total].[activity_id] = [activity_output_employment_edd].[activity_id]
		AND [activity_output_employment_edd].[yr] = 2012 -- 2012 is the observed rate of consumption of employment by activity. Table allows to specify future alternative ratios.
	INNER JOIN
		[pecas_sr13].[xref].[abm_activity_name]
	ON
		[activity_total].[activity_id] = [abm_activity_name].[activity_id]
	INNER JOIN
		[ref].[lu_version] -- this join means a scenario needs to be in this table to appear
	ON
		[activity_total].[yr] = [lu_version].[increment]
		AND [lu_version].[lu_version_id] = @lu_version_id
	WHERE
		[activity_total].[scenario_id] = 27 -- hardcoded PECAS scenario contains all years, no xref exists between mgrabase and PECAS, Daniel Flyte advised to use this (a copy of scenario 21).
),

-- pecas adjusted mgrabase employment by abm employment type, not controlled to total mgrabase employment
adjusted_total_mgrabase AS (
SELECT
	mgrabase_emp.[mgra]
	,pecas_activity_totals.[abm_name]
	,SUM(mgrabase_emp.[value] * pecas_activity_totals.[pecas_adjustment_term] / total_mgrabase_emp.[total]) AS [adj_emp]
FROM
	mgrabase_emp
INNER JOIN
	pecas_activity_totals
ON
	mgrabase_emp.[emp_category_sr13] = pecas_activity_totals.[emp_category_sr13]
INNER JOIN
	total_mgrabase_emp
ON
	 mgrabase_emp.[emp_category_sr13] = total_mgrabase_emp.[emp_category_sr13]
GROUP BY
	mgrabase_emp.[mgra]
	,pecas_activity_totals.[abm_name]
),

-- pecas adjusted and controlled mgrabase employment by abm employment type
adjusted_controlled_total_mgrabase AS (
SELECT
	adjusted_total_mgrabase.[mgra]
	,adjusted_total_mgrabase.[abm_name] 
	,CASE	WHEN adjusted_total_mgrabase.[abm_name] = 'emp_fed_mil' THEN adjusted_total_mgrabase.[adj_emp] * ([emp_mil_control_total] / [total_adj_emp_mil])
			ELSE adjusted_total_mgrabase.[adj_emp] * ([emp_civ_control_total] / [total_adj_emp_civ])
			END AS [adj_con_emp]
FROM
	adjusted_total_mgrabase
CROSS JOIN (
	SELECT SUM([adj_emp]) AS [total_adj_emp_civ]
	FROM adjusted_total_mgrabase
	where abm_name <> 'emp_fed_mil'
	) tt1
CROSS JOIN (
	SELECT SUM([adj_emp]) AS [total_adj_emp_mil]
	FROM adjusted_total_mgrabase
	where abm_name = 'emp_fed_mil'
	) tt2
CROSS JOIN
	mgrabase_control_totals
)

-- Final pivotted employment data
INSERT INTO @ret_lu_employment_data_sr13final
SELECT
	@lu_version_id AS [lu_version_id]
	,[mgra] AS [mgra_13]
	,ROUND([emp_ag]+0.035, 0) AS [emp_ag]
	,ROUND([emp_const_non_bldg_prod]+0.035, 0) AS [emp_const_non_bldg_prod]
	,ROUND([emp_const_non_bldg_office]+0.035, 0) AS [emp_const_non_bldg_office]
	,ROUND([emp_utilities_prod]+0.035, 0) AS [emp_utilities_prod]
	,ROUND([emp_utilities_office]+0.035, 0) AS [emp_utilities_office]
	,ROUND([emp_const_bldg_prod]+0.035, 0) AS [emp_const_bldg_prod]
	,ROUND([emp_const_bldg_office]+0.035, 0) AS [emp_const_bldg_office]
	,ROUND([emp_mfg_prod]+0.035, 0) AS [emp_mfg_prod]
	,ROUND([emp_mfg_office]+0.035, 0) AS [emp_mfg_office]
	,ROUND([emp_whsle_whs]+0.035, 0) AS [emp_whsle_whs]
	,ROUND([emp_trans]+0.035, 0) AS [emp_trans]
	,ROUND([emp_retail]+0.035, 0) AS [emp_retail]
	,ROUND([emp_prof_bus_svcs]+0.035, 0) AS [emp_prof_bus_svcs]
	,ROUND([emp_prof_bus_svcs_bldg_maint]+0.035, 0) AS [emp_prof_bus_svcs_bldg_maint]
	,ROUND([emp_pvt_ed_k12]+0.035, 0) AS [emp_pvt_ed_k12]
	,ROUND([emp_pvt_ed_post_k12_oth]+0.035, 0) AS [emp_pvt_ed_post_k12_oth]
	,ROUND([emp_health]+0.035, 0) AS [emp_health]
	,ROUND([emp_personal_svcs_office]+0.035, 0) AS [emp_personal_svcs_office]
	,ROUND([emp_amusement]+0.035, 0) AS [emp_amusement]
	,ROUND([emp_hotel]+0.035, 0) AS [emp_hotel]
	,ROUND([emp_restaurant_bar]+0.035, 0) AS [emp_restaurant_bar]
	,ROUND([emp_personal_svcs_retail]+0.035, 0) AS [emp_personal_svcs_retail]
	,ROUND([emp_religious]+0.035, 0) AS [emp_religious]
	,ROUND([emp_pvt_hh]+0.035, 0) AS [emp_pvt_hh]
	,ROUND([emp_state_local_gov_ent]+0.035, 0) AS [emp_state_local_gov_ent]
	,ROUND([emp_fed_non_mil]+0.035, 0) AS [emp_fed_non_mil]
	,ROUND([emp_fed_mil]+0.035, 0) AS [emp_fed_mil]
	,ROUND([emp_state_local_gov_blue]+0.035, 0) AS [emp_state_local_gov_blue]
	,ROUND([emp_state_local_gov_white]+0.035, 0) AS [emp_state_local_gov_white]
	,ROUND([emp_public_ed]+0.035, 0) AS [emp_public_ed]
	-- Four following employment types are not actually associated with employees
	-- They have always just been 0 and continue to be until defm has employment for them
	-- Do not know why they are in ABM input file but they are.....
	,ROUND((ISNULL([emp_own_occ_dwell_mgmt], 0)+0.035), 0) AS [emp_own_occ_dwell_mgmt]
	,ROUND((ISNULL([emp_fed_gov_accts], 0)+0.035), 0) AS [emp_fed_gov_accts]
	,ROUND((ISNULL([emp_st_lcl_gov_accts], 0)+0.035), 0) AS [emp_st_lcl_gov_accts]
	,ROUND((ISNULL([emp_cap_accts], 0)+0.035), 0) AS [emp_cap_accts]
FROM
	adjusted_controlled_total_mgrabase
PIVOT (
		SUM([adj_con_emp])
	FOR
		[abm_name]
	IN (
		[emp_ag]
		,[emp_const_non_bldg_prod]
		,[emp_const_non_bldg_office]
		,[emp_utilities_prod]
		,[emp_utilities_office]
		,[emp_const_bldg_prod]
		,[emp_const_bldg_office]
		,[emp_mfg_prod]
		,[emp_mfg_office]
		,[emp_whsle_whs]
		,[emp_trans]
		,[emp_retail]
		,[emp_prof_bus_svcs]
		,[emp_prof_bus_svcs_bldg_maint]
		,[emp_pvt_ed_k12]
		,[emp_pvt_ed_post_k12_oth]
		,[emp_health]
		,[emp_personal_svcs_office]
		,[emp_amusement]
		,[emp_hotel]
		,[emp_restaurant_bar]
		,[emp_personal_svcs_retail]
		,[emp_religious]
		,[emp_pvt_hh]
		,[emp_state_local_gov_ent]
		,[emp_fed_non_mil]
		,[emp_fed_mil]
		,[emp_state_local_gov_blue]
		,[emp_state_local_gov_white]
		,[emp_public_ed]
		,[emp_own_occ_dwell_mgmt]
		,[emp_fed_gov_accts]
		,[emp_st_lcl_gov_accts]
		,[emp_cap_accts]
		)
	) tt2
RETURN
END



GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to return all series 13 final employment land use data used to create mgra based input file' , @level0type=N'SCHEMA',@level0name=N'abm_input', @level1type=N'FUNCTION',@level1name=N'lu_employment_data_sr13final'
GO



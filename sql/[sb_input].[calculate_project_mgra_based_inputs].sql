USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sb_input].[calculate_project_mgra_based_inputs]    Script Date: 4/23/2019 9:03:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION
	[sb_input].[calculate_project_mgra_based_inputs] 
(
	@popsyn_run_id smallint -- Need to specify [popsyn_run_id] located in [ref].[popsyn_run]
	,@project_input_table AS project_input_table_type READONLY
)
RETURNS @calculate_project_mgra_based_inputs TABLE 
(
	[mgra] [int] NOT NULL,
	[mgra_geography_zone_id] [int] NOT NULL,
	[taz] [int] NOT NULL,
	[taz_geography_zone_id] [int] NOT NULL,
	[luz] [int] NOT NULL,
	[luz_geography_zone_id] [int] NOT NULL,
	[hs] AS ([hs_sf]+[hs_mf]+[hs_mh]),
	[hs_sf] [smallint] NOT NULL,
	[hs_mf] [smallint] NOT NULL,
	[hs_mh] [smallint] NOT NULL,
	[hh] AS ([hh_sf]+[hh_mf]+[hh_mh]),
	[hh_sf] [smallint] NOT NULL,
	[hh_mf] [smallint] NOT NULL,
	[hh_mh] [smallint] NOT NULL,
	[gq_civ] [smallint] NOT NULL,
	[gq_mil] [smallint] NOT NULL,
	[i1] [smallint] NOT NULL,
	[i2] [smallint] NOT NULL,
	[i3] [smallint] NOT NULL,
	[i4] [smallint] NOT NULL,
	[i5] [smallint] NOT NULL,
	[i6] [smallint] NOT NULL,
	[i7] [smallint] NOT NULL,
	[i8] [smallint] NOT NULL,
	[i9] [smallint] NOT NULL,
	[i10] [smallint] NOT NULL,
	[hhs] [decimal](6, 4) NOT NULL,
	[pop] AS CAST(ROUND([hhs] * ([hh_sf]+[hh_mf]+[hh_mh]), 0) + [gq_civ] + [gq_mil] AS smallint),
	[hhp] AS CAST(ROUND([hhs] * ([hh_sf]+[hh_mf]+[hh_mh]), 0) AS smallint),
	[emp_ag] [int] NOT NULL,
	[emp_const_non_bldg_prod] [int] NOT NULL,
	[emp_const_non_bldg_office] [int] NOT NULL,
	[emp_utilities_prod] [int] NOT NULL,
	[emp_utilities_office] [int] NOT NULL,
	[emp_const_bldg_prod] [int] NOT NULL,
	[emp_const_bldg_office] [int] NOT NULL,
	[emp_mfg_prod] [int] NOT NULL,
	[emp_mfg_office] [int] NOT NULL,
	[emp_whsle_whs] [int] NOT NULL,
	[emp_trans] [int] NOT NULL,
	[emp_retail] [int] NOT NULL,
	[emp_prof_bus_svcs] [int] NOT NULL,
	[emp_prof_bus_svcs_bldg_maint] [int] NOT NULL,
	[emp_pvt_ed_k12] [int] NOT NULL,
	[emp_pvt_ed_post_k12_oth] [int] NOT NULL,
	[emp_health] [int] NOT NULL,
	[emp_personal_svcs_office] [int] NOT NULL,
	[emp_amusement] [int] NOT NULL,
	[emp_hotel] [int] NOT NULL,
	[emp_restaurant_bar] [int] NOT NULL,
	[emp_personal_svcs_retail] [int] NOT NULL,
	[emp_religious] [int] NOT NULL,
	[emp_pvt_hh] [int] NOT NULL,
	[emp_state_local_gov_ent] [int] NOT NULL,
	[emp_fed_non_mil] [int] NOT NULL,
	[emp_fed_mil] [int] NOT NULL,
	[emp_state_local_gov_blue] [int] NOT NULL,
	[emp_state_local_gov_white] [int] NOT NULL,
	[emp_public_ed] [int] NOT NULL,
	[emp_own_occ_dwell_mgmt] [int] NOT NULL,
	[emp_fed_gov_accts] [int] NOT NULL,
	[emp_st_lcl_gov_accts] [int] NOT NULL,
	[emp_cap_accts] [int] NOT NULL,
	[emp_total] AS ([emp_ag]+[emp_const_non_bldg_prod])+[emp_const_non_bldg_office]+
					[emp_utilities_prod]+[emp_utilities_office]+[emp_const_bldg_prod]+
					[emp_const_bldg_office]+[emp_mfg_prod]+[emp_mfg_office]+[emp_whsle_whs]+
					[emp_trans]+[emp_retail]+[emp_prof_bus_svcs]+[emp_prof_bus_svcs_bldg_maint]+
					[emp_pvt_ed_k12]+[emp_pvt_ed_post_k12_oth]+[emp_health]+[emp_personal_svcs_office]+
					[emp_amusement]+[emp_hotel]+[emp_restaurant_bar]+[emp_personal_svcs_retail]+
					[emp_religious]+[emp_pvt_hh]+[emp_state_local_gov_ent]+[emp_fed_non_mil]+
					[emp_fed_mil]+[emp_state_local_gov_blue]+[emp_state_local_gov_white]+
					[emp_public_ed]+[emp_own_occ_dwell_mgmt]+[emp_fed_gov_accts]+
					[emp_st_lcl_gov_accts]+[emp_cap_accts],
	[enrollgradekto8] [int] NOT NULL,
	[enrollgrade9to12] [int] NOT NULL,
	[collegeenroll] [int] NOT NULL,
	[othercollegeenroll] [int] NOT NULL,
	[adultschenrl] [int] NOT NULL,
	[ech_dist] [int] NOT NULL,
	[hch_dist] [int] NOT NULL,
	[pseudomsa] [tinyint] NOT NULL,
	[parkarea] [tinyint] NOT NULL,
	[hstallsoth] [smallint] NOT NULL,
	[hstallssam] [smallint] NOT NULL,
	[hparkcost] [decimal](4, 2) NOT NULL,
	[numfreehrs] [tinyint] NOT NULL,
	[dstallsoth] [smallint] NOT NULL,
	[dstallssam] [smallint] NOT NULL,
	[dparkcost] [decimal](4, 2) NOT NULL,
	[mstallsoth] [smallint] NOT NULL,
	[mstallssam] [smallint] NOT NULL,
	[mparkcost] [decimal](4, 2) NOT NULL,
	[totint] [smallint] NULL,
	[duden] [decimal](7, 4) NULL,
	[empden] [decimal](7, 4) NULL,
	[popden] [decimal](7, 4) NULL,
	[retempden] [decimal](7, 4) NULL,
	[totintbin] [tinyint] NULL,
	[empdenbin] [tinyint] NULL,
	[dudenbin] [tinyint] NULL,
	[zip09] [int] NOT NULL,
	[parkactive] [decimal](9, 4) NOT NULL,
	[openspaceparkpreserve] [decimal](9, 4) NOT NULL,
	[beachactive] [decimal](9, 4) NOT NULL,
	[budgetroom] [int] NOT NULL,
	[economyroom] [int] NOT NULL,
	[luxuryroom] [int] NOT NULL,
	[midpriceroom] [int] NOT NULL,
	[upscaleroom] [int] NOT NULL,
	[hotelroomtotal] AS ([budgetroom]+[economyroom]+[luxuryroom]+
						[midpriceroom]+[upscaleroom]),
	[luz_id] [smallint] NOT NULL,
	[truckregiontype] [tinyint] NOT NULL,
	[district27] [tinyint] NOT NULL,
	[milestocoast] [decimal](7, 4) NOT NULL,
	PRIMARY KEY ([mgra_geography_zone_id])
)
AS
BEGIN

DECLARE @lu_version_id smallint = (SELECT [lu_version_id] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = @popsyn_run_id)
DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
DECLARE @middle_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
DECLARE @major_geography_type_id smallint = (SELECT [major_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)

INSERT INTO @calculate_project_mgra_based_inputs
SELECT 
	[new_input].[mgra]
	,[new_input].[mgra_geography_zone_id]
	,[new_input].[taz]
	,[new_input].[taz_geography_zone_id]
	,[new_input].[luz]
	,[new_input].[luz_geography_zone_id]
	--ZOU Date 3/29/2018
	--the housing structure is a wholesale change, using the lu.csv input to place the regional input by MGRA
	--,CASE	WHEN ([old_input].[hs_sf] - ISNULL([new_input].[hh_sf], 0)) > 0 
	--			THEN ([old_input].[hs_sf] - ISNULL([new_input].[hh_sf], 0)) + ISNULL([new_input].[hh_sf], 0)
	--		ELSE ISNULL([new_input].[hh_sf], 0)
	--		END AS [hs_sf]
	--,CASE	WHEN ([old_input].[hs_mf] - ISNULL([new_input].[hh_mf], 0)) > 0 
	--			THEN ([old_input].[hs_mf] - ISNULL([new_input].[hh_mf], 0)) + ISNULL([new_input].[hh_mf], 0)
	--		ELSE ISNULL([new_input].[hh_mf], 0)
	--		END AS [hs_mf]
	--,CASE	WHEN ([old_input].[hs_mh] - ISNULL([new_input].[hh_mh], 0)) > 0 
	--			THEN ([old_input].[hs_mh] - ISNULL([new_input].[hh_mh], 0)) + ISNULL([new_input].[hh_mh], 0)
	--		ELSE ISNULL([new_input].[hh_mh], 0)
	--		END AS [hs_mh]
	,ISNULL([new_input].[hh_sf], 0) AS [hs_sf]
	,ISNULL([new_input].[hh_mf], 0) AS [hs_mf]
	,ISNULL([new_input].[hh_mh], 0) AS [hs_mh]
	--,CASE WHEN [new_input].[hh_sf] IS NOT NULL THEN [new_input].[hh_sf] ELSE [old_input].[hs_sf] END AS [hs_sf]
	--,CASE WHEN [new_input].[hh_mf] IS NOT NULL THEN [new_input].[hh_mf] ELSE [old_input].[hs_mf] END AS [hs_mf]
	--,CASE WHEN [new_input].[hh_mh] IS NOT NULL THEN [new_input].[hh_mh] ELSE [old_input].[hs_mh] END AS [hs_mh]
	,ISNULL([new_input].[hh_sf], 0) AS [hh_sf]
	,ISNULL([new_input].[hh_mf], 0) AS [hh_mf]
	,ISNULL([new_input].[hh_mh], 0) AS [hh_mh]
	--,ISNULL([new_input].[gq_civ], 0) AS [gq_civ]   -- previous version 
	,[old_input].[gq_civ]    --changed to use the old data because no chance to input gq_civ through density table, YMA, 4/16/2018
	,[old_input].[gq_mil]      
	    --below for items [i1] to [i10], additonal (1.0* was added to cast [hh_ix_sf]/[hh_sf] into float, otherwise most of results are 0.  --YMA, 4/6/2018
	,[i1] =	ROUND(       
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i1_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_major].[hh_sf] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i1_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i1_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_major].[hh_mf] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i1_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i1_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_major].[hh_mh] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i1_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i2] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i2_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_major].[hh_sf] = 0 THEN 1.0 * (1.0 * [synpop_controls_region].[hh_i2_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 * [synpop_controls_major].[hh_i2_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_major].[hh_mf] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i2_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 * [synpop_controls_major].[hh_i2_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_major].[hh_mh] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i2_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i3] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * ( 1.0 *[synpop_controls_major].[hh_i3_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_major].[hh_sf] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i3_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i3_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_major].[hh_mf] = 0 and [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i3_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i3_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_major].[hh_mh] = 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i3_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i4] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i4_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_major].[hh_sf] = 0 and [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i4_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i4_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_major].[hh_mf] = 0 and [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i4_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i4_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_major].[hh_mh] = 0 and [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i4_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i5] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i5_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i5_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i5_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i5_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i5_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i5_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i6] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i6_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i6_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i6_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i6_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i6_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i6_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i7] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i7_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i7_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i7_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i7_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i7_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i7_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i8] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i8_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i8_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i8_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i8_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i8_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i8_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i9] =	ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i9_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i9_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i9_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i9_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i9_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i9_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[i10] = ROUND(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i10_sf]/[synpop_controls_major].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i10_sf]/[synpop_controls_region].[hh_sf]) * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i10_mf]/[synpop_controls_major].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i10_mf]/[synpop_controls_region].[hh_mf]) * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_major].[hh_i10_mh]/[synpop_controls_major].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN 1.0 * (1.0 *[synpop_controls_region].[hh_i10_mh]/[synpop_controls_region].[hh_mh]) * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			,0)
	,[hhs] = ISNULL(ROUND(
			(
			CASE	WHEN [synpop_controls_major].[hh_sf] > 0 THEN [synpop_controls_major].[hhs_sf] * ISNULL([new_input].[hh_sf], 0)
					WHEN [synpop_controls_region].[hh_sf] > 0 THEN [synpop_controls_region].[hhs_sf] * ISNULL([new_input].[hh_sf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mf] > 0 THEN [synpop_controls_major].[hhs_mf] * ISNULL([new_input].[hh_mf], 0)
					WHEN [synpop_controls_region].[hh_mf] > 0 THEN [synpop_controls_region].[hhs_mf] * ISNULL([new_input].[hh_mf], 0)
					ELSE 0 END +
			CASE	WHEN [synpop_controls_major].[hh_mh] > 0 THEN [synpop_controls_major].[hhs_mh] * ISNULL([new_input].[hh_mh], 0)
					WHEN [synpop_controls_region].[hh_mh] > 0 THEN [synpop_controls_region].[hhs_mh] * ISNULL([new_input].[hh_mh], 0)
					ELSE 0 END
			) / NULLIF((ISNULL([new_input].[hh_sf], 0) + ISNULL([new_input].[hh_mf], 0) + ISNULL([new_input].[hh_mh], 0)), 0)
			, 4), 0)
	,ISNULL([new_input].[emp_ag], 0) AS [emp_ag]
	,ISNULL([new_input].[emp_const_non_bldg_prod], 0) AS [emp_const_non_bldg_prod]
	,ISNULL([new_input].[emp_const_non_bldg_office], 0) AS [emp_const_non_bldg_office]
	,ISNULL([new_input].[emp_utilities_prod], 0) AS [emp_utilities_prod]
	,ISNULL([new_input].[emp_utilities_office], 0) AS [emp_utilities_office]
	,ISNULL([new_input].[emp_const_bldg_prod], 0) AS [emp_const_bldg_prod]
	,ISNULL([new_input].[emp_const_bldg_office], 0) AS [emp_const_bldg_office]
	,ISNULL([new_input].[emp_mfg_prod], 0) AS [emp_mfg_prod]
	,ISNULL([new_input].[emp_mfg_office], 0) AS [emp_mfg_office]
	,ISNULL([new_input].[emp_whsle_whs], 0) AS [emp_whsle_whs]
	,ISNULL([new_input].[emp_trans], 0) AS [emp_trans]
	,ISNULL([new_input].[emp_retail], 0) AS [emp_retail]
	,ISNULL([new_input].[emp_prof_bus_svcs], 0) AS [emp_prof_bus_svcs]
	,ISNULL([new_input].[emp_prof_bus_svcs_bldg_maint], 0) AS [emp_prof_bus_svcs_bldg_maint]
	,ISNULL([new_input].[emp_pvt_ed_k12], 0) AS [emp_pvt_ed_k12]
	,ISNULL([new_input].[emp_pvt_ed_post_k12_oth], 0) AS [emp_pvt_ed_post_k12_oth]
	,ISNULL([new_input].[emp_health], 0) AS [emp_health]
	,ISNULL([new_input].[emp_personal_svcs_office], 0) AS [emp_personal_svcs_office]
	,ISNULL([new_input].[emp_amusement], 0) AS [emp_amusement]
	,ISNULL([new_input].[emp_hotel], 0) AS [emp_hotel]
	,ISNULL([new_input].[emp_restaurant_bar], 0) AS [emp_restaurant_bar]
	,ISNULL([new_input].[emp_personal_svcs_retail], 0) AS [emp_personal_svcs_retail]
	,ISNULL([new_input].[emp_religious], 0) AS [emp_religious]
	,ISNULL([new_input].[emp_pvt_hh], 0) AS [emp_pvt_hh]
	,ISNULL([new_input].[emp_state_local_gov_ent], 0) AS [emp_state_local_gov_ent]
	,ISNULL([new_input].[emp_fed_non_mil], 0) AS [emp_fed_non_mil]
	  --,[old_input].[emp_fed_mil]   
    ,ISNULL([new_input].[emp_fed_mil], 0) AS [emp_fed_mil]      --change to use the input, as Mike/Limeng requested, yma, 02/28/2019
	,ISNULL([new_input].[emp_state_local_gov_blue], 0) AS [emp_state_local_gov_blue]
	,ISNULL([new_input].[emp_state_local_gov_white], 0) AS [emp_state_local_gov_white]
	,ISNULL([new_input].[emp_public_ed], 0) AS [emp_public_ed]
	,ISNULL([new_input].[emp_own_occ_dwell_mgmt], 0) AS [emp_own_occ_dwell_mgmt]
	,ISNULL([new_input].[emp_fed_gov_accts], 0) AS [emp_fed_gov_accts]
	,ISNULL([new_input].[emp_st_lcl_gov_accts], 0) AS [emp_st_lcl_gov_accts]
	,ISNULL([new_input].[emp_cap_accts], 0) AS [emp_cap_accts]
	,ISNULL([new_input].[enrollgradekto8], 0) AS [enrollgradekto8]
	,ISNULL([new_input].[enrollgrade9to12], 0) AS [enrollgrade9to12]
	,ISNULL([new_input].[collegeenroll], 0) AS [collegeenroll]
	,ISNULL([new_input].[othercollegeenroll], 0) AS [othercollegeenroll]
	,ISNULL([new_input].[adultschenrl], 0) AS [adultschenrl]      --added as discussed with group, 3/28/2019
	--,[old_input].[adultschenrl]      out since 3/28/2019
	,[old_input].[ech_dist]
	,[old_input].[hch_dist]
	,[old_input].[pseudomsa]
	,[old_input].[parkarea]
	,[old_input].[hstallsoth]
	,[old_input].[hstallssam]
	,[old_input].[hparkcost]
	,[old_input].[numfreehrs]
	,[old_input].[dstallsoth]
	,[old_input].[dstallssam]
	,[old_input].[dparkcost]
	,[old_input].[mstallsoth]
	,[old_input].[mstallssam]
	,[old_input].[mparkcost]
	,[old_input].[totint]
	,[old_input].[duden]
	,[old_input].[empden]
	,[old_input].[popden]
	,[old_input].[retempden]
	,[old_input].[totintbin]
	,[old_input].[empdenbin]
	,[old_input].[dudenbin]
	,[old_input].[zip09]
	,ISNULL([new_input].[parkactive], 0) AS [parkactive]
	,ISNULL([new_input].[openspaceparkpreserve], 0) AS [openspaceparkpreserve]
	,ISNULL([new_input].[beachactive], 0) AS [beachactive]
	,ISNULL([new_input].[budgetroom], 0) AS [budgetroom]
	,ISNULL([new_input].[economyroom], 0) AS [economyroom]
	,ISNULL([new_input].[luxuryroom], 0) AS [luxuryroom]
	,ISNULL([new_input].[midpriceroom], 0) AS [midpriceroom]
	,ISNULL([new_input].[upscaleroom], 0) AS [upscaleroom]
	,[new_input].[luz] AS [luz_id]
	,[old_input].[truckregiontype]
	,[old_input].[district27]
	,[old_input].[milestocoast]
FROM (
	SELECT
		[mgra]
		,[minor_mid_xref].[child_geography_zone_id] AS [mgra_geography_zone_id]
		,[minor_mid_xref].[parent_zone] AS [taz]
		,[minor_mid_xref].[parent_geography_zone_id] AS [taz_geography_zone_id]
		,[minor_major_xref].[parent_zone] AS [luz]
		,[minor_major_xref].[parent_geography_zone_id] AS [luz_geography_zone_id]
		,[abm_category]
		,ROUND(SUM([amount] * [value_per_unit]), 0) AS [value]
	FROM
		@project_input_table AS [project_input_table]
	INNER JOIN
		[data_cafe].[ref].[get_prepopulated_geography_xref](@minor_geography_type_id, @middle_geography_type_id) AS [minor_mid_xref] -- this holds the cross walk between mgra (child) and taz (parent)
	ON
		[project_input_table].[mgra] = [minor_mid_xref].[child_zone]
	INNER JOIN
		[data_cafe].[ref].[get_prepopulated_geography_xref](@minor_geography_type_id, @major_geography_type_id)  AS [minor_major_xref] -- this holds the cross walk between mgra (child) and luz (parent)
	ON
		[project_input_table].[mgra] = [minor_major_xref].[child_zone]
	LEFT OUTER JOIN
		-- temp function is for consultant use only
		-- [sb_input].[lu_emp_enroll_density_sr13final_temp] (@lu_version_id) AS [lu_emp_enroll_density_sr13final]
		-- [sb_input].[lu_emp_enroll_density_sr13final](@lu_version_id)
		[sb_input].[lu_emp_enroll_density_sr13final_revised]() AS [lu_emp_enroll_density_sr13final] -- changed to use the density by survey, 11/17/15, yma
	ON
		[project_input_table].[lu_type_id] = [lu_emp_enroll_density_sr13final].[lu_type_id]
		AND [project_input_table].[lu_code] = [lu_emp_enroll_density_sr13final].[lu_code]
	GROUP BY
		[mgra]
		,[minor_mid_xref].[child_geography_zone_id]
		,[minor_mid_xref].[parent_zone]
		,[minor_mid_xref].[parent_geography_zone_id]
		,[minor_major_xref].[parent_zone]
		,[minor_major_xref].[parent_geography_zone_id]
		,[abm_category]
) AS to_pivot
PIVOT (
	SUM([value]) FOR [abm_category] IN (
		[hh_sf]
		,[hh_mf]
		,[hh_mh]
		,[gq_civ]
		,[emp_ag]
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
		,[emp_fed_mil]                              --it was missed before, added 02/28/2019, yma
		,[emp_state_local_gov_blue]
		,[emp_state_local_gov_white]
		,[emp_public_ed]
		,[emp_own_occ_dwell_mgmt]
		,[emp_fed_gov_accts]
		,[emp_st_lcl_gov_accts]
		,[emp_cap_accts]
		,[enrollgradekto8]
		,[enrollgrade9to12]
		,[collegeenroll]
		,[othercollegeenroll]
		,[adultschenrl]                            --added as discussed with group, 3/28/2019,YMA
		,[parkactive]
		,[openspaceparkpreserve]
		,[beachactive]
		,[budgetroom]
		,[economyroom]
		,[luxuryroom]
		,[midpriceroom]
		,[upscaleroom]
	)
) AS [new_input]
INNER JOIN
	[abm_input].[lu_mgra_input] AS [old_input]
ON
	[old_input].[lu_version_id] = @lu_version_id
	AND [new_input].[mgra] = [old_input].[mgra]
LEFT JOIN --use left joinfor cases where MGRA (LUZ) does not have households in the control file by Ziying Ouyang Aug 2017
	[sb_input].[synpop_controls_aggregator](@popsyn_run_id, @major_geography_type_id) AS [synpop_controls_major]
ON
	[new_input].[luz_geography_zone_id] = [synpop_controls_major].[parent_geography_zone_id]
CROSS JOIN
	[sb_input].[synpop_controls_aggregator](@popsyn_run_id, 4) AS [synpop_controls_region] -- hardcoded region geography_type_id

RETURN
END



GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'calculates project inputs for mgra based input file' , @level0type=N'SCHEMA',@level0name=N'sb_input', @level1type=N'FUNCTION',@level1name=N'calculate_project_mgra_based_inputs'
GO



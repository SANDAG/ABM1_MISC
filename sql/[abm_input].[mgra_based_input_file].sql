USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [abm_input].[mgra_based_input_file]    Script Date: 4/23/2019 8:59:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION
	[abm_input].[mgra_based_input_file]
(
	@lu_version_id smallint
)
RETURNS @ret_mgra_based_input_file TABLE
(
	[mgra] [smallint] NOT NULL,
	[taz] [smallint] NOT NULL,
	[hs]  [smallint] NOT NULL,  --missed so added on 10/08/15
	[hs_sf] [smallint] NOT NULL,
	[hs_mf] [smallint] NOT NULL,
	[hs_mh] [smallint] NOT NULL,
	[hh]    [smallint] NOT NULL, --missed so added on 10/08/15
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
	[pop] [smallint] NOT NULL,
	[hhp] [smallint] NOT NULL,
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
	[emp_total] [int] NOT NULL,
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
	[hotelroomtotal] [int] NOT NULL,
	[luz_id] [smallint] NOT NULL,
	[truckregiontype] [tinyint] NOT NULL,
	[district27] [tinyint] NOT NULL,
	[milestocoast] [decimal](7, 4) NOT NULL,
	[lu_version_id] [smallint] NOT NULL
)
AS
BEGIN

DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
DECLARE @middle_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id);

INSERT INTO @ret_mgra_based_input_file
SELECT
	[mgra]
	,[parent_zone]
	,[hs]      -- missed so added on 10/08/15  
	,[hs_sf]
	,[hs_mf]
	,[hs_mh]
	,[hh]      -- missed so added on 10/08/15
	,[hh_sf]
	,[hh_mf]
	,[hh_mh]
	,[gq_civ]
	,[gq_mil]
	,[i1]
	,[i2]
	,[i3]
	,[i4]
	,[i5]
	,[i6]
	,[i7]
	,[i8]
	,[i9]
	,[i10]
	,[hhs]
	,[pop]
	,[hhp]
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
	,[emp_fed_mil]
	,[emp_state_local_gov_blue]
	,[emp_state_local_gov_white]
	,[emp_public_ed]
	,[emp_own_occ_dwell_mgmt]
	,[emp_fed_gov_accts]
	,[emp_st_lcl_gov_accts]
	,[emp_cap_accts]
	,[emp_total]
	,[enrollgradekto8]
	,[enrollgrade9to12]
	,[collegeenroll]
	,[othercollegeenroll]
	,[adultschenrl]
	,[ech_dist]
	,[hch_dist]
	,[pseudomsa]
	,[parkarea]
	,[hstallsoth]
	,[hstallssam]
	,[hparkcost]
	,[numfreehrs]
	,[dstallsoth]
	,[dstallssam]
	,[dparkcost]
	,[mstallsoth]
	,[mstallssam]
	,[mparkcost]
	,[totint]
	,[duden]
	,[empden]
	,[popden]
	,[retempden]
	,[totintbin]
	,[empdenbin]
	,[dudenbin]
	,[zip09]
	,[parkactive]
	,[openspaceparkpreserve]
	,[beachactive]
	,[budgetroom]
	,[economyroom]
	,[luxuryroom]
	,[midpriceroom]
	,[upscaleroom]
	,[hotelroomtotal]
	,[luz_id]
	,[truckregiontype]
	,[district27]
	,[milestocoast]
	,[lu_version_id]
FROM
	[abm_input].[lu_mgra_input]
INNER JOIN (
		SELECT
			[child_zone].[zone] AS [child_zone]
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
			AND [parent_zone].[geography_type_id] = @middle_geography_type_id
	) AS [minor_mid_xref]
ON
	[lu_mgra_input].[mgra] = [minor_mid_xref].[child_zone]
WHERE
	[lu_mgra_input].[lu_version_id] = @lu_version_id
RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to output mgra based input file for ABM' , @level0type=N'SCHEMA',@level0name=N'abm_input', @level1type=N'FUNCTION',@level1name=N'mgra_based_input_file'
GO



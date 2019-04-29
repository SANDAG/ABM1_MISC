USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [abm_input].[generate_lu_mgra_input_sr13final]    Script Date: 4/23/2019 8:32:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [abm_input].[generate_lu_mgra_input_sr13final]
	@lu_version_id smallint -- Need to specify [lu_version_id] located in [ref].[lu_version]
AS

BEGIN TRANSACTION generate_lu_mgra_input_sr13final WITH mark


BEGIN TRY
	DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)

	-- Insert staging tables into [abm_input].[lu_mgra_input]
	INSERT INTO [abm_input].[lu_mgra_input]
	(
		[lu_version_id]
		,[mgra]
		,[hs_sf]
		,[hs_mf]
		,[hs_mh]
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
		,[enrollgradekto8]
		,[enrollgrade9to12]
		,[collegeenroll]
		,[othercollegeenroll]
		,[adultschenrl]
		,[budgetroom]
		,[economyroom]
		,[luxuryroom]
		,[midpriceroom]
		,[upscaleroom]
		,[parkactive]
		,[openspaceparkpreserve]
		,[beachactive]
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
		,[ech_dist]
		,[hch_dist]
		,[pseudomsa]
		,[parkarea]
		,[zip09]
		,[luz_id]
		,[truckregiontype]
		,[district27]
		,[milestocoast]
		,[totint]
		,[duden]
		,[empden]
		,[popden]
		,[retempden]
		,[totintbin]
		,[empdenbin]
		,[dudenbin]
	)
	SELECT 
		[static_data].[lu_version_id]
		,[static_data].[mgra_13]
		,ISNULL([hs_sf], 0) AS [hs_sf]
		,ISNULL([hs_mf], 0) AS [hs_mf]
		,ISNULL([hs_mh], 0) AS [hs_mh]
		,ISNULL([hh_sf], 0) AS [hh_sf]
		,ISNULL([hh_mf], 0) AS [hh_mf]
		,ISNULL([hh_mh], 0) AS [hh_mh]
		,ISNULL([gq_civ], 0) AS [gq_civ]
		,ISNULL([gq_mil], 0) AS [gq_mil]
		,ISNULL([i1], 0) AS [i1]
		,ISNULL([i2], 0) AS [i2]
		,ISNULL([i3], 0) AS [i3]
		,ISNULL([i4], 0) AS [i4]
		,ISNULL([i5], 0) AS [i5]
		,ISNULL([i6], 0) AS [i6]
		,ISNULL([i7], 0) AS [i7]
		,ISNULL([i8], 0) AS [i8]
		,ISNULL([i9], 0) AS [i9]
		,ISNULL([i10], 0) AS [i10]
		,ISNULL([hhs], 0) AS [hhs]
		,ISNULL([pop], 0) AS [pop]
		,ISNULL([hhp], 0) AS [hhp]
		,ISNULL([emp_ag], 0) AS [emp_ag]
		,ISNULL([emp_const_non_bldg_prod], 0) AS [emp_const_non_bldg_prod]
		,ISNULL([emp_const_non_bldg_office], 0) AS [emp_const_non_bldg_office]
		,ISNULL([emp_utilities_prod], 0) AS [emp_utilities_prod]
		,ISNULL([emp_utilities_office], 0) AS [emp_utilities_office]
		,ISNULL([emp_const_bldg_prod], 0) AS [emp_const_bldg_prod]
		,ISNULL([emp_const_bldg_office], 0) AS [emp_const_bldg_office]
		,ISNULL([emp_mfg_prod], 0) AS [emp_mfg_prod]
		,ISNULL([emp_mfg_office], 0) AS [emp_mfg_office]
		,ISNULL([emp_whsle_whs], 0) AS [emp_whsle_whs]
		,ISNULL([emp_trans], 0) AS [emp_trans]
		,ISNULL([emp_retail], 0) AS [emp_retail]
		,ISNULL([emp_prof_bus_svcs], 0) AS [emp_prof_bus_svcs]
		,ISNULL([emp_prof_bus_svcs_bldg_maint], 0) AS [emp_prof_bus_svcs_bldg_maint]
		,ISNULL([emp_pvt_ed_k12], 0) AS [emp_pvt_ed_k12]
		,ISNULL([emp_pvt_ed_post_k12_oth], 0) AS [emp_pvt_ed_post_k12_oth]
		,ISNULL([emp_health], 0) AS [emp_health]
		,ISNULL([emp_personal_svcs_office], 0) AS [emp_personal_svcs_office]
		,ISNULL([emp_amusement], 0) AS [emp_amusement]
		,ISNULL([emp_hotel], 0) AS [emp_hotel]
		,ISNULL([emp_restaurant_bar], 0) AS [emp_restaurant_bar]
		,ISNULL([emp_personal_svcs_retail], 0) AS [emp_personal_svcs_retail]
		,ISNULL([emp_religious], 0) AS [emp_religious]
		,ISNULL([emp_pvt_hh], 0) AS [emp_pvt_hh]
		,ISNULL([emp_state_local_gov_ent], 0) AS [emp_state_local_gov_ent]
		,ISNULL([emp_fed_non_mil], 0) AS [emp_fed_non_mil]
		,ISNULL([emp_fed_mil], 0) AS [emp_fed_mil]
		,ISNULL([emp_state_local_gov_blue], 0) AS [emp_state_local_gov_blue]
		,ISNULL([emp_state_local_gov_white], 0) AS [emp_state_local_gov_white]
		,ISNULL([emp_public_ed], 0) AS [emp_public_ed]
		,ISNULL([emp_own_occ_dwell_mgmt], 0) AS [emp_own_occ_dwell_mgmt]
		,ISNULL([emp_fed_gov_accts], 0) AS [emp_fed_gov_accts]
		,ISNULL([emp_st_lcl_gov_accts], 0) AS [emp_st_lcl_gov_accts]
		,ISNULL([emp_cap_accts], 0) AS [emp_cap_accts]
		,ISNULL([enrollgradekto8], 0) AS [enrollgradekto8]
		,ISNULL([enrollgrade9to12], 0) AS [enrollgrade9to12]
		,ISNULL([collegeenroll], 0) AS [collegeenroll]
		,ISNULL([othercollegeenroll], 0) AS [othercollegeenroll]
		,ISNULL([adultschenrl], 0) AS [adultschenrl]
		,ISNULL([budgetroom], 0) AS [budgetroom]
		,ISNULL([economyroom], 0) AS [economyroom]
		,ISNULL([luxuryroom], 0) AS [luxuryroom]
		,ISNULL([midpriceroom], 0) AS [midpriceroom]
		,ISNULL([upscaleroom], 0) AS [upscaleroom]
		,ISNULL([parkactive], 0) AS [parkactive]
		,ISNULL([openspaceparkpreserve], 0) AS [openspaceparkpreserve]
		,ISNULL([beachactive], 0) AS [beachactive]
		,ISNULL([hstallsoth], 0) AS [hstallsoth]
		,ISNULL([hstallssam], 0) AS [hstallssam]
		,ISNULL([hparkcost], 0) AS [hparkcost]
		,ISNULL([numfreehrs], 0) AS [numfreehrs]
		,ISNULL([dstallsoth], 0) AS [dstallsoth]
		,ISNULL([dstallssam], 0) AS [dstallssam]
		,ISNULL([dparkcost], 0) AS [dparkcost]
		,ISNULL([mstallsoth], 0) AS [mstallsoth]
		,ISNULL([mstallssam], 0) AS [mstallssam]
		,ISNULL([mparkcost], 0) AS [mparkcost]
		,ISNULL([ech_dist], 0) AS [ech_dist]
		,ISNULL([hch_dist], 0) AS [hch_dist]
		,ISNULL([pseudomsa], 0) AS [pseudomsa]
		,ISNULL([parkarea], 0) AS [parkarea]
		,ISNULL([zip09], 0) AS [zip09]
		,ISNULL([luz_id], 0) AS [luz_id]
		,ISNULL([truckregiontype], 0) AS [truckregiontype]
		,ISNULL([district27], 0) AS [district27]
		,ISNULL([milestocoast], 0) AS [milestocoast]
		,[totint]
		,[duden]
		,[empden]
		,[popden]
		,[retempden]
		,[totintbin]
		,[empdenbin]
		,[dudenbin]
	FROM
		[abm_input].[lu_static_unknown_source_data_sr13final](@lu_version_id) AS [static_data] -- make this the from since it contains all series 13 final mgras
	LEFT OUTER JOIN
		[abm_input].[lu_hh_data_sr13final](@lu_version_id) AS hh
	ON
		static_data.[mgra_13] = hh.[mgra_13]
	LEFT OUTER JOIN
		[abm_input].[lu_employment_data_sr13final](@lu_version_id) AS employment
	ON
		static_data.[mgra_13] = employment.[mgra_13]
	LEFT OUTER JOIN
		[abm_input].[lu_enrollment_data_sr13final](@lu_version_id) AS enrollment
	ON
		static_data.[mgra_13] = enrollment.[mgra_13]
	LEFT OUTER JOIN
		[abm_input].[lu_hotel_data_sr13final](@lu_version_id) AS hotel
	ON
		static_data.[mgra_13] = hotel.[mgra_13]
	LEFT OUTER JOIN
		[abm_input].[lu_park_beach_openspace_data_sr13final](@lu_version_id) AS park_beach_openspace
	ON
		static_data.[mgra_13] = park_beach_openspace.[mgra_13]	
	LEFT OUTER JOIN
		[abm_input].[lu_parking_data_sr13final](@lu_version_id) AS parking
	ON
		static_data.[mgra_13] = parking.[mgra_13]
	LEFT OUTER JOIN
		[abm_input].[abm_4ds](@lu_version_id) AS abm_4ds
	ON
		static_data.[mgra_13] = abm_4ds.[mgra_13]


	-- Confirm inputs have been created
	UPDATE
		[ref].[lu_version]
	SET
		[mgra_based_input_file_created] = GETDATE()
	WHERE
		[lu_version_id] = @lu_version_id


END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH

COMMIT TRANSACTION
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'stored procedure to create series 13 final mgra based input file' , @level0type=N'SCHEMA',@level0name=N'abm_input', @level1type=N'PROCEDURE',@level1name=N'generate_lu_mgra_input_sr13final'
GO



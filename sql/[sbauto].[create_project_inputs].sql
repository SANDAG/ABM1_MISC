USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[create_project_inputs]    Script Date: 4/23/2019 8:42:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<YMA>
-- Create date: <4/14/2018>
-- Description:	<Main Procedure for SB Override Automating>
-- =============================================


CREATE PROCEDURE [sbauto].[create_project_inputs]
 @increment     int
,@lu_scenario_desc nvarchar(200) 


AS
BEGIN

SET NOCOUNT ON
BEGIN TRANSACTION service_bureau_job_override_auto WITH mark


-- set up project ************************************************************
BEGIN TRY
	-- get the land use version id and popsyn run id
	DECLARE @lu_version_id smallint = (SELECT [lu_version_id] FROM ref.lu_version WHERE increment = @increment and lu_version_id between 101 and 108)
	DECLARE @popsyn_run_id smallint = (SELECT [popsyn_run_id] FROM ref.popsyn_run WHERE lu_version_id = @lu_version_id )

	--get geography type ids for the scenario year
	DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
	DECLARE @middle_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
	DECLARE @major_geography_type_id smallint = (SELECT [major_geography_type_id] FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)

	-- populate table to hold data from the service bureau input file
	DECLARE @input_file_table [project_input_table_type]
	INSERT INTO @input_file_table
	select *
	from sbauto.get_project_input_file_tt
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH


-- insert new lu_version_id **************************************************

BEGIN TRY
	DECLARE @new_lu_version_id smallint
	EXECUTE [sb_input].[insert_project_lu_version]
		@lu_version_id
		,@lu_scenario_desc
		,@new_lu_version_id OUTPUT
    --select @new_lu_version_id
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH


-- create mgra based inputs **************************************************
BEGIN TRY
	-- insert new mgra based input file into [abm_input].[lu_mgra_input]
	INSERT INTO
		[abm_input].[lu_mgra_input]
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
		,[luz_id]
		,[truckregiontype]
		,[district27]
		,[milestocoast]
	)
	SELECT
		@new_lu_version_id
		,[old_records].[mgra]
		,ISNULL([new_records].[hs_sf], [old_records].[hs_sf]) AS [hs_sf]
		,ISNULL([new_records].[hs_mf], [old_records].[hs_mf]) AS [hs_mf]
		,ISNULL([new_records].[hs_mh], [old_records].[hs_mh]) AS [hs_mh]
		,ISNULL([new_records].[hh_sf], [old_records].[hh_sf]) AS [hh_sf]
		,ISNULL([new_records].[hh_mf], [old_records].[hh_mf]) AS [hh_mf]
		,ISNULL([new_records].[hh_mh], [old_records].[hh_mh]) AS [hh_mh]
		,ISNULL([new_records].[gq_civ], [old_records].[gq_civ]) AS [gq_civ]
		,ISNULL([new_records].[gq_mil], [old_records].[gq_mil]) AS [gq_mil]
		,ISNULL([new_records].[i1], [old_records].[i1]) AS [i1]
		,ISNULL([new_records].[i2], [old_records].[i2]) AS [i2]
		,ISNULL([new_records].[i3], [old_records].[i3]) AS [i3]
		,ISNULL([new_records].[i4], [old_records].[i4]) AS [i4]
		,ISNULL([new_records].[i5], [old_records].[i5]) AS [i5]
		,ISNULL([new_records].[i6], [old_records].[i6]) AS [i6]
		,ISNULL([new_records].[i7], [old_records].[i7]) AS [i7]
		,ISNULL([new_records].[i8], [old_records].[i8]) AS [i8]
		,ISNULL([new_records].[i9], [old_records].[i9]) AS [i9]
		,ISNULL([new_records].[i10], [old_records].[i10]) AS [i10]
		,ISNULL([new_records].[hhs], [old_records].[hhs]) AS [hhs]
		,ISNULL([new_records].[pop], [old_records].[pop]) AS [pop]
		,ISNULL([new_records].[hhp], [old_records].[hhp]) AS [hhp]
		,ISNULL([new_records].[emp_ag], [old_records].[emp_ag]) AS [emp_ag]
		,ISNULL([new_records].[emp_const_non_bldg_prod], [old_records].[emp_const_non_bldg_prod]) AS [emp_const_non_bldg_prod]
		,ISNULL([new_records].[emp_const_non_bldg_office], [old_records].[emp_const_non_bldg_office]) AS [emp_const_non_bldg_office]
		,ISNULL([new_records].[emp_utilities_prod], [old_records].[emp_utilities_prod]) AS [emp_utilities_prod]
		,ISNULL([new_records].[emp_utilities_office], [old_records].[emp_utilities_office]) AS [emp_utilities_office]
		,ISNULL([new_records].[emp_const_bldg_prod], [old_records].[emp_const_bldg_prod]) AS [emp_const_bldg_prod]
		,ISNULL([new_records].[emp_const_bldg_office], [old_records].[emp_const_bldg_office]) AS [emp_const_bldg_office]
		,ISNULL([new_records].[emp_mfg_prod], [old_records].[emp_mfg_prod]) AS [emp_mfg_prod]
		,ISNULL([new_records].[emp_mfg_office], [old_records].[emp_mfg_office]) AS [emp_mfg_office]
		,ISNULL([new_records].[emp_whsle_whs], [old_records].[emp_whsle_whs]) AS [emp_whsle_whs]
		,ISNULL([new_records].[emp_trans], [old_records].[emp_trans]) AS [emp_trans]
		,ISNULL([new_records].[emp_retail], [old_records].[emp_retail]) AS [emp_retail]
		,ISNULL([new_records].[emp_prof_bus_svcs], [old_records].[emp_prof_bus_svcs]) AS [emp_prof_bus_svcs]
		,ISNULL([new_records].[emp_prof_bus_svcs_bldg_maint], [old_records].[emp_prof_bus_svcs_bldg_maint]) AS [emp_prof_bus_svcs_bldg_maint]
		,ISNULL([new_records].[emp_pvt_ed_k12], [old_records].[emp_pvt_ed_k12]) AS [emp_pvt_ed_k12]
		,ISNULL([new_records].[emp_pvt_ed_post_k12_oth], [old_records].[emp_pvt_ed_post_k12_oth]) AS [emp_pvt_ed_post_k12_oth]
		,ISNULL([new_records].[emp_health], [old_records].[emp_health]) AS [emp_health]
		,ISNULL([new_records].[emp_personal_svcs_office], [old_records].[emp_personal_svcs_office]) AS [emp_personal_svcs_office]
		,ISNULL([new_records].[emp_amusement], [old_records].[emp_amusement]) AS [emp_amusement]
		,ISNULL([new_records].[emp_hotel], [old_records].[emp_hotel]) AS [emp_hotel]
		,ISNULL([new_records].[emp_restaurant_bar], [old_records].[emp_restaurant_bar]) AS [emp_restaurant_bar]
		,ISNULL([new_records].[emp_personal_svcs_retail], [old_records].[emp_personal_svcs_retail]) AS [emp_personal_svcs_retail]
		,ISNULL([new_records].[emp_religious], [old_records].[emp_religious]) AS [emp_religious]
		,ISNULL([new_records].[emp_pvt_hh], [old_records].[emp_pvt_hh]) AS [emp_pvt_hh]
		,ISNULL([new_records].[emp_state_local_gov_ent], [old_records].[emp_state_local_gov_ent]) AS [emp_state_local_gov_ent]
		,ISNULL([new_records].[emp_fed_non_mil], [old_records].[emp_fed_non_mil]) AS [emp_fed_non_mil]
		,ISNULL([new_records].[emp_fed_mil], [old_records].[emp_fed_mil]) AS [emp_fed_mil]
		,ISNULL([new_records].[emp_state_local_gov_blue], [old_records].[emp_state_local_gov_blue]) AS [emp_state_local_gov_blue]
		,ISNULL([new_records].[emp_state_local_gov_white], [old_records].[emp_state_local_gov_white]) AS [emp_state_local_gov_white]
		,ISNULL([new_records].[emp_public_ed], [old_records].[emp_public_ed]) AS [emp_public_ed]
		,ISNULL([new_records].[emp_own_occ_dwell_mgmt], [old_records].[emp_own_occ_dwell_mgmt]) AS [emp_own_occ_dwell_mgmt]
		,ISNULL([new_records].[emp_fed_gov_accts], [old_records].[emp_fed_gov_accts]) AS [emp_fed_gov_accts]
		,ISNULL([new_records].[emp_st_lcl_gov_accts], [old_records].[emp_st_lcl_gov_accts]) AS [emp_st_lcl_gov_accts]
		,ISNULL([new_records].[emp_cap_accts], [old_records].[emp_cap_accts]) AS [emp_cap_accts]
		,ISNULL([new_records].[enrollgradekto8], [old_records].[enrollgradekto8]) AS [enrollgradekto8]
		,ISNULL([new_records].[enrollgrade9to12], [old_records].[enrollgrade9to12]) AS [enrollgrade9to12]
		,ISNULL([new_records].[collegeenroll], [old_records].[collegeenroll]) AS [collegeenroll]
		,ISNULL([new_records].[othercollegeenroll], [old_records].[othercollegeenroll]) AS [othercollegeenroll]
		,ISNULL([new_records].[adultschenrl], [old_records].[adultschenrl]) AS [adultschenrl]
		,ISNULL([new_records].[ech_dist], [old_records].[ech_dist]) AS [ech_dist]
		,ISNULL([new_records].[hch_dist], [old_records].[hch_dist]) AS [hch_dist]
		,ISNULL([new_records].[pseudomsa], [old_records].[pseudomsa]) AS [pseudomsa]
		,ISNULL([new_records].[parkarea], [old_records].[parkarea]) AS [parkarea]
		,ISNULL([new_records].[hstallsoth], [old_records].[hstallsoth]) AS [hstallsoth]
		,ISNULL([new_records].[hstallssam], [old_records].[hstallssam]) AS [hstallssam]
		,ISNULL([new_records].[hparkcost], [old_records].[hparkcost]) AS [hparkcost]
		,ISNULL([new_records].[numfreehrs], [old_records].[numfreehrs]) AS [numfreehrs]
		,ISNULL([new_records].[dstallsoth], [old_records].[dstallsoth]) AS [dstallsoth]
		,ISNULL([new_records].[dstallssam], [old_records].[dstallssam]) AS [dstallssam]
		,ISNULL([new_records].[dparkcost], [old_records].[dparkcost]) AS [dparkcost]
		,ISNULL([new_records].[mstallsoth], [old_records].[mstallsoth]) AS [mstallsoth]
		,ISNULL([new_records].[mstallssam], [old_records].[mstallssam]) AS [mstallssam]
		,ISNULL([new_records].[mparkcost], [old_records].[mparkcost]) AS [mparkcost]
		,ISNULL([new_records].[totint], [old_records].[totint]) AS [totint]
		,ISNULL([new_records].[duden], [old_records].[duden]) AS [duden]
		,ISNULL([new_records].[empden], [old_records].[empden]) AS [empden]
		,ISNULL([new_records].[popden], [old_records].[popden]) AS [popden]
		,ISNULL([new_records].[retempden], [old_records].[retempden]) AS [retempden]
		,ISNULL([new_records].[totintbin], [old_records].[totintbin]) AS [totintbin]
		,ISNULL([new_records].[empdenbin], [old_records].[empdenbin]) AS [empdenbin]
		,ISNULL([new_records].[dudenbin], [old_records].[dudenbin]) AS [dudenbin]
		,ISNULL([new_records].[zip09], [old_records].[zip09]) AS [zip09]
		,ISNULL([new_records].[parkactive], [old_records].[parkactive]) AS [parkactive]
		,ISNULL([new_records].[openspaceparkpreserve], [old_records].[openspaceparkpreserve]) AS [openspaceparkpreserve]
		,ISNULL([new_records].[beachactive], [old_records].[beachactive]) AS [beachactive]
		,ISNULL([new_records].[budgetroom], [old_records].[budgetroom]) AS [budgetroom]
		,ISNULL([new_records].[economyroom], [old_records].[economyroom]) AS [economyroom]
		,ISNULL([new_records].[luxuryroom], [old_records].[luxuryroom]) AS [luxuryroom]
		,ISNULL([new_records].[midpriceroom], [old_records].[midpriceroom]) AS [midpriceroom]
		,ISNULL([new_records].[upscaleroom], [old_records].[upscaleroom]) AS [upscaleroom]
		,ISNULL([new_records].[luz_id], [old_records].[luz_id]) AS [luz_id]
		,ISNULL([new_records].[truckregiontype], [old_records].[truckregiontype]) AS [truckregiontype]
		,ISNULL([new_records].[district27], [old_records].[district27]) AS [district27]
		,ISNULL([new_records].[milestocoast], [old_records].[milestocoast]) AS [milestocoast]
	FROM
		[sb_input].[calculate_project_mgra_based_inputs] (@popsyn_run_id ,@input_file_table) AS [new_records]
	RIGHT OUTER JOIN
		[abm_input].[lu_mgra_input] AS [old_records]
	ON
		[new_records].[mgra] = [old_records].[mgra]
	WHERE
		[old_records].[lu_version_id] = @lu_version_id


-- update lu_version table to confirm mgra input file creation*************
UPDATE 
	[ref].[lu_version]
SET
	[mgra_based_input_file_created] = GETDATE()
WHERE
	[lu_version_id] = @new_lu_version_id

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH

-- create popsyn control targets *********************************************
BEGIN TRY
	DBCC CHECKIDENT('popsyn_input.control_targets', RESEED, 0)
	INSERT INTO [popsyn_input].[control_targets]
	SELECT
		@new_lu_version_id AS [lu_version_id]
		,[target_category_id]
		,[geography_zone_id]
		,[value]
	FROM
		[sbauto].[calculate_project_popsyn_control_targets] (@popsyn_run_id ,@input_file_table) AS [new_targets]


-- update lu_version table to confirm popsyn controls creation
UPDATE 
	[ref].[lu_version]
SET
	[popsyn_targets_created] = GETDATE()
WHERE
	[lu_version_id] = @new_lu_version_id

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH


--created table for 4d ludata input, YMA, modified 4/23/2018*********************************************
BEGIN TRY
   INSERT INTO
		[sbauto].[lu_mgra_4d_input_ludata]
	(
		 [lu_version_id]
		,[mgra]
		,[acres]
		,[effective_acres]
		,[lu]
		,[emp_total]
	)
	SELECT
		 @new_lu_version_id as [lu_version_id]
		,[mgra]
		,0 as [acres]
		,0 as [effective_acres]
		,5001 as [lu]
		,(emp_retail + emp_restaurant_bar + emp_personal_svcs_retail) as emp_total
    FROM [abm_input].[lu_mgra_input]
	WHERE lu_version_id = @new_lu_version_id

	union all

	SELECT
		 @new_lu_version_id as [lu_version_id]
		,[mgra]
		,0 as [acres]
		,0 as [effective_acres]
		,9999 as [lu]
		,(emp_total-(emp_retail + emp_restaurant_bar + emp_personal_svcs_retail)) as emp_total
    FROM [abm_input].[lu_mgra_input]
	WHERE lu_version_id = @new_lu_version_id



-- insert the new lu_version_id into a temp table, YMA, 4/18/2018**************************

TRUNCATE TABLE [sbauto].[temp_version_id];
INSERT INTO [sbauto].[temp_version_id]
VALUES (@new_lu_version_id,@lu_scenario_desc);

--insert the temp input table into the regular table to keep it for valdiation, YMA, 4/25/2018

INSERT INTO
		[sbauto].[project_input_file]
	(
		 [lu_version_id]
		,[mgra]
		,[lu_type_id]
		,[lu_code]
		,[amount]
	)
	SELECT 
	@new_lu_version_id as [lu_version_id]
	,mgra
	,lu_type_id
	,lu_code
	,amount
	FROM sbauto.get_project_input_file_tt

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
	RETURN
END CATCH

COMMIT TRANSACTION

END







GO



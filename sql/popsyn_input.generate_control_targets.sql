USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [popsyn_input].[generate_control_targets]    Script Date: 4/23/2019 8:39:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [popsyn_input].[generate_control_targets]
	@lu_version_id smallint -- Need to specify [lu_version_id] located in [ref].[lu_version]
AS

BEGIN TRANSACTION generate_control_targets WITH mark

-- See if data even exists
IF NOT EXISTS (SELECT * FROM [ref].[lu_version] WHERE [lu_version_id] = @lu_version_id)
BEGIN
	print 'ERROR: specified [lu_version_id] does not exist in [ref].[lu_version]'
	RETURN
END
IF NOT EXISTS (SELECT * FROM [popsyn_input].[vi_lu_data] WHERE [lu_version_id] = @lu_version_id)
BEGIN
	print 'ERROR: specified [lu_version_id] does not exist in [popsyn_input].[vi_lu_data]'
	RETURN
END

DBCC CHECKIDENT ('popsyn_input.control_targets',RESEED, 0)
-- Insert mgra targets
INSERT INTO [popsyn_input].[control_targets]
SELECT
	tt.[lu_version_id]
	,[target_category_id]
    ,[geography_zone_id]
	,[value]
FROM
	[popsyn_input].[vi_lu_data]
UNPIVOT
(
	[value]
	FOR [target_col_nm] IN (
	  [hh]
	  ,[hh_sf]
      ,[hh_mf]
      ,[hh_mh]
      ,[gq_noninst]
      ,[gq_civ_college]
      ,[gq_mil]
	  ,[pop_non_gq]
	  )
) tt
INNER JOIN
	[ref].[target_category]
ON
	tt.[target_col_nm] = [target_category].[target_category_col_nm]
INNER JOIN
	[data_cafe].[ref].[geography_zone]
ON
	tt.[mgra] = [geography_zone].[zone]
INNER JOIN
	[ref].[lu_version]
ON
	tt.[lu_version_id] = [lu_version].[lu_version_id]
WHERE
	[geography_type_id] = [minor_geography_type_id] -- ensure geography join is on the given mgra geography type
	AND tt.[lu_version_id] = @lu_version_id

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END


PRINT 'mgra targets inserted for lu_version_id = ' + CAST(@lu_version_id AS nvarchar)


-- Insert taz targets
INSERT INTO [popsyn_input].[control_targets]
SELECT
	tt2.[lu_version_id]
	,[target_category_id]
    ,[geography_zone_id]
	,[value]
FROM (
	SELECT
		[lu_version_id]
		,[taz]
        ,SUM([hhwoc]) AS [hhwoc]
        ,SUM([hhwc]) AS [hhwc]
        ,SUM([hhworkers0]) AS [hhworkers0]
        ,SUM([hhworkers1]) AS [hhworkers1]
        ,SUM([hhworkers2]) AS [hhworkers2]
        ,SUM([hhworkers3]) AS [hhworkers3]
        ,SUM([hh_income_cat_1]) AS [hh_income_cat_1]
        ,SUM([hh_income_cat_2]) AS [hh_income_cat_2]
        ,SUM([hh_income_cat_3]) AS [hh_income_cat_3]
        ,SUM([hh_income_cat_4]) AS [hh_income_cat_4]
        ,SUM([hh_income_cat_5]) AS [hh_income_cat_5]
        ,SUM([male]) AS [male]
        ,SUM([female]) AS [female]
        ,SUM([age_0_17]) AS [age_0_17]
        ,SUM([age_18_24]) AS [age_18_24]
        ,SUM([age_25_34]) AS [age_25_34]
        ,SUM([age_35_49]) AS [age_35_49]
        ,SUM([age_50_64]) AS [age_50_64]
        ,SUM([age_65_79]) AS [age_65_79]
        ,SUM([age_80plus]) AS [age_80plus]
		,SUM([hisp]) AS [hisp]
		,SUM([nhw]) AS [nhw]
		,SUM([nhb]) AS [nhb]
		,SUM([nho_popsyn]) AS [nho_popsyn]
		,SUM([nha]) AS [nha]
	FROM
		[popsyn_input].[vi_lu_data]
	WHERE
		[lu_version_id] = @lu_version_id
	GROUP BY
		[lu_version_id]
		,[taz]
	) tt1
UNPIVOT
(
	[value]
	FOR [target_col_nm] IN (
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
INNER JOIN
	[ref].[target_category]
ON
	tt2.[target_col_nm] = [target_category].[target_category_col_nm]
INNER JOIN
	[data_cafe].[ref].[geography_zone]
ON
	tt2.[taz] = [geography_zone].[zone]
INNER JOIN
	[ref].[lu_version]
ON
	tt2.[lu_version_id] = [lu_version].[lu_version_id]
WHERE
	[geography_type_id] = [middle_geography_type_id] -- ensure geography join is on the given taz geography type

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'taz targets inserted for lu_version_id = ' + CAST(@lu_version_id AS nvarchar)


-- Insert region targets
INSERT INTO [popsyn_input].[control_targets]
SELECT
	[lu_version_id]
	,[target_category_id]
    ,[geography_zone_id]
	,SUM([value]) AS [value]
FROM (
	SELECT
		[lu_version_id]
		,[region] -- San Diego Region
		,SUM([gq_noninst]) AS [gq_noninst]
		,SUM([pop_non_gq]) AS [pop_non_gq]
	FROM
		[popsyn_input].[vi_lu_data]
	WHERE
		[lu_version_id] = @lu_version_id
	GROUP BY
		[lu_version_id]
		,[region] -- San Diego Region
	) tt1
UNPIVOT
(
	[value]
	FOR [target_col_nm] IN (
	  [gq_noninst]
      ,[pop_non_gq]
	  )
) tt2
INNER JOIN
	[ref].[target_category]
ON
	tt2.[target_col_nm] = [target_category].[target_category_col_nm]
INNER JOIN
	[data_cafe].[ref].[geography_zone]
ON
	tt2.[region] = [geography_zone].[zone]
WHERE
	[geography_type_id] = 4 -- ensure geography join is on San Diego Region, hardcoded
GROUP BY
	[lu_version_id]
	,[target_category_id]
    ,[geography_zone_id]

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'region targets inserted for lu_version_id = ' + CAST(@lu_version_id AS nvarchar)


-- Update date targets created
UPDATE
	[ref].[lu_version]
SET
	[popsyn_targets_created] = GETDATE()
WHERE
	[lu_version_id] = @lu_version_id


PRINT 'all targets inserted for lu_version_id = ' + CAST(@lu_version_id AS nvarchar)

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

COMMIT TRANSACTION
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'stored procedure to generate popsyn control targets from forecast land use data' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'PROCEDURE',@level1name=N'generate_control_targets'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'PROCEDURE',@level1name=N'generate_control_targets'
GO


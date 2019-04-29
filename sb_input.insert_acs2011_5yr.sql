USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [popsyn_input].[insert_acs2011_5yr]    Script Date: 4/23/2019 8:39:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [popsyn_input].[insert_acs2011_5yr]
AS

BEGIN TRANSACTION insert_acs2011_5yr WITH mark

PRINT 'census acs 2011 pums 5 year input data hardcoded as [popsyn_data_source_id] = 1'

-- Populate households
DBCC CHECKIDENT ('popsyn_input.hh',RESEED, 0)
INSERT INTO [popsyn_input].[hh]
SELECT
	1 AS [popsyn_data_source_id]
	,1 AS [region] -- changed from acs pums value of 4 to reflect what is in our geography reference tables
	,[PUMA]
	,[WGTP]
	,[pums_hh_sd].[SERIALNO]
	,[NP]
	,CASE	WHEN [ADJINC]=1102938 THEN CAST((([HINCP]/1.0)*1.016787*1.05156) AS decimal(9,2))
			WHEN [ADJINC]=1063801 THEN CAST((([HINCP]/1.0)*1.018389*1.01265) AS decimal(9,2))
			WHEN [ADJINC]=1048026 THEN CAST((([HINCP]/1.0)*0.999480*1.01651) AS decimal(9,2))
			WHEN [ADJINC]=1039407 THEN CAST((([HINCP]/1.0)*1.007624*1.00000) AS decimal(9,2))
			WHEN [ADJINC]=1018237 THEN CAST((([HINCP]/1.0)*1.018237*0.96942) AS decimal(9,2))
			ELSE 999
			END AS [hh_income_adj] -- adjusted to 2010 dollars
	,[BLD]
	,CASE	WHEN [nwrkrs_esr] IS NULL THEN 0
			ELSE [nwrkrs_esr]
			END
	,[VEH]
	,[HHT]
	,0 AS [gq_type_id] -- Household
	,CASE	WHEN [BLD] IN (2,3) THEN '1'				-- Single-family
			WHEN [BLD] IN (4,5,6,7,8,9) THEN '2'		-- Multi-family
			WHEN [BLD] IN (1,10) THEN '3'				-- Mobile-home
			ELSE '0'
			END AS [hh_type_id]
	,CASE	WHEN [HUPAC] IN (4) THEN '0'				-- No children
			WHEN [HUPAC] IN (1,2,3) THEN '1'			-- 1 or more children
			ELSE 'NULL'
			END AS [hh_child]
FROM
	[pila\SdgIntDb].[census].[acs2011_5yr].[pums_hh_sd] -- 2011 ACS PUMS for san diego
--Setting number of workers in HH based on Employment Status Recode [ESR] attribute in PUMS Person File
LEFT OUTER JOIN ( 
	SELECT
		[SERIALNO]
		,COUNT(*) AS [nwrkrs_esr]
	FROM
		[pila\SdgIntDb].[census].[acs2011_5yr].[pums_pp_sd] -- 2011 ACS PUMS for san diego
	WHERE 
		[ESR] IN (1,2,4,5)
	GROUP BY 
		[SERIALNO]
	) AS hh_workers
ON
	[pums_hh_sd].[SERIALNO] = hh_workers.[SERIALNO]
WHERE
	[pums_hh_sd].[NP] > 0 -- Deleting vacant units
	AND [pums_hh_sd].[TYPE] = 1 -- Deleting gq units

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'census acs 2011 pums 5 year input household data inserted into [popsyn_input].[hh]'


-- Populate persons
DBCC CHECKIDENT ('popsyn_input.person',RESEED, 0)
INSERT INTO [popsyn_input].[person]
SELECT 
	tt.[popsyn_data_source_id]
	,[hh_id]
    ,tt.[PUMA]
	,[hh].[WGTP] -- household weight
	,tt.[SERIALNO]
    ,[SPORDER]
    ,[AGEP]
	,[SEX]
	,[WKHP]
	,[ESR]
	,[SCHG]
	,[employed]
	,[WKW]
	,[MIL]
	,[SCHL]
	,[indp02]
	,[indp07]
	,[occp02]
	,[occp10]
	,[socp00]
	,[socp10]
	,[gq_type_id]
	,[soc]
	,CASE	WHEN soc IN (11,13,15,17,27,19,39) THEN '1'
			WHEN soc IN (21,23,25,29,31) THEN '2'
			WHEN soc IN (35,37) THEN '3'
			WHEN soc IN (41,43) THEN '4'
			WHEN soc IN (45,47,49) THEN '5'
			WHEN soc IN (51,53) THEN '6'
			WHEN soc IN (55) THEN '7'
			WHEN soc IN (33) THEN '8'
			ELSE '999'
			END AS [occp]
	,[HISP]
	,[RAC1P]
	,[popsyn_race_id] =	CASE	WHEN [HISP] > 1 THEN 1 -- hispanic
								WHEN [RAC1P] = 1 AND [HISP] <= 1 THEN 2 -- nhw
								WHEN [RAC1P] = 2 AND [HISP] <= 1 THEN 3 -- nhb
								WHEN [RAC1P] IN (3,4,5,7,8,9) AND [HISP] <= 1 THEN 4 -- nho_popsyn
								WHEN [RAC1P] = 6 AND [HISP] <= 1 THEN 5 -- nha
								ELSE 0
								END
FROM (
SELECT
	1 AS [popsyn_data_source_id]
    ,[PUMA]
	,[SERIALNO]
    ,[SPORDER]
    ,[AGEP]
	,[SEX]
	,[WKHP]
	,[ESR]
	,[SCHG]
	,CASE	WHEN [ESR] IN (1,2,4,5) THEN 1
			ELSE 0
			END AS [employed]
	,[WKW]
	,[MIL]
	,[SCHL]
	,[indp02]
	,[indp07]
	,[occp02]
	,[occp10]
	,[socp00]
	,[socp10]
	,CASE	WHEN [ESR] NOT IN (1,2,4,5) THEN '0'
			WHEN LEFT(LTRIM(RTRIM(socp00)),2) = 'N' OR LEFT(LTRIM(RTRIM(socp00)),2) = 'N.' THEN LEFT(LTRIM(RTRIM(socp10)),2)
			ELSE LEFT(LTRIM(RTRIM(socp00)),2)
			END AS [soc]
	,[HISP]
	,[RAC1P]
FROM 
	[pila\SdgIntDb].[census].[acs2011_5yr].[pums_pp_sd] -- 2011 ACS PUMS for san diego
) AS tt
INNER JOIN -- deletes vacant units and non-gq
	[popsyn_input].[hh]
ON
	tt.[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
	AND tt.[SERIALNO] = [hh].[serialno]

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'census acs 2011 pums 5 year input person data inserted into [popsyn_input].[person]'


-- Populate GQ households
INSERT INTO [popsyn_input].[hh]
SELECT
	1 AS [popsyn_data_source_id]
	,1 AS [region] -- changed from acs pums value of 4 to reflect what is in our geography reference tables
	,[PUMA]
	,[PWGTP] AS [wgtp] -- person weight
	,[pums_hh_sd].[SERIALNO]
	,[NP]
	,NULL AS [hh_income_adj] -- no income for gq households
	,[BLD]
	,CASE	WHEN [nwrkrs_esr] IS NULL THEN 0
			ELSE [nwrkrs_esr]
			END AS [workers]
	,[VEH]
	,[HHT]
	,CASE	WHEN [SCHG] IN (6,7) THEN 1
			WHEN [MIL] = 1 THEN 2
			ELSE 3
			END AS [gq_type_id]
	,NULL AS [hh_type_id]
	,NULL AS [hh_child]
FROM
	[pila\SdgIntDb].[census].[acs2011_5yr].[pums_hh_sd] -- 2011 ACS PUMS for san diego
--Setting number of workers in HH based on Employment Status Recode [ESR] attribute in PUMS Person File
LEFT OUTER JOIN ( 
	SELECT
		[SERIALNO]
		,MAX([SCHG]) AS [SCHG] -- should just be a single record due to GQ
		,MAX([MIL]) AS [MIL] -- should just be a single record due to GQ
		,MAX([PWGTP]) AS [PWGTP] -- should just be a single record due to GQ
		,SUM(CASE	WHEN [ESR] IN (1,2,4,5) THEN 1
					ELSE 0
					END) AS [nwrkrs_esr] -- should just be 1/0 due to GQ
	FROM
		[pila\SdgIntDb].[census].[acs2011_5yr].[pums_pp_sd] -- 2011 ACS PUMS for san diego
	GROUP BY -- in theory not necessary due to GQ
		[SERIALNO]
	) AS hh_workers
ON
	[pums_hh_sd].[SERIALNO] = hh_workers.[SERIALNO]
WHERE
	[NP] > 0
	AND [TYPE] = 3 -- Non-institutional group quarters only

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'census acs 2011 pums 5 year input group quarter household data inserted into [popsyn_input].[hh]'

-- Populate GQ persons
INSERT INTO [popsyn_input].[person]
SELECT 
	tt.[popsyn_data_source_id]
	,[hh_id]
    ,tt.[PUMA]
	,[PWGTP] AS [WGTP] -- person weight as household weight
	,tt.[SERIALNO]
    ,[SPORDER]
    ,[AGEP]
	,[SEX]
	,[WKHP]
	,[ESR]
	,[SCHG]
	,[employed]
	,[WKW]
	,[MIL]
	,[SCHL]
	,[indp02]
	,[indp07]
	,[occp02]
	,[occp10]
	,[socp00]
	,[socp10]
	,[gq_type_id]
	,[soc]
	,CASE	WHEN soc IN (11,13,15,17,27,19,39) THEN '1'
			WHEN soc IN (21,23,25,29,31) THEN '2'
			WHEN soc IN (35,37) THEN '3'
			WHEN soc IN (41,43) THEN '4'
			WHEN soc IN (45,47,49) THEN '5'
			WHEN soc IN (51,53) THEN '6'
			WHEN soc IN (55) THEN '7'
			WHEN soc IN (33) THEN '8'
			ELSE '999'
			END AS [occp]
	,[HISP]
	,[RAC1P]
	,[popsyn_race_id] =	CASE	WHEN [HISP] > 1 THEN 1 -- hispanic
								WHEN [RAC1P] = 1 AND [HISP] <= 1 THEN 2 -- nhw
								WHEN [RAC1P] = 2 AND [HISP] <= 1 THEN 3 -- nhb
								WHEN [RAC1P] IN (3,4,5,7,8,9) AND [HISP] <= 1 THEN 4 -- nho_popsyn
								WHEN [RAC1P] = 6 AND [HISP] <= 1 THEN 5 -- nha
								ELSE 0
								END
FROM (
SELECT
	1 AS [popsyn_data_source_id]
    ,[PUMA]
	,[PWGTP]
	,[SERIALNO]
    ,[SPORDER]
    ,[AGEP]
	,[SEX]
	,[WKHP]
	,[ESR]
	,[SCHG]
	,CASE	WHEN [ESR] IN (1,2,4,5) THEN 1
			ELSE 0
			END AS [employed]
	,[WKW]
	,[MIL]
	,[SCHL]
	,[indp02]
	,[indp07]
	,[occp02]
	,[occp10]
	,[socp00]
	,[socp10]
	,CASE	WHEN [ESR] NOT IN (1,2,4,5) THEN '0'
			WHEN LEFT(LTRIM(RTRIM(socp00)),2) = 'N' OR LEFT(LTRIM(RTRIM(socp00)),2) = 'N.' THEN LEFT(LTRIM(RTRIM(socp10)),2)
			ELSE LEFT(LTRIM(RTRIM(socp00)),2)
			END AS [soc]
	,[HISP]
	,[RAC1P]
FROM 
	[pila\SdgIntDb].[census].[acs2011_5yr].[pums_pp_sd] -- 2011 ACS PUMS for san diego
) AS tt
INNER JOIN -- deletes vacant units, gq hh's now in there
	[popsyn_input].[hh]
ON
	tt.[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
	AND tt.[SERIALNO] = [hh].[SERIALNO]
WHERE
	[NP] > 0
	AND [hh].[gq_type_id] > 0 -- non-institutional GQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

PRINT 'census acs 2011 pums 5 year input group quarter person data inserted into [popsyn_input].[person]'

UPDATE
	[ref].[popsyn_data_source]
SET
	[popsyn_data_source_inputs_created] = GETDATE()
WHERE
	[popsyn_data_source_id] = 1

IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

COMMIT TRANSACTION
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'stored procedure to insert census pums acs 2011 5 year data into [popsyn_input].[hh] and [popsyn_input].[person] tables, hardcoded as [popsyn_data_source_id] = 1' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'PROCEDURE',@level1name=N'insert_acs2011_5yr'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn_input', @level1type=N'PROCEDURE',@level1name=N'insert_acs2011_5yr'
GO


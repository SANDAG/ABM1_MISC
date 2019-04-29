USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn].[households_file]    Script Date: 4/23/2019 9:00:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION
	[popsyn].[households_file]
(
	@popsyn_run_id smallint
)
RETURNS @ret_households_file TABLE
(
	[hhid] [int] IDENTITY (1,1) NOT NULL,
	[household_serial_no] [bigint] NOT NULL,
	[taz] [int] NOT NULL,
	[mgra] [int] NOT NULL,
	[hinccat1] [tinyint] NOT NULL,
	[hinc] [int] NOT NULL,
	[hworkers] [tinyint] NOT NULL,
	[veh] [tinyint] NOT NULL,
	[persons] [tinyint] NOT NULL,
	[hht] [smallint] NOT NULL,
	[bldgsz] [smallint] NOT NULL,
	[unittype] [tinyint] NOT NULL,
	[popsyn_run_id] [smallint] NOT NULL,
	[poverty] [decimal](7,4) NULL,
	[n] [int] NOT NULL, -- just used to create persons file, do not include when outputting csv
	[final_weight] [int] NOT NULL, -- just used to create persons file, do not include when outputting csv
	[synpop_hh_id] [int] NOT NULL -- just used to create persons file, do not include when outputting csv
)
AS
BEGIN

DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id]  WHERE [popsyn_run_id] = @popsyn_run_id)
DECLARE @middle_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id]  WHERE [popsyn_run_id] = @popsyn_run_id);

INSERT INTO @ret_households_file
SELECT
	[serialno] AS [household_serial_no]
	,[parent_zone] AS [taz]
	,[child_zone] AS [mgra]
	,[hinccat1] = CASE	WHEN [hh_income_adj] < 30000 THEN 1
						WHEN [hh_income_adj] >= 30000 AND [hh_income_adj] < 60000 THEN 2
						WHEN [hh_income_adj] >= 60000 AND [hh_income_adj] < 100000 THEN 3
						WHEN [hh_income_adj] >= 100000 AND [hh_income_adj] < 150000 THEN 4
						WHEN [hh_income_adj] >= 150000 THEN 5
						ELSE 1 -- set gq to 1 was how it was done traditionally, should probably be set to some null value but need to asses impact on model and reporting
						END
	,ROUND(ISNULL([hh_income_adj], 0),0) AS [hinc] -- group quarters are 0, see above note
	,[workers]
	,[veh]
	,[np] AS [persons]
	,[hht]
	,[bld]
	,[unittype] = CASE	WHEN [gq_type_id] = 0  THEN 0 -- households
						WHEN [gq_type_id] BETWEEN 1 AND 3 THEN 1 -- institutional group quarters
						ELSE NULL
						END -- we do not have any institutional group quarters
	,@popsyn_run_id AS [popsyn_run_id]
	,[poverty] = CASE	WHEN [gq_type_id] BETWEEN 1 AND 3 THEN -99 -- no income calculations for group quarters, set to this since abm model can't handle nulls
						WHEN [gq_type_id] = 0 THEN ROUND(1.0 * [hh_income_adj] /[income_threshold], 4)
						ELSE NULL
						END -- not actually used in model just for reporting purposes
	,[n]
	,[final_weight]
	,[synpop_hh_id]
FROM
	[popsyn].[synpop_hh]
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
			AND [parent_zone].[geography_type_id] = @middle_geography_type_id
	) AS [minor_mid_xref]
ON
	[synpop_hh].[mgra] = [minor_mid_xref].[child_zone]
INNER JOIN
	[ref].[popsyn_run]
ON
	[synpop_hh].[popsyn_run_id] = [popsyn_run].[popsyn_run_id]
INNER JOIN -- need base acs hh data
	[popsyn_input].[hh]
ON
	[popsyn_run].[popsyn_data_source_id] = [hh].[popsyn_data_source_id]
	AND [synpop_hh].[hh_id] = [hh].[hh_id]
LEFT OUTER JOIN ( -- need base acs number of seniors in the household
	SELECT
		[popsyn_data_source_id]
		,[hh_id]
		,COUNT(*) AS [hh_age65plus]
	FROM
		[popsyn_input].[person]
	WHERE
		[AGEP] >= 65
	GROUP BY
		[popsyn_data_source_id]
		,[hh_id]
	) AS num_seniors
ON
	[popsyn_run].[popsyn_data_source_id] = num_seniors.[popsyn_data_source_id]
	AND [synpop_hh].[hh_id] = num_seniors.[hh_id]
INNER JOIN -- poverty calculation
	[ref].[fed_poverty_threshold_2010]
ON
	CASE	WHEN [hh].[np] > 9 THEN 9 
			ELSE [hh].[np] 
			END							= [fed_poverty_threshold_2010].[hh_persons]
	AND CASE	WHEN [hh].[hh_child] IS NULL THEN 0
				WHEN [hh].[hh_child] > 8 THEN 8 
				WHEN [hh].[np] = [hh].[hh_child] THEN [hh].[hh_child] - 1 -- all child households treated as one adult, rest children
				ELSE [hh].[hh_child] 
				END						= [fed_poverty_threshold_2010].[hh_children]
	AND CASE	WHEN num_seniors.[hh_age65plus] = 2 AND [hh].[NP] = 2 THEN 1
				WHEN (num_seniors.[hh_age65plus] > 0 AND [hh].[NP] > 2) OR num_seniors.[hh_age65plus] IS NULL THEN 0 -- quirk of how poverty is defined, doesn't care about seniors in 3+ person households
				ELSE num_seniors.[hh_age65plus]  
				END						= [fed_poverty_threshold_2010].[hh_age65plus]
INNER JOIN
	[ref].[expansion_numbers] -- expand households based on weight
ON
	[expansion_numbers].[n] BETWEEN 1 AND [synpop_hh].[final_weight]
WHERE
	[synpop_hh].[popsyn_run_id] = @popsyn_run_id
ORDER BY [synpop_hh].[synpop_hh_id],n        -- added on 10/06/2015, YMA

RETURN
END



GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to output households input file for ABM' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'households_file'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'households_file'
GO



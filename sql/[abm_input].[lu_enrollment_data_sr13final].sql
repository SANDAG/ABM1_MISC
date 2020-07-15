USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [abm_input].[lu_enrollment_data_sr13final]    Script Date: 4/23/2019 8:58:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- enrollment
CREATE FUNCTION
	[abm_input].[lu_enrollment_data_sr13final]
(
	@lu_version_id [smallint]
)
RETURNS @ret_lu_enrollment_data_sr13final TABLE
(
	[lu_version_id] [smallint] NOT NULL
    ,[mgra_13] [smallint] NOT NULL
    ,[enrollgradekto8] [int] NOT NULL
    ,[enrollgrade9to12] [int] NOT NULL
    ,[collegeenroll] [int] NOT NULL
    ,[othercollegeenroll] [int] NOT NULL
	,[adultschenrl] [int] NOT NULL
	,PRIMARY KEY ([lu_version_id], [mgra_13])
)
AS
BEGIN
-- Base adult school enrollment was only used in 2008 inputs
-- For all other years its total was distributed by public high school enrollment
-- This total remains fixed through all out years
INSERT INTO @ret_lu_enrollment_data_sr13final
SELECT
	[lu_version_id]
    ,[pasef_enrollment_mgra].[mgra] AS [mgra_13]
    ,[enroll_k8] AS [enrollgradekto8]
    ,[enroll_HS] AS [enrollgrade9to12]
    ,[enroll_MajCol] AS [collegeenroll]
    ,[enroll_OtherCol] AS [othercollegeenroll]
	,ROUND([total_base_adult_enroll] * ([phs_enroll] / [total_phs_enroll]), 0) AS [adultschenrl]
FROM 
	[regional_forecast].[sr13_final].[pasef_enrollment_mgra]
INNER JOIN (
	SELECT
		[mgra]
		,[phs_enroll]
	FROM
		OPENQUERY([pila\SdgIntDb], 'SELECT 
										l.[mgra]
										,ISNULL(SUM(e.[pub_9to12]), 0) AS [phs_enroll]		
									FROM 
										[data_cafe].[dbo].[school_enroll_by_lckey_2011_2012_sr13] AS e 
									RIGHT OUTER JOIN
										[forecast].[gis].[LCGPALL] AS l
									ON 
										e.[lckey] = l.[LCKey]
									GROUP BY 
										l.[mgra]')
	) AS tt
ON
	[pasef_enrollment_mgra].[mgra] = tt.[mgra]
INNER JOIN
	[ref].[lu_version] -- this join means a scenario needs to be in this table to appear
ON
	[pasef_enrollment_mgra].[scenario] = [lu_version].[lu_scenario_id]
	AND [pasef_enrollment_mgra].[year] = [lu_version].[increment]
	AND [lu_version].[lu_major_version] = 13 -- hardcoded series 13 final major version
	AND [lu_version].[lu_minor_version] = 1 -- hardcoded series 13 final minor version
CROSS APPLY (
	SELECT SUM([enrollment07]) AS [total_base_adult_enroll] FROM [travel_data].[abm_input].[adult_school_enrollment_0708]
	) constant_1
CROSS APPLY (
	SELECT [total_phs_enroll] FROM OPENQUERY([pila\SdgIntDb], 'SELECT SUM(e.[pub_9to12]) AS [total_phs_enroll] FROM [data_cafe].[dbo].[school_enroll_by_lckey_2011_2012_sr13] AS e RIGHT OUTER JOIN [forecast].[gis].[LCGPALL] AS l ON e.[lckey] = l.[LCKey]')
	) constant_2
WHERE
	[lu_version].[lu_version_id] = @lu_version_id
RETURN
END

GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to return all series 13 final enrollment land use data used to create mgra based input file' , @level0type=N'SCHEMA',@level0name=N'abm_input', @level1type=N'FUNCTION',@level1name=N'lu_enrollment_data_sr13final'
GO



USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [popsyn].[persons_file]    Script Date: 4/23/2019 9:00:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION
	[popsyn].[persons_file]
(
	@popsyn_run_id smallint
)
RETURNS @ret_persons_file TABLE
(
	[hhid] [int] NOT NULL,
	[perid] [int] IDENTITY(1,1) NOT NULL,
	[household_serial_no] [bigint] NOT NULL,
	[pnum] [tinyint] NOT NULL,
	[age] [tinyint] NOT NULL,
	[sex] [tinyint] NOT NULL,
	[military] [tinyint] NOT NULL,
	[pemploy] [tinyint] NOT NULL,
	[pstudent] [tinyint] NOT NULL,
	[ptype] [tinyint] NOT NULL,
	[educ] [tinyint] NOT NULL,
	[grade] [tinyint] NOT NULL,
	[occen5] [smallint] NOT NULL,
	[occsoc5] [nvarchar](15) NOT NULL,
	[indcen] [smallint] NOT NULL,
	[weeks] [tinyint] NOT NULL,
	[hours] [tinyint] NOT NULL,
	[rac1p] [tinyint] NOT NULL,
	[hisp] [tinyint] NOT NULL,
	[popsyn_run_id] [smallint] NOT NULL
)
AS
BEGIN

INSERT INTO @ret_persons_file
SELECT
	[hhid]
	,[serialno] AS [household_serial_no]
	,[sporder] AS [pnum]
	,[agep] AS [age]
	,[sex] AS [sex]
	,[military] = CASE	WHEN [mil] = 1 THEN 1
						WHEN [mil] IN (2,3) THEN 2
						WHEN [mil] = 4 THEN 3
						WHEN [mil] = 5 THEN 4
						ELSE 0
						END
	,[pemploy] = CASE	WHEN [esr] IN (1,2,4,5) AND [wkw] IN (1,2,3,4) AND [wkhp] >= 35 THEN 1
							WHEN [esr] IN (1,2,4,5) AND ([wkw] IN (5,6) OR [wkhp] < 35) THEN 2
							WHEN [esr] IN (3,6) THEN 3
							ELSE 4
							END
	,[pstudent] = CASE	WHEN [schg] > 0 AND [schg] < 6 THEN 1
							WHEN [schg] IN (6,7) THEN 2
							ELSE 3
							END
	-- order of ptype case statement matters
	,[ptype] = CASE	WHEN [agep] < 6 THEN 8
						WHEN [agep] >= 6 AND [agep] <= 15 THEN 7
						WHEN [esr] IN (1,2,4,5) AND [wkw] IN (1,2,3,4) AND [wkhp] >= 35 THEN 1 -- PEMPLOY = 1
						WHEN [schg] IN (6,7) OR ([agep]>=20 AND [schg] > 0 AND [schg] < 6) THEN 3 -- PSTUDENT = 2 OR AGEP >= 20 AND PSTUDENT = 1
						WHEN [schg] > 0 AND [schg] < 6 THEN 6 -- PSTUDENT = 1
						WHEN [esr] IN (1,2,4,5) AND ([wkw] IN (5,6) OR [wkhp] < 35) THEN 2 -- PEMPLOY = 2
						WHEN [agep] < 65 THEN 4
						ELSE 5
						END
	,[schl] AS [educ]
	,[schg] AS [grade]
	,[occen5] = CASE	WHEN [occp02] = 'N.A.' THEN [occp10]
						WHEN [occp02] = 'N.A.//' THEN [occp10]
						WHEN LEN([occp02]) = 0 OR LEN([occp10]) = 0 THEN 0 
						ELSE [occp02]
						END
	,[occsoc5] = CASE	WHEN [socp00] = 'N.A.' THEN LEFT([socp10], 2) + '-' + RIGHT([socp10], 4)
						WHEN [socp00] = 'N.A.//' THEN LEFT([socp10], 2) + '-' + RIGHT([socp10], 4)
						WHEN LEN([socp00]) = 6 THEN LEFT([socp00], 2) + '-' + RIGHT([socp00], 4)
						WHEN LEN([socp00]) =  0 OR LEN([socp10]) = 0 THEN '00-0000'
						ELSE [socp00]
						END
	,[indcen] = CASE	WHEN [indp02] = 'N.A.' THEN [indp07]
						WHEN [indp02] = 'N.A.//' THEN [indp07]
						WHEN [indp02] = 'N.A.' AND [indp07] = '6672' THEN '6675'
						WHEN len([indp02]) = 0 THEN 0
						WHEN len([indp07]) = 0 THEN 0            
						ELSE [indp02]
						END
	,[wkw] AS [weeks]
	,[wkhp] AS [hours]
	,[rac1p]
	,[hisp]
	,@popsyn_run_id AS [popsyn_run_id]
FROM
	[popsyn].[synpop_person]
INNER JOIN
	[popsyn].[synpop_hh]
ON
	[synpop_person].[popsyn_run_id] = [synpop_hh].[popsyn_run_id]
	AND [synpop_person].[synpop_hh_id] = [synpop_hh].[synpop_hh_id]
INNER JOIN
	[ref].[popsyn_run]
ON
	[synpop_person].[popsyn_run_id] = [popsyn_run].[popsyn_run_id]
INNER JOIN
	[popsyn_input].[person]
ON
	[popsyn_run].[popsyn_data_source_id] = [person].[popsyn_data_source_id]
	AND [synpop_person].[person_id] = [person].[person_id]
INNER JOIN
	[ref].[expansion_numbers] -- expand households based on weight
ON
	[expansion_numbers].[n] BETWEEN 1 AND [synpop_hh].[final_weight]
INNER JOIN
	[popsyn].[households_file](@popsyn_run_id) as households_file  
ON
	[synpop_person].[synpop_hh_id] = [households_file].[synpop_hh_id]
	AND [expansion_numbers].[n] = [households_file].[n]
WHERE
	[synpop_person].[popsyn_run_id] = @popsyn_run_id
ORDER BY
	[hhid],[sporder]  -- added on 12/11/2015 as Clint suggested to fix abm loading issue, YMA

RETURN
END

GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to output persons input file for ABM' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'persons_file'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'FUNCTION',@level1name=N'persons_file'
GO



USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_mgra_csv_file]    Script Date: 4/23/2019 9:09:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <3/26/2019>
-- Description:	<This function is created to verify the magr_based_landuse table result>
-- =============================================

CREATE FUNCTION
	[sbauto].[verify_mgra_csv_file] (@lu_scenario_desc nvarchar(200))
 
RETURNS @verify_mgra_csv_file TABLE
(
	[lu_scenario_desc] nvarchar(200) NOT NULL,
	[lu_version_id] [smallint]  NOT NULL,
	[mgra] [int] NOT NULL,
	[hs]  [int] NOT NULL,
	[hh]  [int] NOT NULL,
	[gq]  [int] NOT NULL,
	[hhp] [int] NOT NULL,
	[pop] [int] NOT NULL,
	[emp_total] [int] NOT NULL,
	[school_enrollment] [int] NOT NULL,
	[college_enrollment] [int] NOT NULL,
	[hotelroomtotal] [int] NOT NULL,
	[duden] [decimal](7, 4) NOT NULL,
	[popden] [decimal](7, 4) NOT NULL,
	[empden] [decimal](7, 4) NOT NULL,
	[dudenbin]   [smallint] NOT NULL,
	[empdenbin]  [smallint] NOT NULL,
	[retail_empden] [decimal](7, 4) NOT NULL,
	[totint]     [smallint] NOT NULL,
	[totintbin]  [smallint] NOT NULL
)AS
BEGIN

DECLARE @lu_version_id smallint = 
						(
							SELECT  lu_version_id						
							FROM [ref].[lu_version]
							WHERE lu_scenario_desc = @lu_scenario_desc
						)


INSERT INTO @verify_mgra_csv_file
SELECT
 @lu_scenario_desc as lu_scenario_desc
,@lu_version_id as lu_version_id
,fl.[mgra]
,[hs]
,[hh]
,([gq_civ]+[gq_mil]) as gq
,[hhp]
,[pop]
,[emp_total]
,([enrollgradekto8]+[enrollgrade9to12]) as school_enrollment
,([collegeenroll]+[othercollegeenroll]+[adultschenrl]) as college_enrollment
,[hotelroomtotal]
,fd.[duden]
,fd.[popden]
,fd.[empden]
,fd.[dudenbin]
,fd.[empdenbin]
,fl.[retempden]
,fl.[totint]
,fl.[totintbin]
FROM [abm_input].[mgra_based_input_file](@lu_version_id) AS fl 
INNER JOIN [sbauto].[lu_mgra_4d_output_join_local_n_region] AS fd 
   ON (fl.MGRA = fd.MGRA and fl.lu_version_id=fd.lu_version_id)
ORDER BY fl.[mgra]


RETURN
END



GO



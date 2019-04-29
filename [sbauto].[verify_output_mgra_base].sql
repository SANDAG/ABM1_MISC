USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_output_mgra_base]    Script Date: 4/23/2019 9:10:19 PM ******/
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
	[sbauto].[verify_output_mgra_base] (@lu_scenario_desc nvarchar(200))
 
RETURNS @verify_output_mgra_base TABLE
(
	[lu_scenario_desc] nvarchar(200) NOT NULL,
	[new_lu_version_id] [smallint]  NOT NULL,
	[old_lu_version_id] [smallint] NOT NULL,
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

DECLARE @new_lu_version_id smallint = 
						(
							SELECT  lu_version_id						
							FROM [ref].[lu_version]
							WHERE lu_scenario_desc = @lu_scenario_desc
						)


DECLARE @old_lu_version_id int = ( 					
select lu_version_id
from ref.lu_version
where increment = (select increment   from ref.lu_version  where  lu_scenario_desc = @lu_scenario_desc)
      and lu_version_id in (101,102,103,104,105,106,107,108,118,128)   
)				       

		

INSERT INTO @verify_output_mgra_base
SELECT
 @lu_scenario_desc as lu_scenario_desc
,@new_lu_version_id as new_lu_version_id
,@old_lu_version_id as old_lu_version_id
,[mgra]
,[hs]
,[hh]
,([gq_civ]+[gq_mil]) as gq
,[hhp]
,[pop]
,[emp_total]
,([enrollgradekto8]+[enrollgrade9to12]) as school_enrollment
,([collegeenroll]+[othercollegeenroll]+[adultschenrl]) as college_enrollment
,[hotelroomtotal]
,[duden]
,[popden]
,[empden]
,[dudenbin]
,[empdenbin]
,[retempden]
,[totint]
,[totintbin]
FROM [abm_input].[mgra_based_input_file](@old_lu_version_id) 
ORDER BY [mgra]


RETURN
END



GO



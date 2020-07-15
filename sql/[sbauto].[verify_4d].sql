USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_4d]    Script Date: 4/23/2019 9:07:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<YMA>
-- Create date: <4/26/2018>
-- Description:	<This function is created to verify the magr_based_landuse table result>
-- =============================================

CREATE FUNCTION
	[sbauto].[verify_4d] (@lu_scenario_desc nvarchar(100))
 
RETURNS @verify_4d TABLE
(
	[mgra] [int] NOT NULL,
	[old_duden] [decimal](7, 4) NOT NULL,
	[old_popden] [decimal](7, 4) NOT NULL,
	[old_empden] [decimal](7, 4) NOT NULL,
	[old_retail_empden] [decimal](7, 4) NOT NULL,
	[new_duden] [decimal](7, 4) NOT NULL,
	[new_popden] [decimal](7, 4) NOT NULL,
	[new_empden] [decimal](7, 4) NOT NULL,
	[new_retail_empden] [decimal](7, 4) NOT NULL
) AS
BEGIN

DECLARE @new_lu_version_id int = (select lu_version_id from ref.lu_version where lu_scenario_desc = @lu_scenario_desc) 

DECLARE @old_lu_version_id int = ( 					
select lu_version_id
from ref.lu_version
where increment = (select increment   from ref.lu_version  where  lu_scenario_desc = @lu_scenario_desc)
      and lu_version_id in (101,102,103,104,105,106,107,108,118,128)
)				       


;with told as
(
select  lu_version_id
       ,mgra
 	   ,duden
	   ,popden
	   ,empden
	   ,retempden
from abm_input.lu_mgra_input
where lu_version_id = @old_lu_version_id and mgra in (select distinct mgra from sbauto.project_input_file where lu_version_id = @new_lu_version_id)
), tnew as
(
select  lu_version_id
       ,mgra
	   ,duden
	   ,popden
	   ,empden
	   ,retempden
	from [sbauto].[lu_mgra_4d_output_keep]
where lu_version_id = @new_lu_version_id and mgra in (select distinct mgra from sbauto.project_input_file where lu_version_id = @new_lu_version_id)
)
INSERT INTO @verify_4d
select  told.mgra
       ,told.duden            as old_duden
	   ,told.popden           as old_popden 
	   ,told.empden           as old_empden
	   ,told.retempden        as old_retempden
	   ,tnew.duden            as new_duden
	   ,tnew.popden           as new_popden
	   ,tnew.empden           as new_empden
	   ,tnew.retempden        as new_retempden
from told
join tnew
    on told.mgra=tnew.mgra
order by told.mgra


RETURN
END

GO



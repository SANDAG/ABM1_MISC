USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[join_4d_output_with_region]    Script Date: 4/23/2019 8:43:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <3/22/2019>
-- Description:	<join 4d output with regional>
-- =============================================


CREATE PROCEDURE [sbauto].[join_4d_output_with_region]
 @lu_scenario_desc nvarchar(200)
,@new_lu_version_id int
 
AS
BEGIN

with fd as
(
select 
       mgra
	  ,[duden]
	  ,[empden]
	  ,[popden]
	  ,[dudenbin]
	  ,[empdenbin]
FROM [sbauto].[lu_mgra_4d_output]
where [mgra] in (select distinct mgra from [popsyn_3_0].[sbauto].[get_project_input_file_tt] )
)
INSERT INTO
	[sbauto].[lu_mgra_4d_output_join_local_n_region](
	[lu_scenario_desc],
	[lu_version_id],
	[mgra], 
	[totint], 
	[duden], 
	[empden], 
	[popden],
	[retempden], 
	[totintbin], 
	[empdenbin], 
	[dudenbin])
select 
	   @lu_scenario_desc   as [lu_scenario_desc]
	  ,@new_lu_version_id  as [lu_version_id]
	  ,fl.mgra
      ,fl.[totint]
      ,isnull(fd.[duden],fl.duden) as duden
	  ,isnull(fd.[empden],fl.empden) as empden
	  ,isnull(fd.[popden],fl.popden) as popden
	  ,fl.[retempden] as retempden
	  ,fl.[totintbin] as totintbin
	  ,isnull(fd.[empdenbin],fl.empdenbin) as empdenbin
	  ,isnull(fd.[dudenbin],fl.dudenbin)   as dudenbin
from [abm_input].[mgra_based_input_file](@new_lu_version_id) as fl
left outer join fd on fl.mgra=fd.mgra

END
GO



USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_households_new_n_old]    Script Date: 4/23/2019 9:08:17 PM ******/
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
	[sbauto].[verify_households_new_n_old] (@lu_scenario_desc nvarchar(200))
 

RETURNS @verify_households_new_n_old TABLE
(
	[lu_scenario_desc] nvarchar(200) NOT NULL,
	[new_lu_version_id] [smallint]  NOT NULL,
	[new_popsyn_run_id] [smallint]  NOT NULL,
	[base_lu_version_id] [smallint]  NOT NULL,
	[base_popsyn_run_id] [smallint]  NOT NULL,
	[base_households_region] [int] NOT NULL,
	[base_households_local] [int] NOT NULL,
	--[old_households_rest] [int] NOT NULL,
	[new_households_region] [int] NOT NULL,
	[new_households_local] [int] NOT NULL
	--[new_households_rest] [int] NOT NULL
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

	
DECLARE @new_popsyn_run_id smallint = 
						(
							SELECT  popsyn_run_id						
							FROM [ref].[popsyn_run]
							WHERE lu_version_id = @new_lu_version_id
						)


DECLARE @old_popsyn_run_id smallint = 
						(
							SELECT  popsyn_run_id						
							FROM [ref].[popsyn_run]
							WHERE lu_version_id = @old_lu_version_id
						)


INSERT INTO @verify_households_new_n_old 
SELECT
 @lu_scenario_desc as lu_scenario_desc
,@new_lu_version_id as new_lu_version_id
,@new_popsyn_run_id as new_popsyn_run_id
,@old_lu_version_id as base_lu_version_id
,@old_popsyn_run_id as base_popsyn_run_id
,(select count(*) from [popsyn].[households_file] (@old_popsyn_run_id ))                                                   as base_households_region
,(select count(*) from [popsyn].[households_file] (@old_popsyn_run_id)
         where mgra in (select distinct mgra from [sbauto].[project_input_file] where lu_version_id = @new_lu_version_id)) as base_households_local
,(select count(*) from [sb_input].[households_file](@old_popsyn_run_id, @new_popsyn_run_id))                               as new_households_region
,(select count(*) from [sb_input].[households_file](@old_popsyn_run_id, @new_popsyn_run_id)
         where mgra in (select distinct mgra from [sbauto].[project_input_file] where lu_version_id = @new_lu_version_id)) as new_households_local

		 
RETURN
END

GO



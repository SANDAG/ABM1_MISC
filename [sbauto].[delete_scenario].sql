USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbauto].[delete_scenario]    Script Date: 4/23/2019 8:42:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <4/20/2018>
-- Description:	<This procedure is to clear up all related tables for a specifie scenario with completed run>
-- =============================================


CREATE PROCEDURE [sbauto].[delete_scenario] @lu_scenario_desc nvarchar(200) 

AS
BEGIN

declare @lu_version_id int
set @lu_version_id = (select lu_version_id from ref.lu_version where lu_scenario_desc = @lu_scenario_desc)


declare @popsyn_run_id int
set @popsyn_run_id = (
select popsyn_run_id
from ref.lu_version   rl
    join ref.popsyn_run rp
	    on rl.lu_version_id=rp.lu_version_id
where rl.lu_scenario_desc = @lu_scenario_desc and user_name=system_user
)

select rl.lu_version_id,popsyn_run_id,increment,lu_scenario_desc,popsyn_targets_created,mgra_based_input_file_created,start_time,end_time
from ref.lu_version   rl
    join ref.popsyn_run rp
	    on rl.lu_version_id=rp.lu_version_id
where rl.lu_scenario_desc = @lu_scenario_desc 
    and user_name=system_user


delete from popsyn.synpop_person
where popsyn_run_id = @popsyn_run_id

delete from popsyn.synpop_hh
where popsyn_run_id = @popsyn_run_id

delete from popsyn_input.control_targets
where lu_version_id = @lu_version_id

delete from ref.popsyn_run
where popsyn_run_id = @popsyn_run_id

delete from [popsyn_3_0].[abm_input].[lu_mgra_input]
where  lu_version_id = @lu_version_id

delete from [popsyn_3_0].[sbauto].[lu_mgra_4d_input_ludata]
where  lu_version_id = @lu_version_id

delete from [popsyn_3_0].[sbauto].[lu_mgra_4d_output_keep]
where  lu_version_id = @lu_version_id

delete from [popsyn_3_0].[sbauto].[lu_mgra_4d_output_join_local_n_region]
where  lu_version_id = @lu_version_id

delete from [popsyn_3_0].[sbauto].[project_input_file]
where  lu_version_id = @lu_version_id

delete from ref.lu_version
where lu_scenario_desc = @lu_scenario_desc


END


GO



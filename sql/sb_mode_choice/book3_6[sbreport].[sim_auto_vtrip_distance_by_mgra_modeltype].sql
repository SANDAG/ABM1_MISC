USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[sim_auto_vtrip_distance_by_mgra_modeltype]    Script Date: 11/20/2019 3:30:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE  [sbreport].[sim_auto_vtrip_distance_by_mgra_modeltype] @scenario_id int
AS
Begin

-- =============================================
-- Author:		<YMA>
-- Create date: <10/31/2019>
-- Description:	<simulated vehicle trip length by model type by MGRA for auto modes only>
-- =============================================

with t0 as
(
select   tps.scenario_id
		,model_type_desc
        ,mgra.value as mgra
		,mode_id
		,party_size
		,trip_distance
        ,CASE 
	         When mode_id in (3,4,5) and party_size = 1   Then   1/2.00
			 When mode_id in (6,7,8) and party_size = 1   Then   1/3.34
	         Else 1.0 
			 End as vfactor
from [abm_13_2_3].[abm].[vi_trip_micro_simul]            tps
join [abm_13_2_3].ref.model_type             rmt    on tps.model_type_id = rmt.model_type_id
join [abm_13_2_3].[ref].geography_zone       rmo    on tps.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
join [abm_13_2_3].[ref].geography_zone       rmd    on tps.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
join [popsyn_3_0].[sbreport].[mgra]          mgra   on (rmo.zone = mgra.value or rmd.zone = mgra.value) 
where tps.scenario_id = @scenario_id and user_id = SYSTEM_USER and mode_id between 1 and 8
),t1 as
(
select   scenario_id
        ,mgra
		,model_type_desc
       ,sum(vfactor) as vehicle
	   ,sum(trip_distance * vfactor) as vmt
	   ,sum(trip_distance * vfactor)/sum(vfactor) as AvgVehDis
from    t0
group by scenario_id,mgra,model_type_desc
),t2 as
(select scenario_id,mgra,model_type_desc,AvgVehDis
from t1
union all
select scenario_id,mgra,'AllModel' as model_type_desc,sum(vmt)/sum(vehicle) as AvgVehDis
from t1
group by scenario_id,mgra
),t22 as
(
select scenario_id,mgra,[Individual], [Joint], [Visitor],[Internal-External],[Cross Border],[Airport],[AllModel]
from t2
pivot (avg(AvgVehDis) for model_type_desc in ([Individual],[Joint],[Visitor],[Internal-External],[Cross Border],[Airport],[AllModel]))as pvt
),t3 as
(select scenario_id,'All' as mgra,model_type_desc,sum(vmt)/sum(vehicle) as AvgVehDis
from t1
group by scenario_id,model_type_desc
union all
select scenario_id,'All' as mgra,'AllModel'as model_type_desc,sum(vmt)/sum(vehicle) as AvgVehDis
from t1
group by scenario_id
)
select scenario_id,mgra,[Individual], [Joint], [Visitor],[Internal-External],[Cross Border],[Airport]
      ,[AllModel] as AllModelAvgVehDis
from t3
pivot (avg(AvgVehDis) for model_type_desc in ([Individual],[Joint],[Visitor],[Internal-External],[Cross Border],[Airport],[AllModel]))as pvt

union all

select @scenario_id as scenario_id
      ,cast([mgra].value as varchar) as mgra
	  ,isnull([Individual],0) as [Individual]
	  ,isnull([Joint],0) as [Joint]
	  ,isnull([Visitor],0) as [Visitor]
	  ,isnull([Internal-External],0) as [Internal-External]
	  ,isnull([Cross Border],0) as [Cross Border]
	  ,isnull([Airport],0) as [Airport]
	  ,isnull([AllModel],0) as AllModelAvgVehDis
from t22
right join [popsyn_3_0].[sbreport].[mgra]     on [mgra].value=t22.mgra
where user_id = system_user
order by mgra DESC


End;

GO



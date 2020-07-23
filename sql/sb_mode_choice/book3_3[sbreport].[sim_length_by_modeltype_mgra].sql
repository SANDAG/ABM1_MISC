USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[sim_length_by_modeltype_mgra]    Script Date: 11/20/2019 3:29:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[sim_length_by_modeltype_mgra] @scenario_id int
AS
Begin

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018> to include MGRA with Null Output
-- Modify date: <04/17/2019> to move to popsyn
-- Modify date: <11/01/2019> to add summary on top row
-- Description:	<simulated person trip length by model type by MGRA >
-- =============================================

with t0 as
(
select  tps.scenario_id
       ,value as mgra
       ,model_type_desc
	   ,sum(trip_distance*party_size) as M_model
	   ,sum(party_size)    as P_model
	   ,sum(party_size*trip_distance)/sum(party_size) as Dis_model
from [abm_13_2_3].[abm].[vi_trip_micro_simul] tps
    join [abm_13_2_3].ref.model_type     rmt 	           on tps.model_type_id = rmt.model_type_id
    join [abm_13_2_3].ref.geography_zone    rmo   	       on tps.orig_geography_zone_id  = rmo.geography_zone_id   and rmo.geography_type_id = 90
    join [abm_13_2_3].ref.geography_zone    rmd            on tps.dest_geography_zone_id  = rmd.geography_zone_id   and rmd.geography_type_id = 90
	join [popsyn_3_0].[sbreport].[mgra]                                  on (rmo.zone =mgra.value  or rmd.zone = mgra.value) 
where tps.scenario_id = @scenario_id  and user_id = System_user
group by tps.scenario_id,value,model_type_desc
), t00 as
(select scenario_id,mgra,model_type_desc,Dis_model
from t0
), t1 as
(
select scenario_id,mgra, [Individual], [Joint], [Visitor],[Internal-External],[Cross Border],[Airport]
from t00
pivot (avg(Dis_model) for model_type_desc in ([Individual],[Joint],[Visitor],[Internal-External],[Cross Border],[Airport]))as pvt
),t2 as
( select mgra,sum(M_model)/sum(P_model) as Dis_taz
  from t0
  group by mgra
),t3 as
(select scenario_id,'All' as mgra,model_type_desc,sum(M_model)/sum(P_model) as AvgVehDis
from t0
group by scenario_id,model_type_desc

union all

select scenario_id,'All' as mgra,'AllModel'as model_type_desc,sum(M_model)/sum(P_model) as AvgVehDis
from t0
group by scenario_id
)
select scenario_id,mgra as FromTo_MGRA,[Individual], [Joint], [Visitor],[Internal-External],[Cross Border],[Airport]
      ,[AllModel] as [AvgDistanceAllModel]
from t3
pivot (avg(AvgVehDis) for model_type_desc in ([Individual],[Joint],[Visitor],[Internal-External],[Cross Border],[Airport],[AllModel]))as pvt

union all

select 
      @scenario_id as scenario_id
	  ,cast([mgra].value as varchar) as FromTo_MGRA 
      ,isnull([Individual],0)        as [Individual]
	  ,isnull([Joint],0)             as [Joint]
	  ,isnull([Visitor],0)           as [Visitor]
	  ,isnull([Internal-External],0) as [Internal-External]
	  ,isnull([Cross Border],0)      as [Cross Border]
	  ,isnull([Airport],0) 	         as [Airport]
	  ,isnull(Dis_taz,0)             as [AvgDistanceAllModel]
from t1
   join t2                         on t1.mgra=t2.mgra
   right join [popsyn_3_0].[sbreport].[mgra]     on [mgra].value=t1.mgra
where user_id = system_user
order by FromTo_MGRA  DESC

End;

GO



USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[sim_trip_bymode_mgra]    Script Date: 11/20/2019 3:28:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[sim_trip_bymode_mgra]  @scenario_id int
-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018> to include MGRA with Null Output
-- Modify date: <11/01/2019> to add summary on top row
-- Description:	<simulated person trips by mode by MGRA >
-- =============================================

AS
Begin

with t0 as
(
select  scenario_id
       ,value as mgra
	   ,mode_category_abbr
	   ,sum(party_size) as ptrips
from [abm_13_2_3].[abm].[vi_trip_micro_simul] tps
    join [abm_13_2_3].ref.geography_zone rmgo   	      on tps.orig_geography_zone_id  = rmgo.geography_zone_id   and rmgo.geography_type_id = 90
    join [abm_13_2_3].ref.geography_zone rmgd             on tps.dest_geography_zone_id  = rmgd.geography_zone_id   and rmgd.geography_type_id = 90
	join [popsyn_3_0].[sbreport].[mgra]                   on (rmgo.zone =mgra.value  or rmgd.zone = mgra.value) 
	join [abm_13_2_3].ref.mode           rmd              on rmd.mode_id = tps.mode_id 
where scenario_id = @scenario_id  and user_id = system_user
group by scenario_id,value,mode_category_abbr
),t1 as
(
select scenario_id,mgra,[SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI],[AIR]
from t0
pivot (sum(ptrips) for mode_category_abbr in ([SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI],[AIR])) as pvt
)
select scenario_id
      ,'Total' as FromTo_MGRA
	  ,sum(isnull([SOV],0))   as [SOV]
      ,sum(isnull([HOV2],0))  as [HOV2]
	  ,sum(isnull([HOV3],0))  as [HOV3]
	  ,sum(isnull([WALK],0))  as [Walk]
      ,sum(isnull([BIKE],0))  as [Bike]
      ,sum(isnull([TRANSIT],0))  as [Transit]
	  ,sum(isnull([SBUS],0)  + isnull([TAXI],0) + isnull([AIR],0)) as [Other]
      ,sum(isnull([SOV],0)+isnull([HOV2],0)+isnull([HOV3],0)+isnull([WALK],0)+isnull([BIKE],0)+isnull([TRANSIT],0)+isnull([SBUS],0)+isnull([TAXI],0)+isnull([AIR],0)) as TotalTrips
from t1
group by scenario_id

union all

select @scenario_id as scenario_id
      ,cast([mgra].value as varchar) as FromTo_MGRA
	  ,isnull([SOV],0)   as [SOV]
                      ,isnull([HOV2],0)  as [HOV2]
					  ,isnull([HOV3],0)  as [HOV3]
					  ,isnull([WALK],0)  as [Walk]
					  ,isnull([BIKE],0)  as [Bike]
					  ,isnull([TRANSIT],0)  as [Transit]
					  ,(isnull([SBUS],0)  + isnull([TAXI],0) + isnull([AIR],0)) as [Other]
                      ,isnull([SOV],0)+isnull([HOV2],0)+isnull([HOV3],0)+isnull([WALK],0)+isnull([BIKE],0)+isnull([TRANSIT],0)+isnull([SBUS],0)+isnull([TAXI],0)+isnull([AIR],0) as TotalTrips
from t1
right join [popsyn_3_0].[sbreport].[mgra] 
    on [mgra].value=t1.mgra
where user_id = system_user
order by FromTo_MGRA DESC


END;

GO



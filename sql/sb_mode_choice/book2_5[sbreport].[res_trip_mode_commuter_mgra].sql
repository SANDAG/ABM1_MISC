USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_trip_mode_commuter_mgra]    Script Date: 11/20/2019 3:23:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE  [sbreport].[res_trip_mode_commuter_mgra] @scenario_id int

AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018> to include MGRA with Null output
-- Modify date: <04/17/2019> to move to popsyn
-- Modify date: <11/13/2019> to add total at the first row
-- Description:	<person commuter trips by mode by MGRA >
-- =============================================


with t1 as
(
select   scenario_id
        ,value as mgra
		,mode_category_abbr
		,sum(party_size) as commute_ptrips
from     [abm_13_2_3].[abm].[trip_ij]            tp
    join [abm_13_2_3].[ref].geography_zone       rmgo    on tp.orig_geography_zone_id = rmgo.geography_zone_id and rmgo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmgd    on tp.dest_geography_zone_id = rmgd.geography_zone_id and rmgd.geography_type_id = 90
	join [abm_13_2_3].[ref].mode                 rmd     on tp.mode_id = rmd.mode_id
	join [popsyn_3_0].[sbreport].[mgra] on (rmgo.zone =value  or rmgd.zone = value) 
where scenario_id = @scenario_id and user_id = SYSTEM_USER
      and purpose_id = 1
      and (time_period_id between 10 and 16 or time_period_id between 30 and 36)
group by scenario_id,value,mode_category_abbr
),t2 as
(
select scenario_id,mgra,[SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI]  
from t1
pivot (sum(commute_ptrips) for mode_category_abbr in ([SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI])) as pvt
), t3 as
(
select  @scenario_id as scenario_id
       ,cast([mgra].value as varchar) as FromTo_MGRA
       ,isnull([SOV],0)   as [SOV]
	   ,isnull([HOV2],0)  as [HOV2]
	   ,isnull([HOV3],0)  as [HOV3]
	   ,isnull([WALK],0)  as [Walk]
	   ,isnull([BIKE],0)  as [Bike]
   	   ,isnull([TRANSIT],0)  as [Transit]        
	   ,(isnull([SBUS],0) + isnull([TAXI],0))  as [Other]
       ,isnull([SOV],0)+isnull([HOV2],0)+isnull([HOV3],0)+isnull([TRANSIT],0)+isnull([WALK],0)+isnull([BIKE],0)+isnull([SBUS],0)+isnull([TAXI],0) as TotalPersonTrips
from t2
right join [popsyn_3_0].[sbreport].[mgra] 
    on [mgra].value=t2.mgra
where user_id = system_user
--order by [mgra].value
)
select scenario_id
       ,'TOTAL' as FromTo_MGRA
	   ,sum([SOV])  as [SOV]
	   ,sum([HOV2]) as [HOV2]
	   ,sum([HOV3]) as [HOV3]
	   ,sum([WALK]) as [WALK]
	   ,sum([BIKE]) as [BIKE]
	   ,sum([Transit]) as [Transit]
	   ,sum([Other]) as [Other]
	   ,sum([TotalPersonTrips]) as [TotalCommuterPersonTrips]
from t3
group by scenario_id

union all

select *
from t3
order by FromTo_MGRA DESC

END

GO



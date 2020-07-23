USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_trip_mode_mgra]    Script Date: 11/20/2019 3:22:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE  [sbreport].[res_trip_mode_mgra] @scenario_id int

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018>
-- Modify data: <04/17/2019> move to popsyn
-- Modify data: <10/30/2019> add summary on top row
-- Description:	<person trips by mode by MGRA, to include MGRA with Null output >
-- =============================================

AS
BEGIN

with t1 as
(
select   scenario_id
        ,value as mgra
		,mode_category_abbr
		,sum(party_size) as ptrips
from     [abm_13_2_3].[abm].[trip_ij]            tp
    join [abm_13_2_3].[ref].geography_zone       rmgo    on tp.orig_geography_zone_id = rmgo.geography_zone_id and rmgo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmgd    on tp.dest_geography_zone_id = rmgd.geography_zone_id and rmgd.geography_type_id = 90
	join [abm_13_2_3].[ref].mode                 rmd    on tp.mode_id = rmd.mode_id
	join [popsyn_3_0].[sbreport].[mgra] on (rmgo.zone =value  or rmgd.zone = value) 
where scenario_id = @scenario_id and user_id = system_user
group by tp.scenario_id,value,mode_category_abbr
),t2 as
(
select scenario_id,mgra,[SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI]  
from t1
pivot (sum(ptrips) for mode_category_abbr in ([SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT],[SBUS],[TAXI])) as pvt
),t3 as
(
select @scenario_id as scenario_id
      ,cast([mgra].value as varchar) as FromTo_MGRA
	  ,isnull([SOV],0)   as [SOV]
      ,isnull([HOV2],0)  as [HOV2]
	  ,isnull([HOV3],0)  as [HOV3]
	  ,isnull([WALK],0)  as [Walk]
	  ,isnull([BIKE],0)  as [Bike]
	  ,isnull([TRANSIT],0)  as [Transit]
	  ,(isnull([SBUS],0)  + isnull([TAXI],0))  as [Other]
      ,isnull([SOV],0)+isnull([HOV2],0)+isnull([HOV3],0)+isnull([WALK],0)+isnull([BIKE],0)+isnull([TRANSIT],0)+isnull([SBUS],0)+isnull([TAXI],0) as TotalTrips
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
	   ,sum([TotalTrips]) as [TotalTrips]
from t3
group by scenario_id

union all

select *
from t3
order by FromTo_MGRA DESC



END

GO



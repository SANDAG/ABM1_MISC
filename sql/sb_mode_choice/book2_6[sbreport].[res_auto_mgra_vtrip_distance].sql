USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_auto_mgra_vtrip_distance]    Script Date: 11/20/2019 3:23:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[res_auto_mgra_vtrip_distance] @scenario_id int
AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <10/31/2019>
-- Description:	<vehicle trip length by MGRA >
-- =============================================

--Set Nocount On
with t0 as
(
select   tp.scenario_id
        ,cast([mgra].value as varchar) as mgra
		,mode_id
		,party_size
		,trip_distance
        ,CASE 
	         When mode_id in (3,4,5) and party_size = 1   Then   1/2.00
			 When mode_id in (6,7,8) and party_size = 1   Then   1/3.34
	         Else 1.0 
			 End as vfactor
from [abm_13_2_3].[abm].[trip_ij]            tp
join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
join [popsyn_3_0].[sbreport].[mgra]          mgra   on (rmo.zone = mgra.value or rmd.zone = mgra.value) 
where tp.scenario_id = @scenario_id and user_id = SYSTEM_USER and mode_id between 1 and 8
),t1 as
(
select   scenario_id
        ,mgra
       ,sum(vfactor) as VehicleTrips
	   ,sum(trip_distance * vfactor) as VehicleMilesTraveled
	   ,sum(trip_distance * vfactor)/sum(vfactor) as AvgVehicleDistance
from    t0
group by scenario_id,mgra
),t2 as
(
select @scenario_id as scenario_id
      ,cast([mgra].value as varchar) as FromTo_MGRA
	  ,isnull(VehicleTrips,0) as VehicleTrips
	  ,isnull(VehicleMilesTraveled,0) as VehicleMilesTraveled
	  ,isnull(AvgVehicleDistance,0) as AvgVehicleDistance
from t1
right join [popsyn_3_0].[sbreport].[mgra]
    on [mgra].value=t1.mgra
where user_id = system_user
)
select scenario_id
       ,'Total' as FromTo_MGRA
       ,sum(isnull(VehicleTrips,0)) as VehicleTrips
	   ,sum(isnull(VehicleMilesTraveled,0)) as VehicleMilesTraveled
	   ,sum(isnull(VehicleMilesTraveled,0))/sum(isnull(VehicleTrips,0)) as AvgVehicleDistance
from t1
group by scenario_id

union all

select *
from t2
order by FromTo_MGRA DESC

END
GO



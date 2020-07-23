USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[sim_length_all_mgra]    Script Date: 11/20/2019 3:29:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE  [sbreport].[sim_length_all_mgra] @scenario_id int
AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <04/17/2019> to move to popsyn
-- Modify date: <11/13/2019> to add the summary at the first row
-- Description:	<simulated person trip length of all by MGRA >
-- =============================================

with t0 as
(
select   tp.scenario_id
        ,value as mgra
	   ,sum(trip_distance*party_size) as PersonMilesTraveled
	   ,sum(party_size)    as PersonTrips
	   ,sum(party_size*trip_distance)/sum(party_size) AvgTripDistance
from     [abm_13_2_3].[abm].[vi_trip_micro_simul]    tp
    join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
	join [popsyn_3_0].[sbreport].[mgra]         on (rmo.zone = mgra.value) or (rmd.zone = mgra.value) 
where tp.scenario_id = @scenario_id and user_id = system_user
group by tp.scenario_id,value
)
select scenario_id
       ,'Total' as FromTo_MGRA
       ,sum(isnull(PersonMilesTraveled,0)) as PersonMilesTraveled
	   ,sum(isnull(PersonTrips,0)) as PersonTrips
	   ,sum(isnull(PersonMilesTraveled,0))/sum(isnull(PersonTrips,0)) as AvgPersonDistanceAllModel
from t0
group by scenario_id

union all

select @scenario_id as scenario_id
       ,cast([mgra].value as varchar) as FromTo_MGRA
	   ,isnull(PersonMilesTraveled,0) as PersonMilesTraveledAllModel
	   ,isnull(PersonTrips,0) as PersonTrips
	   ,isnull(AvgTripDistance,0) as AvgTripDistance
from t0
right join [popsyn_3_0].[sbreport].[mgra] 
    on [mgra].value=t0.mgra
where user_id = system_user
order by FromTo_MGRA  DESC


END;
GO



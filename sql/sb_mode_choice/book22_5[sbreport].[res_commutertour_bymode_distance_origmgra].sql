USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_commutertour_bymode_distance_origmgra]    Script Date: 11/20/2019 3:26:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE  [sbreport].[res_commutertour_bymode_distance_origmgra]  @scenario_id int
-- =============================================
-- Author:		<YMA>
-- Create date: <10/11/2019>
-- Modify date: <11/01/2019> to add summary at top row
-- Description:	<Average tour distance of commuter tours by mode by OrigMGRA >
-- =============================================

AS
Begin 

with t0 as
(
select   tr.tour_ij_id,tr.mode_id,mode_category_abbr as TourMode
         ,cast(rmgo.zone as varchar) as TourOrig
		 ,trip_id,trip_distance,party_size
FROM [abm_13_2_3].[abm].[tour_ij]              tr
    join [abm_13_2_3].[abm].[trip_ij]          tp     on tr.scenario_id=tp.scenario_id and tr.tour_ij_id=tp.tour_ij_id
	join [abm_13_2_3].[ref].geography_zone     rmgo   on tr.orig_geography_zone_id = rmgo.geography_zone_id and rmgo.geography_type_id = 90
	join [abm_13_2_3].[ref].mode               rmd    on tr.mode_id = rmd.mode_id
    join [popsyn_3_0].[sbreport].[mgra]        mgra   on rmgo.zone =mgra.value 
where tr.[scenario_id]=@scenario_id  and user_id = system_user and tr.[purpose_id]=1 
), t1 as
(
select tour_ij_id,TourOrig,TourMode,party_size,sum(trip_distance) as Tour_distance
from t0
group by tour_ij_id,TourOrig,TourMode,party_size
), t2 as
(
select  TourOrig
       ,TourMode
	   ,sum(Tour_distance)/count(tour_ij_id) as AvgTourDis
from t1
group by TourOrig,TourMode
), t22 as
(
select  TourOrig, [SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT]
from t2
pivot (avg(AvgTourDis) for TourMode in ([SOV],[HOV2],[HOV3],[WALK],[BIKE],[TRANSIT])) as pvt
), t3 as
(
select  TourOrig
 	   ,sum(Tour_distance)/count(tour_ij_id) as AvgTourDisAll
from t1
group by TourOrig
), t4 as
(
select  'All' as CommuterTourOrig
		,TourMode
 	   ,sum(Tour_distance)/count(tour_ij_id) as AvgTourDis
from t1
group by TourMode

union all

select 'All' as CommuterTourOrig
       ,'AllModes'as TourMode
	   ,sum(Tour_distance)/count(tour_ij_id) as AvgTourDis
from t1
group by TourOrig
)
select  @scenario_id as scenario_id
       ,CommuterTourOrig
       ,isnull(SOV,0)  as AvgTourMiles_SOV
       ,isnull(HOV2,0) as AvgTourMiles_HOV2
       ,isnull(HOV3,0) as AvgTourMiles_HOV3
       ,isnull(TRANSIT,0) as AvgTourMiles_TRANSIT
       ,isnull(WALK,0) as AvgTourMiles_WALK
       ,isnull(BIKE,0) as AvgTourMiles_BIKE
	   ,isnull(AllModes,0) as AvgTourMilesAllModes
from t4
pivot (avg(AvgTourDis) for TourMode in ([SOV],[HOV2],[HOV3],[WALK],[BIKE],[TRANSIT],[AllModes])) as pvt

union all

select  @scenario_id as scenario_id
       ,cast([mgra].value as varchar) as CommuterTourOrig
       ,isnull(SOV,0)  as AvgTourMiles_SOV
       ,isnull(HOV2,0) as AvgTourMiles_HOV2
       ,isnull(HOV3,0) as AvgTourMiles_HOV3
       ,isnull(TRANSIT,0) as AvgTourMiles_TRANSIT
       ,isnull(WALK,0) as AvgTourMiles_WALK
       ,isnull(BIKE,0) as AvgTourMiles_BIKE
	   ,isnull(AvgTourDisAll,0) as AvgTourMilesAllModes
from t22
join t3 on t22.TourOrig = t3.TourOrig
right join [popsyn_3_0].[sbreport].[mgra]   on [mgra].value=t22.TourOrig
where user_id = system_user
order by CommuterTourOrig DESC

END;

GO



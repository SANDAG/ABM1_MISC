USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_commutertour_bymode_pmt_origmgra]    Script Date: 11/20/2019 3:25:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[res_commutertour_bymode_pmt_origmgra]  @scenario_id int
-- =============================================
-- Author:		<YMA>
-- Create date: <10/11/2019>
-- Description:	<PMT of commuter tours by mode by OrigMGRA >
-- =============================================

AS
Begin 

with t0 as
(
select   tr.tour_ij_id,tr.mode_id,mode_category_abbr as TourMode,rmgo.zone as TourOrig,trip_id,trip_distance,party_size
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
	   ,sum(party_size*Tour_distance) as pmt
from t1
group by TourOrig,TourMode
), t22 as
(
select  TourOrig, [SOV],[HOV2],[HOV3],[WALK],[BIkE],[TRANSIT]
from t2
pivot (sum(pmt) for TourMode in ([SOV],[HOV2],[HOV3],[WALK],[BIKE],[TRANSIT])) as pvt
)
select @scenario_id  as scenario_id
       ,'Total' as CommuterTourOrigMGRA
	   ,sum(isnull(SOV,0))     as PMT_SOV
       ,sum(isnull(HOV2,0))    as PMT_HOV2
       ,sum(isnull(HOV3,0))    as PMT_HOV3
       ,sum(isnull(TRANSIT,0)) as PMT_TRANSIT
       ,sum(isnull(WALK,0))    as PMT_WALK
       ,sum(isnull(BIKE,0))    as PMT_BIKE
	   ,sum(isnull(SOV,0)+isnull(HOV2,0)+isnull(HOV3,0)+isnull(TRANSIT,0)+isnull(WALK,0)+isnull(BIKE,0)) as PMT_Total
from t22

union all

select  @scenario_id as scenario_id
       ,cast([mgra].value as varchar) as CommuterTourOrigMGRA
       ,isnull(SOV,0)  as PMT_SOV
       ,isnull(HOV2,0) as PMT_HOV2
       ,isnull(HOV3,0) as PMT_HOV3
       ,isnull(TRANSIT,0) as PMT_TRANSIT
       ,isnull(WALK,0) as PMT_WALK
       ,isnull(BIKE,0) as PMT_BIKE
	   ,(isnull(SOV,0)+isnull(HOV2,0)+isnull(HOV3,0)+isnull(TRANSIT,0)+isnull(WALK,0)+isnull(BIKE,0)) as PMT_Total
from t22
right join [popsyn_3_0].[sbreport].[mgra]   on [mgra].value=TourOrig
where user_id = system_user
order by CommuterTourOrigMGRA DESC

END;

GO



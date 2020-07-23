USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_triplength_all_mgra]    Script Date: 11/20/2019 3:22:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[res_triplength_all_mgra] @scenario_id int
AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018> to include MGRA with Null output
-- Modify date: <10/30/2019> to add summary at top row
-- Description:	<person trip length by MGRA >
-- =============================================


--Set Nocount On

with temp as
(
select   tp.scenario_id
        ,mgra.value as mgra
		,sum(trip_distance*party_size) as PersonMilesTraveled
		,sum(party_size)    as  PersonTrips
	    ,sum(trip_distance*party_size)/sum(party_size) as AvgDistance
from     [abm_13_2_3].[abm].[trip_ij]            tp
    join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
	join [popsyn_3_0].[sbreport].[mgra]                               on (rmo.zone = mgra.value or rmd.zone = mgra.value) 
where tp.scenario_id = @scenario_id and user_id = SYSTEM_USER
group by tp.scenario_id,mgra.value
),t2 as
(
select @scenario_id as scenario_id
      ,cast([mgra].value as varchar) as FromTo_MGRA
	  ,isnull(PersonTrips,0) as PersonTrips
	  ,isnull(PersonMilesTraveled,0) as PersonMilesTraveled
	  ,isnull(AvgDistance,0) as AvgDistance
from temp
right join [popsyn_3_0].[sbreport].[mgra]
    on [mgra].value=temp.mgra
where user_id = system_user
)
select scenario_id
       ,'Total' as FromTo_MGRA
       ,sum(isnull(PersonTrips,0)) as PersonTrips
	   ,sum(isnull(PersonMilesTraveled,0)) as PersonMilesTraveled
	   ,sum(isnull(PersonMilesTraveled,0))/sum(isnull(PersonTrips,0)) as AvgDistance
from temp
group by scenario_id

union all

select *
from t2
order by FromTo_MGRA DESC

END
GO



USE [popsyn_3_0]
GO




-- ==================================================================================================
-- Author:	ZOU
-- May 2020
-- person trip length by purpose by MGRA for trips either origin or destination	in the MGRA list
-- ==================================================================================================

CREATE PROCEDURE  [sbreport].[res_persontripLength_purpose_mgra] @scenario_id int

AS
BEGIN

with t1 as
(
select   tp.scenario_id
        ,value as mgra
		,purpose_desc
		,sum(party_size*trip_distance) miles_ptrips
		,sum(party_size) ptrips 
		,sum(party_size*trip_distance)/sum(party_size) as AvgPtripDistance 
from     [abm_13_2_3].[abm].[trip_ij]            tp
    join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
	join [abm_13_2_3].[ref].purpose              rpp    on tp.purpose_id = rpp.purpose_id
	join [popsyn_3_0].[sbreport].[mgra] on (rmo.zone =mgra.value ) or (rmd.zone = mgra.value) 
where tp.scenario_id = @scenario_id and user_id = System_User
group by tp.scenario_id,mgra.value,purpose_desc
)

,t2 as
(--this layer is to address multiple rows of same MGRA caused by null value of missing purpose
select scenario_id
	,mgra
	,SUM(ISNULL(Work,0)) Work
	,SUM(ISNULL(University,0)) University
	,SUM(ISNULL(School,0)) School
	,SUM(ISNULL(Escort,0)) Escort
	,SUM(ISNULL(Shop,0)) Shop
	,SUM(ISNULL(Maintenance,0)) Maintenance
	,SUM(ISNULL([Eating Out],0)) [Eating Out]
	,SUM(ISNULL(Visiting,0)) Visiting
	,SUM(ISNULL(Discretionary,0)) Discretionary
	,SUM(ISNULL([Work-Based],0)) [Work-Based]
	,SUM(ISNULL([Work related],0)) [Work related]
	,SUM(ISNULL(Home,0)) Home
from 
(
	select scenario_id,mgra,[Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home]  
	from t1
	pivot (Avg(AvgPtripDistance) for purpose_desc in ([Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home])) as pvt
)tpv
group by scenario_id,mgra
)

,t3 as (
	select
			mgra		   
		   ,SUM(miles_ptrips)/SUM(ptrips) [AvgDistanceAllPurp]   
	from t1
	group by mgra
)
,t0 as (
	select scenario_id
		   ,'TOTAL' as FromTo_MGRA
		   ,purpose_desc
		   ,SUM(miles_ptrips)/SUM(ptrips) agg_avg_pmt   
	from t1
	group by scenario_id ,purpose_desc

	union all
	select scenario_id
		   ,'TOTAL' as FromTo_MGRA
		   ,'AllPurpose' purpose_desc
		   ,SUM(miles_ptrips)/SUM(ptrips) agg_avg_pmt   
	from t1
	group by scenario_id 
)
select
	@scenario_id as scenario_id
    ,FromTo_MGRA
	,ISNULL([Work], 0) AS [Work]
	,ISNULL([University], 0) AS [University]
	,ISNULL([School], 0) AS [School]
	,ISNULL([Escort], 0) AS [Escort]
	,ISNULL([Shop], 0) AS [Shop]
	,ISNULL([Maintenance], 0) AS [Maintenance]
	,ISNULL([Eating Out], 0) AS [EatingOut]
	,ISNULL([Visiting], 0) AS [Visiting]
	,ISNULL([Discretionary], 0) AS [Discretionary]
	,ISNULL([Work-Based], 0) AS [WorkBased]
	,ISNULL([Work related], 0) AS [WorkRelated]
	,ISNULL([Home], 0) AS [Home]
	,ISNULL([AvgDistanceAllPurp],0) [AvgDistanceAllPurp]	
from 
(
select scenario_id, FromTo_MGRA,[Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home]
      ,[AllPurpose] as [AvgDistanceAllPurp]
from t0
pivot (avg(agg_avg_pmt) for purpose_desc in ([Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home], [AllPurpose]))as pvt
)t01

union all

select @scenario_id as scenario_id
    ,cast([mgra].value as varchar) as FromTo_MGRA
	,ISNULL([Work], 0) AS [Work]
	,ISNULL([University], 0) AS [University]
	,ISNULL([School], 0) AS [School]
	,ISNULL([Escort], 0) AS [Escort]
	,ISNULL([Shop], 0) AS [Shop]
	,ISNULL([Maintenance], 0) AS [Maintenance]
	,ISNULL([Eating Out], 0) AS [EatingOut]
	,ISNULL([Visiting], 0) AS [Visiting]
	,ISNULL([Discretionary], 0) AS [Discretionary]
	,ISNULL([Work-Based], 0) AS [WorkBased]
	,ISNULL([Work related], 0) AS [WorkRelated]
	,ISNULL([Home], 0) AS [Home]
	,ISNULL([AvgDistanceAllPurp],0) [AvgDistanceAllPurp]	
from t2
join t3 on t2.mgra = t3.mgra
right join [popsyn_3_0].[sbreport].[mgra]
    on t2.mgra=[mgra].value 
where user_id = System_User
order by FromTo_MGRA  DESC

END


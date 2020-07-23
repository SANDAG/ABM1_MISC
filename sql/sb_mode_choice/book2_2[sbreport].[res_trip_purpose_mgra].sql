USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_trip_purpose_mgra]    Script Date: 11/20/2019 3:21:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modified Date:<12/13/2018> to include MGRA with Null output
-- Modified Date:<04/17/2019> to move to popsyn
-- Modified Date:<10/30/2019> to add summary on top row
-- Description:	<person trips by purpose by MGRA>
-- =============================================

ALTER PROCEDURE  [sbreport].[res_trip_purpose_mgra] @scenario_id int

AS
BEGIN

with t1 as
(
select   tp.scenario_id
        ,value as mgra
		,purpose_desc
		,sum(party_size) as ptrips
from     [abm_13_2_3].[abm].[trip_ij]            tp
    join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
	join [abm_13_2_3].[ref].purpose              rpp    on tp.purpose_id = rpp.purpose_id
	join [popsyn_3_0].[sbreport].[mgra] on (rmo.zone =mgra.value ) or (rmd.zone = mgra.value) 
where tp.scenario_id = @scenario_id and user_id = System_User
group by tp.scenario_id,mgra.value,purpose_desc
),t2 as
(
select scenario_id,mgra,[Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home]  
from t1
pivot (sum(ptrips) for purpose_desc in ([Work],[University],[School],[Escort],[Shop],[Maintenance],[Eating Out],[Visiting],[Discretionary],[Work-Based],[Work related],[Home])) as pvt
),t3 as
(
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
    ,ISNULL([Work], 0)+ISNULL([University], 0)+ISNULL([School], 0)+ISNULL([Escort], 0)+ISNULL([Shop], 0)+ISNULL([Maintenance], 0)+ISNULL([Eating Out], 0)+ISNULL([Visiting], 0)+ISNULL([Discretionary], 0)+ISNULL([Work-Based], 0)+ISNULL([Work related], 0)+ISNULL([Home], 0) as TotalPersonTrips
from t2
right join [popsyn_3_0].[sbreport].[mgra]
    on t2.mgra=[mgra].value 
where user_id = System_User
)
select scenario_id
       ,'TOTAL' as FromTo_MGRA
	   ,sum([Work]) as [Work]
	   ,sum([University]) as [University]
	   ,sum([School]) as [School]
	   ,sum([Escort]) as [Escort]
	   ,sum([Shop]) as [Shop]
	   ,sum([Maintenance]) as [Maintenance]
	   ,sum([EatingOut]) as [EatingOut]
	   ,sum([Visiting])  as [Visiting]
	   ,sum([Discretionary]) as [Discretionary]
	   ,sum([WorkBased]) as [WorkBased]
	   ,sum([WorkRelated]) as [WorkRelated]
	   ,sum([Home]) as [Home]
	   ,sum([TotalPersonTrips]) as [TotalPersonTrips]
from t3
group by scenario_id

union all

select *
from t3
order by FromTo_MGRA DESC

END

GO



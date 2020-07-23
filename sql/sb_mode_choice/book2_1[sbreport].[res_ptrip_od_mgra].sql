USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[res_ptrip_od_mgra]    Script Date: 11/20/2019 3:20:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[res_ptrip_od_mgra] @scenario_id int
AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <12/13/2018> to inclue MGRA with Null output
-- Modify date: <04/17/2019> to move to popsyn
-- Modify date: <10/30/2019> to add summary on top row
-- Description:	<person trips by OD by MGRA>
-- =============================================

with t1 as
(
select   
         tp.scenario_id as scenario_id
		,value as mgra
		,CASE
		       WHEN (rmo.zone = rmd.zone ) THEN 'Intra'
			   ELSE 'Inter'
			   END AS odflag
        ,party_size
from     [abm_13_2_3].[abm].[trip_ij]            tp
	join [abm_13_2_3].[ref].geography_zone       rmo    on tp.orig_geography_zone_id = rmo.geography_zone_id and rmo.geography_type_id = 90
    join [abm_13_2_3].[ref].geography_zone       rmd    on tp.dest_geography_zone_id = rmd.geography_zone_id and rmd.geography_type_id = 90
	join [popsyn_3_0].[sbreport].[mgra] on (rmo.zone = value or rmd.zone = value) 
where tp.scenario_id = @scenario_id  and user_id=SYSTEM_USER
),t2 as
(
select scenario_id,mgra,[Intra],[Inter]
from t1
pivot (sum(party_size) for odflag in ([Intra],[Inter])) as pvt
),t3 as
(
select @scenario_id as scenario_id
       ,cast([mgra].value as varchar) as FromTo_MGRA
      ,isnull([Intra],0)        as [Intra]
	  ,isnull([Inter],0)        as [Inter]
	  ,isnull([Intra],0) + isnull([Inter],0) as [TotalTrips]
	  ,CASE 
	          WHEN (isnull([Intra],0) + isnull([Inter],0))>0  THEN isnull([Intra],0)*1.0/(isnull([Intra],0) + isnull([Inter],0))
			  ELSE 0
			  END as [IntraRatio]
from t2
right join [popsyn_3_0].[sbreport].[mgra]
    on [mgra].value=t2.mgra
where user_id=SYSTEM_USER
--order by [mgra].value
)
select scenario_id
       ,'TOTAL' as FromTo_MGRA
	   ,sum([Intra]) as [Intra]
	   ,sum([Inter]) as [Inter]
	   ,sum([TotalTrips]) as [TotalTrips]
	   ,1.0*sum([Intra])/sum([TotalTrips])  as [IntraRatio]
from t3
group by scenario_id

union all

select *
from t3
order by FromTo_MGRA DESC

END

GO



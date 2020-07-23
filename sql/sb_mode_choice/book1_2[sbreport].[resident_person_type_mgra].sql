USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[resident_person_type_mgra]    Script Date: 11/20/2019 3:19:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[resident_person_type_mgra] @scenario_id int

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modify date: <4/17/2018> to move to popsyn
-- Modify date: <10/30/2018> to add the sum at the top row
-- Description:	<residents summary by person type by MGRA>
-- =============================================

AS
BEGIN


with t0 as
(
select mylist.value as mgra
       ,rgt.zone as taz
	   ,rgm.geography_zone_id as mgra_geography_zone_id
	   ,rgt.geography_zone_id as taz_geography_zone_id
from [popsyn_3_0].[sbreport].[mgra] as mylist
	join [abm_13_2_3].[ref].geography_zone       rgm       on mylist.value = rgm.zone  and rgm.geography_type_id = 90
	join [abm_13_2_3].[ref].[mgra13_xref_taz13]  rx        on rgm.geography_zone_id=rx.mgra_geography_zone_id 
	join [abm_13_2_3].[ref].geography_zone       rgt       on rx.taz_geography_zone_id = rgt.geography_zone_id and rgt.geography_type_id = 34
where user_id = System_User
),t1 as
(
select   lup.scenario_id
        ,t0.mgra_geography_zone_id
		,ptype_desc
		,count(*) as persons
 from    [abm_13_2_3].[abm].lu_person            lup       
	join [abm_13_2_3].[abm].lu_hh                luh       on lup.scenario_id = luh.scenario_id  and lup.lu_hh_id = luh.lu_hh_id
	join [abm_13_2_3].[ref].ptype                rpt       on lup.ptype_id = rpt.ptype_id
	join t0                                                on t0.mgra_geography_zone_id=luh.geography_zone_id
where lup.scenario_id = @scenario_id 
group by lup.scenario_id,t0.mgra_geography_zone_id,ptype_desc
),t2 as
(
select scenario_id,mgra_geography_zone_id,[Full-time Worker],[Part-time Worker],[College Student],[Non-working Adult],[Non-working Senior],[Driving Age Student],[Non-driving Student],[Pre-school]
from t1
pivot (sum(persons) for ptype_desc in ([Full-time Worker],[Part-time Worker],[College Student],[Non-working Adult],[Non-working Senior],[Driving Age Student],[Non-driving Student],[Pre-school])) as pvt
), t3 as
(
select @scenario_id as scenario_id
       ,cast(mgra as varchar) as HomeMGRA
	   ,cast(taz as varchar)  as HomeTAZ
	   ,isnull([Full-time Worker],0) as FullTimeWorker
	   ,isnull([Part-time Worker],0) as PartTimeWorker
	   ,isnull([Non-working Adult],0) as NonWorkingAdult
	   ,isnull([Non-working Senior],0) as NonWorkingSenior
	   ,isnull([College Student],0) as CollegeStudent
	   ,isnull([Driving Age Student],0) as DrivingAgeStudent
	   ,isnull([Non-driving Student],0) as NonDrivingStudent
	   ,isnull([Pre-school],0) as PreSchool
       ,(isnull([Full-time Worker],0)+isnull([Part-time Worker],0) +isnull([Non-working Adult],0)+isnull([Non-working Senior],0)+isnull([College Student],0) +isnull([Driving Age Student],0) +isnull([Non-driving Student],0)+isnull([Pre-school],0)) as TotalPerson    
from t2
right join t0 
    on t0.mgra_geography_zone_id=t2.mgra_geography_zone_id
)
select scenario_id
       ,'TotalMgra' as HomeMGRA
       ,'TotalTaz' as HomeTAZ
       ,sum(FullTimeWorker) as FullTimeWorker
       ,sum(PartTimeWorker) as PartTimeWorker
       ,sum(NonWorkingAdult) as NonWorkingAdult
       ,sum(NonWorkingSenior) as NonWorkingSenior
       ,sum(CollegeStudent) as CollegeStudent
       ,sum(DrivingAgeStudent) as DrivingAgeStudent
       ,sum(NonDrivingStudent) as NonDrivingStudent
       ,sum(PreSchool) as PreSchool
       ,sum(TotalPerson) as TotalPerson
from t3
group by scenario_id

union all

select *
from t3
order by HomeMGRA DESC

END

GO



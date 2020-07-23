USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[employee_employ_type_mgra]    Script Date: 11/20/2019 3:20:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE  [sbreport].[employee_employ_type_mgra] @scenario_id int

AS
BEGIN

-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modified date: <12/12/2018> to include all mgra in list
-- Modified date: <04/17/2019> to move to popsyn
-- Modified date: <10/30/2019> to add summary on top row
-- Description:	<employee summary by employed type by MGRA>
-- =============================================

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
		,pemploy_desc
		,lc.geography_zone_id as work_mgra_geography_zone_id
		,count(*) as number_person
from    [abm_13_2_3].[abm].lu_person                   lup       
 	left outer join [abm_13_2_3].[abm].[lu_person_lc]  lc     on  lup.scenario_id = lc.scenario_id and lup.lu_person_id = lc.lu_person_id 
	join [abm_13_2_3].[ref].[pemploy]                  rpem   on  rpem.pemploy_id = lup.pemploy_id
	join t0                                                   on  lc.geography_zone_id = t0.mgra_geography_zone_id 
where lup.scenario_id = @scenario_id and lc.loc_choice_segment_id <=7 
group by lup.scenario_id,pemploy_desc,lc.geography_zone_id
),t2 as
(
select scenario_id,work_mgra_geography_zone_id,[Employed Full-Time],[Employed Part-Time]
from t1
pivot (sum(number_person) for pemploy_desc in ([Employed Full-Time],[Employed Part-Time])) as pvt
),t3 as
(
select @scenario_id as scenario_id
       ,cast(t0.mgra as varchar) as WorkMGRA
	   ,cast(t0.taz as varchar) as  TAZ
	   ,isnull([Employed Full-Time],0) as EmployedFullTime
	   ,isnull([Employed Part-Time],0) as EmployedPartTime
	   ,isnull([Employed Full-Time],0)+isnull([Employed Part-Time],0) as TotalEmployed
from t2
right join t0 
    on t0.mgra_geography_zone_id=t2.work_mgra_geography_zone_id
)
select scenario_id
      ,'TotalMGRA' as WorkMGRA
	  ,'TotalTaz' as TAZ
	  ,sum(EmployedFullTime) as EmployedFullTime
	  ,sum(EmployedPartTime) as EmployedPartTime
	  ,sum(TotalEmployed) as TotalEmployed
from t3
group by scenario_id

union all

select *
from t3
order by WorkMGRA DESC

END
GO



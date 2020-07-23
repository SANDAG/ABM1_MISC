USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sbreport].[lu_input_summary_mgra]    Script Date: 01/23/2020 14:10:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE  [sbreport].[lu_input_summary_mgra] @scenario_id int
/*
-- =============================================
-- Author:		<YMA>
-- Create date: <12/3/2018>
-- Modidy data: <04/17/2018> to move to popsyn
-- Description:	<SB land use summary by MGRA>

Updated by Ziying Ouyang
Date Jan 23, 2020
Summarize person counts from person file
-- =============================================
*/
AS
BEGIN


with temp as
(
SELECT [scenario_id]
	  ,cast([mgra].value as varchar) as MGRA
	  ,cast(rgt.zone as varchar) as TAZ
      ,sum([hh])  as Household   
      ,sum([hhp])  as Population
      ,sum([gq_civ] + [gq_mil]) as GroupQuater  
      ,sum(ISNULL([zonal_pop],0))  as TotalPop_personFile --from [lu_person]
      --,sum([pop])  as TotalPopulation
      ,sum([emp_total]) as Employment
      ,sum(([enrollgradekto8] + [enrollgrade9to12])) as SchoolEnrollment
      ,sum(([collegeenroll] + [othercollegeenroll] + [adultschenrl])) as CollegeEnrollment
FROM [abm_13_2_3].[abm].[lu_mgra_input]          lu
	join [abm_13_2_3].[ref].geography_zone       rgm       on lu.geography_zone_id = rgm.geography_zone_id and rgm.geography_type_id = 90	 
    join [popsyn_3_0].[sbreport].[mgra]                                  on rgm.zone = [mgra].value and rgm.geography_type_id = 90
	join [abm_13_2_3].[ref].[mgra13_xref_taz13]  rx        on rgm.geography_zone_id=rx.mgra_geography_zone_id 
	join [abm_13_2_3].[ref].geography_zone       rgt       on rx.taz_geography_zone_id = rgt.geography_zone_id and rgt.geography_type_id = 34
	--summarize persons from [abm_13_2_3].abm.[lu_person]
	LEFT OUTER JOIN (SELECT 
				geography_zone_id
				,COUNT(*) zonal_pop				
			FROM [abm_13_2_3].abm.[lu_person] person
			JOIN   [abm_13_2_3].abm.[lu_hh] household
			ON person.scenario_id = household.scenario_id
				AND person.lu_hh_id = household.lu_hh_id
			WHERE person.scenario_id = @scenario_id 
			GROUP BY   
				geography_zone_id) pop
			ON pop.geography_zone_id = lu.geography_zone_id

where [scenario_id] = @scenario_id  and user_id = System_User
group by scenario_id,rgt.zone,[mgra].value
--order by scenario_id,[mgra].value
)
select [scenario_id]
       ,'TOTAL' as MGRA
	   ,'total' as TAZ
       ,sum(Household) as Household
       ,sum(Population) as Population
       ,sum(GroupQuater) as GroupQuater
       ,sum(TotalPop_personFile) TotalPop_personFile
       --,sum(TotalPopulation) as TotalPopulation       
       ,sum(Employment) as Employment
       ,sum(SchoolEnrollment) as SchoolEnrollment
       ,sum(CollegeEnrollment) as CollegeEnrollment
from temp
group by [scenario_id]

union all

select *
from temp

END

GO



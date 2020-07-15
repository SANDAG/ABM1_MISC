USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_total_local]    Script Date: 4/23/2019 9:10:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <3/23/2019>
-- Description:	<This function is created to verify the total amount in local>
-- =============================================

CREATE FUNCTION
	[sbauto].[verify_total_local] (@lu_scenario_desc nvarchar(100))
 
RETURNS @verify_total_local TABLE
(
	[mgra] [int] NOT NULL,
	[old_hh]  [int] NOT NULL,
	[old_gq]  [int] NOT NULL,
	[old_hhp] [int] NOT NULL,
	[old_pop] [int] NOT NULL,
	[old_emp] [int] NOT NULL,
	[old_enroll] [int] NOT NULL,
	[old_hotelroom] [int] NOT NULL,

	[new_hh]  [int] NOT NULL,
	[new_gq]  [int] NOT NULL,
	[new_hhp] [int] NOT NULL,
	[new_pop] [int] NOT NULL,
	[new_emp] [int] NOT NULL,
	[new_enroll] [int] NOT NULL,
	[new_hotelroom] [int] NOT NULL,

	[gap_hh]  [int] NOT NULL,
	[gap_gq]  [int] NOT NULL,
	[gap_hhp] [int] NOT NULL,
	[gap_pop] [int] NOT NULL,
	[gap_emp] [int] NOT NULL,
	[gap_enroll] [int] NOT NULL,
	[gap_hotelroom] [int] NOT NULL

)AS
BEGIN

DECLARE @new_lu_version_id int = (select lu_version_id from ref.lu_version where lu_scenario_desc = @lu_scenario_desc) 

DECLARE @old_lu_version_id int = ( 					
select lu_version_id
from ref.lu_version
where increment = (select increment   from ref.lu_version  where  lu_scenario_desc = @lu_scenario_desc)
      and lu_version_id in (101,102,103,104,105,106,107,108,118,128)   
)				       


;with told as
(
select  lu_version_id
       ,mgra
	   ,hh
	   ,(gq_civ+gq_mil) as gq
	   ,hhp
	   ,pop
	   --,hhs
	   ,emp_total
	   ,(enrollgradekto8 + enrollgrade9to12+collegeenroll+othercollegeenroll+adultschenrl) as school_enroll
	   ,hotelroomtotal as hotelroom
from abm_input.lu_mgra_input
where lu_version_id = @old_lu_version_id and mgra in (select distinct mgra from sbauto.project_input_file where lu_version_id = @new_lu_version_id)
), tnew as
(
select  lu_version_id
       ,mgra
	   ,hh
	   ,(gq_civ+gq_mil) as gq
	   ,hhp
	   ,pop
	   --,hhs
	   ,emp_total
	   ,(enrollgradekto8 + enrollgrade9to12+collegeenroll+othercollegeenroll+adultschenrl) as school_enroll
	   ,hotelroomtotal as hotelroom
from abm_input.lu_mgra_input
where lu_version_id = @new_lu_version_id and mgra in (select distinct mgra from sbauto.project_input_file where lu_version_id = @new_lu_version_id)
)
INSERT INTO @verify_total_local
select told.mgra
       ,told.hh            as old_hh
	   ,told.gq            as old_gq
	   ,told.hhp           as old_hhp
	   ,told.pop           as old_pop
	   ,told.emp_total     as old_employment
	   ,told.school_enroll as old_enrollment
	   ,told.hotelroom     as old_hotelroom

       ,tnew.hh            as new_hh
	   ,tnew.gq            as new_gq
	   ,tnew.hhp           as new_hhp
	   ,tnew.pop           as new_pop
	   ,tnew.emp_total     as new_employment
	   ,tnew.school_enroll as new_enrollment
	   ,tnew.hotelroom     as new_hotelroom

	   ,tnew.hh-told.hh        as gap_hh
	   ,tnew.gq-told.gq        as gap_gq
	   ,tnew.hhp-told.hhp      as gap_hhp
	   ,tnew.pop-told.pop      as gap_pop
	   ,tnew.emp_total-told.emp_total            as gap_emp_total
	   ,tnew.school_enroll-told.school_enroll    as gap_school_enroll
	   ,tnew.hotelroom-told.hotelroom            as gap_hotelroom
from told
join tnew
    on told.mgra=tnew.mgra
order by told.mgra


RETURN
END

GO



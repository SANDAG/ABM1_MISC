USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_lu_result]    Script Date: 4/23/2019 9:09:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <4/20/2018>
-- Description:	<This function is created to verify the magr_based_landuse table result>
-- =============================================

CREATE FUNCTION
	[sbauto].[verify_lu_result] (@lu_version_id int)
 
RETURNS @verify_lu_result_table TABLE
(
	[lu_version_id] [int]  NOT NULL,
	[mgra] [int] NOT NULL,
	[hh]  [int] NOT NULL,
	[gq]  [int] NOT NULL,
	[hhp] [int] NOT NULL,
	[pop] [int] NOT NULL,
	[hhs] [float] NOT NULL,
	[emp_total] [int] NOT NULL,
	[emp_retail_total] [int] NOT NULL,
	[school_enroll] [int] NOT NULL,
	[college_enroll] [int] NOT NULL,
	[hotelroomtotal] [int] NOT NULL,
	[duden] [decimal](7, 4) NOT NULL,
	[popden] [decimal](7, 4) NOT NULL,
	[empden] [decimal](7, 4) NOT NULL,
	[retail_empden] [decimal](7, 4) NOT NULL

)AS
BEGIN

INSERT INTO @verify_lu_result_table
select  lu_version_id,mgra,hh,(gq_civ+gq_mil) as gq,hhp,pop,hhs
	   ,emp_total
	   ,(emp_retail + emp_restaurant_bar + emp_personal_svcs_retail) as emp_retail_total
	   ,(enrollgradekto8 + enrollgrade9to12) as school_enroll
	   ,(collegeenroll+othercollegeenroll+adultschenrl) as college_enroll
	   ,hotelroomtotal
	   ,duden
	   ,popden
	   ,empden
	   ,retempden as retail_empden
from abm_input.lu_mgra_input
where lu_version_id = @lu_version_id
order by mgra

RETURN
END



GO



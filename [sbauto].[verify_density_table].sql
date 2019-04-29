USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_density_table]    Script Date: 4/23/2019 9:07:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<YMA>
-- Create date: <3/23/2019>
-- Description:	<This code is to verify purpose>
-- =============================================

CREATE FUNCTION
	[sbauto].[verify_density_table] ()

RETURNS @verify_density_table TABLE 
(
	 
	[lu_type_id] tinyint NOT NULL
	,[lu_code] smallint NOT NULL
	,[type_desc] nvarchar(100) NULL
	,[code_desc] nvarchar(100) NOT NULL
	,[type_code] nvarchar(20) NOT NULL
	,[value_per_unit] decimal(10,4) NOT NULL
	,PRIMARY KEY ([lu_type_id],[lu_code])
)
AS
BEGIN

INSERT INTO @verify_density_table
SELECT
	lu_type_id
	,lu_code
	,type_desc
	,code_desc
	,type_code
	,value_per_unit
FROM	
(
--lu_type_id=3 (employee)
SELECT  
	   3 as lu_type_id
	   ,'employees' as type_desc
       ,[lu_code] as lu_code
	   ,description as code_desc
	   ,'3_'+CAST(lu_code AS VARCHAR) as type_code
	  ,1.000 as value_per_unit	 
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] 
  				
UNION ALL

--lu_type_id=6 (ksf)
SELECT  
	   6 as lu_type_id
	   ,'ksf' as type_desc
       ,[lu_code] as lu_code
	   ,description as code_desc
	   ,'6_'+CAST(lu_code AS VARCHAR) as type_code
	   ,1000.0/Value_per_unit as value_per_unit	 
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] 

UNION ALL

--lu_type_id=2 (acre)
SELECT  
	   2 as lu_type_id
	   ,'acres' as type_desc
       ,[lu_code] as lu_code
	   ,description as code_desc
	   ,'2_'+CAST(lu_code AS VARCHAR) as type_code
	   ,(43.560*1000.0/[Value_per_unit]) as value_per_unit	 
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] 

UNION ALL

--lu_type_id=1 (units)
	SELECT 1 AS [lu_type_id], 'dwelling units' as type_desc, 101 AS lu_code,'hh_sf' AS code_desc,'1_101' as type_code, 1.0 AS value_per_unit
	UNION ALL
	SELECT 1 AS [lu_type_id], 'dwelling units' as type_desc, 102 AS lu_code,'hh_mf' AS code_desc,'1_102' as type_code, 1.0 AS value_per_unit
	UNION ALL
	SELECT 1 AS [lu_type_id], 'dwelling units' as type_desc, 103 AS lu_code,'hh_mh' AS code_desc,'1_103' as type_code, 1.0 AS value_per_unit	


UNION ALL
 				
--lu_type=7 (hotels)
SELECT  
       7 as lu_type_id
	   ,'rooms' as type_desc
       ,[lu_code] as lu_code
	   ,description as code_desc
	   ,'7_'+CAST(lu_code AS VARCHAR) as type_code
	   ,1 as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
WHERE lu_code BETWEEN 1501 AND 1503

UNION ALL

--lu_type = 8 (school enrollment)
--add series of lu_code between 6891 and 6899 to allow school enrollment inputs, YMA,11/1/2018
SELECT
        8 as lu_type_id
	   ,'students' as type_desc
       ,[lu_code] as lu_code
	   ,CASE WHEN lu_code IN( 6805,6806,6895,6896) THEN 'enrollgradekto8' 
             WHEN lu_code IN( 6804,6894) THEN 'enrollgrade9to12'  
             WHEN lu_code IN( 6801,6891) THEN 'collegeenroll' 
             WHEN lu_code IN( 6802,6803,6892,6893) THEN 'othercollegeenroll' 
             WHEN lu_code IN( 6809,6899) THEN 'adultschenrl'
			 END AS code_desc
	   ,'8_'+CAST(lu_code AS VARCHAR) as type_code
	   ,1 as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] 
WHERE (lu_code BETWEEN 6801 AND 6809	AND lu_code <> 6807)  or (lu_code between 6891 and 6899)  
) AS density


RETURN
END
GO



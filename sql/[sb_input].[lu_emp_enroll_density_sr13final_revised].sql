USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sb_input].[lu_emp_enroll_density_sr13final_revised]    Script Date: 4/23/2019 9:05:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION
	[sb_input].[lu_emp_enroll_density_sr13final_revised] ()

RETURNS @lu_emp_enroll_density_sr13final_revised TABLE 
(
	 
	[lu_type_id] tinyint NOT NULL
	,[lu_code] smallint NOT NULL
	,[abm_category] nvarchar(100) NOT NULL
	,[value_per_unit] decimal(10,4) NOT NULL
	,PRIMARY KEY ([lu_type_id],[lu_code],[abm_category])
)
AS
BEGIN

INSERT INTO @lu_emp_enroll_density_sr13final_revised
SELECT
	
	lu_type_id
	,lu_code
	,abm_category
	,value_per_unit
FROM	
(
--lu_type_id=3 (employee)
SELECT  
      
	   3 as lu_type_id
       ,dt.[lu_code] as lu_code
	   ,dd.abm_category
	  ,dd.value_per_unit	 
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
    JOIN [ref].[sb_input_lucode_survey_pecas] r 
	    ON dt.lu_code=r.lu_code_survey
	JOIN sb_input.lu_emp_share dd
	    ON r.lu_code_pecas = dd.lu_code
where lu_type_id=3  --use the proportion
  				
UNION ALL

--lu_type_id=6 (ksf)
SELECT  
      
       6 as lu_type_id
       ,dt.[lu_code] as lu_code
	   ,dd.abm_category
	   ,1000.0/dt.[Value_per_unit]*dd.value_per_unit as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
    JOIN [ref].[sb_input_lucode_survey_pecas] r 
	    ON dt.lu_code=r.lu_code_survey
	JOIN sb_input.lu_emp_share dd
	    ON r.lu_code_pecas = dd.lu_code
where lu_type_id=3

UNION ALL
  				
--lu_type_id=2 (acre)
SELECT  
       2 as lu_type_id
       ,dt.[lu_code] as lu_code
  	   ,dd.abm_category
	   ,(43.560*1000.0/dt.[Value_per_unit]*dd.value_per_unit) as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
    JOIN [ref].[sb_input_lucode_survey_pecas] r 
	    ON dt.lu_code=r.lu_code_survey
	JOIN sb_input.lu_emp_share dd
	    ON r.lu_code_pecas = dd.lu_code
where  lu_type_id=3
 
UNION ALL
  				
--lu_type=1 (units)

SELECT
	
	[lu_type_id]
	,[lu_code]
	,[abm_category]
	,[value_per_unit]
FROM (
	SELECT 1 AS [lu_type_id], 101 AS [lu_code], 'hh_sf' AS [abm_category], 1 AS [value_per_unit]
	UNION ALL
	SELECT 1, 102, 'hh_mf', 1
	UNION ALL
	SELECT 1, 103, 'hh_mh', 1
) AS tt

UNION ALL
  				
--lu_type=7 (hotels)
SELECT  
       7 as lu_type_id
       ,dt.[lu_code] as lu_code
	   ,CASE WHEN lu_code = 1501 THEN 'economyroom'
	         WHEN lu_code = 1502 THEN 'luxuryroom'
	         WHEN lu_code = 1503 THEN 'midpriceroom' END AS abm_category
	   ,1 as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
WHERE lu_code BETWEEN 1501 AND 1503

UNION ALL
--lu_type = 8 (school enrollment)
--add series of lu_code between 6891 and 6899 to allow school enrollment inputs, YMA,11/1/2018
SELECT
		
       8 as lu_type_id
       ,dt.[lu_code] as lu_code
	   ,CASE WHEN lu_code IN( 6805,6806,6895,6896) THEN 'enrollgradekto8' 
             WHEN lu_code IN( 6804,6894) THEN 'enrollgrade9to12'  
             WHEN lu_code IN( 6801,6891) THEN 'collegeenroll' 
             WHEN lu_code IN( 6802,6803,6892,6893) THEN 'othercollegeenroll' 
             WHEN lu_code IN( 6809,6899,6897) THEN 'adultschenrl' END AS abm_category     --added 6897 on 4/5/2019
	   ,1 as value_per_unit
FROM [popsyn_3_0].[sb_input].[lu_emp_enroll_density_total_sr13] dt
WHERE (dt.lu_code BETWEEN 6801 AND 6809	AND dt.lu_code <> 6807)  or (dt.lu_code between 6891 and 6899)  
) AS lu_table


RETURN
END

GO



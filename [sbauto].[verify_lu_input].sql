USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_lu_input]    Script Date: 4/23/2019 9:08:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<YMA>
-- Create date: <4/26/2018>, modified 3/23/2019
-- Description:	<This function is created to verify input file>
-- =============================================


CREATE FUNCTION
	[sbauto].[verify_lu_input] (@lu_scenario_desc nvarchar(200))
 
RETURNS @verify_lu_input_table TABLE
(
	[lu_scenario_desc] nvarchar(200) NOT NULL,
	[lu_version_id] [smallint] NOT NULL,
	[mgra] [int] NOT NULL,
	[lu_type_id] [tinyint] NOT NULL,
	[lu_type_desc] nvarchar(100) NOT NULL,
	[lu_code] [smallint] NOT NULL,
	[lu_code_desc] nvarchar(100) NULL,
	[type_n_code] nvarchar(20) NOT NULL,
	[amount] [float] NOT NULL
)AS
BEGIN

INSERT INTO @verify_lu_input_table
select lu_scenario_desc
      ,tt.lu_version_id
	  ,mgra
	  ,tt.lu_type_id
	  ,lu_type_desc
	  ,tt.lu_code
	  ,d.description as lu_code_desc
	  ,CAST(tt.lu_type_id AS VARCHAR) + '_' + CAST(tt.lu_code AS VARCHAR) as type_n_code
	  ,amount
from sbauto.project_input_file  tt
    left outer join [sb_input].[lu_emp_enroll_density_total_sr13] d
	    on tt.lu_code=d.lu_code
    left outer join [popsyn_3_0].[ref].[lu_type]  lt
	    on tt.lu_type_id=lt.lu_type_id
    join ref.lu_version lu
	    on lu.lu_version_id=tt.lu_version_id
where lu.lu_scenario_desc = @lu_scenario_desc
order by lu_type_id asc,mgra,lu_code


RETURN
END

GO



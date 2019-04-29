USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [sbauto].[verify_mgra_list]    Script Date: 4/23/2019 9:09:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<YMA>
-- Create date: <3/26/2019>
-- Description:	<This function is created for validation>
-- =============================================


CREATE FUNCTION
	[sbauto].[verify_mgra_list] (@lu_scenario_desc nvarchar(200))
 
RETURNS @verify_mgra_list_table TABLE
(
	[lu_scenario_desc] nvarchar(200) NOT NULL,
	[lu_version_id] [smallint] NOT NULL,
	[mgra] [int] NOT NULL
)AS
BEGIN

INSERT INTO @verify_mgra_list_table
select distinct lu_scenario_desc
      ,tt.lu_version_id
	  ,mgra
from sbauto.project_input_file  tt
    join ref.lu_version lu
	    on tt.lu_version_id=lu.lu_version_id
where lu.lu_scenario_desc = @lu_scenario_desc
order by mgra


RETURN
END

GO



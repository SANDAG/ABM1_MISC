USE [popsyn_3_0]
GO

/****** Object:  UserDefinedFunction [abm_input].[abm_4ds]    Script Date: 4/23/2019 8:57:29 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


-- Household data
CREATE FUNCTION
	[abm_input].[abm_4ds]
(
	@lu_version_id [smallint]
)
RETURNS @ret_abm_4ds TABLE 
(
	[lu_version_id] [smallint] NOT NULL
	,[mgra_13] [int] NOT NULL
    ,[totint] [smallint] NOT NULL
    ,[duden] [decimal](7,4) NOT NULL
    ,[empden] [decimal](7,4) NOT NULL
    ,[popden] [decimal](7,4) NOT NULL
    ,[retempden] [decimal](7,4) NOT NULL
    ,[totintbin] [tinyint] NOT NULL
    ,[empdenbin] [tinyint] NOT NULL
    ,[dudenbin] [tinyint] NOT NULL
	,PRIMARY KEY ([lu_version_id], [mgra_13])
)
AS
BEGIN
INSERT INTO @ret_abm_4ds
SELECT
	[lu_version_id]
	,[mgra_13]
	,[totint]
	,[duden]
	,[empden]
	,[popden]
	,[retempden]
	,[totintbin]
	,[empdenbin]
	,[dudenbin]
FROM
	[popsyn_3_0].[abm_input].[mgra_sr13_based_inputs_4ds]
WHERE
	[lu_version_id] = @lu_version_id
RETURN
END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'function to return all series 13 final abm 4d values until proper way to run them with each scenario is found' , @level0type=N'SCHEMA',@level0name=N'abm_input', @level1type=N'FUNCTION',@level1name=N'abm_4ds'
GO



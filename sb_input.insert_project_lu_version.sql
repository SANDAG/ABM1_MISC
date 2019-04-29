USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [sb_input].[insert_project_lu_version]    Script Date: 4/23/2019 8:40:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [sb_input].[insert_project_lu_version]
	@lu_version_id smallint -- Need to specify [lu_version_id] located in [ref].[lu_version]
	,@lu_scenario_desc nvarchar(200) -- Need to give the project a description
	,@new_lu_version_id smallint OUTPUT
AS
BEGIN

DECLARE @lu_scenario_id smallint =
(
	SELECT 
		MAX([lu_scenario_id]) + 1
	FROM (
		SELECT
			MAX([lu_scenario_id]) AS [lu_scenario_id]
		FROM
			[ref].[lu_version]
		INNER JOIN (
			SELECT
				[lu_major_version]
				,[lu_minor_version]
			FROM
				[ref].[lu_version]
			WHERE
				[lu_version_id] = @lu_version_id
			) AS tt1
		ON
			[lu_version].[lu_major_version] = tt1.[lu_major_version]
			AND [lu_version].[lu_minor_version] = tt1.[lu_minor_version]
		UNION ALL
		SELECT 99 AS [lu_scenario_id]
		) tt2
)

DBCC CHECKIDENT ('ref.lu_version', RESEED, 0)
DBCC CHECKIDENT ('ref.lu_version', RESEED)
INSERT INTO [ref].[lu_version]
SELECT
	[lu_major_version]
	,[lu_minor_version]
	,@lu_scenario_id AS [lu_scenario_id]
	,[increment]
	,[minor_geography_type_id]
	,[middle_geography_type_id]
	,[major_geography_type_id]
	,@lu_scenario_desc AS [lu_scenario_desc]
	,NULL AS [popsyn_targets_created]
	,NULL AS [mgra_based_input_file_created]
FROM
	[ref].[lu_version]
WHERE
	[lu_version_id] = @lu_version_id

-- Return the [lu_version_id]
SELECT
	@new_lu_version_id = MAX([lu_version_id])
FROM
	[ref].[lu_version]
WHERE
	[lu_scenario_id] = @lu_scenario_id
	AND [lu_scenario_desc] = @lu_scenario_desc

END
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'updates [ref].[lu_version] table with new record for a service bureau project' , @level0type=N'SCHEMA',@level0name=N'sb_input', @level1type=N'PROCEDURE',@level1name=N'insert_project_lu_version'
GO


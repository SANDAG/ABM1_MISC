USE [popsyn_3_0]
GO

/****** Object:  StoredProcedure [popsyn].[validator]    Script Date: 4/23/2019 8:34:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [popsyn].[validator]
	@popsyn_run_id smallint -- Need to specify [popsyn_run_id] located in [ref].[popsyn_run]
AS

-- only necessary to review mgra and taz targets as the region targets are ignored by popsyn since they are specified at mgra level
DECLARE @minor_geography_type_id smallint = (SELECT [minor_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id] WHERE [popsyn_run_id] = @popsyn_run_id)
DECLARE @mid_geography_type_id smallint = (SELECT [middle_geography_type_id] FROM [ref].[lu_version] INNER JOIN [ref].[popsyn_run] ON [lu_version].[lu_version_id] = [popsyn_run].[lu_version_id] WHERE [popsyn_run_id] = @popsyn_run_id)


UPDATE [ref].[popsyn_run] SET [validated] = NULL WHERE [popsyn_run_id] = @popsyn_run_id 


IF((SELECT MAX([final_weight]) FROM [popsyn].[synpop_hh] WHERE [popsyn_run_id] = @popsyn_run_id) > 500)
	PRINT 'A large household weight (>500) was assigned by popsyn, targets and acs pums in large disagreement proceed with caution.'


IF((SELECT MAX([final_weight]) FROM [popsyn].[synpop_hh] WHERE [popsyn_run_id] = @popsyn_run_id) > (SELECT MAX([n]) FROM [ref].[expansion_numbers]))
BEGIN
	UPDATE [ref].[popsyn_run] SET [validated] = 'A household weight exceeds maximum n in ref.expansion_numbers, add to this table before using ouput.' WHERE [popsyn_run_id] = @popsyn_run_id
	PRINT 'A household weight assigned by popsyn exceeds largest value in ref.expansion_numbers table, add to this table before using output.'
END


CREATE TABLE
	#temp_results
(
	[popsyn_run_id] smallint NOT NULL
	,[target_category_col_nm] nvarchar(50) NOT NULL
	,[balancing_geography] nvarchar(50) NOT NULL
	,[n] int NOT NULL
	,[observed_region_total] int NOT NULL
	,[target_region_total] int NOT NULL
	,[diff_total] int NOT NULL
	,[diff_mean] decimal(14,4) NOT NULL
	,[diff_stdev] decimal(14,4) NOT NULL
	,[diff_max] int NOT NULL
	,[pct_diff_total] decimal(7,4) NOT NULL
)
INSERT INTO #temp_results
-- mgra targets
SELECT
	@popsyn_run_id AS [popsyn_run_id]
	,[target_category_col_nm]
	,'mgra' AS [balancing_geography]
	,COUNT(*) AS [n]
	,SUM(results_mgra.[value]) AS [observed_region_total]
	,SUM([control_targets].[value]) AS [target_region_total]
	,SUM(results_mgra.[value] - [control_targets].[value]) AS [diff_total]
	,ROUND(AVG(1.0 * results_mgra.[value] - [control_targets].[value]), 4) AS [diff_mean]
	,STDEV(results_mgra.[value] - [control_targets].[value]) AS [diff_stdev]
	,MAX(results_mgra.[value] - [control_targets].[value]) AS [diff_max]
	,ROUND(ISNULL(1.0 * SUM(results_mgra.[value] - [control_targets].[value]) / NULLIF(SUM([control_targets].[value]), 0), 0) * 100, 4) AS [pct_diff_total]
FROM 
	[popsyn_input].[control_targets]
INNER JOIN
	[popsyn].[synpop_target_category_results] (@popsyn_run_id, @minor_geography_type_id) AS results_mgra
ON
	[control_targets].[lu_version_id] = results_mgra.[lu_version_id]
	AND [control_targets].[target_category_id] = results_mgra.[target_category_id]
	AND [control_targets].[geography_zone_id] = results_mgra.[geography_zone_id]
INNER JOIN
	[ref].[target_category]
ON
	[control_targets].[target_category_id] = [target_category].[target_category_id]
WHERE
	[control_targets].[lu_version_id] = (SELECT [lu_version_id] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = @popsyn_run_id)
GROUP BY
	[control_targets].[lu_version_id]
	,[target_category_col_nm]

UNION ALL

-- series 13 taz targets
SELECT
	@popsyn_run_id AS [popsyn_run_id]
	,[target_category_col_nm]
	,'taz' AS balancing_geography
	,COUNT(*) AS [n]
	,SUM(results_taz.[value]) AS [observed_region_total]
	,SUM([control_targets].[value]) AS [target_region_total]
	,SUM(results_taz.[value] - [control_targets].[value]) AS [diff_total]
	,AVG(1.0 * results_taz.[value] - [control_targets].[value]) AS [diff_mean]
	,STDEV(results_taz.[value] - [control_targets].[value]) AS [diff_stdev]
	,MAX(results_taz.[value] - [control_targets].[value]) AS [diff_max]
	,ISNULL(1.0 * SUM(results_taz.[value] - [control_targets].[value]) / NULLIF(SUM([control_targets].[value]), 0), 0) * 100 AS [pct_diff_total]
FROM 
	[popsyn_input].[control_targets]
INNER JOIN
	[popsyn].[synpop_target_category_results] (@popsyn_run_id, @mid_geography_type_id) AS results_taz
ON
	[control_targets].[lu_version_id] = results_taz.[lu_version_id]
	AND [control_targets].[target_category_id] = results_taz.[target_category_id]
	AND [control_targets].[geography_zone_id] = results_taz.[geography_zone_id]
INNER JOIN
	[ref].[target_category]
ON
	[control_targets].[target_category_id] = [target_category].[target_category_id]
WHERE
	[control_targets].[lu_version_id] = (SELECT [lu_version_id] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = @popsyn_run_id)
GROUP BY
	[control_targets].[lu_version_id]
	,[target_category_col_nm]


IF((SELECT MAX([pct_diff_total]) FROM #temp_results WHERE [target_category_col_nm] IN ('Households', 'Non Institutional Group Quarters - Total', 'pop_non_gq')) >= 1)
BEGIN
	UPDATE [ref].[popsyn_run] SET [validated] = 'Households, gq, or non-gq population difference from target exceeds 1% regionally.' WHERE [popsyn_run_id] = @popsyn_run_id
	PRINT 'Households, gq, or non-gq population difference from target exceeds 1% regionally.'
END


IF((SELECT [validated] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = @popsyn_run_id) IS NULL)
UPDATE [ref].[popsyn_run] SET [validated] = 'valid' WHERE [popsyn_run_id] = @popsyn_run_id


SELECT 
	*
FROM 
	#temp_results
GO

EXEC sys.sp_addextendedproperty @name=N'ms_description', @value=N'stored procedure to generate validation results for a given popsyn run' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'PROCEDURE',@level1name=N'validator'
GO

EXEC sys.sp_addextendedproperty @name=N'subsystem', @value=N'popsyn' , @level0type=N'SCHEMA',@level0name=N'popsyn', @level1type=N'PROCEDURE',@level1name=N'validator'
GO


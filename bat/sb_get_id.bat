Rem this bat file is to get the 4id, modified for sb override automating, YMA, 4/20/2018, modified 4/1/2019

@echo off

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [lu_version_id] FROM [ref].[lu_version] WHERE ([increment] = %increment% AND [lu_version_id] between 101 and 108)" -W -h -1 -b > temp_result.txt
if ERRORLEVEL 1 exit /b
set /p lu_version_id=< temp_result.txt
del temp_result.txt
echo base lu_version_id = %lu_version_id%

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [popsyn_run_id] FROM [ref].[popsyn_run] WHERE ([lu_version_id] = %lu_version_id% )" -W -h -1 -b > temp_result.txt
if ERRORLEVEL 1 exit /b
set /p base_popsyn_run_id=< temp_result.txt
del temp_result.txt
echo base popsyn_run_id = %base_popsyn_run_id%

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [popsyn_data_source_id] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = %base_popsyn_run_id%" -W -h -1 -b > temp_result.txt
if ERRORLEVEL 1 exit /b
set /p popsyn_data_source_id=< temp_result.txt
del temp_result.txt
echo popsyn_data_source_id = %popsyn_data_source_id%

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [new_lu_version_id] FROM [sbauto].[temp_version_id] WHERE [lu_scenario_desc] = '%lu_scenario_desc%' " -W -h -1 -b > temp_result.txt
if ERRORLEVEL 1 exit /b
set /p new_lu_version_id=< temp_result.txt
del temp_result.txt
echo new lu_version_id = %new_lu_version_id%

(
     echo.
     echo base lu_version_id = %lu_version_id%
     echo base popsyn_run_id = %base_popsyn_run_id%
     echo new lu_version_id = %new_lu_version_id%
     echo.
) >> "%project_path%\log\log.txt"

if ERRORLEVEL 1 exit /b


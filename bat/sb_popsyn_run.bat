Rem this bat file was copied from the original version, and is modified for Sb override automating, YMA, 4/18/2018, modified 4/1/2019

@echo off

set popsyn_path= T:\ABM\release\POPSYN3\version_3.0.0

echo execute popsyn java program.......

cd %popsyn_path%
rem run the popsyn java program using newly created scenario's [lu_version_id] and the [popsyn_data_source_id] from the base [popsyn_run_id]
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "(gc %popsyn_path%\conf\popsyn.properties) -replace 'popsyn3.landUseVersion=.*','popsyn3.landUseVersion=%new_lu_version_id%' | Out-File %popsyn_path%\conf\popsyn.properties -Encoding UTF8"
if ERRORLEVEL 1 exit /b
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "(gc %popsyn_path%\conf\popsyn.properties) -replace 'popsyn3.dataSource=.*','popsyn3.dataSource=%popsyn_data_source_id%' | Out-File %popsyn_path%\conf\popsyn.properties -Encoding UTF8"
if ERRORLEVEL 1 exit /b

call %popsyn_path%\runPopSynIII.bat
if ERRORLEVEL 1 exit /b

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [popsyn_run_id] FROM [ref].[popsyn_run] WHERE [lu_version_id] = %new_lu_version_id%" -W -h -1 -b > temp_result.txt
set /p popsyn_run_id=< temp_result.txt
del temp_result.txt

if ERRORLEVEL 1 exit /b

echo.
echo new popsyn run id= %popsyn_run_id%
echo ~~~~~~~~~~~~~~~~~~~~popsyn java program is completed~~~~~~~~~~~~~~~~~~~~
echo.


echo execute popsyn validator.......
sqlcmd -S %abm_input_server% -d %abm_input_database% -i %project_path%\sql\popsyn_validate.sql -v popsyn_run_id=%popsyn_run_id% -o %project_path%\temp.txt
type %project_path%\temp.txt >> %project_path%\validate_result.txt
del %project_path%\temp.txt

if ERRORLEVEL 1 exit /b
echo.
echo ~~~~~~~~~~~~~~~~~~~~finish popsyn validator~~~~~~~~~~~~~~~~~~~~  
echo.


sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [validated] FROM [ref].[popsyn_run] WHERE [popsyn_run_id] = %popsyn_run_id%" -W -h -1 -b > temp_result.txt
set /p validated=<temp_result.txt
del temp_result.txt
echo validated = %validated%

if ERRORLEVEL 1 exit /b
echo.
echo ~~~~~~~~~~~~~~~~~~~~Please review %project_path%\validate_result.txt file for validitor result~~~~~~~~~~~~~~~~~~~~
echo.


@echo.
(

     echo.
     echo new popsyn_run_id = %popsyn_run_id%
	 echo validated = %validated%
     echo.
) >> "%project_path%\log\log.txt"

if ERRORLEVEL 1 exit /b
cd %project_path%

 



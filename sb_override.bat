rem start running override procedure from database, YMA, 4/18/2018, modified 04/1/2019

echo off
echo loading lu.csv
sqlcmd -d %abm_input_database%  -E -S %abm_input_server% -Q "TRUNCATE TABLE sbauto.get_project_input_file_tt" -W -h -1 -b 
bcp sbauto.get_project_input_file_tt in %project_path%\lu.csv -c -t, -S %abm_input_server% -d %abm_input_database% -T
echo.
echo finished writing lu.csv into database

echo checking if lu.csv file loaded completely...
sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SELECT count(*) FROM sbauto.get_project_input_file_tt" -W -h -1 -b > temp_lucsv_rows.txt
set /p num_row_lucsv_loaded=< temp_lucsv_rows.txt
del temp_lucsv_rows.txt
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~%num_row_lucsv_loaded% records written into the database~~~~~~~~~~~~~~~~~~~~~~~~~~

echo.
set /p ArgContinue= You have %num_row_lucsv_loaded% records in your lu.csv file. Is that number right? Enter Yes or No:
IF %ArgContinue% == Yes (
  goto continue1
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit    
)

:continue1	

@echo start verifing the input file in database
sqlcmd -S %abm_input_server% -d %abm_input_database% -Q "exec [sbauto].[verify_project_input_file]"

@echo  output lu_input_error.csv
if exist %project_path%\lu_input_error.csv del %project_path%\lu_input_error.csv
bcp "SELECT 'lu_type_id','lu_code','com_code'" queryout "%project_path%\lu_input_error.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT [lu_type_id],[lu_code],[com_code]  FROM [sbauto].[temp_lucsv_error]" queryout "%project_path%\lu_input_error_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\lu_input_error_temp.csv >> %project_path%\lu_input_error.csv
del %project_path%\lu_input_error_temp.csv
echo finished writing %project_path%\lu_input_error.csv

@echo output lu_input_mgra_error.csv
if exist %project_path%\lu_input_mgra_error.csv del %project_path%\lu_input_mgra_error.csv
bcp "SELECT 'mgra'" queryout "%project_path%\lu_input_mgra_error.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT mgra  FROM [sbauto].[temp_lucsv_mgra_error]" queryout "%project_path%\lu_input_mgra_error_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\lu_input_mgra_error_temp.csv >> %project_path%\lu_input_mgra_error.csv
del %project_path%\lu_input_mgra_error_temp.csv
echo finished writing %project_path%\lu_input_mgra_error.csv

rem check rows
FOR /F "delims=: tokens=2 USEBACKQ" %%F IN (`find /c /v "" lu_input_error.csv`) DO (SET/a num_row_error1=%%F)
FOR /F "delims=: tokens=2 USEBACKQ" %%F IN (`find /c /v "" lu_input_mgra_error.csv`) DO (SET/a num_row_error2=%%F)
FOR /F "delims=: tokens=2 USEBACKQ" %%F IN (`find /c /v "" lu.csv`) DO (SET/a num_row_lucsv=%%F)

(
     echo.
     echo num_row_lucsv = %num_row_lucsv%
     echo num_row_loaded = %num_row_lucsv_loaded%
     echo num_error_lucode = %num_row_error1%
     echo num_error_mgra = %num_row_error2%
     echo.
) >> "%project_path%\log\log.txt"


IF %num_row_error1% GTR 1 (
    ECHO !!!!!!!!!! Error was found! Check Lu.csv Input Error in 'lu_input_error.csv' file !!!!!!!!!!
	pause
    exit	
)

IF %num_row_error2% GTR 1 (
    ECHO !!!!!!!!!! Error was found! Check Lu.csv Input Error in 'lu_input_mgra_error.csv' file !!!!!!!!!!
	pause
	exit 
)

set /a newvar = %num_row_lucsv_loaded% + 1
IF %num_row_lucsv% NEQ %newvar% (
    ECHO !!!!!!!!!! Error was found! Lu.csv was not completely loaded into the database, please correct errors in the Lu.CSV file !!!!!!!!!!
	pause
	exit 
)

echo.

set /p ArgContinue= The two error files: lu_input_error.csv and lu_input_mgra_error.csv have been created. Have you checked and confirmed they are all empty? Enter Yes or No:
IF %ArgContinue% == Yes (
  goto continue2
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue2	
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~finished verifying lu.csv file~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.

echo start running master sql procedure, it may take 15 minutes......
sqlcmd -S %abm_input_server% -d %abm_input_database% -i %project_path%\sql\main.sql -v increment=%increment% lu_scenario_desc=%lu_scenario_desc% -o %project_path%\temp.txt

IF %ERRORLEVEL% NEQ 0 (
  Echo !!!!!!!!!!!!!!!!! Error was found. Master Sql Procedure failed !!!!!!!!!!!!!!!!
  pause
  exit
) ELSE (
  goto continue3
)

rem if ERRORLEVEL 1 exit /b

:continue3

del temp.txt
echo.

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~master sql procedure was completed~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~finished adding a new lu_version id, check table [ref].[lu_version] to verify~~~~~~~~~~~~~ 
echo ~~~~~~~~~~~~~finished creating mgra based input, check table [abm_input].[lu_mgra_input] to verify~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~finished creating control target, check table [control_targets] to verify~~~~~~~~~~~~~



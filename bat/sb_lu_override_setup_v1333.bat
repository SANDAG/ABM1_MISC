@echo off
REM This is the file to start with for SB Land Use Override Automating procedure, by YMA, 4/18/2018, modified on 4/18/2019

REM #1 five input and check

echo.
echo ************************************Path Input and Check************************************
echo.

rem input project path and check length
set /p project_path= Enter proposed new project path:
ECHO %project_path%> tempfile.txt
FOR %%? IN (tempfile.txt) DO ( SET /A strlength=%%~z? - 2 )
DEL tempfile.txt
IF %strlength% GTR 60 (
    echo Your project path has length of %strlength%, please make your path shorter than 60 characters!
	goto :eof
)

rem input network path and check if exist
set /p network_path= Enter path where the network files come from:
IF NOT EXIST %network_path%\info (
    ECHO INFO can't be found in %network_path%, please check your network path and restart!
	goto :eof
)
IF NOT EXIST %network_path%\nofwycov (
    ECHO NOFWYCOV can't be found in %network_path%, please check your network path and restart!
	goto :eof
)
IF NOT EXIST %network_path%\walkbar (
    ECHO WALKBAR can't be found in %network_path%, please check your network path and restart!
	goto :eof
)

rem input lu.csv path and chekc if exist
set /p lucsv_path= Enter path where the lu.csv file is found:
IF NOT EXIST %lucsv_path%\lu.csv (
    ECHO LU.CSV file can't be found in %lucsv_path%, please check your path input and restart!
	goto :eof
)

rem input increment and check if valid
set /p increment= Enter year of scenario:
set ARG=2099
set "validArgs=2012;2020;2025;2030;2035;2040;2045;2050"
for  %%A in (%validArgs%) do (
    if  "%increment%"=="%%A" set ARG=%%A
)
IF %ARG%==2099 (
    ECHO The year of %increment% is invalid, please re-input your increment!
	echo errorlevel=%errorlevel%
	goto :eof
)

rem input project description
set curdate=%date:~4,10%
set curh=%Time:~0,2%
set curm=%Time:~3,2%
set /p scenario_desc_temp= Enter porject description:
set "lu_scenario_desc=%scenario_desc_temp%_%username%_%curdate%_%curh%%curm%"
set lu_scenario_desc=%lu_scenario_desc: =%

ECHO Remember your project description is: %lu_scenario_desc%

rem write input to log file

md %project_path%
md %project_path%\log

(
     echo project path = %project_path%
	 echo network_path = %network_path%
	 echo lucsv_path = %lucsv_path%
	 echo input_year = %increment%
	 echo description = %lu_scenario_desc%
) > "%project_path%\log\log.txt"

echo.	

rem forced pause and check
ECHO Finished Path Input. Please check log\log.txt file to confirm your input is right.
set /p ArgContinue= Are you ready to continue? Enter Yes or No:
IF %ArgContinue% == Yes (
  goto :continue1
) ELSE (
  goto :eof    
  
)

:continue1


REM #2 Setup the work structure
echo.
echo ************************************Start setting up work structure************************************
echo.

cd %project_path%

echo copying network files for 4d use...
robocopy %network_path%\info  4d\info  /s /xf *.lock >nul
robocopy %network_path%\nofwycov  4d\nofwycov  /s /xf *.lock >nul
robocopy %network_path%\walkbar  4d\walkbar  /s /xf *.lock   >nul


IF EXIST "t:\devel\sr13\4Ds" (
  goto :continue11
) ELSE (
  echo Can't find t:\devel\sr13\4Ds folder
  goto :eof    
)

:continue11

echo copying csv files for 4d use...
copy t:\devel\sr13\4Ds\2008x\mgraint.csv 4d\mgraint-by.csv 
copy t:\devel\sr13\4Ds\2008x\mgraint-nofwy.csv 4d\mgraint-nofwy-by.csv
copy t:\devel\sr13\4Ds\2008x\mgraint-ratio.csv 4d\mgraint-ratio-by.csv
copy T:\devel\sr13\4Ds\13_3_3\input\pasef%increment%.csv 4d\pasef%increment%.csv
copy T:\devel\sr13\4Ds\13_3_3\input\mgrahalo%increment%.csv 4d\mgrahalo%increment%.csv
xcopy T:\devel\sr13\4Ds\13_3_3\input\mgra13pt.csv input\mgra13pt.csv*

echo create property file of 4d use...
SET a=year=
SET aa=%a%%increment%
SET b=luDir=
SET bb=%b%%project_path%%\4d\
echo %aa% > 4d\sandag.properties
echo %bb% >> 4d\sandag.properties

echo copying lu.csv file
copy %lucsv_path%\lu.csv lu.csv

echo copying sql files
xcopy T:\ABM\release\POPSYN3\sb_override_v1333\sql\*.* /Y sql\*.**

echo copying bin files
xcopy T:\ABM\release\POPSYN3\sb_override_v1333\bin\*.* /Y bin\*.**

echo copying xls files
xcopy T:\ABM\release\POPSYN3\sb_override_v1333\xls\*.* /Y xls\*.**

echo.
echo ******************************Finished setting up work structure****************************
echo.

echo The project folder should include 9 folders (including subfolders) now.
echo Please check if the project folder setup looks right.

set /p ArgContinue= Have you checked project folder and confirm all is right? Enter Yes or No:
IF %ArgContinue% == Yes (
  goto :continue2
) ELSE (
  goto :eof    
)

:continue2
echo.
echo ************************************Start the workflow************************************
echo.


set abm_input_database= popsyn_3_0
set abm_input_server= sql2014a8

call bin\sb_workflow.bat

IF %ERRORLEVEL% NEQ 0 (
Echo !!!!!!!!!!!!!!!!!!!!!!Procedure failed. Please re-run the procedure!!!!!!!!!!!!!!!!!!!!
) ELSE (
  goto continue3
)

if ERRORLEVEL 1 exit /b

:continue3
echo.
echo ************************The whole procedure was completed************************
echo.
echo *****************Please verify the result: the 3 output csv files****************


cmd /k

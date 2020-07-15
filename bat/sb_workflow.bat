@echo off
Rem start from here and run each step   YMA, modified 4/1/2019

set abm_input_database= popsyn_3_0
set abm_input_server= sql2014a8

echo.
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~step1:start calling sb_override.bat~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
call bin\sb_override.bat
if ERRORLEVEL 1 exit /b


echo.
echo ---------------------------finished step 1: sb override master procedure in database---------------------------
echo.

set /p ArgContinue=You have finished sb_override procedure, are you ready to continue, Enter Yes or No to continue:
IF %ArgContinue% == Yes (
  goto continue4
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue4

call bin\sb_get_id.bat
if ERRORLEVEL 1 exit /b

echo.
echo ---------------------------finished step 2: getting 3 ids from database---------------------------
echo.


set /p ArgContinue= You have finished sb_get_id. Check if the four new ID make sense, Enter Yes or No to contine:
IF %ArgContinue% == Yes (
  goto continue5
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue5

call bin\sb_4d_input.bat
if ERRORLEVEL 1 exit /b

echo.
echo ---------------------------finished step 3: finished preparing 4d input---------------------------
echo.


set /p ArgContinue= Check if 'hhdata20xx.csv' and 'ludata20xx.csv' created in 4d folder. Also pick one local MGRA to check if the result reflect the lu input. Enter Yes or No to continue:
IF %ArgContinue% == Yes (
  goto continue6
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue6

call bin\sb_4d_run.bat
if ERRORLEVEL 1 exit /b

echo.
echo ------------------------finished step 4: finished 4d run in fortran program------------------------
echo.


set /p ArgContinue= You have finished sb_4d_run. Enter Yes or No to continue:
IF %ArgContinue% == Yes (
  goto continue7
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue7

call bin\sb_popsyn_run.bat
if ERRORLEVEL 1 exit /b


echo.
echo ---------------------finished step 5: finished popsyn run in jave and validator---------------------
echo.


set /p ArgContinue= You have finished sb_popsyn_run. Please check the table [ref.popsyn_run] to confirm the run is completed. Enter Yes or No to continue:
IF %ArgContinue% == Yes (
  goto continue8
) ELSE (
  echo !!!!!!!!!!!!!!!!!!!!You have choosen to stop the procedure!!!!!!!!!!!!!!!!!!!!
  pause
  exit  
)

:continue8

call bin\sb_output.bat
if ERRORLEVEL 1 exit /b


echo.
echo ---------------------finished step 6: finished generatiing 3 production csv files---------------------
echo.












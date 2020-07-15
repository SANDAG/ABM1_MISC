rem this batch file was originally written by RCU, modified for sb override automating, by YMA, 4/18/2018, modified 4/1/2019
@echo off

set fortran_path= T:\devel\sr13\4Ds\fortran_old
cd %project_path%\4d

IF EXIST %fortran_path%\4dmgra.exe (
  goto continue1
) ELSE (
  echo !!!!!!!!!!!!!! Fortran Program Folder Not Exist !!!!!!!!!!!!!!
  pause
  exit
)

:continue1

IF EXIST %fortran_path%\4ddensity.exe (
  goto continue2
) ELSE (
  echo !!!!!!!!!!!!!! Fortran Program Folder Not Exist !!!!!!!!!!!!!!
  pause
  exit
)

:continue2


%fortran_path%\4dmgra  %project_path%\4d
%fortran_path%\4ddensity 
if ERRORLEVEL 1 exit /b

echo ~~~~~~~~~~~~~~~finish 4d run~~~~~~~~~~~~~~~

rem check 4dABM size
for %%A in (%project_path%\4d\4dABM.csv) do @set size_4dABM=%%~zA
echo 4dABM.csv has size of %size_4dABM% 

IF %size_4dABM% GTR 1300000 (
  goto continue3
) ELSE (
  echo !!!!!!!!!! 4dABM.csv file has wrong size. Please double check !!!!!!!!!!
  pause
  exit    
)

:continue3


if ERRORLEVEL 1 exit /b

sqlcmd -d %abm_input_database%  -E -S %abm_input_server% -Q "TRUNCATE TABLE sbauto.lu_mgra_4d_output" -W -h -1 -b 
bcp sbauto.lu_mgra_4d_output in %project_path%\4d\4dABM.csv -c -t, -S %abm_input_server% -d %abm_input_database% -T
if ERRORLEVEL 1 exit /b
echo ~~~~~~~~~~~~~~~finish writing 4d into temp table~~~~~~~~~~~~~~~

sqlcmd -S %abm_input_server% -d %abm_input_database% -i %project_path%\sql\sub.sql -v lu_scenario_desc=%lu_scenario_desc% new_lu_version_id=%new_lu_version_id% -o %project_path%\temp.txt
if ERRORLEVEL 1 exit /b
echo ~~~~~~~~~~~~~~~finish saving 4d in keep table~~~~~~~~~~~~~~~ 

sqlcmd -S %abm_input_server% -d %abm_input_database% -i %project_path%\sql\join_4d.sql -v lu_scenario_desc=%lu_scenario_desc% new_lu_version_id=%new_lu_version_id% -o %project_path%\temp.txt
if ERRORLEVEL 1 exit /b
echo ~~~~~~~~~~~~~~~finish join local 4d with regional~~~~~~~~~~~~~~~  


cd..
del temp.txt

if ERRORLEVEL 1 exit /b

echo  ~~~~~~~~~~~~~~~4dABM.csv has been created. Check if the size greater than 14k~~~~~~~~~~~~~~~
echo  ~~~~~~~~~~~~~~~4dABM.csv has been loaded into [sbauto].[lu_mgra_4d_output_keep]. Note this is the raw output from fortran~~~~~~~~~~~~~~~
echo  ~~~~~~~~~~~~~~~By joining the locan with the regional base, the final 4d was saved in [sbauto].[lu_mgra_4d_output_join_local_n_region]~~~~~~~~~~~~~~~



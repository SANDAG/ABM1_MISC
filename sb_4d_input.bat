REM This batch file is to prepare for 4d input, YMA, 4/18/2018, modified 4/1/2019
@echo off

rem output ludata.csv
bcp "SELECT 'mgra','lu','acres','effective_acres','emp_total'" queryout "%project_path%\4d\ludata%increment%.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT [mgra],[lu],[acres],[effective_acres],[emp_total]  FROM [sbauto].[lu_mgra_4d_input_ludata]  where ([lu_version_id] = %new_lu_version_id%) ORDER BY [mgra],[lu]" queryout "%project_path%\4d\ludata%increment%_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\4d\ludata%increment%_temp.csv >> %project_path%\4d\ludata%increment%.csv
del %project_path%\4d\ludata%increment%_temp.csv
echo finished writing %project_path%\4d\ludata.csv

echo.

rem output hhdata.csv
bcp "SELECT 'mgra','hs','hs_sf','hs_mf','hs_mh','gq_civ','gq_mil','hh','hh_sf','hh_mf','hh_mh','i1','i2','i3','i4','i5','i6','i7','i8','i9','i10','pop','hhp'" queryout "%project_path%\4d\hhdata%increment%.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT [mgra],[hs],[hs_sf],[hs_mf],[hs_mh],[gq_civ],[gq_mil],[hh],[hh_sf],[hh_mf],[hh_mh],[i1],[i2],[i3],[i4],[i5],[i6],[i7],[i8],[i9],[i10],[pop],[hhp] FROM [abm_input].[mgra_based_input_file](%new_lu_version_id%) ORDER BY [mgra]" queryout "%project_path%\4d\hhdata%increment%_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\4d\hhdata%increment%_temp.csv >> %project_path%\4d\hhdata%increment%.csv
del %project_path%\4d\hhdata%increment%_temp.csv
echo finished writing %project_path%\4d\hhdata.csv

echo.

if ERRORLEVEL 1 exit /b
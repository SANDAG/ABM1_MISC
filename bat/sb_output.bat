REM This batch file is to create the 3 output csv files, YMA, 4/18/2018, modified 4/1/2019

@echo off

sqlcmd -d %abm_input_database% -C -E -S %abm_input_server% -Q "SET NOCOUNT ON; SELECT [popsyn_run_id] FROM [ref].[popsyn_run] WHERE ([lu_version_id] = %new_lu_version_id% )" -W -h -1 -b > temp_result.txt
set /p new_popsyn_run_id=< temp_result.txt
del temp_result.txt
if ERRORLEVEL 1 exit /b

rem output mgra_based_input_file.csv
bcp "SELECT 'mgra','taz','hs','hs_sf','hs_mf','hs_mh','hh','hh_sf','hh_mf','hh_mh','gq_civ','gq_mil','i1','i2','i3','i4','i5','i6','i7','i8','i9','i10','hhs','pop','hhp','emp_ag','emp_const_non_bldg_prod','emp_const_non_bldg_office','emp_utilities_prod','emp_utilities_office','emp_const_bldg_prod','emp_const_bldg_office','emp_mfg_prod','emp_mfg_office','emp_whsle_whs','emp_trans','emp_retail','emp_prof_bus_svcs','emp_prof_bus_svcs_bldg_maint','emp_pvt_ed_k12','emp_pvt_ed_post_k12_oth','emp_health','emp_personal_svcs_office','emp_amusement','emp_hotel','emp_restaurant_bar','emp_personal_svcs_retail','emp_religious','emp_pvt_hh','emp_state_local_gov_ent','emp_fed_non_mil','emp_fed_mil','emp_state_local_gov_blue','emp_state_local_gov_white','emp_public_ed','emp_own_occ_dwell_mgmt','emp_fed_gov_accts','emp_st_lcl_gov_accts','emp_cap_accts','emp_total','enrollgradekto8','enrollgrade9to12','collegeenroll','othercollegeenroll','adultschenrl','ech_dist','hch_dist','pseudomsa','parkarea','hstallsoth','hstallssam','hparkcost','numfreehrs','dstallsoth','dstallssam','dparkcost','mstallsoth','mstallssam','mparkcost','totint','duden','empden','popden','retempden','totintbin','empdenbin','dudenbin','zip09','parkactive','openspaceparkpreserve','beachactive','budgetroom','economyroom','luxuryroom','midpriceroom','upscaleroom','hotelroomtotal','luz_id','truckregiontype','district27','milestocoast'" queryout "%project_path%\mgra13_based_input%increment%.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT fl.[mgra],[taz],[hs],[hs_sf],[hs_mf],[hs_mh],[hh],[hh_sf],[hh_mf],[hh_mh],[gq_civ],[gq_mil],[i1],[i2],[i3],[i4],[i5],[i6],[i7],[i8],[i9],[i10],[hhs],[pop],[hhp],[emp_ag],[emp_const_non_bldg_prod],[emp_const_non_bldg_office],[emp_utilities_prod],[emp_utilities_office],[emp_const_bldg_prod],[emp_const_bldg_office],[emp_mfg_prod],[emp_mfg_office],[emp_whsle_whs],[emp_trans],[emp_retail],[emp_prof_bus_svcs],[emp_prof_bus_svcs_bldg_maint],[emp_pvt_ed_k12],[emp_pvt_ed_post_k12_oth],[emp_health],[emp_personal_svcs_office],[emp_amusement],[emp_hotel],[emp_restaurant_bar],[emp_personal_svcs_retail],[emp_religious],[emp_pvt_hh],[emp_state_local_gov_ent],[emp_fed_non_mil],[emp_fed_mil],[emp_state_local_gov_blue],[emp_state_local_gov_white],[emp_public_ed],[emp_own_occ_dwell_mgmt],[emp_fed_gov_accts],[emp_st_lcl_gov_accts],[emp_cap_accts],[emp_total],[enrollgradekto8],[enrollgrade9to12],[collegeenroll],[othercollegeenroll],[adultschenrl],[ech_dist],[hch_dist],[pseudomsa],[parkarea],[hstallsoth],[hstallssam],[hparkcost],[numfreehrs],[dstallsoth],[dstallssam],[dparkcost],[mstallsoth],[mstallssam],[mparkcost],fl.[totint],fd.[duden],fd.[empden],fd.[popden],fl.[retempden],fl.[totintbin],fd.[empdenbin],fd.[dudenbin],[zip09],[parkactive],[openspaceparkpreserve],[beachactive],[budgetroom],[economyroom],[luxuryroom],[midpriceroom],[upscaleroom],[hotelroomtotal],[luz_id],[truckregiontype],[district27],[milestocoast] FROM [abm_input].[mgra_based_input_file](%new_lu_version_id%) AS fl INNER JOIN [sbauto].[lu_mgra_4d_output_keep] AS fd ON (fl.MGRA = fd.MGRA and fl.lu_version_id=fd.lu_version_id) ORDER BY fl.[mgra]" queryout "%project_path%\mgra13_based_input%increment%_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\mgra13_based_input%increment%_temp.csv >> %project_path%\mgra13_based_input%increment%.csv
del %project_path%\mgra13_based_input%increment%_temp.csv

if ERRORLEVEL 1 exit /b

echo ~~~~~~~~~~~~~~~mgra_based_input%increment% written to %project_path%~~~~~~~~~~~~~~~

rem output households.csv
bcp "SELECT 'hhid','household_serial_no','taz','mgra','hinccat1','hinc','hworkers','veh','persons','hht','bldgsz','unittype','version','poverty'" queryout "%project_path%\households.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c 
bcp "SELECT [hhid],[household_serial_no],[taz],[mgra],[hinccat1],[hinc],[hworkers],[veh],[persons],[hht],[bldgsz],[unittype],[popsyn_run_id] AS [version],[poverty] FROM [sb_input].[households_file](%base_popsyn_run_id%, %new_popsyn_run_id%) ORDER BY [hhid]" queryout "%project_path%\households_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c 
type %project_path%\households_temp.csv >> %project_path%\households.csv
del %project_path%\households_temp.csv

if ERRORLEVEL 1 exit /b

echo ~~~~~~~~~~~~~~~households.csv written to %project_path%~~~~~~~~~~~~~~~


rem output persons.csv
bcp "SELECT 'hhid','perid','household_serial_no','pnum','age','sex','miltary','pemploy','pstudent','ptype','educ','grade','occen5','occsoc5','indcen','weeks','hours','rac1p','hisp','version'" queryout "%project_path%\persons.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
bcp "SELECT [hhid],[perid],[household_serial_no],[pnum],[age],[sex],[military] AS [miltary],[pemploy],[pstudent],[ptype],[educ],[grade],[occen5],[occsoc5],[indcen],[weeks],[hours],[rac1p],[hisp],[popsyn_run_id] AS [version] FROM [sb_input].[persons_file](%base_popsyn_run_id%, %new_popsyn_run_id%) ORDER BY [hhid],[perid]" queryout "%project_path%\persons_temp.csv" -S %abm_input_server% -d %abm_input_database% -T -t "," -r "\n" -c
type %project_path%\persons_temp.csv >> %project_path%\persons.csv
del %project_path%\persons_temp.csv

if ERRORLEVEL 1 exit /b

echo ~~~~~~~~~~~~~~~persons.csv written to %project_path%~~~~~~~~~~~~~~~



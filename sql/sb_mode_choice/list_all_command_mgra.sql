use [popsyn_3_0]
go

--===========book1==============
-- Book1_1  "LandUse":
exec [sbreport].[lu_input_summary_mgra] '1134'

-- Book1_2  "Residents":
exec [sbreport].[resident_person_type_mgra] '1134'

-- Book1_3  "Employees":
exec [sbreport].[employee_employ_type_mgra] '1134'

--===========book2==============
-- Book2_1  "InternalCapture":
EXEC [sbreport].[res_ptrip_od_mgra] '1134'

-- Book2_2  "PersonTripbyPurpose":
EXEC [sbreport].[res_trip_purpose_mgra] '1201'

-- Book2_3  "PersonTripbyModeChoice":
EXEC [sbreport].[res_trip_mode_mgra] '1188'

-- Book2_4  "PersonTripLength1":
EXEC [sbreport].[res_triplength_all_mgra] '1201'

-- Book2_5  "CommuteModeChoice1":
EXEC [sbreport].[res_trip_mode_commuter_mgra] '1134'

-- Book2_6  "Vehicle TripLength of Auto Modes, Residential Model", added on 10/31/2019
exec [sbreport].[res_auto_mgra_vtrip_distance] '1201'

-- Book2_7  "Person TripLength by purpose, Residential Model", added on 5/11/2020
EXEC [sbreport].[res_persontripLength_purpose_mgra] '1093'

-- Book2_8  "Auto TripLength by purpose, Residential Model", added on 5/14/2020
EXEC [sbreport].[res_autotripLength_purpose_mgra] '1093'

--===========book22==============
-- Book22_1  "TourPerson_by_Orig":
EXEC [sbreport].[res_commutertour_bymode_person_origmgra] '1134'

-- Book22_2  "TourPerson_by_Dest":
EXEC [sbreport].[res_commutertour_bymode_person_destmgra] '1134'

-- Book22_3  "TourPMT_by_Orig":
EXEC [sbreport].[res_commutertour_bymode_pmt_origmgra] '1134'

-- Book22_4  "TourPMT_by_Dest":
EXEC [sbreport].[res_commutertour_bymode_pmt_destmgra] '1134'

-- Book22_5  "Tour_Average_Distance_by_Orig":
EXEC [sbreport].[res_commutertour_bymode_distance_origmgra] '1134'

-- Book22_6  "Tour_Average_Distance_by_Dest":
EXEC [sbreport].[res_commutertour_bymode_distance_destmgra] '1093'



--===========book3==============
-- Book3_1  "ModelTypeTrips":
EXEC [sbreport].[sim_trip_by_modeltype_mgra] '1093'

-- Book3_2  "TripsByMode":
EXEC [sbreport].[sim_trip_bymode_mgra] '1093'

-- Book3_3  "TripLength2":
EXEC [sbreport].[sim_length_by_modeltype_mgra] '1093'

-- Book3_4  "PersonMiles":
EXEC [sbreport].[sim_length_all_mgra] '1093'

-- Book3_5  "CommuteModeChoice2":
EXEC [sbreport].[sim_commuter_mode_mgra] '1093'

-- Book3_6   "Vehicle TripLength of Auto Modes by Model Type", new added on 10/31/2019
EXEC [sbreport].[sim_auto_vtrip_distance_by_mgra_modeltype] '1093'
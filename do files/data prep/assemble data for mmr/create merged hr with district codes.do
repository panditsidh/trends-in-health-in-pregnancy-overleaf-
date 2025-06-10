if "`c(username)'" == "sidhpandit" {
	
	global nfhs4hr "/Users/sidhpandit/Desktop/nfhs/nfhs4hr/IAHR74FL.DTA"
	global nfhs5hr "/Users/sidhpandit/Desktop/nfhs/nfhs5hr/IAHR7EFL.DTA"
	
	global statedistrict_match "/Users/sidhpandit/Library/CloudStorage/GoogleDrive-sidh.pandit@utexas.edu/.shortcut-targets-by-id/1sIaQEa2-53mt0I99nuJH46bguMQaQsz8/data/statedistrict match.do"
	
	global dataset"/Users/sidhpandit/Library/CloudStorage/GoogleDrive-sidh.pandit@utexas.edu/.shortcut-targets-by-id/1sIaQEa2-53mt0I99nuJH46bguMQaQsz8/data/mergedhr45_district_codes"
	
}


if "`c(username)'" == "spearsde" {	
	global nfhs4hr "/Users/spearsde/Downloads/IAHR74FL.DTA"
	global nfhs5hr "/Users/spearsde/Downloads/IAHR7EFL.DTA"
	
	** @Dean - if you have "statedistrictmatch.do" downloaded (from shared drive)
	global statedistrict_match "/Users/spearsde/Downloads/statedistrict match.do"
	
	** @Dean - path to "statedistrictmatch.do" in the shared drive
// 	global statedistrict_match "/Users/spearsde/Library/CloudStorage/GoogleDrive-..."
	
	global dataset "/Users/spearsde/Downloads/mergedhr45_district_codes"

	
}

if "`c(username)'" == "dc42724" {

	global nfhs4hr "G:\Shared drives\maternal mortality\data\IAHR74FL.DTA"
	global nfhs5hr "G:\Shared drives\maternal mortality\data\IAHR7EFL.DTA"
	
	global statedistrict_match "G:\Shared drives\maternal mortality\code\statedistrict match.do"

	
	global dataset "G:\Shared drives\maternal mortality\data\mergedhr45_district_codes"
	
}


** @Diane not sure what variables you want to use
clear all 
use shdist hv* using $nfhs5hr, clear
tempfile nfhs5hr
save `nfhs5hr'

use shdistri hv* using $nfhs4hr, clear
append using `nfhs5hr'


gen round = 5 if hv000=="IA7"
replace round = 4 if hv000=="IA6"

do "${statedistrict_match}"

gen district_code_merged = district

save $dataset, replace





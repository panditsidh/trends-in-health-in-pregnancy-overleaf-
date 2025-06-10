if "`c(username)'" == "sidhpandit" {
	
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global statedistrict_match "/Users/sidhpandit/Library/CloudStorage/GoogleDrive-sidh.pandit@utexas.edu/.shortcut-targets-by-id/1sIaQEa2-53mt0I99nuJH46bguMQaQsz8/data/statedistrict match.do"
	
	global dataset"/Users/sidhpandit/Library/CloudStorage/GoogleDrive-sidh.pandit@utexas.edu/.shortcut-targets-by-id/1sIaQEa2-53mt0I99nuJH46bguMQaQsz8/data/mergedbr45_district_codes"
	
}

if "`c(username)'" == "spearsde" {
	global nfhs4br "/Users/spearsde/Downloads/IABR71FL.DTA"
	global nfhs5br "/Users/spearsde/Downloads/IABR7EFL.DTA"
	
	** @Dean - if you have "statedistrictmatch.do" downloaded (from shared drive)
	global statedistrict_match "/Users/spearsde/Downloads/statedistrict match.do"
	
	** @Dean - path to "statedistrictmatch.do" in the shared drive
// 	global statedistrict_match "/Users/spearsde/Library/CloudStorage/GoogleDrive-..."
	
	global dataset "/Users/spearsde/Downloads/mergedbr45_district_codes"

	
}

if "`c(username)'" == "dc42724" {
	global nfhs4br "G:\Shared drives\maternal mortality\data\IABR71FL.DTA"
	global nfhs5br "G:\Shared drives\maternal mortality\data\IABR7EFL.DTA"
	
	global statedistrict_match "G:\Shared drives\maternal mortality\data\statedistrict match.do"
	
	global dataset "G:\Shared drives\maternal mortality\data\mergedbr45_district_codes"
	
}


clear all 
use $nfhs4br
append using $nfhs5br

* so that it works with the state district matching file, which i made for households
gen hv024 = v024
gen hv000 = v000

gen round = 5 if v000=="IA7"
replace round = 4 if v000=="IA6"

gen shdistri = sdistri
gen shdist = sdist

do "${statedistrict_match}"

gen district_code_merged = district


save $dataset, replace

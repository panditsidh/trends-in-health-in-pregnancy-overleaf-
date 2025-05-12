if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/demographics3_"
	
}

use $ir_combined, clear

keep if v213==1 & mopreg>=3
replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)


gen educ_none      = v106 == 0  // no education
gen educ_primary   = v106 == 1  // primary
gen educ_secondary = v106 == 2  // secondary
gen educ_higher    = v106 == 3  // higher


gen husband_away1mo = s907 if round==4
replace husband_away1mo = s909 if round==5

gen husband_away6mo = s908 if round==4
replace husband_away6mo = s910 if round==5


label var educ_none      "No education"
label var educ_primary   "Primary education"
label var educ_secondary "Secondary education"
label var educ_higher    "Higher education"


svy: mean v012 v133 educ_none educ_primary educ_secondary educ_higher



gen health_facility_alone = s824b==1 if round==3
replace health_facility_alone = s928b==1 if round==4
replace health_facility_alone = s930b==1 if round==5

gen own_money = w124==1 if round==3
replace own_money = s930==1 if round==4
replace own_money = s932==1 if round==5

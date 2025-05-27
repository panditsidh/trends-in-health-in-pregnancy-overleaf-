* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/report_notpregnant.tex"
	
}

use $ir_combined, clear

keep if sterilized==0

gen moperiod_all = .
replace moperiod_all = 1 if v215>=101 & v215 <= 128 
replace moperiod_all = 2 if v215>=129 & v215 <= 156 
replace moperiod_all = 3 if v215>=157 & v215 <= 184 
replace moperiod_all = 4 if v215>=185 & v215 <= 198 
replace moperiod_all = 1 if v215>=201 & v215 <= 204 
replace moperiod_all = 2 if v215>=205 & v215 <= 208 
replace moperiod_all = 3 if v215>=209 & v215 <= 213 
replace moperiod_all = 1 if v215==301 
replace moperiod_all = 2 if v215==302 
replace moperiod_all = 3 if v215==303 
replace moperiod_all = 4 if v215==304 
replace moperiod_all = 5 if v215==305 
replace moperiod_all = 6 if v215==306 
replace moperiod_all = 7 if v215==307 
replace moperiod_all = 8 if v215==308 
replace moperiod_all = 9 if v215==309 
replace moperiod_all = 10 if v215==310 
replace moperiod_all = 11 if v215==311 

gen not_pregnant = v213==0


eststo clear
foreach r of numlist 3/5 {
	
	
	eststo model`r': reg v439 v213
	
	foreach i of numlist 1/11 {
		
		sum not_pregnant [aw=v005] if round==`r' & moperiod_all==`i' 
		eststo round`r': estadd scalar prop`i' = r(mean)*100
		
	}
	
}


#delimit ;
esttab round3 round4 round5, 
	stats(prop1 prop2 prop3 prop4 prop5 prop6 prop7 prop8 prop9 prop10 prop11, labels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11")) 
	drop(v213 _cons)
	mtitle("NFHS-3" "NFHS-4" "NFHS-5")
	nonumbers nostar noobs not	;
#delimit cr
	
#delimit ;
esttab round3 round4 round5 using $out_github, replace 
	stats(prop1 prop2 prop3 prop4 prop5 prop6 prop7 prop8 prop9 prop10 prop11, labels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11")) 
	drop(v213 _cons)
	mtitle("NFHS-3" "NFHS-4" "NFHS-5")
	nonumbers nostar noobs not booktabs;
#delimit cr

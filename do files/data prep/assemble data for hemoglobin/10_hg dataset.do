
if "`c(username)'" == "sidhpandit" {
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global nfhs3br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global nfhs3mr "/Users/sidhpandit/Desktop/nfhs/nfhs3mr/IAMR52FL.dta"
	global nfhs4mr "/Users/sidhpandit/Desktop/nfhs/nfhs4mr/IAMR74FL.DTA"
	global nfhs5mr "/Users/sidhpandit/Desktop/nfhs/nfhs5mr/IAMR7EFL.DTA"
	
	global nfhs3hmr "/Users/sidhpandit/Desktop/nfhs/nfhs3hmr/IAPR52FL.DTA"
	global nfhs4hmr "/Users/sidhpandit/Desktop/nfhs/nfhs4hmr/IAPR74FL.DTA"
	global nfhs5hmr "/Users/sidhpandit/Desktop/nfhs/nfhs5hmr/IAPR7EFL.DTA"
	
	global nfhs5cr "/Users/sidhpandit/Desktop/nfhs/nfhs5cr/IAKR7EFL.DTA"
	
}


if "`c(username)'" == "dc42724" {
	
	global ir_combined "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"
	
	global nfhs3br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\br\IABR52FL.dta"
	global nfhs4br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\br\IABR71FL.DTA"
	global nfhs5br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IABR7EDT\IABR7EFL.DTA"
	
	global nfhs3mr ""
	global nfhs4mr ""
	global nfhs5mr ""
	
	global nfhs3hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\hhmr\IAPR52FL.dta"
	global nfhs4hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\hhmr\IAPR71FL.DTA"
	global nfhs5hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAPR7DDT\IAPR7DFL.DTA"
	
}


use $nfhs3hmr
append using $nfhs4hmr
append using $nfhs5hmr

gen round = .
replace round = 3 if hv000 == "IA5"
replace round = 4 if hv000 == "IA6"
replace round = 5 if hv000 == "IA7"


// 1. Create hg variable & source (non/pregnant women, men, children)

gen source = .

* all women (ha55 is 0 when hemoglobin was measured)
gen hg = ha56 if ha55==0

* pregnant women
replace source = 1 if ha55==0 & ha54==1

* non-pregnant women
replace source = 2 if ha55==0 & ha54==0

* children
replace hg = hc56 if hc55==0
replace source = 3 if hc55==0

* men
replace hg = hb56 if hb55==0
replace source = 4 if hb55==0

label define sourcelbl 1 "Pregnant women" 2 "Non-pregnant women" 3 "Children" 4 "Men"
label values source sourcelbl


// 2. Get CDC for everyone

* first fix invalid dates (ie. June 31st).

gen hv016_fixed = hv016
replace hv016_fixed = 30 if inlist(hv006, 4, 6, 9, 11) & hv016 == 31 // Apr, Jun, Sep, Nov
replace hv016_fixed = 28 if hv006 == 2 & hv016 > 28 // crude Feb fix; safe if no leap year data

gen CDCcode = mdy(hv006, hv016_fixed, hv007) + 21916



// 3. Make sure state is coded the same for all 3 rounds
*run the 11_statedistrict_match do file

//4. Clean the hg measurements
replace hg=. if hg>900
replace hg=hg/10

// 4. Create a time variable (pref use time of 3rd BP reading - hg testing is immediately after)
gen consent_bp3 = shb25
replace consent_bp3 = shb23 if hv000=="IA7"

* in NFHS-5 we have shb28 (hhmm, 24 hour clock)
gen hour_bp3 = floor(shb28 / 100) if hv000=="IA7"
gen minutes_bp3 = mod(shb28, 100) if hv000=="IA7"

* in NFHS-4 we have shb26h (time, hour) and shb26m (time, minutes)
replace hour_bp3 = shb26h if hv000 == "IA6"
replace minutes_bp3 = shb26m if hv000 == "IA6"

* make one variable
gen time_minutes_bp3 = hour_bp3*60 + minutes_bp3
gen time_decimal_bp3 = hour_bp3 + minutes_bp3/60

// gen time_minutes = shb26h * 60 + shb26m shb26h
// gen time_decimal = shb26h + shb26m/60 if hv000 == "IA6"
//
// replace time_minutes = shb28_hour * 60 + shb28_min if hv000 == "IA7"
// replace time_decimal = shb28_hour + shb28_min/60 if hv000 == "IA7"


* if missing time of third BP reading, fill in with time of second
gen consent_bp2 = shb21
replace consent_bp2 = shb23 if hv000=="IA7"

gen hour_bp2 = floor(shb24 / 100) if hv000=="IA7"
gen minutes_bp2 = mod(shb24, 100) if hv000=="IA7"

replace hour_bp2 = shb26h if hv000 == "IA6"
replace minutes_bp2 = shb26m if hv000 == "IA6"

gen time_minutes_bp2 = hour_bp2*60 + minutes_bp2
gen time_decimal_bp2 = hour_bp2 + minutes_bp2/60




* if still missing, fill in with time of first?

gen hour_bp1 = floor(shb17 / 100) if hv000=="IA7"
gen minutes_bp1 = mod(shb17, 100) if hv000=="IA7"

replace hour_bp1 = shb15h if hv000 == "IA6"
replace minutes_bp1 = shb15m if hv000 == "IA6"

gen time_minutes_bp1 = hour_bp1*60 + minutes_bp1
gen time_decimal_bp1 = hour_bp1 + minutes_bp1/60


* create single var

gen time_minutes = time_minutes_bp3 if !missing(time_minutes_bp3)
gen time_decimal = time_decimal_bp3 if !missing(time_decimal_bp3)
gen consent = consent_bp3

replace time_minutes = time_minutes_bp2 if missing(time_minutes) & !missing(time_minutes_bp2)
replace time_decimal = time_decimal_bp2 if missing(time_decimal) & !missing(time_decimal_bp2)
replace consent = consent_bp2 if missing(consent)

replace time_minutes = time_minutes_bp1 if missing(time_minutes) & !missing(time_minutes_bp1)
replace time_decimal = time_decimal_bp1 if missing(time_decimal) & !missing(time_decimal_bp1)

gen timevar_missing = missing(time_minutes)



// 5. Generate svy variables

egen strata = group(hv000 hv024 hv025) 
egen psu = group(hv000 hv001 hv024 hv025)




gen sc = sh46==1 if inlist(round,3,5)
gen st = sh46==2 if inlist(round,3,5)
gen obc = sh46==3 if inlist(round,3,5)
gen forward = sh46==4 if inlist(round,3,5)

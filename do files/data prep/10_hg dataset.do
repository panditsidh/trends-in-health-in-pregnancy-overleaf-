
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

* all women
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



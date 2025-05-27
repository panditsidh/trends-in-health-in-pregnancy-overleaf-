* This code generates the reweighting variables for a single survey round. 


* To test on a single survey round, uncomment these lines and replace file paths
// use caseid s46 v* using "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/IAIR52FL.dta", clear
// global nfhs_br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"


* gen months since last period for currently pregnant women
gen moperiod = .
replace moperiod = 1 if v215>=101 & v215 <= 128 & v213==1
replace moperiod = 2 if v215>=129 & v215 <= 156 & v213==1
replace moperiod = 3 if v215>=157 & v215 <= 184 & v213==1
replace moperiod = 4 if v215>=185 & v215 <= 198 & v213==1
replace moperiod = 1 if v215>=201 & v215 <= 204 & v213==1
replace moperiod = 2 if v215>=205 & v215 <= 208 & v213==1
replace moperiod = 3 if v215>=209 & v215 <= 213 & v213==1
replace moperiod = 1 if v215==301 & v213==1
replace moperiod = 2 if v215==302 & v213==1
replace moperiod = 3 if v215==303 & v213==1
replace moperiod = 4 if v215==304 & v213==1
replace moperiod = 5 if v215==305 & v213==1
replace moperiod = 6 if v215==306 & v213==1
replace moperiod = 7 if v215==307 & v213==1
replace moperiod = 8 if v215==308 & v213==1
replace moperiod = 9 if v215==309 & v213==1
replace moperiod = 10 if v215==310 & v213==1
replace moperiod = 11 if v215==311 & v213==1

* compare to self reported duration of current pregnancy
gen diff = moperiod-v214

* gen gestational duration using moperiod if avaliable
gen mopreg = moperiod
replace mopreg = v214 if mopreg==.

* gen preg, an indicator for 3+ mo gestational duration
gen preg= mopreg > 3
replace preg=. if mopreg==.	


* gen using modern method of contraception indicator
gen vcal_1_trim = trim(vcal_1)
gen done = 0
gen isnumber = .
gen answer = .
forvalues i = 1(1)15 {
	gen month`i' = substr(vcal_1_trim,`i',1)
	replace isnumber = real(month`i')
	replace answer = isnumber if isnumber !=.&done==0
	replace done = 1 if done == 0 & isnumber !=.
}
gen modernmethod = .
replace modernmethod = 0 if answer==0 | answer ==8 | answer==9
replace modernmethod = 1 if answer>0 & answer <8 

* gen sterilized, don't include in reweighting bc no "risk" of pregnancy
gen sterilized = answer==6 | answer ==7
// drop if sterilized==1

* gen education indicators
gen lessedu= (v106==0| v106==1)
replace lessedu = . if v106==.

gen educ_none      = v106 == 0  // no education
gen educ_primary   = v106 == 1  // primary
gen educ_secondary = v106 == 2  // secondary
gen educ_higher    = v106 == 3  // higher

label var educ_none      "No education"
label var educ_primary   "Primary education"
label var educ_secondary "Secondary education"
label var educ_higher    "Higher education"
	
* gen age categories
gen age_10 = v013
replace age_10=4 if v013==5
replace age_10=6 if v013==7


/* gen age/breastfeeding status of youngest child (if any)
	1 less than two and BF
	2 less than two and not BF 
	3 two to five
	4 five plus (removed) 
	
	for pregnant women - age of youngest child at start of pregnancy */

preserve

	clear all 
	use $nfhs_br

	bysort caseid: egen maxbord=max(bord)
	gen youngest = bord==maxbord

	by caseid: egen noalive=total(b5)

	keep if youngest == 1
	keep caseid v213 youngest noalive bord b0 b3 b5 b7 b8 m4
	
	tempfile nfhs_youngest
	save `nfhs_youngest'

restore

merge 1:1 caseid using `nfhs_youngest' // drop children wo mothers
drop if _merge == 2
gen youngest_status=.
replace youngest_status = 0 if v213==1 & v218==0 


* pregnant women
gen agetoday=v008-b3
gen ageatpreg=.
replace ageatpreg=agetoday-mopreg if mopreg>3 & v213==1 

gen bfatpreg=.
replace bfatpreg=1 if youngest==1 & m4==95 & v213==1
replace bfatpreg=1 if m4>=ageatpreg & m4<61 & v213==1
replace youngest_status = 1 if v213==1 & youngest==1 & ageatpreg<24 & bfatpreg==1 & v218!=0
replace youngest_status = 2 if v213==1 & youngest==1 & ageatpreg<24 & bfatpreg==. & v218!=0
replace youngest_status = 3 if v213==1 & youngest==1 & ageatpreg>=24 & v218!=0

* nonpregnant women
replace youngest_status = 0 if v213==0 & v218==0 
gen bfnow=.
replace bfnow=1 if youngest==1 & m4==95 & v213==0
replace youngest_status = 1 if v213==0 & youngest==1 & agetoday<24 & bfnow==1 & v218!=0
replace youngest_status = 2 if v213==0 & youngest==1 & agetoday<24 & bfnow==. & v218!=0
replace youngest_status = 3 if v213==0 & youngest==1 & agetoday>=24 & v218!=0
*replace youngest_status = 4 if v213==0 & youngest==1 & agetoday>=60 & v218!=0


* gen child died in past 5 years (including those who never had a child)
preserve
	clear all
	use $nfhs_br
	sort caseid
	gen timeagodied = v008-b3
	gen diedpastfiveyr= timeagodied<60 & b5==0
	by caseid: egen diedpast5yr = max(diedpastfiveyr)
	collapse diedpast5yr, by(caseid)
	tab diedpast5yr, m
	
	tempfile nfhs_dead
	save `nfhs_dead'
restore

rename _merge merge1
merge 1:1 caseid using `nfhs_dead'
drop if _merge == 2
gen childdied = diedpast5yr==1

* gen number of living children
gen noliving = v218
replace noliving = 4 if v218>3
replace noliving = . if v218==.

* gen urban/ rural
gen urban = v025 == 1
gen rural = v025==2

* gen has a living boy indicator
gen hasboy = v202 >0 & v202!=.
replace hasboy = 1 if v204 >0 & v204!=.


* gen reweights using all predictors for bins

egen bin_all=group(modernmethod lessedu age_10 urban youngest_status noliving childdied hasboy) if sterilized==0
gen counter=1


preserve
	collapse (sum) counter (mean) modernmethod lessedu age_10 urban youngest_status noliving childdied hasboy, by(bin_all v213)
	drop if bin_all == .
	reshape wide counter, i(bin_all) j(v213)
	replace counter0 = 0 if counter0 == .
	replace counter1 = 0 if counter1 == .
	count if counter0==0&counter1>0 
// 	list counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0
// 	list bin counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0

	gen dropbin_all = counter0==0&counter1>0
// 	tab dropbin_all, m
	keep bin_all dropbin_all
	
	tempfile dropbins_all
	save `dropbins_all'
restore

merge m:1 bin_all using `dropbins_all', gen(dropbins_all_merge)

replace dropbin_all=1 if sterilized==1

egen pregweight_all = sum(v005) if v213 == 1.& dropbin_all!=1, by(bin_all)
egen nonpregweight_all = sum(v005) if v213 == 0 & dropbin_all!=1, by(bin_all)
egen transferpreg_all = mean(pregweight_all) if dropbin_all!=1, by(bin_all)
egen transfernonpreg_all = mean(nonpregweight_all) if dropbin_all!=1, by(bin_all)

gen reweightingfxn_all = v005*transferpreg_all/transfernonpreg_all if dropbin_all!=1

* gen reweights using single year age as bins
gen bin_age=v012 if sterilized==0

preserve
	collapse (sum) counter, by(bin_age v213)
	drop if bin_age == .
	reshape wide counter, i(bin_age) j(v213)
	replace counter0 = 0 if counter0 == .
	replace counter1 = 0 if counter1 == .
	count if counter0==0&counter1>0 

	gen dropbin_age = counter0==0&counter1>0

	keep bin_age dropbin_age
	
	tempfile dropbins_age
	save `dropbins_age'
restore

merge m:1 bin_age using `dropbins_age', gen(dropbins_age_merge)
// drop if dropbin_age==1
// drop dropbin_age

replace dropbin_age=1 if sterilized==1

egen pregweight_age = sum(v005) if v213 == 1 & dropbin_age==0, by(bin_age)
egen nonpregweight_age = sum(v005) if v213 == 0 & dropbin_age==0, by(bin_age)
egen transferpreg_age = mean(pregweight_age) if dropbin_age==0, by(bin_age)
egen transfernonpreg_age = mean(nonpregweight_age) if dropbin_age==0, by(bin_age)


* 560 missing observations - fewer age bins in which there are no pregnant women 
gen reweightingfxn_age = v005*transferpreg_age/transfernonpreg_age if dropbin_age==0

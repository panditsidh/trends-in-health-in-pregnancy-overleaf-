* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global nfhs3ir "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/IAIR52FL.dta"
	global nfhs4ir "/Users/sidhpandit/Desktop/nfhs/nfhs4ir/IAIR74FL.DTA"	
	global nfhs5ir "/Users/sidhpandit/Desktop/nfhs/nfhs5ir/IAIR7EFL.DTA"
	
	global nfhs3br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global nfhs3_youngest "/Users/sidhpandit/Desktop/nfhs/nfhs3br/nfhs3_youngest.dta"
	global nfhs4_youngest "/Users/sidhpandit/Desktop/nfhs/nfhs4br/nfhs4_youngest.DTA"
	global nfhs5_youngest "/Users/sidhpandit/Desktop/nfhs/nfhs5br/nfhs5_youngest.DTA"
	
	global nfhs3_dead "/Users/sidhpandit/Desktop/nfhs/nfhs3br/nfhs3_dead.dta"
	global nfhs4_dead"/Users/sidhpandit/Desktop/nfhs/nfhs4br/nfhs4_dead.DTA"
	global nfhs5_dead"/Users/sidhpandit/Desktop/nfhs/nfhs5br/nfhs5_dead.DTA"
	
	global nfhs3_dropbins "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/dropbins3.DTA"
	global nfhs4_dropbins "/Users/sidhpandit/Desktop/nfhs/nfhs4ir/dropbins4.DTA"
	global nfhs5_dropbins "/Users/sidhpandit/Desktop/nfhs/nfhs5ir/dropbins5.DTA"
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
}


if "`c(username)'" == "diane" {
	global nfhs3ir 
	global nfhs4ir 
	global nfhs5ir 
	
	global nfhs3br 
	global nfhs4br 
	global nfhs5br 
	
	global nfhs3_youngest 
	global nfhs4_youngest 
	global nfhs5_youngest 
	
	global nfhs3_dead 
	global nfhs4_dead 
	global nfhs5_dead 
	
	global nfhs3_dropbins 
	global nfhs4_dropbins 
	global nfhs5_dropbins 
	
	global ir_combined
	
}

global nfhs_ir $nfhs3ir
global nfhs_br $nfhs3br
global nfhs_youngest $nfhs3_youngest
global nfhs_dead $nfhs3_dead
global dropbins $nfhs3_dropbins


foreach x of numlist 3/5 {

	if `x'==3 { 
		global nfhs_ir $nfhs3ir
		global nfhs_br $nfhs3br
		global nfhs_youngest $nfhs3_youngest
		global nfhs_dead $nfhs3_dead
		global dropbins $nfhs3_dropbins
	}
	
	if `x'==4 { 
		global nfhs_ir $nfhs4ir
		global nfhs_br $nfhs4br
		global nfhs_youngest $nfhs4_youngest
		global nfhs_dead $nfhs4_dead
		global dropbins $nfhs4_dropbins
	}
	
	if `x'==5 { 
		global nfhs_ir $nfhs5ir
		global nfhs_br $nfhs5br
		global nfhs_youngest $nfhs5_youngest
		global nfhs_dead $nfhs5_dead
		global dropbins $nfhs5_dropbins
	}



clear all

if `x'==3 {
	use caseid s46* v* using $nfhs_ir	
}


else {
	use caseid s46* v* s236 s220b* using $nfhs_ir	
}



************************** preparing the sample ********************************

* weight in kg variable
replace v437=. if v445>9990 
replace v437=v437/10

* calc months since last period for currently pregnant women
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


* calc months pregnant using moperiod 
gen mopreg = moperiod
replace mopreg = v214 if mopreg==.


* focus on pregnancies after first trimester
gen preg= mopreg > 3
replace preg=. if mopreg==.



********** 1 predictor of pregnancy: not using modern method of contraception **********

gen vcal_1_trim = trim(vcal_1)
gen done = 0
gen isnumber = .
gen answer = .


* go each month thru repd. history, save month of most recent reprd. use in answer
forvalues i = 1(1)15{
	gen month`i' = substr(vcal_1_trim,`i',1)
	replace isnumber = real(month`i')
	replace answer = isnumber if isnumber !=.&done==0
	replace done = 1 if done == 0 & isnumber !=.
}

* drop couples who are sterilized
drop if answer==6 | answer ==7

gen modernmethod = .
replace modernmethod = 0 if answer==0 | answer ==8 | answer==9
replace modernmethod = 1 if answer>0 & answer <8 


********** 2 predictor of pregnancy: none or only primary education *************
gen lessedu= (v106==0| v106==1)
replace lessedu = . if v106==.



********** 3 predictor of pregnancy: age in 10 year groups **********
gen age_10 = v013
replace age_10=4 if v013==5
replace age_10=6 if v013==7


********** 4 predictor of pregnancy: age/breastfeeding status of youngest child **********

* first get youngest child dataset from births recode
preserve

	clear all 
	use $nfhs_br

	bysort caseid: egen maxbord=max(bord)
	gen youngest = bord==maxbord

	by caseid: egen noalive=total(b5)

	keep if youngest == 1
	keep caseid v213 youngest noalive bord b0 b3 b5 b7 b8 m4

	save $nfhs_youngest, replace

restore

* merge, drop children without mothers & mothers without children
merge 1:1 caseid using $nfhs_youngest
drop if _merge == 2
gen youngest_status=.
replace youngest_status = 0 if v213==1 & v218==0 


*-------	pregnant women: youngest status at START of pregnancy	------------
* age of youngest child at start of current pregnancy
gen agetoday=v008-b3
gen ageatpreg=.
replace ageatpreg=agetoday-mopreg if mopreg>3 & v213==1 

* is youngest child still being breastfed (m4==95)
gen bfatpreg=.
replace bfatpreg=1 if youngest==1 & m4==95 & v213==1
replace bfatpreg=1 if m4>=ageatpreg & m4<61 & v213==1 // not sure about this line, what is m4<61
replace youngest_status = 1 if v213==1 & youngest==1 & ageatpreg<24 & bfatpreg==1 & v218!=0
replace youngest_status = 2 if v213==1 & youngest==1 & ageatpreg<24 & bfatpreg==. & v218!=0
replace youngest_status = 3 if v213==1 & youngest==1 & ageatpreg>=24 & v218!=0
*replace youngest_status = 4 if v213==1 & youngest==1 & ageatpreg>=60 & v218!=0

/*
*1 less than two and BF
*2 less than two and not BF 
*3 two to five
*4 five plus (removed)
*/


* ---------------  nonpregnant women: youngest status now	--------------------

replace youngest_status = 0 if v213==0 & v218==0 
gen bfnow=.
replace bfnow=1 if youngest==1 & m4==95 & v213==0
replace youngest_status = 1 if v213==0 & youngest==1 & agetoday<24 & bfnow==1 & v218!=0
replace youngest_status = 2 if v213==0 & youngest==1 & agetoday<24 & bfnow==. & v218!=0
replace youngest_status = 3 if v213==0 & youngest==1 & agetoday>=24 & v218!=0
*replace youngest_status = 4 if v213==0 & youngest==1 & agetoday>=60 & v218!=0

/*
*0 no children
*1 less than two and BF
*2 less than two and not BF 
*3 two plus
*4 five plus 
*/


 
********** 5 predictor of pregnancy: previous child death **********


preserve
	clear all
	use $nfhs_br
	sort caseid
	gen timeagodied = v008-b3
	gen diedpastfiveyr= timeagodied<60 & b5==0
	by caseid: egen diedpast5yr = max(diedpastfiveyr)
	collapse diedpast5yr, by(caseid)
	tab diedpast5yr, m
	save $nfhs_dead, replace
restore

rename _merge merge1
merge 1:1 caseid using $nfhs_dead
drop if _merge == 2 // moms in child death dataset that aren't in individual recode
gen childdied = diedpast5yr==1
*0 no child died in past 5 years (including those who never had a child)
*1 child died in last 5 years




********** 6 predictor of pregnancy: no. of living children **********
gen noliving = v218
replace noliving = 4 if v218>3
replace noliving = . if v218==.

********** 7 predictor of pregnancy: urban/rural **********
gen urban = v025 == 1

********** 8 predictor of pregnancy: has a living boy **********
gen hasboy = v202 >0 & v202!=.
replace hasboy = 1 if v204 >0 & v204!=.



************************** making the bins ********************************


*What are the most important "risk factors" for pregnancy in India?
*Now let's make the bins.
/*
- modern method of contraception: modernmethod (2 bins)
- primary education: lessedu (2 bins, 10 are missing) 
- age: v013 (5 bins, 30-40 is a bin, 40-50 is a bin)
- urban/rural: (2 bins)
- youngest status: (4 bins)
- number of kids: noliving (5 bins, actually 4 since no kids is already included in status of youngest)
- child death: childdied (2 bins, child died in last 5 years, child did not die, or never pregnant)
- living boy hasboy (2 bins)
*/


egen bin=group(modernmethod lessedu v013 urban youngest_status noliving childdied hasboy)
gen counter=1


* drop bins that have only pregnant women
preserve
	collapse (sum) counter (mean) modernmethod lessedu v013 urban youngest_status noliving childdied hasboy, by(bin v213)
	drop if bin == .
	reshape wide counter, i(bin) j(v213)
	replace counter0 = 0 if counter0 == .
	replace counter1 = 0 if counter1 == .
	count if counter0==0&counter1>0 
// 	list counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0
// 	list bin counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0

	gen dropbin = 1 if counter0==0&counter1>0
	tab dropbin, m
	keep bin dropbin
	save $dropbins, replace
restore

rename _merge merge2
merge m:1 bin using $dropbins
drop if dropbin==1
drop dropbin




************************** reweighting using the bins ********************************

*Calculate average BMI of "childbearing" women.
egen pregweight = sum(v005) if v213 == 1, by(bin)
egen nonpregweight = sum(v005) if v213 == 0, by(bin)
egen transferpreg = mean(pregweight), by(bin)
egen transfernonpreg = mean(nonpregweight), by(bin)

gen reweightingfxn = v005*transferpreg/transfernonpreg
sum v437 [aweight=reweightingfxn] if v213 == 0
*AVERAGE WEIGHT OF PRE PREGNANT WOMEN: 45.29



if `x'== 3 {
	tempfile nfhs3
	save `nfhs3'
}

if `x'== 4 {
	tempfile nfhs4
	save `nfhs4'
}

if `x'== 5 {
	tempfile nfhs5
	save `nfhs5'
}



} // giant for loop end



************************** append the survey rounds and gen variables ********************************

append using `nfhs4'
append using `nfhs3'

gen round5=(v000=="IA7")
gen round4=(v000=="IA6")
gen round3=(v000=="IA5")

gen round=5 if round5==1
replace round=4 if round4==1
replace round=3 if round3==1

gen bmi = v445 if v445!=9998 & v445!= 9999
replace bmi = bmi/100


*Calculate weights
egen strata = group(v000 v024 v025) 
egen psu = group(v000 v001 v024 v025)

bysort v000: egen totalwt = total(v005)
gen wt = v005/totalwt



save $ir_combined, replace



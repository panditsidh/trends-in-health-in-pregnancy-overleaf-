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
	use caseid s824b w124 v044 d* s46* v*  using $nfhs_ir	
}


if `x'==4 {
	use caseid s928b s930 s927 v743a* v044 d105a-d105j d129 s907 s908 s116 v* s236 s220b* using $nfhs_ir	
}


if `x'==5 {
	use caseid s930b s932 s929 v743a* v044 d105a-d105j d129 s909 s910 s920 s116 v* s236 s220b* using $nfhs_ir	
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

gen educ_none      = v106 == 0  // no education
gen educ_primary   = v106 == 1  // primary
gen educ_secondary = v106 == 2  // secondary
gen educ_higher    = v106 == 3  // higher

label var educ_none      "No education"
label var educ_primary   "Primary education"
label var educ_secondary "Secondary education"
label var educ_higher    "Higher education"


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
gen rural = v025==2

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

label define roundlbl 3 "NFHS-3 (2005-2006)" 4 "NFHS-4 (2015-2016)" 5 "NFHS-5 (2019-2021)"
label values round roundlbl


gen bmi = v445 if v445!=9998 & v445!= 9999
replace bmi = bmi/100

* Step 1: Define region value labels
label define regionlbl ///
    1 "focus" ///
    2 "central" ///
    3 "east" ///
    4 "west" ///
    5 "north" ///
    6 "south" ///
    7 "northeast"

* Step 2: Generate the numeric variable
gen region = .

* Step 3: NFHS-5 (round == 5)
replace region = 1 if inlist(v024, 9, 10) & round == 5 // UP, Bihar
replace region = 2 if inlist(v024, 23, 22) & round == 5 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21) & round == 5 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30) & round == 5 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1, 2, 3, 5, 6, 8) & round == 5 // J&K, HP, Punjab, Uttarakhand, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28, 29, 32, 33, 36) & round == 5 // AP, Karnataka, Kerala, TN, Telangana
replace region = 7 if inlist(v024, 12, 13, 14, 15, 16, 18) & round == 5 // NE states

* Step 4: NFHS-4 (round == 4)
replace region = 1 if inlist(v024, 33, 5) & round == 4 // UP, Bihar
replace region = 2 if inlist(v024, 19, 7) & round == 4 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 35, 15, 26) & round == 4 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 11, 20, 10) & round == 4 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 14, 13, 28, 12, 34, 6) & round == 4 // J&K, HP, Punjab, Uttarakhand, Delhi, Haryana
replace region = 6 if inlist(v024, 2, 36, 17, 31, 16) & round == 4 // AP, Telangana, Kerala, TN, Karnataka
replace region = 7 if inlist(v024, 3, 23, 24, 21, 32, 22, 4, 30) & round == 4 // NE states

* Step 5: NFHS-3 (round == 3)
replace region = 1 if inlist(v024, 9, 10) & round == 3 // UP, Bihar
replace region = 2 if inlist(v024, 23, 22) & round == 3 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21) & round == 3 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30) & round == 3 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1, 2, 3, 5, 6, 8) & round == 3 // J&K, HP, Punjab, Uttarakhand, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28, 29, 32, 33) & round == 3 // AP, Karnataka, Kerala, TN
replace region = 7 if inlist(v024, 12, 13, 14, 15, 16, 18) & round == 3 // NE states

gen india=1
gen focus = region==1
gen central = region==2
gen east = region==3
gen west = region==4
gen north = region==5
gen south = region==6
gen northeast = region==7


* Step 6: Apply value labels
label values region regionlbl


* Step 1: Create the variable
gen group = .

* Step 2: Hindus by caste
* NFHS-3: caste in s46, religion in v130
replace group = 1 if v130 == 1 & s46 == 4 & round == 3 // Forward Caste
replace group = 2 if v130 == 1 & s46 == 3 & round == 3 // OBC
replace group = 3 if v130 == 1 & s46 == 1 & round == 3 // Dalit
replace group = 4 if v130 == 1 & s46 == 2 & round == 3 // Adivasi

* NFHS-4/5: caste in s116, religion in v130
replace group = 1 if v130 == 1 & s116 == 4 & inlist(round, 4, 5) // Forward Caste
replace group = 2 if v130 == 1 & s116 == 3 & inlist(round, 4, 5) // OBC
replace group = 3 if v130 == 1 & s116 == 1 & inlist(round, 4, 5) // Dalit
replace group = 4 if v130 == 1 & s116 == 2 & inlist(round, 4, 5) // Adivasi

* Step 3: Non-Hindu religion dominates
replace group = 5 if v130 == 2  // Muslim
replace group = 6 if inlist(v130, 3, 4, 6) // Christian, Sikh, Jain

* Step 4: Assign label
label define grouplbl ///
    1 "Forward Caste" ///
    2 "OBC" ///
    3 "Dalit" ///
    4 "Adivasi" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian"

label values group grouplbl

gen forward = group==1
gen obc = group==2
gen dalit = group==3
gen adivasi = group==4
gen muslim = group==5
gen sikh_jain_christian = group==6
gen other_group = missing(group)

label var forward "Forward"
label var obc "OBC"
label var dalit "Dalit"
label var adivasi "Adivasi"
label var muslim "Muslim"
label var sikh_jain_christian "Sikh, Jain or Christian"
label var other_group "Other social group"


* husband away 6 mo is only asked for women who say yes to husband away 1 month

gen husband_away1mo = s907 if round==4
replace husband_away1mo = s909 if round==5
label var husband_away1mo "Husband away for 1+ mo. in last year"

gen husband_away6mo = s908 if round==4
replace husband_away6mo = s910 if round==5
replace husband_away6mo = 0 if husband_away1mo==0
label var husband_away6mo "Husband away for 6+ mo. in last year"

gen health_facility_alone = s824b==1 if round==3 & !missing(s824b)
replace health_facility_alone = s928b==1 if round==4 & !missing(s928b)
replace health_facility_alone = s930b==1 if round==5 & !missing(s930b)
label var health_facility_alone "Can go to health facility alone"

gen own_money = w124==1 if round==3 & !missing(w124)
replace own_money = s927==1 if round==4 & !missing(s930)
replace own_money = s929==1 if round==5 & !missing(s932)
label var own_money "Has money she can decide how to use"

gen healthdecide_alone = v743a==1 if !missing(v743a)
gen healthdecide_whusb = v743a==2 if !missing(v743a)
gen healthdecide_husband = v743a==4 if !missing(v743a)
gen healthdecide_else = v743a==5 if !missing(v743a)
gen healthdecide_other = v743a==6 if !missing(v743a)

label variable healthdecide_alone "own healthcare: Respondent alone"
label variable healthdecide_whusb "own healthcare: Respondent + husband"
label variable healthdecide_husband "own healthcare: Husband alone"
label variable healthdecide_else "own healthcare: Someone else"
label variable healthdecide_other "own healthcare: Other"

gen dv_section_incomplete = inlist(v044, 2,3) & v044!=0
label variable dv_section_incomplete "Couldn't answer DV section"

egen physical_dv = anymatch(d105a-d105j), values(1 2)
label variable physical_dv "Experienced physical violence in last 12 months"

gen afraidof_husband = inlist(d129,1,2) if !missing(d129)
label variable afraidof_husband "Afraid of husband some or most of the time"

gen mobile_phone = s932 if round==5
replace mobile_phone = s930 if round==4
label variable mobile_phone "Has own mobile phone"


gen currently_working = v714==1 if !missing(v714)
label variable currently_working "Currently working"

gen any_work = inlist(v731,1,2,3) if !missing(v731)
label variable any_work "Worked in last 12 months"

* paid work is only asked for any_work ==1
gen paid_work = inlist(v741,1,2,3) if !missing(v741)
label variable paid_work "Paid in cash or in-kind for work"

*Calculate weights
egen strata = group(v000 v024 v025) 
egen psu = group(v000 v001 v024 v025)

bysort v000: egen totalwt = total(v005)
gen wt = v005/totalwt



save $ir_combined, replace



if "`c(username)'" == "sidhpandit" {
	global nfhs3ir "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/IAIR52FL.dta"
	global nfhs4ir "/Users/sidhpandit/Desktop/nfhs/nfhs4ir/IAIR74FL.DTA"	
	global nfhs5ir "/Users/sidhpandit/Desktop/nfhs/nfhs5ir/IAIR7EFL.DTA"
	
	global nfhs3br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
}

if "`c(username)'" == "dc42724" {
	global nfhs3ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\ir\IAIR52FL.dta"
	global nfhs4ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\ir\IAIR71FL.DTA"
	global nfhs5ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAIR7DDT\IAIR7DFL.DTA"
	
	global nfhs3br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\br\IABR52FL.dta"
	global nfhs4br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\br\IABR71FL.DTA"
	global nfhs5br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IABR7EDT\IABR7EFL.DTA"

	global ir_combined "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"
	
}

/*

For graphs/tables that don't need reweighting, 

Reweighting steps

for pregnant women, gen
- mopreg
- moperiod

for all women, gen
- modernmethod
- edu vars
- age in 10 year bins
- youngest status (4 categories based on age & bf status)
		* use a tempfile for this
- previous child death
		* use a tempfile for this
- no. living children
- urban/rural
- has living boy

create bins, based on
- all predictors
- age, single year
- find bins that have only pregnant women
		* use a tempfile for this
		* instead of dropping observations in dropbins, just don't	 	generate weights for them
- generate weights

*/


* initialize general ir and br file paths - the loop will reassign them to the corresponding survey round
global nfhs_ir $nfhs3ir
global nfhs_br $nfhs3br


foreach x of numlist 3/5 {
	
clear all

if `x'==3 { 
		global nfhs_ir $nfhs3ir
		global nfhs_br $nfhs3br
		
		use caseid s824b w124 v044 d* s46* v*  using $nfhs_ir	
	}
	
	if `x'==4 { 
		global nfhs_ir $nfhs4ir
		global nfhs_br $nfhs4br
		
		use caseid s928b s930 s927 v743a* v044 d105a-d105j d129 s907 s908 s116 v* s236 s220b* ssmod sb* using $nfhs_ir
	}
	
	if `x'==5 { 
		global nfhs_ir $nfhs5ir
		global nfhs_br $nfhs5br
		
		use caseid s930b s932 s929 v743a* v044 d105a-d105j d129 s909 s910 s920 s116 v* s236 s220b* ssmod sb* using $nfhs_ir	

}


	
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

egen bin_all=group(modernmethod lessedu v013 urban youngest_status noliving childdied hasboy)
gen counter=1

preserve
	collapse (sum) counter (mean) modernmethod lessedu v013 urban youngest_status noliving childdied hasboy, by(bin_all v213)
	drop if bin_all == .
	reshape wide counter, i(bin_all) j(v213)
	replace counter0 = 0 if counter0 == .
	replace counter1 = 0 if counter1 == .
	count if counter0==0&counter1>0 
// 	list counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0
// 	list bin counter1 modernmethod lessedu v013 urban youngest_status noliving childdied hasboy if counter0==0&counter1>0

	gen dropbin_all = 1 if counter0==0&counter1>0
// 	tab dropbin_all, m
	keep bin_all dropbin_all
	
	tempfile dropbins_all
	save `dropbins_all'
restore

merge m:1 bin_all using `dropbins_all', gen(dropbins_all_merge)

egen pregweight_all = sum(v005) if v213 == 1 & dropbin_all==0, by(bin_all)
egen nonpregweight_all = sum(v005) if v213 == 0 & dropbin_all==0, by(bin_all)
egen transferpreg_all = mean(pregweight_all) if dropbin_all==0, by(bin_all)
egen transfernonpreg_all = mean(nonpregweight_all) if dropbin_all==0, by(bin_all)

gen reweightingfxn_all = v005*transferpreg_all/transfernonpreg_all if dropbin_all==0

* gen reweights using single year age as bins

gen bin_age=v012

preserve
	collapse (sum) counter, by(bin_age v213)
	drop if bin_age == .
	reshape wide counter, i(bin_age) j(v213)
	replace counter0 = 0 if counter0 == .
	replace counter1 = 0 if counter1 == .
	count if counter0==0&counter1>0 

	gen dropbin_age = 1 if counter0==0&counter1>0

	keep bin_age dropbin_age
	
	tempfile dropbins_age
	save `dropbins_age'
restore

merge m:1 bin_age using `dropbins_age', gen(dropbins_age_merge)
// drop if dropbin_age==1
// drop dropbin_age

egen pregweight_age = sum(v005) if v213 == 1 & dropbin_age==0, by(bin_age)
egen nonpregweight_age = sum(v005) if v213 == 0 & dropbin_age==0, by(bin_age)
egen transferpreg_age = mean(pregweight_age) if dropbin_age==0, by(bin_age)
egen transfernonpreg_age = mean(nonpregweight_age) if dropbin_age==0, by(bin_age)

gen reweightingfxn_age = v005*transferpreg_age/transfernonpreg_age if dropbin_age==0


* save current survey round IR with generated variables to stack later 
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

}


append using `nfhs4'
append using `nfhs3'

*there is a dataset generated at the end of this command 
*survey rounds for loop end, now stack and generate all other variables
* use "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta" from here


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

* gen weight in kg
replace v437=. if v445>9990 
replace v437=v437/10


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
gen groups6 = .
*This follows the groups8 variable from the IHDS.  A potential difference is that it codes people who didn't know/didn't answer the caste question as forward caste if they say they are Hindu.  it does not do this for other religions.

* Step 2: Hindus by caste
* NFHS-3: caste in s46, religion in v130
replace groups6 = 3 if s46 == 1 & round == 3 // Dalit
replace groups6 = 4 if s46 == 2 & round == 3 // Adivasi
replace groups6 = 5 if v130 == 2 & groups6==. &round==3  // Muslim
replace groups6 = 6 if (v130 == 3| v130==4 | v130==6) & groups6==. &round==3 // Christian, Sikh, Jain
replace groups6 = 2 if (v130 == 1 |v130==4) & s46 == 3 & round == 3 // OBC - hindu and sikh
replace groups6 = 1 if v130 == 1 & (s46 == 4 |s46==8 |s46==9 |s46==.) & round == 3 // Forward Caste


* NFHS-4/5: caste in s116, religion in v130
replace groups6 = 3 if s116 == 1 & inlist(round, 4, 5) // Dalit
replace groups6 = 4 if s116 == 2 & inlist(round, 4, 5) // Adivasi
replace groups6 = 5 if v130 == 2 & groups6==. & inlist(round, 4, 5)  // Muslim
replace groups6 = 6 if (v130 == 3| v130==4 | v130==6) & groups6==. & inlist(round, 4, 5) // Christian, Sikh, Jain
replace groups6 = 2 if (v130 == 1 |v130==4) & s116 == 3 & inlist(round, 4, 5) // OBC - hindu and sikh
replace groups6 = 1 if v130 == 1 & (s116 == 4 | s116==8 |s116==.) & inlist(round, 4, 5) // Forward Caste

tab round groups6 if v213==1 [aweight=v005], row m

* Step 4: Assign label
label define grouplbl ///
    1 "Forward Caste" ///
    2 "OBC" ///
    3 "Dalit" ///
    4 "Adivasi" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian"

label values groups6 groups6lbl

gen forward = groups6==1
gen obc = groups6==2
gen dalit = groups6==3
gen adivasi = groups6==4
gen muslim = group==5
gen sikh_jain_christian = groups6==6
gen other_group = missing(groups6)

label var forward "Forward"
label var obc "OBC"
label var dalit "Dalit"
label var adivasi "Adivasi"
label var muslim "Muslim"
label var sikh_jain_christian "Sikh, Jain or Christian"
label var other_group "Other social group"

*Need a variable that indicates than an

* husband away 6 mo is only asked for women who say yes to husband away 1 month

gen husband_away1mo = s907 if round==4
// tab husband_away1mo if round==4, m

replace husband_away1mo = s909 if round==5
// tab husband_away1mo, m if nfhs5==1

label var husband_away1mo "Husband away for 1+ month in last year"

gen husband_away6mo = s908 if round==4
replace husband_away6mo = s910 if round==5
replace husband_away6mo = 0 if husband_away1mo==0
replace husband_away6mo = . if husband_away1mo==.

* because missings might be coded as 9 which affects the mean
tab husband_away6mo, m

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
replace physical_dv = . if v044!=1
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

*blood pressure
*only measured in NFHS 4 and 5
*This way of coding blood pressure marks diastolic and systolic BP over 300 as missing, and uses the average of 3 observations if none are missing and all are below 300.  If one is missing, it uses the average of the other two.  If two are not available, it uses whatever single observation is available.
*I think we should drop systolic pressures over

gen bp_d = .
replace bp_d = sb18d if sb18d < 300 & round==5
replace bp_d = sb25d if sb25d < 300 & bp_d ==. & round==5
replace bp_d = sb29d if sb29d < 300 & bp_d ==. & round==5
replace bp_d = (sb18d + sb25d)/2 if sb18d < 300 & sb25d < 300 & round==5
replace bp_d = (sb18d + sb29d)/2 if sb18d < 300 & sb29d < 300 & round==5
replace bp_d = (sb29d + sb25d)/2 if sb29d < 300 & sb25d < 300 & round==5
replace bp_d = (sb18d + sb25d + sb29d)/3 if sb18d < 300 & sb25d < 300 & sb29d < 300 & round==5

replace bp_d = sb16d if sb16d < 300 & round==4
replace bp_d = sb23d if sb23d < 300 & bp_d ==. & round==4
replace bp_d = sb27d if sb27d < 300 & bp_d ==. & round==4
replace bp_d = (sb16d + sb23d)/2 if sb16d < 300 & sb23d < 300 & round==4
replace bp_d = (sb16d + sb27d)/2 if sb16d < 300 & sb27d < 300 & round==4
replace bp_d = (sb27d + sb23d)/2 if sb27d < 300 & sb23d < 300 & round==4
replace bp_d = (sb16d + sb23d + sb27d)/3 if sb16d < 300 & sb23d < 300 & sb27d < 300 & round==4


gen bp_s = .
replace bp_s = sb18s if sb18s < 300 & round==5 
replace bp_s = sb25s if sb25s < 300 & bp_s ==. & round==5
replace bp_s = sb29s if sb29s < 300 & bp_s ==. & round==5
replace bp_s = (sb18s + sb25s)/2 if sb18s < 300 & sb25s < 300 & round==5
replace bp_s = (sb18s + sb29s)/2 if sb18s < 300 & sb29s < 300 & round==5
replace bp_s = (sb29s + sb25s)/2 if sb29s < 300 & sb25s < 300 & round==5
replace bp_s = (sb18s + sb25s + sb29s)/3 if sb18s < 300 & sb25s < 300 & sb29s < 300 & round==5

replace bp_s = sb16s if sb16s < 300 & round==4
replace bp_s = sb23s if sb23s < 300 & bp_s ==. & round==4
replace bp_s = sb27s if sb27s < 300 & bp_s ==. & round==4
replace bp_s = (sb16s + sb23s)/2 if sb16s < 300 & sb23s < 300 & round==4
replace bp_s = (sb16s + sb27s)/2 if sb16s < 300 & sb27s < 300 & round==4
replace bp_s = (sb27s + sb23s)/2 if sb27s < 300 & sb23s < 300 & round==4
replace bp_s = (sb16s + sb23s + sb27s)/3 if sb16s < 300 & sb23s < 300 & sb27s < 300 & round==4

*I think we should drop the 250 but the others look right, we need to come up with a rule that covers this.
list bp_s if bp_s > 200 & bp_s!=. & v213==1

*No pregnant women have diastolic over 200.
list bp_d if bp_d > 200 & bp_d!=. & v213==1

gen age_in_mo_at_survey = (v008-v011)/12


*Calculate weights
egen strata = group(v000 v024 v025) 
egen psu = group(v000 v001 v024 v025)

bysort v000: egen totalwt = total(v005)
gen wt = v005/totalwt

save $ir_combined, replace

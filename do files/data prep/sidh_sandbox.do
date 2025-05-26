
* this code generates all variables besides the reweighting ones

if "`c(username)'" == "sidhpandit" {
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
}

if "`c(username)'" == "dc42724" {
	global ir_combined "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"

	
}

* to test, uncomment the following line(s). 
use $ir_combined, clear
drop round5-wt
label drop roundlbl regionlbl grouplbl


gen round5=(v000=="IA7")
gen round4=(v000=="IA6")
gen round3=(v000=="IA5")

gen round=5 if round5==1
replace round=4 if round4==1
replace round=3 if round3==1

label define roundlbl 3 "NFHS-3 (2005-2006)" 4 "NFHS-4 (2015-2016)" 5 "NFHS-5 (2019-2021)"
label values round roundlbl

gen state_module = ssmod
gen ssmod_placeholder = 1 if round==3
replace ssmod_placeholder = ssmod if inlist(round,4,5)


gen age_in_mo_at_survey = (v008-v011)/12

************************************ HEALTH ************************************


gen bmi = v445 if v445!=9998 & v445!= 9999
replace bmi = bmi/100

replace v437=. if v445>9990 
replace v437=v437/10


****************************** BLOOD PRESSURE ***********************************

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

twoway (kdensity bp_s if round==4) (kdensity bp_s if round==5), legend(label(1 "NFHS-4" 2 "NFHS-5"))

*I think we should drop the 250 but the others look right, we need to come up with a rule that covers this.
list bp_s if bp_s > 200 & bp_s!=. & v213==1

*No pregnant women have diastolic over 200.
list bp_d if bp_d > 200 & bp_d!=. & v213==1


************************************ REGION ************************************

label define regionlbl ///
    1 "focus" ///
    2 "central" ///
    3 "east" ///
    4 "west" ///
    5 "north" ///
    6 "south" ///
    7 "northeast"

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


******************************** SOCIAL GROUP **********************************


* caste breakdown within Muslim, Christian, Sikh, Jain 


gen caste = s116 if inlist(round,4,5)
replace caste = s46 if round==3

label define caste_lbl ///
    1 "Scheduled Caste" ///
    2 "Scheduled Tribe" ///
    3 "Other Backward Class" ///
    4 "None of the Above" ///
    8 "Don't Know"

label values caste caste_lbl

* should OBC take precedence over religion when Muslim, C/S/J?
* caste breakdown of C/S/J
tab caste if inlist(v130,2,3,4) [aw=wt], m
// 37.53% OBC
// 34.94% none of the above
// 13.3% missing 


* caste breakdown of Muslims
tab caste if inlist(v130,2) [aw=wt], m
// 42.51% OBC
// 36.37% none of the above
// 16.18% missing

* religion breakdown of 'idk' caste
tab v130 if caste==8 [aw=wt]


* should Hindus who answer don't know to caste be coded as forward?

* religion breakdown within "don't know"
tab v130 if caste==8 [aw=wt]
// 70% Hindu
// 26% Muslim

* education breakdown of 'idk caste' among Hindus
tab v106 if caste==8 & v130==1 [aw=wt]

* education breakdown of upper caste Hindus
tab v106 if caste==4 & v130==1 [aw=wt]

* education breakdown of SC/ST
tab v106 if inlist(caste,1,2) & v130==1 [aw=wt]

// distribution of education among caste idk looks more like SC/ST than forward 
// decided to code them as missing then

* 3 - Dalit 
* 4 - Adivasi 
* 5 - Muslim (not SC/ST)
* 6 - Christian/Sikh/Jain (not SC/ST)
* 2 - OBC (only Hindus & Sikhs)
* 1 - forward (only Hindus)


* Step 1: Create the variable
gen groups6 = .
*This follows the groups8 variable from the IHDS.  A potential difference is that it codes people who didn't know/didn't answer the caste question as forward caste if they say they are Hindu.  it does not do this for other religions.

* Step 2: Hindus by caste
* NFHS-3: caste in s46, religion in v130
replace groups6 = 3 if s46 == 1 & round == 3 // Dalit
replace groups6 = 4 if s46 == 2 & round == 3 // Adivasi
replace groups6 = 5 if v130 == 2 & groups6==. &round==3  // Muslim (if not alr Dalit/Adivasi)
replace groups6 = 6 if (v130 == 3| v130==4 | v130==6) & groups6==. &round==3 // Christian, Sikh, Jain (if not alr Dalit/Adivasi)
replace groups6 = 2 if (v130 == 1 |v130==4) & s46 == 3 & round == 3 // OBC - Hindu and Sikh
replace groups6 = 1 if v130 == 1 & (s46 == 4 |s46==9 |s46==.) & round == 3 // Forward Caste if Hindu & not SC, ST or OBC (even don't know)
replace groups6 = . if v130 == 1 & s46==8 // Hindus who don't know their caste

* NFHS-4/5: caste in s116, religion in v130
replace groups6 = 3 if s116 == 1 & inlist(round, 4, 5) // Dalit
replace groups6 = 4 if s116 == 2 & inlist(round, 4, 5) // Adivasi
replace groups6 = 5 if v130 == 2 & groups6==. & inlist(round, 4, 5)  // Muslim
replace groups6 = 6 if (v130 == 3| v130==4 | v130==6) & groups6==. & inlist(round, 4, 5) // Christian, Sikh, Jain
replace groups6 = 2 if (v130 == 1 |v130==4) & s116 == 3 & inlist(round, 4, 5) // OBC - hindu and sikh
replace groups6 = 1 if v130 == 1 & (s116 == 4 |s116==.) & inlist(round, 4, 5) // Forward Caste
replace groups6 = . if v130 == 1 & s116==8 // Hindus who don't know their caste

tab round groups6 if v213==1 [aweight=v005], row m

* alternative grouping that gives precendence to OBC
gen groups6_obc = groups6
replace groups6_obc = 2 if caste==3

* Step 4: Assign label
label define grouplbl ///
    1 "Forward Caste" ///
    2 "OBC" ///
    3 "Dalit" ///
    4 "Adivasi" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian"

label values groups6 groups6lbl
label values groups6_obc groups6lbl

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


******************************** WOMEN'S STATUS ********************************

* The following questions are only asked of those selected for DV module 
// bysort round: tab v044, m

gen dv_section_incomplete = inlist(v044, 2,3) & v044!=0
label variable dv_section_incomplete "Couldn't answer DV section"
// bysort round: tab v044, m
// no missings

* This is asked for those who have ever been married or in union
egen physical_dv = anymatch(d105a-d105j), values(1 2)
replace physical_dv = . if v044!=1
label variable physical_dv "Experienced physical violence in last 12 months"
// bysort round: tab d105a if v044==1 & v501!=0, m
// almost no missings

gen afraidof_husband = inlist(d129,1,2) if !missing(d129)
label variable afraidof_husband "Afraid of husband some or most of the time"

bysort round: tab d129 if v044==1, m
// not asked for nfhs3
// 13,716 (17.2%) missing in nfhs4
// 8,469 (11.71%) missing in nfhs5
// COME BACK TO THIS ONE


// The following questions are only asked of those selected for state module in rounds 4 & 5.

// NFHS-4: 122,351 (17.49%) selected for state module
// NFHS-5: 108,785 (15.02%) selected for state module


gen health_facility_alone = s824b==1 if round==3 & !missing(s824b)
// tab s824b if round==3, m // 28 missing in nfhs3

replace health_facility_alone = s928b==1 if round==4 & !missing(s928b)
// tab s928b if round==4 & ssmod==1, m // 0 missing in nfhs4

replace health_facility_alone = s930b==1 if round==5 & !missing(s930b)
// tab s930b if round==5 & ssmod==1, m // 0 missing in nfhs5

label var health_facility_alone "Can go to health facility alone"

gen own_money = w124==1 if round==3 & !missing(w124)
// tab w124 if round==3, m // 9 missing in nfhs3

replace own_money = s927==1 if round==4 & !missing(s927)
// tab s927 if round==4 & ssmod==1, m // 0 missing in nfhs4

replace own_money = s929==1 if round==5 & !missing(s932)
// tab s929 if round==5 & ssmod==1, m // 0 missing in nfhs3

label var own_money "Has money she can decide how to use"

* healthcare decisions is only asked for married women
gen healthdecide_alone = v743a==1 if !missing(v743a)
gen healthdecide_whusb = v743a==2 if !missing(v743a)
gen healthdecide_husband = v743a==4 if !missing(v743a)
gen healthdecide_else = v743a==5 if !missing(v743a)
gen healthdecide_other = v743a==6 if !missing(v743a)
// bysort round: tab v743a if ssmod_placeholder==1 & v501==1, m 
// no missings

label variable healthdecide_alone "own healthcare: Respondent alone"
label variable healthdecide_whusb "own healthcare: Respondent + husband"
label variable healthdecide_husband "own healthcare: Husband alone"
label variable healthdecide_else "own healthcare: Someone else"
label variable healthdecide_other "own healthcare: Other"

gen mobile_phone = s932 if round==5
// tab s932 if ssmod==1 & round==5, m
// no missings

replace mobile_phone = s930 if round==4
// tab s930 if ssmod==1 & round==4, m
// no missings

label variable mobile_phone "Has own mobile phone"

gen currently_working = v714==1 if !missing(v714)
label variable currently_working "Currently working"
// bysort round: tab v714 if ssmod_placeholder==1, m
// 236 missing in nfhs3
// none missing in nfhs4 or 5

gen any_work = inlist(v731,1,2,3) if !missing(v731)
label variable any_work "Worked in last 12 months"
// bysort round: tab v731 if ssmod_placeholder==1, m
// 17 missing in nfhs3
// none missing in nfhs4 or nfhs5


* paid work is only asked for any_work ==1
* code as 0 for any_work==0
gen paid_work = inlist(v741,1,2,3) & !missing(any_work)
// bysort round: tab v741 if ssmod_placeholder==1 & inlist(v731,1,2,3), m
// bysort round: tab paid_work if ssmod_placeholder==1, m
// no missings

label variable paid_work "Paid in cash or in-kind for work"

* husband away 1 mo is only asked for married women
gen husband_away1mo = s907 if round==4
// tab s907 if ssmod==1 & round==4 & v501==1, m
// no missings

replace husband_away1mo = s909 if round==5
// tab s909 if ssmod==1 & round==5 & v501==1, m
// no missings

label var husband_away1mo "Husband away for 1+ month in last year"

* husband away 6 mo is only asked for women who say yes to husband away 1 month
gen husband_away6mo = s908 if round==4
// tab s908 if ssmod==1 & round==4 & s907==1, m
// no missings

replace husband_away6mo = s910 if round==5
// tab s910 if ssmod==1 & round==5 & s909==1, m
// no missings


replace husband_away6mo = 0 if husband_away1mo==0
replace husband_away6mo = . if husband_away1mo==.

label var husband_away6mo "Husband away for 6+ mo. in last year"


*Calculate weights
egen strata = group(v000 v024 v025) 
egen psu = group(v000 v001 v024 v025)

bysort v000: egen totalwt = total(v005)
gen wt = v005/totalwt


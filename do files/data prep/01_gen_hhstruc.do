if "`c(username)'" == "sidhpandit" {
	global nfhs5hr "/Users/sidhpandit/Desktop/nfhs/nfhs5hr/IAHR7EFL.DTA"
	global nfhs4hr "/Users/sidhpandit/Desktop/nfhs/nfhs4hr/IAHR74FL.DTA"
	global nfhs3hr "/Users/sidhpandit/Desktop/nfhs/nfhs3hr/IAHR52FL.dta"	
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	

	global nfhs3hmr "/Users/sidhpandit/Desktop/nfhs/nfhs3hmr/IAPR52FL.DTA"
	
	global nfhs4hmr "/Users/sidhpandit/Desktop/nfhs/nfhs4hmr/IAPR74FL.DTA"
	
	global nfhs5hmr "/Users/sidhpandit/Desktop/nfhs/nfhs5hmr/IAPR7EFL.DTA"
}


* stack hmr 

clear all

use hv000 hv001 hv002 hhid hv101 hv104 using $nfhs4hmr
tempfile nfhs4hmr
save `nfhs4hmr'

use hv000 hv001 hv002 hhid hv101 hv104 using $nfhs5hmr
tempfile nfhs5hmr
save `nfhs5hmr'

use hv000 hv001 hv002 hhid hv101 hv104 using $nfhs3hmr
append using `nfhs4hmr'
append using `nfhs5hmr'

* generate indicators for relation to hh head

gen non_nuclear_member = !inlist(hv101,1,2,3)

gen mother_of_head = hv101==6 & hv104==2
gen father_of_head = hv101==6 & hv104==1

gen mil_of_head = hv101==4 & hv104==2
gen fil_of_head = hv101==4 & hv104==1

gen son_of_head = hv101==3 & hv104==1
gen daughter_of_head = hv101==3 & hv104==2

gen sil_of_head = hv101==7 & hv104==1
gen dil_of_head = hv101==7 & hv104==2

gen brother_of_head = hv101==8 & hv104==1
gen brotherinlaw_of_head = hv101==15 & hv104==1

gen husband_of_head = hv101==2 & hv104==1
gen wife_of_head = hv101==2 & hv104==2

* collapse to hh level

foreach var in non_nuclear_member mother_of_head father_of_head mil_of_head fil_of_head son_of_head daughter_of_head sil_of_head dil_of_head brother_of_head brotherinlaw_of_head husband_of_head wife_of_head {

	bysort hv000 hhid: egen has_`var' = max(`var')
}

rename hv000 v000
rename hv001 v001 
rename hv002 v002

keep v000 v001 v002 ///
     has_non_nuclear_member has_mother_of_head has_father_of_head ///
     has_mil_of_head has_fil_of_head has_son_of_head has_daughter_of_head ///
     has_sil_of_head has_dil_of_head has_brother_of_head has_brotherinlaw_of_head ///
     has_husband_of_head has_wife_of_head

duplicates drop

tempfile hr_combined
save `hr_combined'

* merge into individual recode

use $ir_combined, clear

drop hh_merge sasural-nuclear
merge m:1 v000 v001 v002 using `hr_combined', generate(hh_merge)
drop if hh_merge==2

* generate hh structure variables relative to woman

*********** NUCLEAR ***********
gen nuclear = 0 

* hh head is woman or her husband, and someone besides their child is present
replace nuclear = 1 if inlist(v150,1,2) & has_non_nuclear_member==0

*********** SASURAL: Patrilocal extended with Parents-in-Law ***********
gen sasural = 0
gen joint_patrilocal_pil = 0
gen joint_patrilocal_no_pil = 0

* woman is dil of hh head
replace sasural = 1 if v150==4

* hh head is husband & his parent is present
replace sasural = 1 if v150==2 & (has_mother_of_head==1 | has_father_of_head==1)

* woman is hh head & her parent-in-law is present
replace sasural = 1 if v150==1 & (has_mil_of_head==1 | has_fil_of_head==1)
replace joint_patrilocal_pil=1 if v150==1 & (has_mil_of_head==1 | has_fil_of_head==1)

* woman is sister-in-law of male hh head & his parent is present
replace sasural = 1 if v150==15 & v151==1
replace joint_patrilocal_pil=1 if v150==15 & v151==1 & (has_mother_of_head==1 | has_father_of_head==1)


*********** SASURAL: Patrilocal extended with no Parents-in-Law ***********

* woman is sister-in-law of male hh head & his parents are not present 
replace joint_patrilocal_no_pil=1 if v150==15 & v151==1 & has_mother_of_head==0 & has_father_of_head==0

* woman is hh head & her husband & brother-in-law is present, but no parent in laws
replace sasural = 1 if v150==1 & has_husband_of_head==1 & has_brotherinlaw_of_head==1 & has_mil_of_head==0 & has_fil_of_head==0

replace joint_patrilocal_no_pil=1 if v150==1 & has_husband_of_head==1 & has_brotherinlaw_of_head==1 & has_mil_of_head==0 & has_fil_of_head==0


*********** NATAL ***********
gen natal = 0

* woman is daughter of hh head
replace natal = 1 if v150==3

* woman is sister of hh head
replace natal = 1 if v150==8

* woman is hh head and her brother/parent is present
replace natal = 1 if v150==1 & (has_mother_of_head==1 | has_father_of_head==1 | has_brother_of_head==1)

* woman is granddaughter of hh head
replace natal = 1 if v150==5

*********** OTHER ***********
gen other = nuclear==0 & sasural==0 & natal==0


label variable nuclear         "Observed in nuclear"
label variable sasural         "Observed in sasural"
label variable natal           "Observed in meika"


save $ir_combined, replace

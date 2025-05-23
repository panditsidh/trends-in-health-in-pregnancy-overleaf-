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
gen non_nuclear_member = !inlist(hv101,1,2,3) // someone who is not child or spouse of the hh head
gen non_nuclear_member_who = hv101 if non_nuclear_member==1

gen nnm_code = string(hv101) if !inlist(hv101,1,2,3)

gen mother_of_head = hv101==6 & hv104==2
gen father_of_head = hv101==6 & hv104==1
gen parent_of_head = (mother_of_head==1 | father_of_head==1)

gen mil_of_head = hv101==4 & hv104==2
gen fil_of_head = hv101==4 & hv104==1
gen pil_of_head = (mil_of_head==1 | fil_of_head==1)

gen son_of_head = hv101==3 & hv104==1
gen daughter_of_head = hv101==3 & hv104==2

gen sil_of_head = hv101==7 & hv104==1
gen dil_of_head = hv101==7 & hv104==2
gen sib_inlaw_of_head = (sil_of_head==1 | dil_of_head==1)

gen brother_of_head = hv101==8 & hv104==1
gen sister_of_head = hv101==8 & hv104==2
gen sib_of_head = (brother_of_head==1 | sister_of_head==1)

gen brotherinlaw_of_head = hv101==15 & hv104==1

gen husband_of_head = hv101==2 & hv104==1
gen wife_of_head = hv101==2 & hv104==2

* collapse to household level

foreach var in non_nuclear_member mother_of_head father_of_head parent_of_head mil_of_head fil_of_head pil_of_head son_of_head daughter_of_head sil_of_head dil_of_head sib_inlaw_of_head brother_of_head sister_of_head sib_of_head brotherinlaw_of_head husband_of_head wife_of_head {
	bysort hv000 hhid: egen has_`var' = max(`var')
}

bysort hv000 hhid (hv101): gen nnm_list = nnm_code
bysort hv000 hhid (hv101): replace nnm_list = nnm_list[_n-1] + " " + nnm_code if _n > 1 & !missing(nnm_code)
bysort hv000 hhid (hv101): replace nnm_list = nnm_list[_N]


rename hv000 v000
rename hv001 v001 
rename hv002 v002

keep v000 v001 v002 has_non_nuclear_member has_mother_of_head has_father_of_head has_parent_of_head has_mil_of_head has_fil_of_head has_pil_of_head has_son_of_head has_daughter_of_head has_sil_of_head has_dil_of_head has_sib_inlaw_of_head has_brother_of_head has_sister_of_head has_sib_of_head has_brotherinlaw_of_head has_husband_of_head has_wife_of_head nnm_list

duplicates drop

tempfile hr_combined
save `hr_combined'

* merge into individual recode

use $ir_combined, clear

* this should include all variables generated after this line (in case you're rerunning this file)
capture drop hh_merge nuclear sasural joint_patrilocal_pil joint_patrilocal_no_pil natal other patrilocal_extended_allendorf 

merge m:1 v000 v001 v002 using `hr_combined', generate(hh_merge)
drop if hh_merge==2

* generate hh structure variables relative to woman

* 1) NUCLEAR
gen nuclear = 0 

* hh head is woman or her husband, and someone besides their child is present
replace nuclear = 1 if inlist(v150,1,2) & has_non_nuclear_member==0

* 2.1) SASURAL: Patrilocal extended with Parents-in-Law
gen sasural = 0
gen joint_patrilocal_pil = 0
gen joint_patrilocal_no_pil = 0

* woman is dil of hh head
replace sasural = 1 if v150==4
replace joint_patrilocal_pil = 1 if v150==4

* hh head is husband & his parent is present
replace sasural = 1 if v150==2 & has_parent_of_head==1
replace joint_patrilocal_pil = 1 if v150==2 & has_parent_of_head==1

* woman is hh head & her parent-in-law is present
replace sasural = 1 if v150==1 & has_pil_of_head==1
replace joint_patrilocal_pil=1 if v150==1 & has_pil_of_head==1

* woman is sister-in-law of male hh head & his parent is present
replace sasural = 1 if v150==15 & v151==1 & has_parent_of_head==1
replace joint_patrilocal_pil=1 if v150==15 & v151==1 & has_parent_of_head==1

* 2.2) SASURAL: Patrilocal extended with no Parents-in-Law ***********

* woman is sister-in-law of male hh head & his parents are not present 
replace sasural = 1 if v150==15 & v151==1 & has_parent_of_head==0
replace joint_patrilocal_no_pil=1 if v150==15 & v151==1 & has_parent_of_head==0

* woman is hh head & her husband & brother-in-law is present, but no parent in laws
replace sasural = 1 if v150==1 & has_husband_of_head==1 & has_brotherinlaw_of_head==1 & has_pil_of_head==0
replace joint_patrilocal_no_pil=1 if v150==1 & has_husband_of_head==1 & has_brotherinlaw_of_head==1 & has_pil_of_head==0

* woman's husband is hh head & his brother/sister is present, but no parents
replace sasural = 1 if v150==2 & has_sib_of_head==1
replace joint_patrilocal_no_pil = 1 if v150==2 & has_sib_of_head==1 & has_parent_of_head==0


* 2.3) SASURAL: Allendorf's definition (woman resides with 1+ adult in-laws)

gen patrilocal_extended_allendorf = 0

* woman is hh head
replace patrilocal_extended_allendorf = 1 if v150==1 & (has_pil_of_head==1 | has_sib_inlaw_of_head==1)

* woman's husband is hh head
replace patrilocal_extended_allendorf = 1 if v150==2 & (has_parent_of_head==1 | has_sib_of_head==1)

* woman's parent in law or sibling in law is hh head
replace patrilocal_extended_allendorf = 1 if inlist(v150,4,15)


* 3) NATAL
gen natal = 0

* woman is daughter of hh head
replace natal = 1 if v150==3

* woman is sister of hh head
replace natal = 1 if v150==8

* woman is hh head and her brother/parent is present
replace natal = 1 if v150==1 & (has_mother_of_head==1 | has_father_of_head==1 | has_brother_of_head==1)

* woman is granddaughter of hh head
replace natal = 1 if v150==5

* 4) OTHER 
gen other = nuclear==0 & sasural==0 & natal==0

label variable nuclear         "Observed in nuclear"
label variable sasural         "Observed in sasural"
label variable natal           "Observed in meika"


save $ir_combined, replace


* Codes to generate: 4 to 17 and 98
foreach code in 4 5 6 7 8 9 10 11 12 13 14 15 16 17 98 {
    gen non_nuclear`code' = strpos(nnm_list, "`code' ") | strpos(nnm_list, " `code'")
}


foreach code in 4 5 6 7 8 9 10 11 12 13 14 15 16 17 98 {
    sum non_nuclear`code' if other==1 & inlist(v150,1) & v213==1 
	
}



use $ir_combined, clear


/*
allendorf sample
- currently married
- 15-29
- usual residents
- living with husbands */

gen allendorf_sample = v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1

/*


issues
- sasural and nuclear overlap
- allendorf sample total is 29,907. I have 30,898
- allendorf sample extended is 16,630 (56.5%). I have 15,949 (53.1%)
- allendorf sample nuclear is 13,277. I have 12,357 (39.67%)

- 12%, 9% and 8% of women are not classified into a household structure

- fix patrilocal breakdown variables

how if woman is head or spouse of head, hh structure is unclassified? 




figure out what is going on with other

likely they're not nuclear, someone else is there

they're not sasural because parent in law or brother in law is not present

they're not natal because parent or brother is not present

relative to woman/hh head 
- child in law 38%
- grandchild 42%
- parent 5%
- parent in law 11%
- sibling 17%
- other relative 12%
- adopted child 3%
- sibling in law 10%
- niece/nephew 13%
- "domestic servant" 2%


so who is the non_nuclear_member in these cases?

*/


if "`c(username)'" == "sidhpandit" {
	global nfhs5hr "/Users/sidhpandit/Desktop/nfhs/nfhs5hr/IAHR7EFL.DTA"
	global nfhs4hr "/Users/sidhpandit/Desktop/nfhs/nfhs4hr/IAHR74FL.DTA"
	global nfhs3hr "/Users/sidhpandit/Desktop/nfhs/nfhs3hr/IAHR52FL.dta"	
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	
	global nfhs3hmr "/Users/sidhpandit/Desktop/nfhs/nfhs3hmr/nfhs5hmr/IAPR7EFL.DTA"
	
	global nfhs4hmr "/Users/sidhpandit/Desktop/nfhs/nfhs3hmr/nfhs4hmr/IAPR74FL.DTA"
	
	global nfhs5hmr "/Users/sidhpandit/Desktop/nfhs/nfhs3hmr/nfhs5hmr/IAPR7EFL.DTA"
}



// * trying this with the hmr
// use $nfhs3hmr, clear
// append using $nfhs4hmr
// append using $nfhs5hmr
//
// rename hv000 v000
// rename hv001 v001 
// rename hv002 v002
//
// tempfile hmr_combined
// save `hmr_combined'
//
// use $ir_combined, clear
//
// joinby v000 v001 v002 using `hmr_combined', unmatched(master) _merge(joinby_m)
//
// merge m:m v000 v001 v002 using `hmr_combined', generate(hh_merge)



* merge women to their households
use hv* using $nfhs5hr, clear
tempfile nfhs5hr
save `nfhs5hr'

use hv* using $nfhs4hr, clear
append using $nfhs3hr
append using `nfhs5hr'

rename hv000 v000
rename hv001 v001 
rename hv002 v002


tempfile hr_combined
save `hr_combined'

use $ir_combined

keep if v213==1
merge m:1 v000 v001 v002 using `hr_combined', generate(hh_merge)

drop if hh_merge==2

egen wid_round = group(v000 caseid)

*-------------------------------------------------------------
* Setup: Generate household structure flags
*-------------------------------------------------------------

preserve
keep if v213==1

gen household_structure = .

gen nuclear = 0
gen sasural = 0
gen natal = 0

gen mil = 0
gen fil = 0

gen bhai = 0
gen bahu = 0

gen mother = 0
gen father = 0
gen other = 0

*-------------------------------------------------------------
* Loop over other household members
*-------------------------------------------------------------
forvalues i = 2/41 {
    local j = string(`i', "%02.0f")

    * Relationship code: hv101_`j'
    * Sex code: hv104_`j'
    * Age: hv105_`j'
	
	* household head is husband
    replace sasural = 1 if v150==2 & hv101_`j'==6
    replace fil     = 1 if v150==2 & hv101_`j'==6 & hv104_`j'==1
    replace mil     = 1 if v150==2 & hv101_`j'==6 & hv104_`j'==2

    replace bhai        = 1 if v150==2 & hv101_`j'==8
    replace bahu = 1 if v150==2 & hv101_`j'==15 & hv104_`j'==2

    * woman is household head, but not nuclear
	replace mother = 1 if hv101_`j'==6 & hv104_`j'==2 & v150==1
	replace father = 1 if hv101_`j'==6 & hv104_`j'==1 & v150==1
	
	* household head is parent
    replace natal = 1 if v150==3 | v150==11
	replace mother = 1 if v151==2 & v150==3
	replace father = 1 if v151==2 & v150==3

    * household head is parent in law
    replace sasural = 1 if v150==4
    replace fil = 1 if v150==4 & v151==1
    replace mil = 1 if v150==4 & v151==2

    replace bhai = 1 if v150==4 & hv101_`j'==3 & v034 != `i'
    replace bahu = 1 if v150==4 & hv101_`j'==4 & hv104_`j'==2
	
	
	

    * woman is household head
    replace mother = 1 if v150==1 & hv101_`j'==6 & hv104_`j'==2
    replace father = 1 if v150==1 & hv101_`j'==6 & hv104_`j'==1
    replace mil    = 1 if v150==1 & hv101_`j'==7 & hv104_`j'==2
    replace fil    = 1 if v150==1 & hv101_`j'==7 & hv104_`j'==1
}

*-------------------------------------------------------------
* Define nuclear: woman is head or spouse, and no in-laws present
*-------------------------------------------------------------
replace nuclear = 1 if inlist(v150,1,2) & mil == 0 & fil == 0 & mother==0 & father==0


* household head is woman's sibling in law
replace sasural = 1 if v150==15

* household head is grandparent
replace natal = 1 if v150==5

* household head is woman's child/stepchild, uncle/aunt, other
replace other = 1 if inlist(v150, 6, 7, 10, 12, 16, 17)


label variable nuclear         "Observed in nuclear"
label variable sasural         "Observed in sasural"
label variable natal           "Observed in meika"
label variable mil             "Observed in mother-in-law's home"
label variable fil             "Observed in father-in-law's home"
// label variable natal_usual     "Natal (usual residence)"
// label variable natal_visitor   "Natal (visiting)"
// label variable sasural_fil     "Sasural – FIL present"
// label variable sasural_mil     "Sasural – MIL present"
// label variable sasural_pil     "Sasural – PILs present"
// label variable nuclear_head    "Nuclear HH – Woman is head"
// label variable nuclear_husband "Nuclear HH – Husband is head"

save $ihr_pregnant, replace


/*

unhandled cases
- woman is the household head, parents are present (natal?)
- woman's grandparent is the household head (natal)
- woman's child/stepchild/niece/nephew is the household head (?)
- someone unrelated to woman is household head (other)
- woman's sibling is household head (natal?)
- woman's sibling-in-law is household head (sasural?)
- woman is "domestic worker" (other)


*/



restore
/*




/*

questions
- quality of "household head" reporting wrt migration

case where
- woman's parent in law is household head


info we want from woman's perspective:

-  badi/choti bahu (sister in law of husband)
-  male members younger to her husband (besides father in law????)
-  male members older to her husband


sasural: just mil 
sasural: just fil
sasural: both pil

natal: usual resident
natal: not usual resident

nuclear: hh head
nuclear: husband hh head


*/




gen nuclear = 0
gen sasural = 0
gen natal = 0

replace sasural = 1 if v150==4  // woman is dil of hh head
replace natal = 1 if v150==3  // woman is daughter of hh head

gen mil = 0
gen fil = 0

gen bhai = 0
gen bade_bhai = 0
gen chota_bhai = 0

gen bahu = 0

* if woman's husband is hh head, are his parents/siblings present?
if v150==2 {
	
	foreach i of numlist 2/41 {
		
		if `i'<10 {
			local j = "0`i'"
		}

		
		* parent in law is present
		replace sasural = 1 if hv101_`j'==6
		replace fil = 1 if hv101_`j'==6 & hv104_`j'==1
		replace mil = 1 if hv101_`j'==6 & hv104_`j'==2
		
		* husband's brother/sister
		if hv101_`j'==8 {
			replace bhai = 1
			replace bade_bhai = 1 if hv104_`j'==1 & hv105_`j'>hv105_01
			replace chota_bhai = 1 if hv104_`j'==1 & hv105_`j'>hv105_01			
		}

		*husband's brother's wife?
		replace bahu = 1 if hv101_`j'==15 & hv104_`j'==2	
	}
	
}

* if woman's parent-in-law is hh head, who else is present
if v150==4 {
	
	replace sasural = 1
	replace nuclear = 0
	
	replace fil = 1 if v151==1
	replace mil = 1 if v151==2
	
	
	foreach i of numlist 2/41 {
		
		if `i'<10 {
			local j = "0`i'"
		}
		
		replace fil==1 if v151==2 & hv101_`j'==2
		replace mil==1 if v151==2 & hv101_`j'==2
	
		* son of household head (bade/ chota bhai harder in this case)
		replace bhai = 1 if hv101_`j'==3 & v034!=`j'
		
		replace bahu = 1 if hv101_`j'==4 & hv104_`j'==2
		
	}
}



* woman is household head
if v150==1 {
	foreach i of numlist 2/41 {
		
		if `i'<10 {
			local j = "0`i'"
		}
		
		replace mother = 1 if hv101_`j'==6 & hv104_`j'==2
		replace father = 1 if hv101_`j'==6 & hv104_`j'==1
		
		replace mil = 1 if hv101_`j'==7 & hv104_`j'==2
		replace fil = 1 if hv101_`j'==7 & hv104_`j'==1
		
	}

}

replace nuclear = 1 if (v150==1|v150==2) & mil==0 & fil==0


gen natal_usual = natal==1 & v135==1
gen natal_visitor = natal==1 & v135==2

gen sasural_fil = sasural==1 & fil==1 & mil==0
gen sasural_mil = sasural==1 & fil==0 & mil==1
gen sasural_pil = sasural==1 & fil==1 & mil==1

gen nuclear_head = nuclear==1 & v150==1
gen nuclear_husband = nuclear==1 & v150==2


label variable nuclear         "Observed in nuclear family"
label variable sasural         "Observed in sasural"
label variable natal           "Observed in meika"
label variable mil             "Observed in mother-in-law's home"
label variable fil             "Observed in father-in-law's home"
label variable natal_usual     "Natal (usual residence)"
label variable natal_visitor   "Natal (visiting)"
label variable sasural_fil     "Sasural – FIL present"
label variable sasural_mil     "Sasural – MIL present"
label variable sasural_pil     "Sasural – PILs present"
label variable nuclear_head    "Nuclear HH – Woman is head"
label variable nuclear_husband "Nuclear HH – Husband is head"


save $ihr_pregnant, replace

/*










dimensions of living situation of pregnant women


extended:
- both parents in law
- just mother in law
- just father in law
- married sibling
- unmarried sibling
- niece/nephews




ok so we need to know


how is the pregnant woman related with the head of the household (already in IR)
- that tells us if she's in natal home or sasural




who else lives in the househoold

- merge the household dataset
- shstruc variable (nuclear/non-nuclear)


- go through relationship to household head variable



if household head = husband
{
	if linenumber relationship = mother {
		
		mil_present = 1
		
	}
}













*/

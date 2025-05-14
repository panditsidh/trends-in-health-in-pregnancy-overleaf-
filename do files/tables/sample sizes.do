* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes.tex"
	
	global out_tex2 "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes2.tex"
	
}
*** test comment 
use $ihr_pregnant, clear

keep if mopreg>=3

gen natal_usual = natal==1 & v135==1
gen natal_visitor = natal==1 & v135==2
gen nuclear_head = nuclear==1 & v150==1
gen nuclear_husband = nuclear==1 & v150==2

gen up_bihar = inlist(v024,9,10) if round==5
replace up_bihar = inlist(v024,33,5) if round==4|round==5

replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)

label variable up_bihar "Uttar Pradesh and Bihar"


// ** this gets the confidence interval output that I screenshotted
//
// foreach var in eag north central east northeast west south rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal_usual natal_visitor nuclear_head nuclear_husband {
//	
// 	replace `var' = `var'*100
// }
//
// foreach r of numlist 3/5 {
//	
// 	preserve
// 	keep if round==`r'
// 	svy: mean eag north central east northeast west south rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal
//	
// 	restore
// }


*** getting counts

eststo clear
foreach r of numlist 3/5 {
	
	estpost sum india focus central east west north south northeast rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal other if round==`r'
	
	eststo round_`r'
	
}

#delimit ;
esttab round_3 round_4 round_5, replace
    cells("sum(fmt(0))") 
    collabels("N" "%") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1 1)) 
	nonumbers
    label;
#delimit cr

#delimit ;
esttab round_3 round_4 round_5 using $out_tex, replace
    cells("sum(fmt(0))") 
    collabels("N" "%") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1 1)) 
	nonumbers
	booktabs
    label;
#delimit cr

*** getting % of sample

foreach var in india focus central east west north south northeast rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal other {
	replace `var' = `var'*100
}

eststo clear
foreach r of numlist 3/5 {
	
	estpost sum india focus central east west north south northeast rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal other if round==`r' [aw=wt]
	
	eststo round_`r'
	
}


#delimit ;
esttab round_3 round_4 round_5,
    cells("mean(fmt(1))") 
    collabels("percent of sample") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1)) 
    label
	nonumbers;

#delimit ;
esttab round_3 round_4 round_5 using $out_tex2, replace
    cells("mean(fmt(1))") 
    collabels("percent of sample") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1 1)) 
    label
	nonumbers
	booktabs;



	


	
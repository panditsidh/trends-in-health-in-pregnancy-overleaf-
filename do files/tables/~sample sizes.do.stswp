* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes.tex"
	
	global out_tex2 "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes2.tex"
	
}


use $ihr_pregnant, clear

keep if mopreg>=3

gen natal_usual = natal==1 & v135==1
gen natal_visitor = natal==1 & v135==2
gen nuclear_head = nuclear==1 & v150==1
gen nuclear_husband = nuclear==1 & v150==2


replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)

** make sure it's only 3+ MO preg. women

foreach var in eag north central east northeast west south rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal_usual natal_visitor nuclear_head nuclear_husband {
	
	replace `var' = `var'*100
}

foreach r of numlist 3/5 {
	
	preserve
	keep if round==`r'
	svy: mean eag north central east northeast west south rural urban forward obc dalit adivasi muslim sikh_jain_christian nuclear sasural natal
	
	restore
}


*** sadly this doesn't work with confidence intervals

eststo clear
foreach r of numlist 3/5 {
	
	preserve 
	keep if round==`r'
    svy: mean eag north-northeast rural urban forward-sikh_jain_christian nuclear sasural natal natal_usual natal_visitor nuclear_head nuclear_husband
    eststo round_`r'
	restore
}


#delimit ;
esttab round_3 round_4 round_5 using $out_tex2, replace
    collabels("Mean" "SE") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1 1)) nonumbers 
	label
	se par
	booktabs;


	
if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes.tex"
	
	global out_tex2 "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes2.tex"
	
}

*** test comment
use $ir_combined, clear

keep if v213==1

replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)

foreach var in eag central east west north south northeast rural urban forward obc dalit adivasi muslim sikh_jain_christian {
	
	foreach r of numlist 3/5 {
		
		
		preserve
		keep if round==`r'
		
		svy: mean v012 if `var'==1
		
		
	}
}

esttab model_3 model_4

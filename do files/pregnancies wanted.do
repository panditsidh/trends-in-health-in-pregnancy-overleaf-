


* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/pregnancies_wanted.tex"
	
}

use $ir_combined, clear


gen parity_1 = v219==1
gen parity_2 = v219==2
gen parity_3 = v219==3
gen parity_4plus = v219>=4



gen parity = v219 if v219<=4

replace parity = 4 if v219>=4


gen preg_wanted_then = v225==1

eststo clear

foreach r of numlist 3/5 {	
	eststo round`r': reg v439 v213
	foreach p of numlist 1/4 {
		
		sum preg_wanted_then [aw=v005] if round==`r' & parity==`p' & v213==1
		
		eststo round`r': estadd scalar preg_wanted`p' = r(mean)*100
	}
}

#delimit ;
esttab round3 round4 round5 using $out_github, 
	stats(preg_wanted1 preg_wanted2 preg_wanted3 preg_wanted4, labels("Parity 1" "Parity 2" "Parity 3" "Parity 4+")) 
	drop(v213 _cons)
	mtitle("NFHS-3" "NFHS-4" "NFHS-5")
	nonumber;

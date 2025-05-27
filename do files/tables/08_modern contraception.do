

* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/modern_contraception.tex"
	
}

use $ir_combined, clear

keep if v213==0

eststo clear
foreach r of numlist 3/5 {
	
	eststo round`r': reg v439 v213
	
	sum modernmethod [aw=v005] if round==`r' & hasboy==0 & v501==1
	eststo round`r': estadd scalar no_boy = r(mean)*100
	
	sum modernmethod [aw=v005] if round==`r' & v218==0 & v501==1
	eststo round`r': estadd scalar no_child = r(mean)*100
	
}


local labels `" "No living boy child" "No children" "'

#delimit ;
esttab round3 round4 round5, 
	replace
    stats(no_boy no_child, labels(`labels')) 
    drop(v213 _cons)
    mtitle("NFHS-3 (2005–2006)" "NFHS-4 (2015–2016)" "NFHS-5 (2019–2021)") 
    nonumbers nostar noobs not;
#delimit cr


#delimit ;
esttab round3 round4 round5 using $out_github, 
	replace
    stats(no_boy no_child, labels(`labels')) 
    drop(v213 _cons)
    mtitle("NFHS-3 (2005–2006)" "NFHS-4 (2015–2016)" "NFHS-5 (2019–2021)") 
    nonumbers nostar noobs not
	booktabs;
#delimit cr

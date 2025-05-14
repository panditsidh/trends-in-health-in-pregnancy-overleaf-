
if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/bar graph number of children.png"
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/bar graph number of children.png"
}

use $ir_combined, clear

gen parity_1 = v219==1
gen parity_2 = v219==2
gen parity_3 = v219==3
gen parity_4plus = v219>=4


gen parity = v219 if v219<=4

replace parity = 4 if v219>=4


#delimit ;
graph hbar (mean) parity_1 parity_2 parity_3 parity_4plus [aw=v005], over(round) 
	legend(label(1 "Parity 1") label(2 "Parity 2") label(3 "Parity 3") label(4 "Parity 4+"))
	ytitle("Mean Proportion");


// graph export "$out_dropbox", as(png) name("Graph") replace
graph export "$out_github", as(png) name("Graph") replace

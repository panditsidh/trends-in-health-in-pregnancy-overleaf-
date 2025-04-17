
if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/bar graph number of children.png"
	
}

use $ir_combined, clear


gen parity_1 = v219==1
gen parity_2 = v219==2
gen parity_3 = v219==3
gen parity_4plus = v219>=4


gen parity = v219 if v219<=4

replace parity = 4 if v219>=4

graph hbar (mean) parity_1 parity_2 parity_3 parity_4plus [aw=v005], over(round)


graph export "$out", as(png) name("Graph") replace

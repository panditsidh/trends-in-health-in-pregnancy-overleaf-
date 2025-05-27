
* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/boxplots ages.png"
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/boxplots ages.png"
	
}

use $ir_combined, clear




preserve

keep if v012<=37

#delimit ;
graph box v012 if v213==1 [aw=wt], ///
    over(round) ///
    ylabel(15(5)35, angle(0) nogrid) ///
    ytitle("Age") ///
    yscale(range(15 37)) ;
# delimit cr
	
restore


// graph export "$out_dropbox", as(png) name("Graph") replace
graph export "$out_github", as(png) name("Graph") replace


* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/boxplots ages.png"
	
}

use $ir_combined, clear



label define roundlbl ///
    3 "NFHS-3 (2005–2006)" ///
    4 "NFHS-4 (2015–2016)" ///
    5 "NFHS-5 (2019–2021)"

label values round roundlbl

preserve

keep if v012<=37

#delimit ;
graph box v012 if v213==1 [aw=wt], ///
    over(round) ///
    ylabel(15(5)35, angle(0) nogrid) ///
    ytitle("Age") ///
    title("Box plot of age by survey round") ///
    yscale(range(15 37)) ;

	
restore


graph export "$out", as(png) name("Graph") replace

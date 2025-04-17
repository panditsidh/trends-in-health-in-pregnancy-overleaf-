
* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/cdf nine months bmi.png"
	
}

use $ir_combined, clear


keep if bmi<=30

gen cdf = .

foreach r of numlist 3/5 {
    
    * Temp vars for each round
    tempvar cdf_p
	tempvar cdf_np
    
    * Create sorted CDF using weights
    cumul bmi if round == `r' & v213==1 & mopreg>=9 [aw=wt], gen(cdf_p`r') 

    * Merge into main cdf var for plotting
    replace cdf = cdf_p`r' if round == `r' & v213==1
}


#delimit ;
twoway 
  (line cdf bmi if round == 3 & v213==1, sort lpattern(solid) lcolor(blue) legend(label(1 "NFHS-3 (2005-2006)"))) 
  (line cdf bmi if round == 4 & v213==1, sort lpattern(dash)  lcolor(green) legend(label(2 "NFHS-4 (2015-2016)"))) 
  (line cdf bmi if round == 5 & v213==1, sort lpattern(dot)   lcolor(red) legend(label(3 "NFHS-5 (2019-2021)"))),
  title("CDF of End-pregnancy BMI by Survey Round") 
  xlabel(10(5)30) ylabel(0(0.1)1, format(%3.1f)) 
  xscale(range(10 30))
  legend(order(1 2 3)) 
  xtitle("BMI") ytitle("Cumulative Probability")
  name(a, replace);
#delimit cr

graph export "$out", as(png) replace

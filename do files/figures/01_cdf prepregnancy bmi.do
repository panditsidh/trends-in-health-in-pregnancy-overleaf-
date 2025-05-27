
* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/cdf prepregnancy bmi.png"
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/cdf prepregnancy bmi.png"
	
}

use $ir_combined, clear

keep if bmi<=30

gen cdf = .

foreach r of numlist 3/5 {
    
    * Temp vars for each round
    tempvar cdf_p
	tempvar cdf_np
    
    * Create sorted CDF using weights
    cumul bmi if round == `r' & v213==1 [aw=wt], gen(cdf_p`r') 
	cumul bmi if round == `r' & v213==0 [aw=reweightingfxn_all], gen(cdf_np`r') 

    * Merge into main cdf var for plotting
    replace cdf = cdf_p`r' if round == `r' & v213==1
	replace cdf = cdf_np`r' if round == `r' & v213==0
}


* Plot CDFs overlaid

#delimit ;
twoway 
  (line cdf bmi if round == 3 & v213==0, sort lpattern(solid) lcolor(blue) legend(label(1 "NFHS-3 (2005-2006)"))) 
  (line cdf bmi if round == 4 & v213==0, sort lpattern(solid)  lcolor(green) legend(label(2 "NFHS-4 (2015-2016)"))) 
  (line cdf bmi if round == 5 & v213==0, sort lpattern(solid)   lcolor(red) legend(label(3 "NFHS-5 (2019-2021)"))),
  xlabel(10(5)30) ylabel(0(0.1)1, format(%3.1f)) 
  xscale(range(10 30))
  legend(order(1 2 3)) 
  xtitle("BMI") ytitle("Cumulative Probability")
  name(a, replace);
#delimit cr

// graph export "$out_dropbox", as(png) replace

graph export "$out_github", as(png) replace


#delimit ;  
twoway 
  (line cdf bmi if round == 3 & v213==1, sort lpattern(solid) lcolor(blue) legend(label(1 "NFHS-3 (2005-2006)"))) 
  (line cdf bmi if round == 4 & v213==1, sort lpattern(dash)  lcolor(green) legend(label(2 "NFHS-4 (2015-2016)"))) 
  (line cdf bmi if round == 5 & v213==1, sort lpattern(dot)   lcolor(red) legend(label(3 "NFHS-5 (2019-2021)"))),
  title("CDF of Pregnancy BMI by Survey Round") 
  xlabel(10(5)30) ylabel(0(0.1)1, format(%3.1f)) 
  xscale(range(10 30))
  legend(order(1 2 3)) 
  xtitle("BMI") ytitle("Cumulative Probability")
  name(b, replace);
#delimit cr


#delimit ;  
grc1leg a b, 
	position(6) ring(1)
	colfirst xcommon rows(2)
	iscale(0.7)
	name(c, replace);
#delimit cr


#delimit ;  
graph display c, 
	xsize(10) ysize(15);
#delimit cr




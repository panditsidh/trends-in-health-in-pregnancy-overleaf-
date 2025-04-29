
if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/ultrasound by pregnancy duration.png"
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/ultrasound by pregnancy duration.png"
}

use $ir_combined, clear


gen ultra=s236*100

gen no_edu=v106==0
replace no_edu=no_edu*100

table mopreg round if inlist(round,4,5) & v213==1 [aw=v005] , statistic(mean ultra no_edu) nformat(%5.2f) nototals



preserve


collapse (sum) s236 v213 if v213==1 & !missing(s236) [aw=v005], by(mopreg round)



gen cum_ultrasound = sum(s236)
gen cum_pregnant   = sum(v213)



gen prop_ultra = s236/v213

gen cdf_ultra = cum_ultrasound / cum_pregnant


#delimit ;
twoway ///
    (line prop_ultra mopreg if round==4, sort 
        lcolor(green) lwidth(medthick) 
        legend(label(1 "NFHS-4 (2015–2016)"))) ///
    (line prop_ultra mopreg if round==5, sort 
        lcolor(red) lwidth(medthick) 
        legend(label(2 "NFHS-5 (2019–2021)"))) 
    , ///
    ytitle("Proportion with ≥1 Ultrasound") 
    xtitle("Months Pregnant (mopreg)") 
    legend(position(6) cols(2)) 
    graphregion(color(white))
	xlabel(0(1)11);
	
	
#delimit cr

graph export "$out_github", as(png) name("Graph") replace

restore

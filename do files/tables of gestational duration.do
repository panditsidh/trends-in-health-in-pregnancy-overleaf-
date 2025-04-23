* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/boxplots ages.png"
	
	global outtex_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/table of gestational duration.tex"
	
}

use $ir_combined, clear


table mopreg round if v213 == 1 [aw=v005], statistic(percent, across(mopreg)) nototals


table moperiod round if v213 == 1 [aw=v005], statistic(percent, across(moperiod)) nototals



#delimit ;
twoway
    (hist mopreg if v213==1 & round==3 [aw=wt], 
        width(1) start(0) color(%30) lcolor(blue) lwidth(medthin) 
        legend(label(1 "NFHS-3"))) 
    (hist mopreg if v213==1 & round==4 [aw=wt], 
        width(1) start(0) color(%30) lcolor(green) lwidth(medthin) 
        legend(label(2 "NFHS-4"))) 
    (hist mopreg if v213==1 & round==5 [aw=wt], 
        width(1) start(0) color(%30) lcolor(red) lwidth(medthin) 
        legend(label(3 "NFHS-5"))) 
    , 
    title("Histogram of Duration of Pregnancy by Survey Round") 
    xtitle("Months Pregnant") ytitle("Weighted Count") 
    xlabel(0(1)11) 
    legend(position(6) cols(3)) 
    graphregion(color(white));

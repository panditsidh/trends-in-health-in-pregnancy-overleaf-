* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/boxplots ages.png"
	
	global outtex_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/table_of_gestational_duration.tex"
	
}

use $ir_combined, clear





//
// table mopreg round if v213 == 1 [aw=v005], statistic(percent, across(mopreg)) nototals
//
//
// table moperiod round if v213 == 1 [aw=v005], statistic(percent, across(moperiod)) 
//
//
//
// #delimit ;
// twoway
//     (hist mopreg if v213==1 & round==3 [aw=wt], 
//         width(1) start(0) color(%30) lcolor(blue) lwidth(medthin) 
//         legend(label(1 "NFHS-3"))) 
//     (hist mopreg if v213==1 & round==4 [aw=wt], 
//         width(1) start(0) color(%30) lcolor(green) lwidth(medthin) 
//         legend(label(2 "NFHS-4"))) 
//     (hist mopreg if v213==1 & round==5 [aw=wt], 
//         width(1) start(0) color(%30) lcolor(red) lwidth(medthin) 
//         legend(label(3 "NFHS-5"))) 
//     , 
//     title("Histogram of Duration of Pregnancy by Survey Round") 
//     xtitle("Months Pregnant") ytitle("Weighted Count") 
//     xlabel(0(1)11) 
//     legend(position(6) cols(3)) 
//     graphregion(color(white));
//
//	
//	
	

keep if v213==1
	
eststo clear

foreach r of numlist 3/5 {
	
	eststo model_mopreg`r': qui reg v013 v213
	
	foreach i of numlist 1/11 {
		gen mopreg_`i' = mopreg==`i'
		qui sum mopreg_`i' [aw=v005] if round==`r'
		eststo model_mopreg`r': qui estadd scalar prop_`i' = r(mean)*100
	}

	
	
	eststo model_moperiod`r': qui reg v013 v213

	foreach i of numlist 1/11 {	
		gen moperiod_`i' = moperiod==`i'
		qui sum moperiod_`i' [aw=v005] if round==`r'
		eststo model_moperiod`r': qui estadd scalar prop_`i' = r(mean)*100
	}
	
	
	drop moperiod_* mopreg_*
	
	
}


local labels `" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "'


#delimit ;
esttab model_mopreg3 model_moperiod3 model_mopreg4 model_moperiod4 model_mopreg5 model_moperiod5,
	replace
	stats(prop_1 prop_2 prop_3 prop_4 prop_5 prop_6 prop_7
	prop_8 prop_9 prop_10 prop_11, labels(`labels') fmt(2))
	drop(v213 _cons)
	nonumbers nostar noobs not
	mtitles("Mopreg" "Moperiod" "Mopreg" "Moperiod" "Mopreg" "Moperiod")
	mgroups("NFHS-3 (2005-2006)" "NFHS-4 (2015-2016)" "NFHS-5 (2019-2021)", pattern(1 0 1 0 1 0) )
	addnotes("Mopreg refers to respondents self reported gestational duration. Moperiod refers months since last menstrual period.");
	
#delimit cr

#delimit ;
esttab model_mopreg3 model_moperiod3 model_mopreg4 model_moperiod4 model_mopreg5 model_moperiod5 using $outtex_github,
	replace
	stats(prop_1 prop_2 prop_3 prop_4 prop_5 prop_6 prop_7
	prop_8 prop_9 prop_10 prop_11, labels(`labels') fmt(2))
	drop(v213 _cons)
	nonumbers nostar noobs not
	mtitles("Mopreg" "Moperiod" "Mopreg" "Moperiod" "Mopreg" "Moperiod")
	mgroups("NFHS-3 (2005-2006)" "NFHS-4 (2015-2016)" "NFHS-5 (2019-2021)", pattern(1 0 1 0 1 0) )
	addnotes("Mopreg refers to respondents self reported gestational duration. Moperiod refers months since last menstrual period.")
	booktabs;
	
#delimit cr
	

	
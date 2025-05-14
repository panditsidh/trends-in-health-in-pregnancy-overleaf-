if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/summary_stats.tex"
}

use $ihr_pregnant, clear


gen nuclear8mo = nuclear if mopreg>=8
gen sasural8mo = sasural if mopreg>=8
gen natal8mo = natal if mopreg>=8

keep if v213==1 & mopreg>=3
replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata) singleunit(centered)

foreach var in educ_none educ_primary educ_secondary educ_higher husband_away1mo husband_away6mo healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other own_money mobile_phone health_facility_alone dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo {
	
	replace `var' = `var' *100
}

local varlist v012 v133 educ_none educ_primary educ_secondary educ_higher husband_away1mo husband_away6mo healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other own_money mobile_phone health_facility_alone dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo


* Set up result matrix
local nvars : word count `varlist'
matrix results = J(`nvars', 9, .)
local row = 1

* Loop over variables
foreach var in `varlist' {
    local col = 1
    foreach r of numlist 3/5 {
        
        * Check if non-missing data exists for this round
        quietly count if !missing(`var') & round == `r'
        
        if r(N) != 0 {
            quietly svy: mean `var' if round == `r'
            matrix temp = r(table)
            
            * Extract mean, LL, UL
            matrix results[`row', `col']     = temp[1,1]
            matrix results[`row', `col'+1]   = temp[5,1]
            matrix results[`row', `col'+2]   = temp[6,1]
        }

        local col = `col' + 3
    }
    local ++row
}

matrix rownames results = ///
"Age" ///
"Education: Years" ///
"Education: None" ///
"Education: Primary" ///
"Education: Secondary" ///
"Education: Higher " ///
"Husband away: ≥1 mo" ///
"Husband away: ≥6 mo" ///
"Health decide: alone" ///
"Health decide: w/ husb" ///
"Health decide: husband" ///
"Health decide: else" ///
"Health decide: other" ///
"Has own: money" ///
"Has own: mobile phone" ///
"Can visit health facility" ///
"DV section incomplete" ///
"Experienced physical DV" ///
"Afraid of husband" ///
"Observed in nuclear family" ///
"Observed in sasural" ///
"Observed in meica" /// 
"Observed in nuclear (8+ mo preg)" ///
"Observed in sasural (8+ mo preg)" ///
"Observed in natal (8+ mo preg)" ///

matrix colnames results = mean3 ll3 ul3 mean4 ll4 ul4 mean5 ll5 ul5

* Display matrix
matlist results, format(%6.2f)

local nrows = rowsof(results)
local ncols = colsof(results)

forvalues i = 1/`nrows' {
    forvalues j = 1/`ncols' {
        matrix results[`i', `j'] = round(results[`i', `j'], 0.01)
    }
}

#delimit ;
esttab matrix(results),
	cells("mean(fmt(2))")
    noobs nonumber label;	


#delimit ;
esttab matrix(results) using $out_tex, replace 
	cells("mean(fmt(2))")
    noobs nonumber label booktabs;

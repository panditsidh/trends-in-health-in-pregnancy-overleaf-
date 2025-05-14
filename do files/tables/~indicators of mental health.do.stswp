if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/mental_health.tex"
}

use $ir_combined, clear

keep if mopreg>=3 & v213==1

gen pregnancy_wanted_now = 100 if v225==1
replace pregnancy_wanted_now = 0 if v225!=1

replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)

* Define over groups
local overvars region group

* Clear everything
matrix drop _all
eststo clear

* Loop over rounds
foreach r in 3 4 5 {
    
    preserve
    keep if round == `r'

    local i = 1
	svy: mean pregnancy_wanted_now
    matrix m = r(table)
    matrix mean = m[1,1]'
    matrix lb   = m[5,1]'
    matrix ub   = m[6,1]'
    matrix m_ci_`i' = mean , lb , ub
    matrix colnames m_ci_`i' = Mean_`r' LB_`r' UB_`r'
    local ++i
	
    foreach var of local overvars {

        svy: mean pregnancy_wanted_now, over(`var')
        matrix m = r(table)

        matrix mean = m[1,1...]'
        matrix lb   = m[5,1...]'
        matrix ub   = m[6,1...]'

        matrix m_ci_`i' = mean , lb , ub
        matrix colnames m_ci_`i' = Mean_`r' LB_`r' UB_`r'

        local ++i
    }

    * Stack for this round
	matrix rownames m_ci_1 = 1.india
    matrix m_ci_round`r' = m_ci_1 \ m_ci_2 \ m_ci_3

    restore
}

* Combine all three rounds horizontally

matrix full_ci = m_ci_round3 , m_ci_round4 , m_ci_round5

* Assign rownames (hardcoded, same for all rounds)
matrix rownames full_ci = ///
    India Focus Central East West North South Northeast ///
    "Forward Caste" OBC Dalit Adivasi Muslim "Sikh, Jain, Christian"
	
	

local nrows = rowsof(full_ci)
local ncols = colsof(full_ci)

forvalues i = 1/`nrows' {
    forvalues j = 1/`ncols' {
        matrix full_ci[`i', `j'] = round(full_ci[`i', `j'], 0.1)
    }
}

#delimit ;
esttab matrix(full_ci), replace
    noobs nonumber label;


#delimit ;
esttab matrix(full_ci) using $out_tex, replace 
	cells("mean(fmt(2))")
    noobs nonumber label booktabs;


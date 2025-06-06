if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/demographics2_bi.tex"

	
}

*** test comment
use $ir_combined, clear

keep if v213==1 & mopreg>=3 & v201==1
replace strata = 137 if strata==138

* strata 59 and 108 also have only 1 observation
replace strata = 60 if strata==59
replace strata = 107 if strata==108

replace strata = 93 if strata==94
replace strata = 143 if strata==144


svyset psu [pw=wt], strata(strata)


gen full_term_date = v008+(9-mopreg)
gen birth_interval = full_term_date-v211


local overvars region v102 group

* Clear everything
matrix drop _all
eststo clear

* Loop over rounds
foreach r in 3 4 5 {
    
    preserve
    keep if round == `r'

    local i = 1
	
	svy: mean birth_interval
    matrix m = r(table)
    matrix mean = m[1,1]'
    matrix lb   = m[5,1]'
    matrix ub   = m[6,1]'
    matrix m_ci_`i' = mean , lb , ub
    matrix colnames m_ci_`i' = Mean_`r' LB_`r' UB_`r'
    local ++i
	
    foreach var of local overvars {

        svy: mean birth_interval, over(`var')
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
    matrix m_ci_round`r' = m_ci_1 \ m_ci_2 \ m_ci_3 \ m_ci_4

    restore
}

* Combine all three rounds horizontally
matrix full_ci = m_ci_round3 , m_ci_round4 , m_ci_round5

* Assign rownames (hardcoded, same for all rounds)
matrix rownames full_ci = ///
    India Focus Central East West North South Northeast ///
    Rural Urban ///
    "Forward Caste" OBC Dalit Adivasi Muslim "Sikh, Jain, Christian"

local nrows = rowsof(full_ci)
local ncols = colsof(full_ci)

forvalues i = 1/`nrows' {
    forvalues j = 1/`ncols' {
        matrix full_ci[`i', `j'] = round(full_ci[`i', `j'], 1)
    }
}	

#delimit ;
esttab matrix(full_ci),
    noobs nonumber label;


#delimit ;
esttab matrix(full_ci) using $out_tex, replace
    noobs nonumber label booktabs;




* Tag one observation per PSU
bysort strata psu: gen tag = _n == 1

* Count number of PSUs in each stratum
egen n_psus_per_strata = total(tag), by(strata)

* How many strata have only one PSU?
count if n_psus_per_strata == 1

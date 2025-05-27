if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/demographics3_hasboy.tex"

	
}

*** test comment
use $ir_combined, clear


keep if v213==1 & mopreg>=3
replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)


* Define over groups
local overvars region v102 group

* Clear everything
matrix drop _all
eststo clear

* Loop over rounds
foreach r in 3 4 5 {
    
    preserve
    keep if round == `r'

    local i = 1
	
	svy: mean hasboy
    matrix m = r(table)
    matrix mean = m[1,1]'
    matrix lb   = m[5,1]'
    matrix ub   = m[6,1]'
	matrix mean = 100 * mean
	matrix lb   = 100 * lb
	matrix ub   = 100 * ub
	
    matrix m_ci_`i' = mean , lb , ub
	matrix colnames m_ci_`i' = Mean_`r' LB_`r' UB_`r'
    local ++i
	
    foreach var of local overvars {

        svy: mean hasboy, over(`var')
        matrix m = r(table)

        matrix mean = m[1,1...]'
        matrix lb   = m[5,1...]'
        matrix ub   = m[6,1...]'
		
		matrix mean = 100 * mean
		matrix lb   = 100 * lb
		matrix ub   = 100 * ub

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
        matrix full_ci[`i', `j'] = round(full_ci[`i', `j'], 0.01)
    }
}	

#delimit ;
esttab matrix(full_ci), replace
    title("Mean v012 with 95 Confidence Intervals by Group and Survey Round")
    noobs nonumber label;
#delimit cr


gen row = ""
input str30 rows
"India"
"Focus"
"Central"
"East"
"West"
"North"
"South"
"Northeast"
"Rural"
"Urban"
"Forward Caste"
"OBC"
"Dalit"
"Adivasi"
"Muslim"
"Sikh, Jain, Christian"
end


replace row = rows
drop rows


svmat full_ci, names(col)



gen ci_3 = string(Mean_3, "%4.1f") + " (" + string(LB_3, "%4.1f") + ", " + string(UB_3, "%4.1f") + ")" if !missing(Mean_3)
gen ci_4 = string(Mean_4, "%4.1f") + " (" + string(LB_4, "%4.1f") + ", " + string(UB_4, "%4.1f") + ")" if !missing(Mean_4)
gen ci_5 = string(Mean_5, "%4.1f") + " (" + string(LB_5, "%4.1f") + ", " + string(UB_5, "%4.1f") + ")" if !missing(Mean_5)

keep row ci_3 ci_4 ci_5

drop if missing(row)



#delimit ;
listtex row ci_3 ci_4 ci_5 using $out_tex, replace ///
  rstyle(tabular) ///
  head("\begin{tabular}{lccc}" ///
       "\toprule" ///
       "Group & NFHS-3 & NFHS-4 & NFHS-5 \\\\" ///
       "\midrule") ///
  foot("\bottomrule" ///
       "\end{tabular}"); ///

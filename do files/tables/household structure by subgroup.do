if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/hh_structure_subgroups.tex"
}

use $ihr_pregnant, clear

keep if v213==1

replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata)

* Define over groups
local overvars region v102 group

* Clear everything
matrix drop _all
eststo clear


foreach outcome in sasural nuclear natal {
	
	replace `outcome' = `outcome'*100
	* Loop over rounds
	foreach r in 3 4 5 {
		
		preserve
		keep if round == `r'

		local i = 1
		svy: mean `outcome'
		matrix m = r(table)
		matrix mean = m[1,1]'
		matrix lb   = m[5,1]'
		matrix ub   = m[6,1]'
		matrix m_ci_`i' = mean , lb , ub
		matrix colnames m_ci_`i' = Mean_`r' LB_`r' UB_`r'
		local ++i
		
		foreach var of local overvars {

			svy: mean `outcome', over(`var')
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

	matrix full_ci_`outcome' = m_ci_round3 , m_ci_round4 , m_ci_round5

	* Assign rownames (hardcoded, same for all rounds)
	matrix rownames full_ci_`outcome' = ///
		"`outcome': India" "`outcome': Focus" "`outcome': Central" "`outcome':East" "`outcome':West" "`outcome': North" "`outcome': South" "`outcome': Northeast" ///
		"`outcome': Rural" "`outcome': Urban" "`outcome': Forward Caste" "`outcome': OBC" "`outcome': Dalit" "`outcome': Adivasi" "`outcome': Muslim" "`outcome': Sikh, Jain, Christian"
		
	local nrows = rowsof(full_ci_`outcome')
	local ncols = colsof(full_ci_`outcome')

	forvalues i = 1/`nrows' {
		forvalues j = 1/`ncols' {
			matrix full_ci_`outcome'[`i', `j'] = round(full_ci_`outcome'[`i', `j'], 0.1)
		}
	}

}

matrix full = full_ci_nuclear \ full_ci_sasural \ full_ci_natal

#delimit ;
esttab matrix(full), replace
    title("Mean v012 with 95 Confidence Intervals by Group and Survey Round")
    noobs nonumber label;


#delimit ;
esttab matrix(full_ci) using $out_tex, replace 
	cells("mean(fmt(2))")
    noobs nonumber label booktabs;



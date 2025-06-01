if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/hh_structure_subgroups.tex"
	
	global out_tex_ci "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/hh_structure_subgroups_ci.tex"
}

use $ir_combined, clear

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
esttab matrix(full) using $out_tex, replace 
	cells("mean(fmt(2))")
    noobs nonumber label booktabs;
#delimit cr


	
* Step 1: Create empty 2×9 matrix
matrix blank2 = J(2, 9, .)
matrix blank1 = J(1, 9, .)

* Step 2: Stack vertically
matrix full_expanded = /// 
	blank1 \ ///
    full_ci_nuclear \  ///
    blank2 \            ///
    full_ci_sasural \  ///
    blank2 \            ///
    full_ci_natal


gen row = ""
input str30 rows
"\textbf{Nuclear Households}"
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
""
"\textbf{Sasural Households}"
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
""
"\textbf{Natal Households}"
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
""
end


replace row = rows
drop rows


svmat full_expanded, names(col)

rename c1 mean_3
rename c2 lb_3
rename c3 ub_3
rename c4 mean_4
rename c5 lb_4
rename c6 ub_4
rename c7 mean_5
rename c8 lb_5
rename c9 ub_5

gen ci_3 = string(mean_3, "%4.1f") + " (" + string(lb_3, "%4.1f") + ", " + string(ub_3, "%4.1f") + ")" if !missing(mean_3)
gen ci_4 = string(mean_4, "%4.1f") + " (" + string(lb_4, "%4.1f") + ", " + string(ub_4, "%4.1f") + ")" if !missing(mean_4)
gen ci_5 = string(mean_5, "%4.1f") + " (" + string(lb_5, "%4.1f") + ", " + string(ub_5, "%4.1f") + ")" if !missing(mean_5)

keep row ci_3 ci_4 ci_5

gen blank_row = row == ""

gen next_blank = blank_row[_n+1]
drop if blank_row == 1 & next_blank == 1

drop blank_row next_blank

#delimit ;
listtex row ci_3 ci_4 ci_5 using $out_tex_ci, replace ///
  rstyle(tabular) ///
  head("\begin{tabular}{lccc}" ///
       "\toprule" ///
       "Group & NFHS-3 & NFHS-4 & NFHS-5 \\\\" ///
       "\midrule") ///
  foot("\bottomrule" ///
       "\end{tabular}"); ///

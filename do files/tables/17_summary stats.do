if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global ihr_pregnant "/Users/sidhpandit/Desktop/ra/ihr345_pregnant.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/summary_stats.tex"
	global out_tex2"/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/response_rates.tex"
}

use $ir_combined, clear

keep if v213==1

gen nuclear8mo = nuclear if mopreg>=8
gen sasural8mo = sasural if mopreg>=8
gen natal8mo = natal if mopreg>=8

gen nuclear_parity1 = nuclear if v219==1
gen sasural_parity1 = sasural if v219==1
gen natal_parity1 = natal if v219==1

gen nuclear_parity2 = nuclear if v219==2
gen sasural_parity2 = sasural if v219==2
gen natal_parity2 = natal if v219==2

gen nuclear_parity3 = nuclear if v219==3
gen sasural_parity3 = sasural if v219==3
gen natal_parity3 = natal if v219==3

gen nuclear_parity4plus = nuclear if v219>=4
gen sasural_parity4plus = sasural if v219>=4
gen natal_parity4plus = natal if v219>=4

keep if v213==1 & mopreg>=3
replace strata = 137 if strata==138
svyset psu [pw=wt], strata(strata) singleunit(centered)

foreach var in educ_none educ_primary educ_secondary educ_higher husband_away1mo husband_away6mo currently_working any_work paid_work healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other own_money mobile_phone health_facility_alone dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo nuclear_parity1 sasural_parity1 natal_parity1 nuclear_parity2 sasural_parity2 natal_parity2 nuclear_parity3 sasural_parity3 natal_parity3 nuclear_parity4plus sasural_parity4plus natal_parity4plus {
	
	replace `var' = `var' *100
}

gen blank = .

// local varlist v012 v133 educ_none educ_primary educ_secondary educ_higher husband_away1mo husband_away6mo currently_working any_work paid_work healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other health_facility_alone own_money mobile_phone  dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo nuclear_parity1 sasural_parity1 natal_parity1 nuclear_parity2 sasural_parity2 natal_parity2 nuclear_parity3 sasural_parity3 natal_parity3 nuclear_parity4plus sasural_parity4plus natal_parity4plus 


#delimit ;
local varlist	v012 blank 
				v133 educ_none educ_primary educ_secondary educ_higher blank 
				husband_away1mo husband_away6mo blank 
				currently_working any_work paid_work blank
				healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other health_facility_alone blank
				own_money mobile_phone blank
				dv_section_incomplete physical_dv afraidof_husband blank
				nuclear sasural natal blank 
				nuclear8mo sasural8mo natal8mo blank
				nuclear_parity1 sasural_parity1 natal_parity1 blank
				nuclear_parity2 sasural_parity2 natal_parity2 blank
				nuclear_parity3 sasural_parity3 natal_parity3 blank 
				nuclear_parity4plus sasural_parity4plus natal_parity4plus blank;
#delimit cr


foreach var in `varlist' {
	tab `var' if ssmod==1, m 
}

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
		
		if r(N) == 0 {
			matrix results[`row', `col']     = .
            matrix results[`row', `col'+1]   = .
            matrix results[`row', `col'+2]   = .
		}

        local col = `col' + 3
    }
    local ++row
}


#delimit ;
matrix rownames results = ///
"Age" ///
""
"Education: Years" ///
"Education: None" ///
"Education: Primary" ///
"Education: Secondary" ///
"Education: Higher " ///
""
"Husband away: ≥1 mo" ///
"Husband away: ≥6 mo" ///
""
"Employment: Currently working" ///
"Employment: Worked in the last 12 months" ///
"Employment: Paid cash or in-kind for work" ///
""
"Health decide: alone" ///
"Health decide: w/ husb" ///
"Health decide: husband" ///
"Health decide: else" ///
"Health decide: other" ///
"Health decide: Can visit health facility alone" ///
""
"Has own: money" ///
"Has own: mobile phone" ///
""
"Domestic Violence: DV section incomplete" ///
"Domestic Violence: Experienced physical DV" ///
"Domestic Violence: Afraid of husband" ///
""
"Household structure: Observed in nuclear family" ///
"Household structure: Observed in sasural" ///
"Household structure: Observed in meica" /// 
""
"Household structure (8+ mo preg): Observed in nuclear" ///
"Household structure (8+ mo preg): Observed in sasural" ///
"Household structure (8+ mo preg): Observed in natal" ///
""
"Household structure (parity 1): Observed in nuclear" ///
"Household structure (parity 1): Observed in sasural" ///
"Household structure (parity 1): Observed in natal" ///
""
"Household structure (parity 2): Observed in nuclear" ///
"Household structure (parity 2): Observed in sasural" ///
"Household structure (parity 2): Observed in natal" ///
""
"Household structure (parity 3): Observed in nuclear" ///
"Household structure (parity 3): Observed in sasural" ///
"Household structure (parity 3): Observed in natal" ///
""
"Household structure (parity 4+): Observed in nuclear" ///
"Household structure (parity 4+): Observed in sasural" ///
"Household structure (parity 4+): Observed in natal" ///
"";
#delimit cr

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
#delimit cr


*** CI formatting

gen row = ""
input str30 rows
"Age"
"\textbf{Education}"
"Years" 
"None" 
"Primary" 
"Secondary" 
"Higher " 
"\textbf{Husband away}"
"≥1 mo" 
"≥6 mo" 
"\textbf{Employment}"
"Currently working" 
"Worked in the last 12 months" 
"Paid cash or in-kind for work" 
"\textbf{Health decide}"
"alone" 
"w/ husb" 
"husband" 
"else" 
"other" 
"Can visit health facility alone" 
"\textbf{Has own}"
"money" 
"mobile phone" 
"\textbf{Domestic Violence}"
"DV section incomplete" 
"Experienced physical DV" 
"Afraid of husband" 
"\textbf{hhstruc, all}"
"Observed in nuclear family" 
"Observed in sasural" 
"Observed in meica" 
"\textbf{hhstruc, 8+ mo preg}"
"Observed in nuclear" 
"Observed in sasural" 
"Observed in natal" 
"\textbf{hhstruc, parity 1}"
"Observed in nuclear" 
"Observed in sasural" 
"Observed in natal" 
"\textbf{hhstruc, parity 2}"
"Observed in nuclear" 
"Observed in sasural" 
"Observed in natal" 
"\textbf{hhstruc, 8+ mo preg}"
"Observed in nuclear" 
"Observed in sasural" 
"Observed in natal" 
"\textbf{hhstruc, parity 4+}"
"Observed in nuclear" 
"Observed in sasural" 
"Observed in natal" 
""
end


replace row = rows
drop rows

svmat results, names(col)


gen ci_3 = string(mean3, "%4.1f") + " (" + string(ll3, "%4.1f") + ", " + string(ul3, "%4.1f") + ")" if !missing(mean3)
gen ci_4 = string(mean4, "%4.1f") + " (" + string(ll4, "%4.1f") + ", " + string(ul4, "%4.1f") + ")" if !missing(mean4)
gen ci_5 = string(mean5, "%4.1f") + " (" + string(ll5, "%4.1f") + ", " + string(ul5, "%4.1f") + ")" if !missing(mean5)

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
#delimit cr

********************** response rates

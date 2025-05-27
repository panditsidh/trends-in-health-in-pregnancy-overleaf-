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


local varlist husband_away1mo husband_away6mo currently_working any_work paid_work healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other health_facility_alone own_money mobile_phone  dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo nuclear_parity1 sasural_parity1 natal_parity1 nuclear_parity2 sasural_parity2 natal_parity2 nuclear_parity3 sasural_parity3 natal_parity3 nuclear_parity4plus sasural_parity4plus natal_parity4plus 


eststo clear

foreach r of numlist 3/5 {
	
	eststo model`r': reg v012 v133
	
	foreach var in 	`varlist' {
		
		sum `var' if round==`r'
		
		eststo model`r': estadd scalar `var' = r(N)
		
	}
	
}

local labels `" "Husband away: ≥1 mo" "Husband away: ≥6 mo" "Employment: Currently working" "Employment: Worked in the last 12 months" "Employment: Paid cash or in-kind for work" "Health decide: alone" "Health decide: w/ husb" "Health decide: husband" "Health decide: else" "Health decide: other" "Health decide: Can visit health facility alone" "Has own: money" "Has own: mobile phone" "Domestic Violence: DV section incomplete" "Domestic Violence: Experienced physical DV" "Domestic Violence: Afraid of husband" "Household structure: Observed in nuclear family" "Household structure: Observed in sasural" "Household structure: Observed in meica" "Household structure (parity 1 and 2): Observed in nuclear" "Household structure (parity 1 and 2): Observed in sasural" "Household structure (parity 1 and 2): Observed in natal" "Household structure (8+ mo preg): Observed in nuclear" "Household structure (8+ mo preg): Observed in sasural" "Household structure (8+ mo preg): Observed in natal" "Household structure (parity 1): Observed in nuclear" "Household structure (parity 1): Observed in sasural" "Household structure (parity 1): Observed in natal" "Household structure (parity 2): Observed in nuclear" "Household structure (parity 2): Observed in sasural" "Household structure (parity 2): Observed in natal" "Household structure (parity 3): Observed in nuclear" "Household structure (parity 3): Observed in sasural" "Household structure (parity 3): Observed in natal" "Household structure (parity 4+): Observed in nuclear" "Household structure (parity 4+): Observed in sasural" "Household structure (parity 4+): Observed in natal" "'


#delimit ; 
esttab model3 model4 model5,
	drop(v133 _cons)
	mtitles("NFHS-3" "NFHS-4" "NFHS-5")
	stats(husband_away1mo husband_away6mo currently_working any_work paid_work healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other health_facility_alone own_money mobile_phone  dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo nuclear_parity1 sasural_parity1 natal_parity1 nuclear_parity2 sasural_parity2 natal_parity2 nuclear_parity3 sasural_parity3 natal_parity3 nuclear_parity4plus sasural_parity4plus natal_parity4plus , label(`labels'));

	
#delimit ; 
esttab model3 model4 model5 using $out_tex2, replace
	drop(v133 _cons)
	mtitles("NFHS-3" "NFHS-4" "NFHS-5")
	stats(husband_away1mo husband_away6mo currently_working any_work paid_work healthdecide_alone healthdecide_whusb healthdecide_husband healthdecide_else healthdecide_other health_facility_alone own_money mobile_phone  dv_section_incomplete physical_dv afraidof_husband nuclear sasural natal nuclear8mo sasural8mo natal8mo nuclear_parity12 sasural_parity12 natal_parity12, label(`labels'))    booktabs nonumbers nostar noobs not;


if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global reweight "/Users/sidhpandit/Documents/GitHub/maternal-nutrition-and-social-groups/dofiles/assemble data/01_reweight within social group.do"
	
}


if "`c(username)'" == "dc42724" {
	
	global reweight "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\do files\data prep\assemble data for social group pre-pregnancy\01_reweight within social group.do"
	
	global ir_combined "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"
	
	
}

use $ir_combined, clear

gen edu = 0 if inlist(v106,0,1) // none or primary
replace edu = 1 if v106==2 // secondary
replace edu = 2 if v106==3 // higher

replace preg = v213

gen underweight = bmi<18.5

gen parity = v219 if v219<=3 
replace parity = 4 if v219>=4 
replace parity = parity-1 if v213==1


do "${reweight}"

svyset psu [pw=reweightingfxn], strata(strata) singleunit(centered)

keep if forward==1

capture graph drop _all
capture drop m ll ul m_*

* Define outcome list
local outcomes underweight bmi

foreach outcome of local outcomes {
	
	
	gen m = .
    gen ll = .
    gen ul = .
	
	gen m_overall_outcome = .
	gen m_overall_parity = .
	
	local outcome underweight
	* Estimate mean and CI by round and parity
    foreach i of numlist 3/5 {
        foreach p of numlist 0/4 {
            quietly svy: mean `outcome' if round==`i' & parity==`p' & preg==0
            
            replace m = r(table)[1,1] if round==`i' & parity==`p'
            replace ll = r(table)[5,1] if round==`i' & parity==`p'
            replace ul = r(table)[6,1] if round==`i' & parity==`p'
        }
		
		quietly svy: mean `outcome' if round==`i' & preg==0
		replace m_overall_outcome = r(table)[1,1] if round==`i' & preg==0
		
		quietly svy: mean parity if round==`i' & preg==0
		replace m_overall_parity = r(table)[1,1] if round==`i' & preg==0
    }
	
	
	local ylabel ""
	local yscale ""

	if "`outcome'" == "underweight" {
		local ylabel ylabel(0(0.05)0.3, angle(horizontal))
		local yscale yscale(range(0 0.3))
	}
	else if "`outcome'" == "bmi" {
		local ylabel ylabel(20(1)26, angle(horizontal))
		local yscale yscale(range(20 26))
	}
	
	preserve
		
	duplicates drop round m ll ul m_overall_outcome m_overall_parity, force
		
	#delimit ;
	qui twoway
		(scatter m_overall_outcome m_overall_parity if round==3, msymbol(X) mcolor(red)) 
		(rcap ll ul parity if round==3, color(red)) 
		(scatter m parity if round==3, msymbol(circle_hollow) mcolor(red))
		
		(scatter m_overall_outcome m_overall_parity if round==4, msymbol(X) mcolor(blue))
		(rcap ll ul parity if round==4, color(blue)) 
		(scatter m parity if round==4, msymbol(square_hollow) mcolor(blue))
		
		(scatter m_overall_outcome m_overall_parity if round==5, msymbol(X) mcolor(green))
		(rcap ll ul parity if round==5, color(green)) 
		(scatter m parity if round==5, msymbol(triangle_hollow) mcolor(green)),
		xlabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4+") 
		ytitle("estimated prevalence of pre-pregnancy `outcome'", size(vsmall))
		xtitle("number of living children")
		title("nutrition and parity by survey round")
		`ylabel' ///
		`yscale' ///
		legend(order(1 "NFHS-3" 4 "NFHS-4" 7 "NFHS-5") rows(3)) ///
		name(`outcome'_fwd_vs_group`i', replace);
	#delimit cr
	* Export graph as PNG
//         graph export "`outcome'_fwd_vs_group`i'.png", replace width(1200)
	
// 	graph export "${path}`outcome'_fwd_vs_group`i'.png", replace width(1200)
	
	restore
		
  

    * Drop variables to avoid conflict in next loop
    drop m ll ul m*
	
   
}

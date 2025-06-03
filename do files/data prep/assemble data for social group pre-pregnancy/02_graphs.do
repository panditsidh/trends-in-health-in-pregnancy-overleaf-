* need to fix export function here

if "`c(username)'" == "sidhpandit" {
	global path "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/maternal nutrition by social group/"
	
}

if "`c(username)'" == "dc42724" {
	global path "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\figures\maternal nutrition by social group\"
	
	
}

svyset psu [pw=reweightingfxn], strata(strata) singleunit(centered)

* Define outcome list
local outcomes underweight bmi

* Clear any existing graph names
graph drop _all

foreach outcome of local outcomes {
    
    * Create new variables for mean and CI
    gen m = .
    gen ll = .
    gen ul = .

    * Estimate mean and CI by group and parity
    foreach i of numlist 1/5 {
        foreach p of numlist 0/4 {
            quietly svy: mean `outcome' if groups6==`i' & parity==`p'
            
            replace m = r(table)[1,1] if groups6==`i' & parity==`p'
            replace ll = r(table)[5,1] if groups6==`i' & parity==`p'
            replace ul = r(table)[6,1] if groups6==`i' & parity==`p'
        }
    }

    * Create plots: each non-forward group vs forward caste
    foreach i of numlist 2/5 {

        local groupname : label grouplbl `i'

        twoway ///
            (rcap ll ul parity if groups6==1, color(blue)) ///
            (scatter m parity if groups6==1, msymbol(circle) mcolor(blue)) ///
            (rcap ll ul parity if groups6==`i', color(red)) ///
            (scatter m parity if groups6==`i', msymbol(square) mcolor(red)), ///
            xlabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4+") ///
            ytitle("Mean `outcome'") ///
            xtitle("Parity") ///
            title("`outcome': `groupname' vs Forward Caste") ///
            legend(order(2 "Forward Caste" 4 "`groupname'") rows(2)) ///
            name(`outcome'_fwd_vs_group`i', replace)

        * Export graph as PNG
//         graph export "`outcome'_fwd_vs_group`i'.png", replace width(1200)
		
		graph export "${path}`outcome'_fwd_vs_group`i'.png", replace width(1200)
    }

    * Drop variables to avoid conflict in next loop
    drop m ll ul
}


* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	global out_dropbox "/Users/sidhpandit/Dropbox/trends in health in pregnancy/figures and tables/kdensities ages.png"
	
	global out_github"/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/figures/kdensities ages.png"
	
}


use $ir_combined, clear


gen preg_3moplus = (v213==1 & v214>=3)


foreach r of numlist 3/5 {
	
	count if round==`r' & preg_3moplus==1
	local n_preg`r' = r(N)
	
	sum preg_3moplus [aw=wt] if round==`r'
	
	local preg_3moplus_`r' : display %9.2f `=r(mean)*100'
	
}

#delimit ;
twoway
	(kdensity v012 [aw=wt] if round==3 & v213==1, bwidth(1.9) lcolor(blue) legend(label(1 "NFHS-3 (2005-2006)")))
	(kdensity v012 [aw=wt] if round==4 & v213==1, bwidth(1.9) lcolor(green) legend(label(2 "NFHS-4 (2005-2006)")))
	(kdensity v012 [aw=wt] if round==5 & v213==1, bwidth(1.9) lcolor(red) legend(label(3 "NFHS-5 (2005-2006)"))),
	xtitle("Age")
	xtick(10(5)50)
	ytitle("Proportion in sample")
	legend(order(1 2 3) position(6) cols(3))
	text(0.08 48 "Count of 3+mo preg. women:", placement(west) size(small))
	text(0.075 48 " - NFHS-3: `n_preg3'", placement(west) size(small))
	text(0.07 48 " - NFHS-4: `n_preg4'", placement(west) size(small))
	text(0.065 48 " - NFHS-5: `n_preg5'", placement(west) size(small))
	
	text(0.055 48 "Percent of 3+mo preg. women:", placement(west) size(small))
	text(0.05 48 " - NFHS-3: `preg_3moplus_3'%", placement(west) size(small))
	text(0.045 48 " - NFHS-4: `preg_3moplus_4'%", placement(west) size(small))
	text(0.04 48 " - NFHS-5: `preg_3moplus_5'%", placement(west) size(small));
#delimit cr

graph display, xsize(15) ysize(10) 

// graph export "$out_dropbox", as(png) name("Graph") replace

graph export "$out_github", as(png) name("Graph") replace

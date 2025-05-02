* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/sample_sizes.tex"
	
	
	
}


use $ir_combined, clear


gen rural = v102==2


gen india = 1
gen state = v024

*region 
gen north = 0
gen south = 0
gen west = 0
gen central = 0
gen east = 0
gen northeast = 0

* Assign zone based on state codes
replace north = 1 if inlist(state, 1, 2, 3, 4, 5, 6, 7, 9, 10)  // Jammu & Kashmir, Himachal Pradesh, Punjab, Chandigarh, Uttarakhand, Haryana, NCT of Delhi, Uttar Pradesh, Bihar
replace south = 1 if inlist(state, 28, 29, 32, 33, 34, 35, 36)  // Andhra Pradesh, Karnataka, Kerala, Tamil Nadu, Puducherry, Andaman & Nicobar Islands, Telangana
replace west = 1 if inlist(state, 23, 24, 25, 27, 30)  // Maharashtra, Gujarat, Dadra & Nagar Haveli, Lakshadweep
replace central = 1 if inlist(state, 21, 22, 23)  // Odisha, Chhattisgarh, Madhya Pradesh
replace east = 1 if inlist(state, 18, 19, 20)  // Assam, West Bengal, Jharkhand
replace northeast = 1 if inlist(state, 11, 12, 13, 14, 15, 16, 17)  // Sikkim, Arunachal Pradesh, Nagaland, Manipur, Mizoram, Tripura, Meghalaya
gen eag = inlist(v024, 5, 7, 15, 19, 26, 29, 33, 34)


gen forward = 0
replace forward = 100 if s46==4 & round==3
replace forward = 100 if s116==4 & (round==4|round==5)

gen obc = 0
replace obc = 100 if s116==3 & (round==4|round==5)
replace obc = 100 if s46==3 & round==3

gen dalit = 0
replace dalit = 100 if s46==1 & round==3
replace dalit = 100 if s116==1 & (round==4|round==5) 

gen adivasi = 0 
replace adivasi = 100 if s46 == 2 & round==3
replace adivasi = 100 if s116==2 & (round==4|round==5)

gen muslim = 0
replace muslim = 100 if v130==2

gen sikh_jain_christian = 0
replace sikh_jain_christian = 100 if inlist(v130, 3,4,6)



eststo clear
foreach r of numlist 3/5 {
    estpost ci eag north south east west central northeast rural urban ///
        forward obc dalit adivasi muslim sikh_jain_christian ///
        if round == `r'
    eststo round_`r'
}


#delimit ;
esttab round_3 round_4 round_5 using $out_tex, replace 
    cells("b(fmt(3)) lb(fmt(3)) ub(fmt(3))") 
    collabels("Mean" "lb" "ub") 
    mgroups("NFHS-3" "NFHS-4" "NFHS-5", pattern(1 1 1)) nonumbers 
	label;



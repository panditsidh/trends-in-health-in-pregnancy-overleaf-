
* change these paths to work locally

if "`c(username)'" == "sidhpandit" {
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global out_github "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/pregnancies_wanted.tex"
	
}


use $ir_combined, clear




gen rural = v102==2
gen urban = v102==1

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




tabstat north-northeast rural urban, by(round)

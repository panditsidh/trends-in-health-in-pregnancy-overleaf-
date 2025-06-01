if "`c(username)'" == "sidhpandit" {
	
	global path "/Users/sidhpandit/Dropbox/trends in health in pregnancy/datasets/STATcompilerExport2025531_135252.xlsx"
	
}

if "`c(username)'" == "dc42724" {

	global path "C:\Users\dc42724\Dropbox\trends in health in pregnancy\datasets\STATcompilerExport2025531_135252.xlsx"
	
}

import excel "${path}", sheet("Indicator Data") firstrow clear

rename A Country
rename B Survey
rename Childrenwithanyanemia anemia_children
rename Womenwithanyanemia anemia_women
rename Menwithanyanemia anemia_men

drop if missing(Country) | Country=="Country"


* First, encode and sort properly
encode Country, gen(country_id)
gen survey_year = real(substr(Survey, 1, 4))  // Extract the first 4 digits as year

* Sort so diffs are within country and in order
sort country_id survey_year

destring anemia_children anemia_women anemia_men, replace force


* Create change variables for each group
gen change_children = anemia_children - anemia_children[_n-1] if country_id == country_id[_n-1]
gen change_women    = anemia_women    - anemia_women[_n-1]    if country_id == country_id[_n-1]
gen change_men      = anemia_men      - anemia_men[_n-1]      if country_id == country_id[_n-1]




tab country if change_children>=9.6 & !missing(change_children)

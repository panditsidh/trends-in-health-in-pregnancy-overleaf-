if "`c(username)'" == "sidhpandit" {
	global nfhs3ir "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/IAIR52FL.dta"
	global nfhs4ir "/Users/sidhpandit/Desktop/nfhs/nfhs4ir/IAIR74FL.DTA"	
	global nfhs5ir "/Users/sidhpandit/Desktop/nfhs/nfhs5ir/IAIR7EFL.DTA"
	
	global nfhs3br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global out_tex "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/tables/up_district_bw.tex"
	
}

if "`c(username)'" == "dc42724" {
	global nfhs3ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\ir\IAIR52FL.dta"
	global nfhs4ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\ir\IAIR71FL.DTA"
	global nfhs5ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAIR7DDT\IAIR7DFL.DTA"
	
	global nfhs3br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\br\IABR52FL.dta"
	global nfhs4br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\br\IABR71FL.DTA"
	global nfhs5br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IABR7EDT\IABR7EFL.DTA"
	
	
	global out_tex "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\tables/up_district_bw.tex"

	
	
	
}


use $nfhs5br, clear

keep if v024==9 // uttar pradesh

keep if b2>=v007-3 // births in the last 3 years

egen strata = group(v000 v024 v025) 
egen psu = group(v000 v001 v024 v025)

svyset psu [pw=v005], strata(strata) singleunit(centered)


* make sure birthweight question is asked for everyone


gen has_bw = !inlist(m19,9996,9998) & m19!=. & !missing(m19)


* source of birthweight, among those for whom it's available

gen bw_from_card = m19a==1 if has_bw==1
gen bw_recalled = m19a==2 if has_bw==1



* bw multiple of 500, among those for whom it's available 

gen bw_500 = mod(m19, 500) == 0 if has_bw==1


* nnm, imr, pnm indicators

gen elapsed = v008-b3 // time elapsed between child's birth and date of interview
gen IMR = 0 if elapsed >= 12 // 0 if child lives past 1 year
replace IMR = 1000 if IMR == 0 & b7 <12 // 1000 if child died before first birthday

gen NNM = 0 if elapsed >= 1 // 0 if child lives past 1 month
replace NNM = 1000 if NNM == 0 & b7 == 0 // 1000 if child died within first month
gen PNM = IMR - NNM
replace PNM = . if NNM == 1000


* birthweight recorded indicator, among neonatal deaths

gen has_bw_nnm = has_bw if NNM==1000


local outcomes has_bw bw_500 has_bw_nnm

local n_outcomes : word count `outcomes'

qui tab sdist if v024==9
local n_districts = r(r)

matrix results = J(`n_districts', 1, .)

foreach outcome in `outcomes' {
	
	qui svy: mean `outcome', over(sdist)
	
	matrix mean = r(table)[1,1..`n_districts']'
	matrix colnames mean = mean_`outcome'
	
	matrix ll = r(table)[5,1..`n_districts']'
	matrix colnames ll = ll_`outcome'
	
	matrix ul = r(table)[6,1..`n_districts']'
	matrix colnames ul = ul_`outcome'
	
	matrix results = results, mean, ll, ul

}


svmat results, names(col)


levelsof sdist, local(levels)
local i = 1
gen str30 district = ""
foreach v of local levels {
    local label : label (sdist) `v'
	replace district = "`label'" in `i'
    local ++i
}



keep mean* ll* ul* district

foreach outcome in `outcomes' {
	
	replace mean_`outcome' = mean_`outcome'*100
	replace ll_`outcome' = ll_`outcome'*100
	replace ul_`outcome' = ul_`outcome'*100
	
	
	gen `outcome' = string(mean_`outcome', "%4.1f") + " (" + string(ll_`outcome', "%4.1f") + ", " + string(ul_`outcome', "%4.1f") + ")" if !missing(mean_`outcome')

}

keep district `outcomes'
drop if missing(district)

#delimit ;
listtex district `outcomes' using $out_tex, replace ///
  rstyle(tabular) ///
  head("\begin{tabular}{lccc}" ///
       "\toprule" ///
       "district & has birthweight record (\%) & birthweight record not 500 (\%) & neonatal deaths with birthweight record (\%) \\\\" ///
       "\midrule") ///
  foot("\bottomrule" ///
       "\end{tabular}"); ///

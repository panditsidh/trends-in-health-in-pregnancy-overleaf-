*This do file uses the dataset that is referred to by $ir_combined.
*For Diane, the path to the dataset is "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"

sort round
by round: sum hg

gen hemo = hg/10
replace hemo=. if hemo>20

by round: sum hemo, detail

gen nfhs4 = round == 4
gen nfhs5 = round ==5
gen nfhs3= round ==3

*NFHS 3 and 5 took place more in the summer months



* 



preserve
collapse hv006 time_decimal round, by(hhid)

twoway (kdensity hv006 if round==3) (kdensity hv006 if round==4) (kdensity hv006 if round==5), legend(on order(1 "NFHS 3" 2 "NFHS 4" 3 "NFHS 5"))

twoway (kdensity time_decimal if round==3) (kdensity time_decimal if round==4) (kdensity time_decimal if round==5), legend(on order(1 "NFHS 3" 2 "NFHS 4" 3 "NFHS 5"))

restore

*There is a relationship between hemoglobin measurement and time of 
lpoly hemo hv801 if round==5 & hv801>741 & hv801<2100, noscatter

*NFHS 5 - huge jump in hemoglobin around covid
lpoly hemo CDCcode if round==5, noscatter


*NFHS 5 - huge jump in hemoglobin around covid
lpoly hemo CDCcode if round==4, noscatter





reghdfe hemo nfhs4 nfhs5 CDCcode i.source, absorb(state)

reghdfe hemo nfhs5 CDCcode time_decimal i.source if inlist(round,4,5), absorb(district) cluster(psu)



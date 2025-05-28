*This do file uses the dataset that is referred to by $ir_combined.
*For Diane, the path to the dataset is "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"

sort round
by round: sum v453

gen hemo = v453/10
replace hemo=. if hemo>20

by round: sum hemo, detail

gen nfhs4 = round == 4
gen nfhs5 = round ==5
gen nfhs3= round ==3

*NFHS 3 and 5 took place more in the summer months
twoway (kdensity v006 if nfhs3==1) (kdensity v006 if nfhs4==1) (kdensity v006 if nfhs5==1), legend(on order(1 "NFHS 3" 2 "NFHS 4" 3 "NFHS 5"))


*There is a relationship between hemoglobin measurement and time of 
lpoly hemo sb28 if round==5 & sb28>741 & sb28<2100, noscatter

*NFHS 5 - huge jump in hemoglobin around covid
lpoly hemo v008a if round==5, noscatter


*NFHS 5 - huge jump in hemoglobin around covid
lpoly hemo v008a if round==4, noscatter


reg hemo 





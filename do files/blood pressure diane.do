*This do file uses the dataset that is referred to by $ir_combined.
*For Diane, the path to the dataset is "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"

*put this variable in the gen variables do file:

gen preg3to11mo = .
replace preg3to11mo = 1 if mopreg>2 &mopreg!=.

sort round
by round: sum bp_s if preg3to11mo, detail
by round: count if bp_s==. &  preg3to11mo == 1
by round: count if bp_s!=. &  preg3to11mo == 1

*BP data are missing for 1% of pregnant women 3-11 mo in NFHS4, 3% of such women in NFHS5


*How many pregnant women have BP readings that qualify as gestational hypertension by trimester?

gen highbp = bp_s>140 
replace highbp=1 if bp_d > 90
replace highbp = . if bp_s==.  
replace highbp = . if bp_d==.  

by round: sum highbp if preg3to11mo==1

gen bmisq=bmi^2

*3.5% of women in NFHS4 and 3.6% of women in NFHS5 had high bp by this definition.

twoway (lpoly bp_s age_in_mo_at_survey if groups6==1 & preg3to11mo==1) (lpoly bp_s age_in_mo_at_survey if groups6==3 & preg3to11mo==1), legend(order(1 "forward caste" 2 "dalit"))

reg bp_s dalit i.mopreg bmi bmisq age_in_mo_at_survey if (groups6==3 | groups6==1) & preg3to11mo==1

*at first glance, not differences by social group in average systolic or diastolic BP
by groups6: sum bp_s if preg3to11mo==1
by groups6: sum bp_d if preg3to11mo==1

by groups6: sum highbp if preg3to11mo==1

*a slightly higher prevalence of high bp among forward caste pregnant women relative to dalits seems to be explained by age differences
reg highbp dalit age_in_mo_at_survey if (groups6==3 | groups6==1) & preg3to11mo==1
reg age_in_mo_at_survey dalit if (groups6==3 | groups6==1) & preg3to11mo==1

gen hhtype = .
replace hhtype=1 if nuclear==1
replace hhtype=2 if sasural==1
replace hhtype=3 if natal==1

by hhtype: sum bp_s if preg3to11mo==1
by hhtype: sum bp_d if preg3to11mo==1

by hhtype: sum highbp if preg3to11mo==1

gen firstpreg= v219==1
replace firstpreg=. if v219==.

*this regression suggests that social support matters for BP
*women in nuclear families are more likely to have high bp than women in natal and sasural
*forward caste have higher due to age, and possibly also prepregnancy bmi
reg highbp nuclear sasural i.groups6 i.region i.mopreg i.round firstpreg age_in_mo_at_survey if preg3to11mo==1 

*north and northeast have higher BP than other regions
by region: sum highbp if preg3to11mo==1

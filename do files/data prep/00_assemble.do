* This code runs the reweighting within survey round, then across

if "`c(username)'" == "sidhpandit" {
	global nfhs3ir "/Users/sidhpandit/Desktop/nfhs/nfhs3ir/IAIR52FL.dta"
	global nfhs4ir "/Users/sidhpandit/Desktop/nfhs/nfhs4ir/IAIR74FL.DTA"	
	global nfhs5ir "/Users/sidhpandit/Desktop/nfhs/nfhs5ir/IAIR7EFL.DTA"
	
	global nfhs3br "/Users/sidhpandit/Desktop/nfhs/nfhs3br/IABR52FL.dta"
	global nfhs4br "/Users/sidhpandit/Desktop/nfhs/nfhs4br/IABR74FL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global ir_combined "/Users/sidhpandit/Desktop/ra/ir345_prepregweights.dta"
	
	global reweighting "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/do files/data prep/01_reweighting.do"
	
	global gen_vars "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/do files/data prep/02_gen_vars.do"
	
	global gen_hhstruc "/Users/sidhpandit/Documents/GitHub/trends-in-health-in-pregnancy-overleaf-/do files/data prep/03_gen_hhstruc.do"
	
}

if "`c(username)'" == "dc42724" {
	global nfhs3ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\ir\IAIR52FL.dta"
	global nfhs4ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\ir\IAIR71FL.DTA"
	global nfhs5ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAIR7DDT\IAIR7DFL.DTA"
	
	global nfhs3br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\br\IABR52FL.dta"
	global nfhs4br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\br\IABR71FL.DTA"
	global nfhs5br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IABR7EDT\IABR7EFL.DTA"

	global ir_combined "C:\Users\dc42724\Dropbox\K01\trends_health_pregnancy\datasets\ir345_trends_pregnancy.dta"
	
	global reweighting "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\do files\data prep\01_reweighting.do"
	
	global gen_vars "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\do files\data prep\02_gen_vars.do"
	
	global gen_hhstruc "C:\Users\dc42724\Documents\GitHub\trends-in-health-in-pregnancy-overleaf-\do files\data prep\03_gen_hhstruc.do"
	
}


* initialize general ir and br file paths - the loop will reassign them to the each survey round
global nfhs_ir $nfhs3ir
global nfhs_br $nfhs3br



* this loop creates reweighting variables for each survey round, and saves them in a tempfile to be appended later
foreach x of numlist 3/5 {
	
	clear all

	if `x'==3 { 
		global nfhs_ir $nfhs3ir
		global nfhs_br $nfhs3br
		
		use caseid s824b w124 v044 d* s46* v*  using $nfhs_ir	
		
		qui do "${reweighting}"
		tempfile nfhs3
		save `nfhs3'
	}
		
	if `x'==4 { 
		
		global nfhs_ir $nfhs4ir
		global nfhs_br $nfhs4br
		
		use caseid s928b s930 s927 v743a* v044 d105a-d105j d129 s907 s908 s116 v* s236 s220b* ssmod sb* sb16d sb23d sb27d sb16s sb23s sb27s using $nfhs_ir
		
		qui do "${reweighting}"
		
		tempfile nfhs4
		save `nfhs4'
	}
		
	if `x'==5 { 
		global nfhs_ir $nfhs5ir
		global nfhs_br $nfhs5br
		
		use caseid s930b s932 s929 v743a* v044 d105a-d105j d129 s909 s910 s920 s116 v* s236 s220b* ssmod sb* sb18d sb25d sb29d sb18s sb25s sb29s using $nfhs_ir	
		
		qui do "${reweighting}"

	}

}

append using `nfhs4'
append using `nfhs3'

* at this point, we have all survey rounds stacked with reweighting variables generated

* now we generate other variables
do "${gen_vars}"

save $ir_combined, replace

do "${gen_hhstruc}"

save $ir_combined, replace





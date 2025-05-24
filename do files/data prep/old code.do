
/*
* Step 1: Create the variable
gen group = .

* Step 2: Hindus by caste
* NFHS-3: caste in s46, religion in v130
replace group = 1 if v130 == 1 & s46 == 4 & round == 3 // Forward Caste
replace group = 2 if v130 == 1 & s46 == 3 & round == 3 // OBC
replace group = 3 if v130 == 1 & s46 == 1 & round == 3 // Dalit
replace group = 4 if v130 == 1 & s46 == 2 & round == 3 // Adivasi

* NFHS-4/5: caste in s116, religion in v130
replace group = 1 if v130 == 1 & s116 == 4 & inlist(round, 4, 5) // Forward Caste
replace group = 2 if v130 == 1 & s116 == 3 & inlist(round, 4, 5) // OBC
replace group = 3 if v130 == 1 & s116 == 1 & inlist(round, 4, 5) // Dalit
replace group = 4 if v130 == 1 & s116 == 2 & inlist(round, 4, 5) // Adivasi

* Step 3: Non-Hindu religion dominates
replace group = 5 if v130 == 2  // Muslim
replace group = 6 if inlist(v130, 3, 4, 6) // Christian, Sikh, Jain

* Step 4: Assign label
label define grouplbl ///
    1 "Forward Caste" ///
    2 "OBC" ///
    3 "Dalit" ///
    4 "Adivasi" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian"

label values group grouplbl

gen forward = group==1
gen obc = group==2
gen dalit = group==3
gen adivasi = group==4
gen muslim = group==5
gen sikh_jain_christian = group==6
gen other_group = missing(group)

label var forward "Forward"
label var obc "OBC"
label var dalit "Dalit"
label var adivasi "Adivasi"
label var muslim "Muslim"
label var sikh_jain_christian "Sikh, Jain or Christian"
label var other_group "Other social group"
*/
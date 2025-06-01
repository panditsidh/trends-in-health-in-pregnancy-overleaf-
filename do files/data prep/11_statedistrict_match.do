* This file generates a consistent variable "state" and "district" across all 3 survey rounds of the household member recode.


// 1. Match states (ChatGPT)

gen state = .

* NFHS-5 coding (already mostly aligned to modern geography)
replace state = hv024 if round == 5

* NFHS-4 remapping
replace state = 35 if round == 4 & hv024 == 1   // Andaman and Nicobar Islands
replace state = 28 if round == 4 & hv024 == 2   // Andhra Pradesh
replace state = 12 if round == 4 & hv024 == 3   // Arunachal Pradesh
replace state = 18 if round == 4 & hv024 == 4   // Assam
replace state = 10 if round == 4 & hv024 == 5   // Bihar
replace state = 4  if round == 4 & hv024 == 6   // Chandigarh
replace state = 22 if round == 4 & hv024 == 7   // Chhattisgarh
replace state = 25 if round == 4 & hv024 == 8   // Dadra & Nagar Haveli
replace state = 25 if round == 4 & hv024 == 9   // Daman & Diu
replace state = 30 if round == 4 & hv024 == 10  // Goa
replace state = 24 if round == 4 & hv024 == 11  // Gujarat
replace state = 6  if round == 4 & hv024 == 12  // Haryana
replace state = 2  if round == 4 & hv024 == 13  // Himachal Pradesh
replace state = 1  if round == 4 & hv024 == 14  // Jammu & Kashmir
replace state = 20 if round == 4 & hv024 == 15  // Jharkhand
replace state = 29 if round == 4 & hv024 == 16  // Karnataka
replace state = 32 if round == 4 & hv024 == 17  // Kerala
replace state = 31 if round == 4 & hv024 == 18  // Lakshadweep
replace state = 23 if round == 4 & hv024 == 19  // Madhya Pradesh
replace state = 27 if round == 4 & hv024 == 20  // Maharashtra
replace state = 14 if round == 4 & hv024 == 21  // Manipur
replace state = 17 if round == 4 & hv024 == 22  // Meghalaya
replace state = 15 if round == 4 & hv024 == 23  // Mizoram
replace state = 13 if round == 4 & hv024 == 24  // Nagaland
replace state = 7  if round == 4 & hv024 == 25  // Delhi
replace state = 21 if round == 4 & hv024 == 26  // Odisha
replace state = 34 if round == 4 & hv024 == 27  // Puducherry
replace state = 3  if round == 4 & hv024 == 28  // Punjab
replace state = 8  if round == 4 & hv024 == 29  // Rajasthan
replace state = 11 if round == 4 & hv024 == 30  // Sikkim
replace state = 33 if round == 4 & hv024 == 31  // Tamil Nadu
replace state = 16 if round == 4 & hv024 == 32  // Tripura
replace state = 9  if round == 4 & hv024 == 33  // Uttar Pradesh
replace state = 5  if round == 4 & hv024 == 34  // Uttarakhand
replace state = 19 if round == 4 & hv024 == 35  // West Bengal
replace state = 36 if round == 4 & hv024 == 36  // Telangana

* NFHS-3 remapping
replace state = 1  if round == 3 & hv024 == 1   // Jammu & Kashmir
replace state = 2  if round == 3 & hv024 == 2   // Himachal Pradesh
replace state = 3  if round == 3 & hv024 == 3   // Punjab
replace state = 5  if round == 3 & hv024 == 5   // Uttaranchal = Uttarakhand
replace state = 6  if round == 3 & hv024 == 6   // Haryana
replace state = 7  if round == 3 & hv024 == 7   // Delhi
replace state = 8  if round == 3 & hv024 == 8   // Rajasthan
replace state = 9  if round == 3 & hv024 == 9   // Uttar Pradesh
replace state = 10 if round == 3 & hv024 == 10  // Bihar
replace state = 11 if round == 3 & hv024 == 11  // Sikkim
replace state = 12 if round == 3 & hv024 == 12  // Arunachal Pradesh
replace state = 13 if round == 3 & hv024 == 13  // Nagaland
replace state = 14 if round == 3 & hv024 == 14  // Manipur
replace state = 15 if round == 3 & hv024 == 15  // Mizoram
replace state = 16 if round == 3 & hv024 == 16  // Tripura
replace state = 17 if round == 3 & hv024 == 17  // Meghalaya
replace state = 18 if round == 3 & hv024 == 18  // Assam
replace state = 19 if round == 3 & hv024 == 19  // West Bengal
replace state = 20 if round == 3 & hv024 == 20  // Jharkhand
replace state = 21 if round == 3 & hv024 == 21  // Orissa = Odisha
replace state = 22 if round == 3 & hv024 == 22  // Chhattisgarh
replace state = 23 if round == 3 & hv024 == 23  // Madhya Pradesh
replace state = 24 if round == 3 & hv024 == 24  // Gujarat
replace state = 27 if round == 3 & hv024 == 27  // Maharashtra
replace state = 28 if round == 3 & hv024 == 28  // Andhra Pradesh
replace state = 29 if round == 3 & hv024 == 29  // Karnataka
replace state = 30 if round == 3 & hv024 == 30  // Goa
replace state = 32 if round == 3 & hv024 == 32  // Kerala
replace state = 33 if round == 3 & hv024 == 33  // Tamil Nadu


label define statelbl ///
    1 "Jammu & Kashmir" ///
    2 "Himachal Pradesh" ///
    3 "Punjab" ///
    4 "Chandigarh" ///
    5 "Uttarakhand" ///
    6 "Haryana" ///
    7 "Delhi" ///
    8 "Rajasthan" ///
    9 "Uttar Pradesh" ///
    10 "Bihar" ///
    11 "Sikkim" ///
    12 "Arunachal Pradesh" ///
    13 "Nagaland" ///
    14 "Manipur" ///
    15 "Mizoram" ///
    16 "Tripura" ///
    17 "Meghalaya" ///
    18 "Assam" ///
    19 "West Bengal" ///
    20 "Jharkhand" ///
    21 "Odisha" ///
    22 "Chhattisgarh" ///
    23 "Madhya Pradesh" ///
    24 "Gujarat" ///
    25 "Dadra & Nagar Haveli and Daman & Diu" ///
    27 "Maharashtra" ///
    28 "Andhra Pradesh" ///
    29 "Karnataka" ///
    30 "Goa" ///
    31 "Lakshadweep" ///
    32 "Kerala" ///
    33 "Tamil Nadu" ///
    34 "Puducherry" ///
    35 "Andaman & Nicobar Islands" ///
    36 "Telangana" ///
    37 "Ladakh"

label values state statelbl


// 2. Match districts (Nathan's code)

gen district = shdistri if hv000 == "IA6"
replace district = shdist if hv000 == "IA7" & shdist < 800

* Harmonize districts that changed between NFHS-4 and NFHS-5
replace district = 2000 if inlist(shdist,879,880) | inlist(shdistri,43)         // Firozpur → Fazilka
replace district = 2001 if inlist(shdist,881,882) | inlist(shdistri,35)         // Gurdaspur → Pathankot
replace district = 2002 if inlist(shdist,865,866) | inlist(shdistri,81)         // Bhiwani → Charkhi Dadri
replace district = 2003 if inlist(shdist,837,838,839,840,841,842,843,844,845,846,847) | ///
                        inlist(shdistri,90,91,92,93,94,95,96,97,98)             // Delhi → 11 subdistricts
replace district = 2004 if inlist(shdist,921,927,930) | inlist(shdistri,158,179) // Rae Bareli, Sultanpur → Amethi
replace district = 2005 if inlist(shdist,923,924) | inlist(shdistri,140)         // Ghaziabad → Hapur
replace district = 2006 if inlist(shdist,922,925,928) | inlist(shdistri,135,149) // Budaun → Sambhal
replace district = 2007 if inlist(shdist,926,929) | inlist(shdistri,133)         // Muzaffarnagar → Shamli

* Arunachal Pradesh
replace district = 2008 if inlist(shdist,802,803) | inlist(shdistri,256)         // Kurung Kumey → Kra Daadi
replace district = 2009 if inlist(shdist,804,806) | inlist(shdistri,259)         // Lohit → Namsai
replace district = 2010 if inlist(shdist,805,808) | inlist(shdistri,254)         // Tirap → Longding
replace district = 2011 if inlist(shdist,801,807,809) | inlist(shdistri,250,251) // West Siang → Siang, etc.

* Tripura
replace district = 2012 if inlist(shdist,915,917,920) | inlist(shdistri,289)     // West Tripura → Gomati, Sepahijala
replace district = 2013 if inlist(shdist,914,918) | inlist(shdistri,290)         // South Tripura → South, etc.
replace district = 2014 if inlist(shdist,916,919) | inlist(shdistri,292)         // North Tripura → Unakoti

* Meghalaya
replace district = 2015 if inlist(shdist,871,873) | inlist(shdistri,294)
replace district = 2016 if inlist(shdist,872,877) | inlist(shdistri,299)
replace district = 2017 if inlist(shdist,875,878) | inlist(shdistri,296)
replace district = 2018 if inlist(shdist,874,876) | inlist(shdistri,293)

* Assam
replace district = 2019 if inlist(shdist,810,819) | inlist(shdistri,306)
replace district = 2020 if inlist(shdist,811,818) | inlist(shdistri,311)
replace district = 2021 if inlist(shdist,813,817) | inlist(shdistri,305)
replace district = 2022 if inlist(shdist,812,820) | inlist(shdistri,301)
replace district = 2023 if inlist(shdist,815,821) | inlist(shdistri,314)
replace district = 2024 if inlist(shdist,814,816) | inlist(shdistri,312)

* West Bengal
replace district = 2025 if inlist(shdist,931,932) | inlist(shdistri,335)

* Chhattisgarh
replace district = 2026 if inlist(shdist,822,826,829) | inlist(shdistri,409)
replace district = 2027 if inlist(shdist,823,830,833) | inlist(shdistri,410)
replace district = 2028 if inlist(shdist,824,835,836) | inlist(shdistri,401)
replace district = 2029 if inlist(shdist,825,831) | inlist(shdistri,414)
replace district = 2030 if inlist(shdist,827,832) | inlist(shdistri,406)
replace district = 2031 if inlist(shdist,828,834) | inlist(shdistri,416)

* Madhya Pradesh
replace district = 2032 if inlist(shdist,867,868) | inlist(shdistri,436)

* Gujarat
replace district = 2033 if inlist(shdist,849,862) | inlist(shdistri,472)
replace district = 2034 if inlist(shdist,848,850,851) | inlist(shdistri,474,481)
replace district = 2035 if inlist(shdist,852,864) | inlist(shdistri,486)
replace district = 2036 if inlist(shdist,857,858,860) | inlist(shdistri,483,484)
replace district = 2037 if inlist(shdist,853,855,859,861,863) | inlist(shdistri,475,476,477)
replace district = 2038 if inlist(shdist,854,856) | inlist(shdistri,479)

* Maharashtra
replace district = 2039 if inlist(shdist,869,870) | inlist(shdistri,517)

* Telangana
replace district = 2040 if inlist(shdist,883,893,896,901) | inlist(shdistri,532)
replace district = 2041 if inlist(shdist,884,886,887,888,891,892,894,897,900,903,904,906,907,908,911,912,913) | ///
                        inlist(shdistri,534,535,539,540,541)
replace district = 2042 if inlist(shdist,885) | inlist(shdistri,536)
replace district = 2043 if inlist(shdist,898,905,909) | inlist(shdistri,537)
replace district = 2044 if inlist(shdist,889,895,899,910) | inlist(shdistri,538)
replace district = 2045 if inlist(shdist,890,902) | inlist(shdistri,533)

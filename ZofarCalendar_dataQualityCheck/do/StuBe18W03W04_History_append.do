****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history.csv, Studienberechtigte 2018.3b
**					history.csv, Studienberechtigte 2018.4
** created by:		Schulze, Andrea
****************************************************************************

version 17

global c2018w3b "${orig}slc_StuBe18-3b\orig\2021-04-21\"
global c2018w4 "${orig}slc_StuBe18-4\orig\2023-06-07\"

cd "${workdir}\log"
cap log close
log using log_append_`: di %tdCY-N-D daily("$S_DATE", "DMY")', append

*_________________________________________________________________
** Do-File zur Erstellung eines gemeinsamen history-Datensatzes
*_________________________________________________________________

*********************************************************************
** append data sets
** - history data from SLC Studienberechtigte 2018, wave 3b
** - history data from SLC Studienberechtigte 2018, wave 4 
** 
*********************************************************************

************************************************************************
*** preparing 2018, wave 3b 
import delimited "${c2018w3b}history.csv", delimiter(comma) bindquote(strict) clear 

* generate wave id 
gen wave= 201803
tostring participant_id, gen(part_id)

* generate unique participant_id, including wave identifier
cap drop pid
gen pid="201803"+part_id
drop part_id

save "${datadir}history_2018-3b.dta", replace


************************************************************************
*** preparing 2018, wave 4 
import delimited "${c2018w4}history.csv", delimiter(comma) bindquote(strict) clear 
* generate wave id 
gen wave= 201804
tostring participant_id, gen(part_id)

* generate unique participant_id, including wave identifier
cap drop pid
gen pid="201804"+part_id
drop part_id

save "${datadir}history_2018-4.dta", replace

************************************************************************
*** add wave 3b data
append using "${datadir}history_2018-3b.dta"


*____________delete test cases ____________________
foreach t of numlist 1/500 {
	quiet: drop if token=="tester`t'" | token=="part`t'"
}


*____________label wave ____________________
*label define wavelb 201803 "2018, 3. Welle" 201804 "2018, 4. Welle"
label define wavelb 201803 "static calendar" 201804 "dynamic calendar"
label val wave wavelb
label var wave "calendar type"


************************************************************************
*** save merged data
save "${datadir}history_2018w3bw4.dta", replace
************************************************************************

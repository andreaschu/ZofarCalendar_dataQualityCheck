****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4.dta
** created by:		Schulze, Andrea
****************************************************************************


cd "${workdir}log"
cap log close
log using log_pageNumModule_`: di %tdCY-N-D daily("$S_DATE", "DMY")', append


*_________________________________________________________________
** Do-File zur Aufbereitung der history-Daten (SLC, Studienberechtigte 2018, 3. und 4. Welle)
*_________________________________________________________________


*____________Daten importieren____________________
use "${datadir}history_2018w3bw4.dta", clear



*_________Zeitstempel in numerische Variable umwandeln_______
gen double seiteneing=clock(timestamp, "YMDhms")

format seiteneing %-tc
label var seiteneing "Zeitstempel für Seiteneingang"


*________Berechnung der Verweildauer pro Seite (in Sekunden)____
//Achtung: automatischer SessionTimeout i.d.R. nach einer halben Stunde
sort participant_id seiteneing, stable
gen verwdauer= seiteneing[_n+1]-seiteneing if participant_id==participant_id[_n+1]

replace verwdauer= verwdauer/1000

label var verwdauer "Verweildauer pro Seite in Sekunden"

tabstat verwdauer, statistics(mean median min max sd)
//Korrektur der Verweildauer auf max. 30 Minuten (1800 Sekunden) pro Seitenbesuch
replace verwdauer=1800 if verwdauer>1800 & verwdauer!=.


*__________Fragebogenseiten nummerieren___________
// Seitennummerierung nach Reihenfolge im Fragebogen (QML)
gen pagenum=.

do "${dodir}define_Pagenum_StuBe18-3.do"
do "${dodir}define_Pagenum_StuBe18-4.do"

tab page if pagenum==.

label var pagenum "Fragebogenseite"



*__________maximaler Fragebogenfortschritt___________
sort pid id, stable
by pid: egen maxpage03 = max(pagenum) if wave==201803
by pid: egen maxpage04 = max(pagenum) if wave==201804
gen maxpage=maxpage03 if wave==201803
replace maxpage=maxpage04 if wave==201804
drop maxpage03 maxpage04

label var maxpage "maximaler Fortschritt im Fragebogen"


*__________letzte Fragebogenseite___________
sort pid id, stable
by pid: gen last = pagenum if pid!=pid[_n+1]
by pid: egen lastpage = max(last)
label var lastpage "letzte gesehene Fragebogenseite"
drop last


*__________Fragebogen beendet___________
sort pid id, stable
cap by pid: gen finished = 0
cap by pid: replace finished= 1 if  lastpage==1780 /*end_0*/ | lastpage==1781 /*end*/
cap label define finlb 0 "unfinished" 1 "finished"
cap label val finished finlb
label var lastpage "Beendigungsstatus des Fragebogens"



*______Seitenaufrufe pro Seite pro Befragten im Verlauf der Befragung_________
sort pid pagenum, stable
by pid pagenum: gen visit=_N
label var visit "Anzahl des Seitenaufrufes im Verlauf der Befragung"


*__________Fragebogenseiten zu Modul zuordnen ____________________________
*     (siehe auch weiter unten: "Boxplot Bearbeitungsdauer nach Modul")
gen modul=""

do "${dodir}define_Module_StuBe18-3.do"
do "${dodir}define_Module_StuBe18-4.do"

label var modul "Fragenmodul"


*______________________________________________________________________________
*__________Paradaten aus Befragungsdaten anspielen ____________________________
*** [1] 2018.3b

* calendar range in wave==201803
// "h_exitlabel" ="'Dezember 2020'"
// "h_enterdatum" ="'Januar 2020'" condition="PRELOADwave.value == '1'"
// "h_enterdatum" ="'Juli 2018'" condition="PRELOADwave.value != '1'"


merge m:1 token using "${orig}slc_StuBe18-3b\lieferung\studpanel18.3b_export_2021-04-21\csv\data.dta", ///
	keepusing(preloadcohort_id preloadwave uas jscheck jscheck2 jscheck3 ismobile ismobile2 ismobile3 /// 
	width width2 width3 height height2 height3 )

destring jscheck, replace force
rename _merge merge201803

   
*** [2] 2018.4

* calendar range in wave==201804
// "calendar_range_start_month"="'01'"
// "calendar_range_start_year" ="2021" condition="(epiretro==1)"
// "calendar_range_start_year" ="2020" condition="(epiretro==2)"
// "calendar_range_start_year" ="2019" condition="(epiretro==3)"
// "calendar_range_end_month" ="'02'"
// "calendar_range_end_year" ="'2023'"

merge m:1 token using "${orig}slc_StuBe18-4\lieferung\slc_Stube18-4_korrektur_2023-06-07\csv\data.dta" , /// 
	keepusing(uas ismobile ///
	jscheck jscheck1 jscheck_stu /// 
	width width1 width_t width_stu /// 
	height height1 height_t height_stu ///
	preloadepiretro preloadsample_23 calendarstate complete panel_id)  ///
	update

*____________leere gemergte Fälle löschen ____________________
drop if _merge==2

/*
foreach t of numlist 1/200 {
	quiet: drop if token=="tester`t'" | token=="part`t'"
}
*/


*____________Variablen für weitere Analysen erstellen ____________________
do "${dodir}StuBe18W03W04_History_createVariables.do"

/*
// Test: panel_id (201804) = preloadcohort_id (201803)
gen pers_id =substr(preloadcohort_id, 1,10)
(861,194 missing values generated)

replace pers_id= panel_id if test==""
(861,194 real changes made)
*/

*____________Arbeitsdatensatz speichern ____________________
save "${datadir}history_2018w3bw4_enriched.dta", replace

log close

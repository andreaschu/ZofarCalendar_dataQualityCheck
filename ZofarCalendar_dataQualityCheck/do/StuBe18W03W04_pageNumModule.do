****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4.dta
** created by:		Schulze, Andrea
****************************************************************************

/*
version 17

global orig "..\slc_stube18\"
global workdir "..\esra23_calendar\"

global dodir "${workdir}do\"
global datadir "${workdir}data\"
global log "${workdir}log\"
global out "${workdir}out\"
*/

cd "${workdir}log"
cap log close
log using log_pageNumModule_`: di %tdCY-N-D daily("$S_DATE", "DMY")', append


*_________________________________________________________________
** Do-File zur Aufbereitung der history-Daten (SLC, Studienberechtigte 2018, 3. Welle)
*_________________________________________________________________

*____________Daten importieren____________________
*import delimited "${orig}history.csv", delimiter(comma) bindquote(strict) clear 
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
by pid: egen maxpage03 = max(pagenum) if cohort==201803
by pid: egen maxpage04 = max(pagenum) if cohort==201804
gen maxpage=maxpage03 if cohort==201803
replace maxpage=maxpage04 if cohort==201804
drop maxpage03 maxpage04

label var maxpage "maximaler Fortschritt im Fragebogen"


*__________letzte Fragebogenseite___________
sort pid id, stable
by pid: gen last = pagenum if pid!=pid[_n+1]
by pid: egen lastpage = max(last)
label var lastpage "letzte gesehene Fragebogenseite"
drop last


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




log close

*__________Paradaten aus Befragungsdaten anspielen ____________________________
* merge 201803
/// ismobile ismobile1 ismobile2 
/// width width1 width2, height height1 height2
/// uas
/// jscheck

* merge 201804
/// ismobile 
/// width height
/// jscheck

/*cap drop jscheck ismobile uas jscheck2 ismobile2 jscheck3 ismobile3 width height width2 height2 width3 height3 merge201803 jscheck1 jscheck_stu height_t width_t height1 width1 height_stu width_stu _merge moduldauer moduldauer_minutes moduln cohortstrng modul_labeled screenwidth mobile_view
save "${datadir}history_2018w3bw4_enriched_dropped.dta", replace


use "${datadir}history_2018w3bw4_enriched_dropped.dta", clear 
*/

merge m:1 token using "${orig}slc_StuBe18-3b\lieferung\studpanel18.3b_export_2021-04-21\csv\data.dta", keepusing(uas jscheck ismobile width height width2 width3 height2 height3 ismobile2 ismobile3 jscheck2 jscheck3)


destring jscheck, replace force
rename _merge merge201803
 
merge m:1 token using "${orig}slc_StuBe18-4\lieferung\slc_Stube18-4_export_2023-06-07\csv\data.dta" , keepusing(uas jscheck ismobile width height width1 width_t width_stu height1 height_t height_stu  jscheck1 jscheck_stu) update


save "${datadir}history_2018w3bw4_enriched.dta", replace


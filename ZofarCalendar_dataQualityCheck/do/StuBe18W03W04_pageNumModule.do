****************************************************************************
** Projekt/ Studie:       Vortrag auf ESRA23
** 						
** Erstelldatum:          2023-06-20
** Bearbeitet von:        Schulze, Andrea
****************************************************************************

version 17

global orig "slc\slc_stube18\"
glglobal workdir "ZofarCalendar_dataQualityCheck\esra23_calendar\"

global dodir "${workdir}do\"
global datadir "${workdir}data\"
global log "${workdir}log\"
global out "${workdir}out\"

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

do "${dodir}definePagenum_StuBe18-3.do"
do "${dodir}definePagenum_StuBe18-4.do"

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

do "${dodir}defineModule_StuBe18-3.do"
do "${dodir}defineModule_StuBe18-4.do"

label var modul "Fragenmodul"


log close

save "${datadir}history_2018w3bw4_enriched.dta", replace


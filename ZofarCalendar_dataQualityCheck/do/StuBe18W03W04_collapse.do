****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4_enriched.dta
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

*cd "${workdir}log"
*cap log close

*************************************************************************
use "${datadir}history_2018w3bw4_enriched.dta", clear

*_______überflüssige Variablen löschen_________
drop id timestamp



*************************************************************************
****** Datensatz umwandeln in ein breites Format mit aggregierten Daten **

*________Datensatz aggregieren____________________
// Datensatz reduzieren auf eine Zeile pro Befragten und Fragebogenseite
// !Achtung: bei mehrmaligem Laden einer Seite wird der Verbleib summiert!
bysort pid page: gen allmiss=mi(verwdauer)

*** Datensatz reduzieren

collapse (sum) verwdauer (first) token pagenum  modul cohort participant_id     ///
		seiteneing (max) allmiss visit (mean) maxpage lastpage, ///
		by(pid page)
		

//Korrektur des automatischen Ersetzens von fehlenden Werten mit 0 
replace verwdauer=. if  allmiss


save "${datadir}history_2018w3bw4_collapsed.dta", replace

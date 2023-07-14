****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4_enriched.dta
** created by:		Schulze, Andrea
****************************************************************************



*_________________________________________________________________
** Do-File zur Reduzierung der Daten auf ein Fall pro Befragungsseite je Person**
*_________________________________________________________________


use "${datadir}history_2018w3bw4_enriched.dta", clear



*_______überflüssige Variablen löschen_________
drop id timestamp panel_id preloadcohort_id



*________Datensatz aggregieren____________________
** Marker setzen für Seiten, die keine Verweildauer haben (weil es die letzte Befragungsseite ist)
bysort pid page: gen allmiss=mi(verwdauer)


** Datensatz reduzieren auf eine Zeile pro Befragten und Fragebogenseite
// !Achtung: bei mehrmaligem Laden einer Seite wird der Verbleib summiert!
collapse (sum) verwdauer (first) token pagenum  modul wave participant_id     ///
		seiteneing (max) allmiss visit (mean) maxpage lastpage, ///
		by(pid page)
		

//Korrektur des automatischen Ersetzens von fehlenden Werten mit 0 
replace verwdauer=. if  allmiss


save "${datadir}history_2018w3bw4_collapsed.dta", replace
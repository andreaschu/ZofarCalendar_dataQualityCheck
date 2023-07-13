****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history.csv, Studienberechtigte 2018.3b
**					history.csv, Studienberechtigte 2018.4
** created by:		Schulze, Andrea
****************************************************************************


*********************************************************************
** Ziel: Antwortqualität von Episodendaten 
**    -> Vergleich neues Zofar-Kalendarium und dynamischen Episodendaten
**       mit vorheriger Lösung und 'altem' Kalendarium
** Qualitätskriterien: 
**    - responseTime - erster Besuch der Kalendarseite
**    - responseTime des Episodenmoduls gesamt
**    - Abbrüche (erster Besuch der Kalender-Page)
**    - Abbrüche im Episodenmodul gesamt
*********************************************************************


version 17

*global version "2023-06-19"

di "`c(pwd)'"

cd ..
global root "`c(pwd)'"


global orig "P:\Zofar\slc\slc_stube18\"
global workdir "P:\Zofar\Schulze\esra23_calendar\"

global dodir "${workdir}do\"
global datadir "${workdir}data\"
global log "${workdir}log\"
global out "${workdir}out\"

set maxvar 8000, perm
*********************************************************************
*** [1.] History-Daten zusammenführen
do "${dodir}StuBe18W03W04_History_append.do"
// out: history_2018w3bw4.dta

*** [2.] History-Daten aufbereiten, mit Paradaten anreichern
do "${dodir}StuBe18W03W04_History_pageNumModule.do"
// out: history_2018w3bw4_enriched.dta 

*** [3.] History-Daten reduzieren
// eine Zeile pro Seite, pro Person
do "${dodir}StuBe18W03W04_History_collapse.do"
// out: history_2018w3bw4_collapsed.dta

*** [4.] Auswertungen: Abbrüche und Antwortzeiten 
do "${dodir}nls_respTime_breakoffs.do"
// use: ${datadir}history_2018w3bw4_collapsed.dta
// out: ${out}slc_StuBe18W3_abbrecher.xls
// out: ${out}slc_StuBe18W4_abbrecher.xls
// out: ${out}slc_StuBe18W3_verwdauer.xls
// out: ${out}slc_StuBe18W4_verwdauer.xls

*** [5.] Auswertungen: Antwortzeiten nach Modul
do "${dodir}nls_boxPlot_respTime.do"
// use: ${datadir}history_2018w3bw4_enriched.dta
// out: ${out}ResponseTime_nachModul.gph

*** [6.] Auswertungen: Vergleich Antwortzeiten nach Wellen/ Kalendarien
do "${dodir}nls_respTimeCalendar.do"
// use:  ${datadir}history_2018w3bw4_enriched.dta

*** [7.] Coefplot
*do "${dodir}nls_coefplot.do"
// use:  ${datadir}history_2018w3bw4_enriched.dta


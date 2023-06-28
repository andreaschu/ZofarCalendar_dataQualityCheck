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


global orig "..\slc_stube18\"
global workdir "..\esra23_calendar\"

global dodir "${workdir}do\"
global datadir "${workdir}data\"
global log "${workdir}log\"
global out "${workdir}out\"

set maxvar 8000, perm
*********************************************************************

do "${dodir}StuBe18W03W04_History_append.do"
// out: history_2018w3bw4.dta

do "${dodir}StuBe18W03W04_History_pageNumModule.do"
*do "${dodir}historyAufbereitung_StuBe18W03W04.do"
// out: history_2018w3bw4_enriched.dta 


do "${dodir}StuBe18W03W04_History_collapse.do"
// out: history_2018w3bw4_collapsed.dta

do "${dodir}nls_respTime_breakoffs.do"
// 

do "${dodir}nls_boxPlot_respTime.do"
// 

do "${dodir}nls_respTimeCalendar.do"
// 

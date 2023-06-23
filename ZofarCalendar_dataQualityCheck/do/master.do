****************************************************************************
** Projekt/ Studie:       Vortrag auf ESRA23
** Erstelldatum:          2023-06-20
** Datensätze:            history.csv, Studienberechtigte 2018.3b
**						  history.csv, Studienberechtigte 2018.4
** Bearbeitet von:        Schulze, Andrea
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


glglobal workdir "ZofarCalendar_dataQualityCheck\esra23_calendar\"
global dodir "${workdir}do\"



*********************************************************************

do "${dodir}append_StuBe18W03W04.do"
// history_2018w3bw4.dta

do "${dodir}StuBe18W03W04_pageNumModule.do"
*do "${dodir}historyAufbereitung_StuBe18W03W04.do"
// history_2018w3bw4_enriched.dta 


do "${dodir}StuBe18W03W04_collapse.do"
// history_2018w3bw4_collapsed.dta

do "${dodir}nls_respTime_breakoffs.do"
// .dta

*do "${dodir}nls_boxPlot_respTimeModule.do"
// .dta

****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4_enriched.dta
** created by:		Schulze, Andrea
****************************************************************************

use "${datadir}history_2018w3bw4_enriched.dta", clear

*____________ response time for calendar pages (on first visit)
table page if visit==1 & (((page=="cal1" | page=="cal25") & cohort==201803) | (page=="calendar" & cohort==201804)), stat(n verwdauer )  stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.2f)

quiet: tabout page using "${out}slc_StuBe18W3W4_resTimeCalendar.xls" ///
	if visit==1 & (((page=="cal1" | page=="cal25") & cohort==201803) | (page=="calendar" & cohort==201804)), ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma

	
	
	
*____________ T-Test (Kalendarium)
ttest verwdauer if visit==1 & ((page=="cal1" | page=="cal25") | page=="calendar"), by(cohort)


*____ Bildschirmbreite mit Werten von beiden Befragungen, die kurz vor Kalendarium abgefragt wurde
// width3 -> cohort=201803
// width -> cohort=201804
cap drop screenwidth
gen screenwidth= width2 if cohort==201803
replace screenwidth= width if screenwidth==. & cohort==201804


*____ Variable für Kalendersetie ___________
cap drop calendar
gen calendar=.
replace calendar=1 if page=="calendar"
replace calendar=1 if page=="cal1"
replace calendar=1 if page=="cal25"


cap drop mobile_view 
gen mobile_view= .
replace mobile_view= 0 if screenwidth>=768
replace mobile_view= 1 if screenwidth<768

cap label define mobil_lb 0 "non-mobile" 1 "mobile"
cap label val mobile_view mobil_lb 


*____________ Box Plot: Bearbeitungszeit calendar page ___________

set scheme s1color
graph hbox verwdauer if calendar==1 & visit==1, ///
	over(mobile_view, label(labsize(vsmall))) by(cohort) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/*title("Bearbeitungsdauer nach Ansicht", size(medium))*/ ///
	note("SLC Studienberechtigte 2018", size(vsmall)) ///
	ytitle("response time of calendar page (in minutes)", size(small)) ///
	ylabel( , labsize(vsmall))


graph save Graph "${out}ResponseTimeCalendar_nachAnsicht.gph", replace
graph export "${out}ResponseTimeCalendar_nachAnsicht.png", as(png) replace




*************************************************************************
use "${datadir}history_2018w3bw4_enriched.dta", clear

*************************************************************************

cap log close
cd "${workdir}log"
log using log_responseTimeCalendar_`: di %tdCY-N-D daily("$S_DATE", "DMY")', replace



*____________ response time für Kalenderseiten (erster Seitenbesuch)
table page if visit==1 & calendar==1 & cal_st==0, stat(n verwdauer )  stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.2f)

quiet: tabout page using "${out}slc_StuBe18W3W4_resTimeCalendar.xls" ///
	if visit==1 & cal_st==0, ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma


	
*____________ T-Test (Kalendarium)
ttest verwdauer if visit==1 & ((page=="cal1" | page=="cal25") | page=="calendar"), by(wave)


*____________ Box Plot: Bearbeitungszeit calendar page ___________
/// unterschieden nach: Kalendertyp; 
/// over: View und KalenderRange 
/// eingeschränkt: nur 2 Jahre, bei erstem Seitenbesuch
set scheme s1color
graph hbox verwdauer if calendar==1 & visit==1 & calendarRange==2, ///
	over(mobile_view, label(labsize(vsmall))) ///
	by(wave) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/*title("Bearbeitungsdauer nach Ansicht", size(medium))*/ ///
	/*note("SLC Studienberechtigte 2018", size(vsmall)))*/ ///
	ytitle("response time of calendar page (minutes)", size(small)) ///
	ylabel( , labsize(vsmall))

	
	
*____________ Box Plot: Bearbeitungszeit calendar page ___________
/// unterschieden nach: Kalendertyp; 
/// over: View und KalenderRange 
/// eingeschränkt: nur 2 Jahre, bei erstem Seitenbesuch
set scheme s1color
graph hbox verwdauer if calendar==1 & visit==1 & calendarRange==2, ///
	over(mobile_view, label(labsize(vsmall))) ///
	by(wave) ///
	/*subtitle(, size(small) color("95 95 95") fcolor("250 250 250"))  */ ///
	subtitle(, size(small) color("black") nobox fcolor()) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/*title("Bearbeitungsdauer nach Ansicht", size(medium))*/ ///
	/*note("SLC Studienberechtigte 2018", size(vsmall)))*/ ///
	ytitle("response time of calendar page (minutes)", size(small)) ///
	ylabel( , labsize(vsmall))
	
graph save Graph "${out}ResponseTimeCalendar_nachAnsicht.gph", replace
graph export "${out}ResponseTimeCalendar_nachAnsicht.svg", as(svg) replace


*____________ Box Plot: Bearbeitungszeit calendar page ___________
/// unterschieden nach: Kalendertyp; 
/// over: View und KalenderRange 
/// eingeschränkt: bei erstem Seitenbesuch
set scheme s1color
graph hbox verwdauer if calendar==1 & visit==1, ///
	over(mobile_view, label(labsize(vsmall))) ///
	over(calendarRange) ///
	by(wave) ///
	subtitle(, size(small) color("black") nobox fcolor()) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/*title("Bearbeitungsdauer nach Ansicht", size(medium))*/ ///
	/*note("SLC Studienberechtigte 2018", size(vsmall)))*/ ///
	ytitle("response time of calendar page (in minutes)", size(small)) ///
	ylabel( , labsize(vsmall))

graph save Graph "${out}boxPlot_respTime_CalendarWaveView.svg.gph", replace
graph export "${out}boxPlot_respTime_CalendarWaveView.svg", as(svg) name("Graph") replace


/*
set scheme s1color
graph hbox verwdauer if calendar==1 & visit==1, ///
	over(mobile_view, label(labsize(vsmall))) ///
	over(wave, label(labsize(vsmall))) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///
	/*title("Bearbeitungsdauer nach Ansicht", size(medium))*/ ///
	/*note("SLC Studienberechtigte 2018", size(vsmall)))*/ ///
	ytitle("response time of calendar page (in minutes)", size(small)) ///
	ylabel( , labsize(vsmall))
	
	
graph save Graph "${out}ResponseTimeCalendar_CaltypeAnsicht.gph", replace
graph export "${out}ResponseTimeCalendar_CaltypeAnsicht.png", as(png) replace
*/

log close
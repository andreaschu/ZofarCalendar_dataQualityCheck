
*************************************************************************
use "${datadir}history_2018w3bw4_enriched.dta", clear

*************************************************************************

*_________Statistiken der Bearbeitungsdauer nach Modul__________________________________
// unterschieden nach Welle/ Kalendertyp
// eingeschränkt auf Fälle, die das Episodenmodul beendet haben

*table modul, contents(wave n moduln median time_modul min time_modul max time_modul)

table (wave modul) if epiFinish==1, stat(freq) ///
	stat(mean moduldauer_minutes) ///
	stat(median moduldauer_minutes) ///
	stat(min moduldauer_minutes) ///
	stat(max moduldauer_minutes) ///
	nformat(%9.2f) nototals

	
*_________Boxplot Bearbeitungsdauer nach Modul__________________________________
*  (siehe oben: "Fragebogenseiten zu Modul zuordnen" muss zuvor erledigt werden)

* Labels für Module vorbereiten


cap drop wavestrng
gen wavestrng=""
replace wavestrng="03" if wave==201803
replace wavestrng="04" if wave==201804

qui levelsof(wave)
local wavelist `r(levels)'

qui levelsof(modul)
local levelslist `r(levels)'

levelsof(wavestrng)
local wavelb `r(levels)'


cap drop modul_labeled
gen modul_labeled = ""

foreach modul_name in `"`levelslist'"' {
foreach wave in `"`wavelb'"' {
	qui levelsof pid if wavestrng=="`wave'" & modul =="`modul_name'" // Anzahl Befragte im Modul
	local part_count : word count `r(levels)'

	qui levelsof page if wavestrng=="`wave'" & modul =="`modul_name'"   // Anzahl pages pro Modul (aus den history-Daten)
	local page_count : word count `r(levels)'

	replace modul_labeled=`"`wave', `modul_name' (n=`part_count', pages: `page_count')"' if wavestrng=="`wave'" & modul ==`"`modul_name'"' & epiFinish==1 & calendarRange==2
	di `"`modul_name' `page_count' `part_count'"'
}
}


*____________ Box Plot: Bearbeitungszeit calendar page ___________
/// over: Modul und View (Seiten pro Modul+Personen in Labels)
/// eingeschränkt: nur 2 Jahre, Episodenmodul beendet

set scheme s1color
graph hbox moduldauer_minutes if epiFinish==1 & calendarRange==2, ///
	over(modul_labeled, label(labsize(vsmall))) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/* title("Bearbeitungsdauer nach Modul", size(medium)) */ ///
	/* note("SLC Studienberechtigte 2018", size(vsmall)) */ ///
	ytitle("resonse time (minutes)", size(small)) ///
	ylabel( , labsize(vsmall))

graph save Graph "${out}ResponseTime_nachModul_extLabel.gph", replace
graph export "${out}ResponseTime_nachModul_extLabel.svg", as(svg) replace


*____________ Box Plot: Bearbeitungszeit calendar page ___________
/// over: Modul und View
/// eingeschränkt: nur 2 Jahre, Episodenmodul beendet, keine SessionTimeout im jeweiligen Modul
table (wave modul) if epiFinish==1 & calendarRange==2 & modul_st==0, stat(freq) ///
	stat(mean moduldauer_minutes) ///
	stat(median moduldauer_minutes) ///
	stat(min moduldauer_minutes) ///
	stat(max moduldauer_minutes) ///
	nformat(%9.2f) nototals
	
	
table (wave modul) if finished==1 & calendarRange==2 & modul_st==0, stat(freq) ///
	stat(mean moduldauer_minutes) ///
	stat(median moduldauer_minutes) ///
	stat(min moduldauer_minutes) ///
	stat(max moduldauer_minutes) ///
	nformat(%9.2f) nototals

	

set scheme s1color
graph hbox moduldauer_minutes if epiFinish==1 & calendarRange==2 & modul_st==0, ///
	over(modul, label(labsize(vsmall))) ///
	/// over(wave, label(labsize(small))) ///
	by(wave) ///
	subtitle(, size(small) color("black") nobox fcolor()) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	/* title("Bearbeitungsdauer nach Modul", size(medium)) */ ///
	/* note("SLC Studienberechtigte 2018", size(vsmall)) */ ///
	ytitle("resonse time (minutes)", size(small)) ///
	ylabel( , labsize(vsmall))	

	
graph save Graph "${out}ResponseTime_nachModul.gph", replace
graph export "${out}ResponseTime_nachModul.svg", as(svg) replace


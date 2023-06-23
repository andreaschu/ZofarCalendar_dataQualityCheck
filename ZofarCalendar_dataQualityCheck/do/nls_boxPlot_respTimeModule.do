 

*_________Boxplot Bearbeitungsdauer nach Modul__________________________________
*  (siehe oben: "Fragebogenseiten zu Modul zuordnen" muss zuvor erledigt werden)

* Labels für Module vorbereiten

cap drop wavestrng
gen wavestrng=""
replace wavestrng="03" if cohort==201803
replace wavestrng="04" if cohort==201804

qui levelsof(cohort)
local cohortlist `r(levels)'

qui levelsof(modul)
local levelslist `r(levels)'

qui levelsof(wavestrng)
local wavelb `r(levels)'


cap drop modul_labeled
gen modul_labeled = ""

foreach modul_name in `"`levelslist'"' {
foreach wave in `"`wavelb'"' {
	qui levelsof piy if wavestrng=="`wave'" & modul =="`modul_name'" // Anzahl Befragte im Modul
	local part_count : word count `r(levels)'

	qui levelsof page if wavestrng=="`wave'" & modul =="`modul_name'" // Anzahl pages pro Modul (aus den history-Daten)
	local page_count : word count `r(levels)'

	replace modul_labeled=`"`wave': `modul_name' (n=`part_count', pages: `page_count')"' if wavestrng=="`wave'" & modul ==`"`modul_name'"'
	di `"`modul_name' `page_count' `part_count'"'
}
}

set scheme s1color
graph hbox moduldauer_minutes, ///
	over(modul_labeled, label(labsize(vsmall)))  /// 
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///
	title("Bearbeitungsdauer nach Modul", size(medium)) ///
	note("SLC Studienberechtigte 2018", size(vsmall)) ///
	ytitle("Bearbeitungszeit in Minuten", size(vsmall)) ///
	ylabel( , labsize(vsmall))
	
/*
graph hbox moduldauer_minutes, ///
	over(cohort, label(labsize(small))) ///
	over(modul_labeled, label(labsize(vsmall)))  /// 
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///
	title("Bearbeitungsdauer nach Modul", size(medium)) ///
	note("SLC Studienberechtigte (cohort 2018)", size(vsmall)) ///
	ytitle("Bearbeitungszeit in Minuten", size(vsmall)) ///
	ylabel( , labsize(vsmall))
*/
graph save Graph "${doc}ResponseTime_nachModul.gph", replace
graph export "${doc}ResponseTime_nachModul.png", as(png) replace


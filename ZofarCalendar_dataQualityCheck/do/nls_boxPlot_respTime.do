use "${datadir}history_2018w3bw4_enriched.dta", clear
	

* Bearbeitungszeit nach Modul
bysort cohort pid modul: egen moduldauer=total(verwdauer)
label var moduldauer "Bearbeitungsdauer des Moduls pro Befragten"


cap drop moduldauer_minutes
bysort cohort: gen moduldauer_minutes = moduldauer / 60
lab var moduldauer_minutes "Bearbeitungsdauer pro Modul in Minuten"

cap drop moduln
bysort cohort modul: egen moduln=count(pid)

*table modul, contents(cohort n moduln median time_modul min time_modul max time_modul)

table (cohort modul), stat(freq) ///
	stat(mean moduldauer_minutes) ///
	stat(median moduldauer_minutes) ///
	stat(min moduldauer_minutes) ///
	stat(max moduldauer_minutes) ///
	nformat(%9.2f) nototals
		
	

	
*_________Boxplot Bearbeitungsdauer nach Modul__________________________________
*  (siehe oben: "Fragebogenseiten zu Modul zuordnen" muss zuvor erledigt werden)

* Labels für Module vorbereiten


cap drop cohortstrng
gen cohortstrng=""
replace cohortstrng="03" if cohort==201803
replace cohortstrng="04" if cohort==201804

qui levelsof(cohort)
local cohortlist `r(levels)'

qui levelsof(modul)
local levelslist `r(levels)'

levelsof(cohortstrng)
local cohortlb `r(levels)'


cap drop modul_labeled
gen modul_labeled = ""

foreach modul_name in `"`levelslist'"' {
foreach cohort in `"`cohortlb'"' {
	qui levelsof pid if cohortstrng=="`cohort'" & modul =="`modul_name'" // Anzahl Befragte im Modul
	local part_count : word count `r(levels)'

	qui levelsof page if cohortstrng=="`cohort'" & modul =="`modul_name'"   // Anzahl pages pro Modul (aus den history-Daten)
	local page_count : word count `r(levels)'

	replace modul_labeled=`"`cohort', `modul_name' (n=`part_count', pages: `page_count')"' if cohortstrng=="`cohort'" & modul ==`"`modul_name'"'
	di `"`modul_name' `page_count' `part_count'"'
}
}



set scheme s1color
graph hbox moduldauer_minutes, ///
	over(modul_labeled, label(labsize(vsmall))) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	title("Bearbeitungsdauer nach Modul", size(medium)) ///
	note("SLC Studienberechtigte 2018", size(vsmall)) ///
	ytitle("Bearbeitungszeit in Minuten", size(small)) ///
	ylabel( , labsize(vsmall))




/*
foreach modul_name in `"`levelslist'"' {
foreach cohort in `cohortlist' {
	qui levelsof pid if cohort==`cohort' & modul =="`modul_name'" // Anzahl Befragte im Modul
	local part_count : word count `r(levels)'

	qui levelsof page if cohort==`cohort' & modul =="`modul_name'"   // Anzahl pages pro Modul (aus den history-Daten)
	local page_count : word count `r(levels)'

	replace modul_labeled=`"`cohort', `modul_name' (n=`part_count', pages: `page_count')"' if cohort==`cohort' & modul ==`"`modul_name'"'
	di `"`modul_name' `page_count' `part_count'"'
}
}
*/

/*

set scheme s1color
graph hbox moduldauer_minutes, ///
	over(modul, label(labsize(vsmall))) ///
	over(cohort, label(labsize(small))) ///
	nooutsides ///
	box(1, fcolor("10 125 148") ///
	fintensity(inten100) ///
	lcolor(black) ///
	lwidth(vthin)) ///	
	title("Bearbeitungsdauer nach Modul", size(medium)) ///
	note("SLC Studienberechtigte 2018", size(vsmall)) ///
	ytitle("Bearbeitungszeit in Minuten", size(small)) ///
	ylabel( , labsize(vsmall))	
*/
	
graph save Graph "${out}ResponseTime_nachModul.gph", replace
graph export "${out}ResponseTime_nachModul.png", as(png) replace


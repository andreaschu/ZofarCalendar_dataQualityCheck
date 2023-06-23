****************************************************************************
** Projekt/ Studie:       Vortrag auf ESRA23
** 						
** Erstelldatum:          2023-06-20
** Bearbeitet von:        Schulze, Andrea
****************************************************************************

version 17

global orig "slc\slc_stube18\"
glglobal workdir "ZofarCalendar_dataQualityCheck\esra23_calendar\"

global dodir "${workdir}do\"
global datadir "${workdir}data\"
global log "${workdir}log\"
global out "${workdir}out\"

*cd "${workdir}log"
*cap log close

*************************************************************************
use "${datadir}history_2018w3bw4_collapsed.dta", clear

*************************************************************************
*************************************************************************
****** Indikatoren berechnen **



*________Anzahl der Besucher pro Seite___________
bysort cohort pagenum: gen visitor= _N
label var visitor "Anzahl der Besucher pro Seite (ohne doppelte Besuche)"

*________Anzahl der Abbrecher pro Seite___________
bysort cohort pagenum lastpage: egen abbrecher= count(participant_id) if pagenum==lastpage
label var abbrecher "Anzahl der Abbrecher pro Seite (mit lastpage)"

bysort cohort pagenum: egen dropout= max(abbrecher)
label var dropout "Anzahl der Abbrecher pro Seite (mit lastpage) [Konstante]"

*________Abbruchquote_____________________________
bysort cohort pagenum: gen dropoutrate= dropout/visitor
label var dropoutrate "Abbruchquote (Anz. Abbrecher im Verhältn. zu Seitenbesucher)"

*________Anzahl der besuchten Seiten pro Befragten___________
bysort pid: gen anzseiten= _N 
label var anzseiten "Anzahl der besuchten Seiten pro Befragten"

*________Durchschnittliche Bearbeitungsdauer___________
bysort cohort: egen dauer_mn=mean(verwdauer)
label var dauer_mn "Verweildauer: arithmetisches Mittel"

bysort cohort: egen dauer_med=median(verwdauer)
label var dauer_med "Verweildauer: Median"

bysort cohort: egen dauer_min=min(verwdauer)
label var dauer_min "Verweildauer: Minimum"

bysort cohort: egen dauer_max=max(verwdauer)
label var dauer_max "Verweildauer: Maximum"

bysort cohort: egen dauer_sd=sd(verwdauer)
label var dauer_sd "Verweildauer: Standardabweichung"



*nach Modul
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
	


    /*
    *_________Boxplot Bearbeitungsdauer nach Modul__________________________________
    *  (siehe oben: "Fragebogenseiten zu Modul zuordnen" muss zuvor erledigt werden)

        * Labels für Module vorbereiten
        qui levelsof(modul)

        local levelslist `r(levels)'

        cap drop modul_labeled
        gen modul_labeled = ""

        foreach modul_name in `"`levelslist'"' {
            qui levelsof participant_id if modul =="`modul_name'" // Anzahl Befragte im Modul
            local part_count : word count `r(levels)'

            qui levelsof page if modul =="`modul_name'" // Anzahl pages pro Modul (aus den history-Daten)
            local page_count : word count `r(levels)'

            replace modul_labeled=`"`modul_name' (n=`part_count', pages: `page_count')"' if modul ==`"`modul_name'"'
            di `"`modul_name' `page_count' `part_count'"'
        }


    graph hbox moduldauer_minutes, over(modul_labeled, label(labsize(vsmall))) nooutsides ///
        title("Bearbeitungsdauer nach Modul") ///
        note("Nacaps (cohort 2020, wave 2)") ///
        ytitle("Bearbeitungszeit in Minuten", size(small)) ///
        ylabel( , labsize(vsmall))

    graph save Graph "${doc}ResponseTime_nachModul.gph", replace
    graph export "${doc}ResponseTime_nachModul.png", as(png) replace
    */

*_______________________________________________________________
cap log close


log using "${log}StuBe18W3W4_abbrecher-verwdauer.smcl", append

*******************************************************************************
********************* Auswertungen Abbrüche und Verweildauern **********************

*________Anzahl der Abbrecher pro Seite___________
// table page, contents(n abbrecher mean dropoutrate n dropoutrate) format(%9.4f)

**** Kohorte 2018, Welle 3b
table page if cohort==201803, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)


quiet: tabout page using "${out}slc_StuBe18W3_abbrecher.xls" if cohort==201803, ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	clab(Abbrecher Abbruchquote Seitenbesucher) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma

	
**** Kohorte 2018, Welle 4
table page if cohort==201804, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)

quiet: tabout page using "${out}slc_StuBe18W4_abbrecher.xls" if cohort==201804, ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	clab(Abbrecher Abbruchquote Seitenbesucher) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma

	
*________Seitenverweildauer ____________________
**** Kohorte 2018, Welle 3b
tabstat verwdauer if cohort==201803, statistics(mean median min max sd)

*________Seitenverweildauer ____________________
**** Kohorte 2018, Welle 4
tabstat verwdauer if cohort==201804, statistics(mean median min max sd)


*________Seitenverweildauer nach Seite ____________________
**** Kohorte 2018, Welle 3b
table page if cohort==201803, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

quiet: tabout page using "${out}slc_StuBe18W3_verwdauer.xls" if cohort==201803, ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma


*________Seitenverweildauer nach Seite ____________________
**** Kohorte 2018, Welle 4
table page if cohort==201804, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

quiet: tabout page using "${out}slc_StuBe18W4_verwdauer.xls" if cohort==201804, ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma
	

log close
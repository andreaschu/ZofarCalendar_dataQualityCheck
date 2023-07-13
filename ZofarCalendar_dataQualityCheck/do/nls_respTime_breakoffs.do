****************************************************************************
** Project:			Talk, ESRA23
** date:			2023-06-20
** used data sets:	history_2018w3bw4_collapsed.dta
** created by:		Schulze, Andrea
****************************************************************************

version 17

*cd "${workdir}log"
*cap log close

*************************************************************************
use "${datadir}history_2018w3bw4_collapsed.dta", clear
*************************************************************************
*************************************************************************
****** Indikatoren berechnen ******


*________Anzahl der Besucher pro Seite___________
bysort wave pagenum: gen visitor= _N
label var visitor "Anzahl der Besucher pro Seite (ohne doppelte Besuche)"

*________Anzahl der Abbrecher pro Seite___________
bysort wave pagenum lastpage: egen abbrecher= count(participant_id) if pagenum==lastpage
label var abbrecher "Anzahl der Abbrecher pro Seite (mit lastpage)"

bysort wave pagenum: egen dropout= max(abbrecher)
label var dropout "Anzahl der Abbrecher pro Seite (mit lastpage) [Konstante]"

*________Abbruchquote_____________________________
bysort wave pagenum: gen dropoutrate= dropout/visitor
label var dropoutrate "Abbruchquote (Anz. Abbrecher im Verhältn. zu Seitenbesucher)"

*________Anzahl der besuchten Seiten pro Befragten___________
bysort pid: gen anzseiten= _N 
label var anzseiten "Anzahl der besuchten Seiten pro Befragten"

*________Durchschnittliche Bearbeitungsdauer___________
bysort wave: egen dauer_mn=mean(verwdauer)
label var dauer_mn "Verweildauer: arithmetisches Mittel"

bysort wave: egen dauer_med=median(verwdauer)
label var dauer_med "Verweildauer: Median"

bysort wave: egen dauer_min=min(verwdauer)
label var dauer_min "Verweildauer: Minimum"

bysort wave: egen dauer_max=max(verwdauer)
label var dauer_max "Verweildauer: Maximum"

bysort wave: egen dauer_sd=sd(verwdauer)
label var dauer_sd "Verweildauer: Standardabweichung"


*_______________________________________________________________
cap log close


log using "${out}StuBe18W3W4_abbrecher-verwdauer_2023-07-12.smcl", replace

*******************************************************************************
********************* Auswertungen Abbrüche und Verweildauern **********************

*________Anzahl der Abbrecher pro Seite___________
// table page, contents(n abbrecher mean dropoutrate n dropoutrate) format(%9.4f)

**** Kohorte 2018, Welle 3b
table page if wave==201803, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)

/*
quiet: tabout page using "${out}slc_StuBe18W3_abbrecher.xls" if wave==201803, ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	clab(Abbrecher Abbruchquote Seitenbesucher) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma
*/
	
**** Kohorte 2018, Welle 4
table page if wave==201804, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)

/*
quiet: tabout page using "${out}slc_StuBe18W4_abbrecher.xls" if wave==201804, ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	clab(Abbrecher Abbruchquote Seitenbesucher) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma
*/
	
*________Seitenverweildauer ____________________
**** Kohorte 2018, Welle 3b
tabstat verwdauer if wave==201803, statistics(mean median min max sd)

*________Seitenverweildauer ____________________
**** Kohorte 2018, Welle 4
tabstat verwdauer if wave==201804, statistics(mean median min max sd)


*________Seitenverweildauer nach Seite ____________________
**** Kohorte 2018, Welle 3b
table page if wave==201803, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

/*
quiet: tabout page using "${out}slc_StuBe18W3_verwdauer.xls" if wave==201803, ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma
*/

*________Seitenverweildauer nach Seite ____________________
**** Kohorte 2018, Welle 4
table page if wave==201804, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

/*
quiet: tabout page using "${out}slc_StuBe18W4_verwdauer.xls" if wave==201804, ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma
*/

log close


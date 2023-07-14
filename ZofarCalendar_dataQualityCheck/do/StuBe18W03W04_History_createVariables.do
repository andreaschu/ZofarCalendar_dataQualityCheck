
*_________________________________________________________________
** Variablen für Analysen erstellen
*_________________________________________________________________


*____ Variable für Kalenderseite ___________
// wellenübergreifende Anzeiger, dass Seite=Kalendarium
cap drop calendar
gen calendar=.
replace calendar=1 if page=="calendar"
replace calendar=1 if (page=="cal25" | page=="cal1")
cap label define callb 0 "others" 1 "calendar"
cap label val calendar callb
label var calendar "page is calendar page"


sort pid timestamp
tab verwdauer wave if visit==1 & calendar==1 & calendar[_n+1]==1, miss
tab verwdauer wave if calendar==1 & calendar[_n+1]==1, miss
tab page if calendar==1


*____ Bildschirmbreite mit Werten von beiden Befragungen, die kurz vor Kalendarium abgefragt wurde
// width3 -> wave=201803
// width -> wave=201804
cap drop screenwidth
gen screenwidth= width2 if wave==201803
replace screenwidth= width if screenwidth==. & wave==201804
cap label var screenwidth "screen width of view on calendar page"

*____ Variable für Mobilansicht ___________
// Bildschirmbreite, da Anzeige/ Umbruch technisch auf width beruht
cap drop mobile_view 
gen mobile_view= .
replace mobile_view= 0 if screenwidth>=768
replace mobile_view= 1 if screenwidth<768
cap label var mobile_view "device by screen width"
cap label define mobil_lb 0 "non-mobile" 1 "mobile"
cap label val mobile_view mobil_lb 


*____ Variable für Kalenderzeitraum ___________
// angezeigter Kalenderzeitraum in Jahren
cap drop calendarRange
gen calendarRange=.
replace calendarRange=1 if wave==201803 & preloadwave ==1
replace calendarRange=2 if (wave==201803 & preloadwave !=1) | (wave==201804 & preloadepiretro==1)
replace calendarRange=3 if wave==201804 & preloadepiretro==2
replace calendarRange=4 if wave==201804 & preloadepiretro==3
cap label define rangelb 1 "1 year" 2 "2 years" 3 "3 years" 4 "4 years"
cap label val calendarRange rangelb
cap label var calendarRange "time period of calendar"
tab calendarRange wave


*_______Marker für SessionTimeout erstellen_________
// sessionTimeout==1, wenn Verweildauer länger als 30 Minuten (1800 Sekunden) war
cap drop sessionTimeout
gen sessionTimeout=.
replace sessionTimeout=1 if verwdauer>=1800
replace sessionTimeout=0 if verwdauer<1800
// Korrektur, da ST auf End-page zu häufig vorkommt
replace sessionTimeout=0 if sessionTimeout==1 & (pagenum==1781 | pagenum==1780)
cap label define st_lb 0 "no timeout" 1 "session timeout"
cap label val sessionTimeout st_lb
cap label var sessionTimeout "session timeout on page"

/// unklar, ob notwendig
*_______Marker für SessionTimeout nach Modul erstellen_________
// sessionTimeout==1, wenn Verweildauer länger als 30 Minuten (1800 Sekunden) war
cap drop modul_st
bysort pid modul: egen modul_st=total(sessionTimeout)
replace modul_st=1 if modul_st>=1
cap label val modul_st st_lb
label var modul_st "session timeout in module"

*_______Marker für SessionTimeout auf der Kalenderseite erstellen_________
// cal_st==1, wenn Verweildauer auf Kalenderseite länger als 30 Minuten (1800 Sekunden) war
// Fälle werden bei Analysen der Verweildauern ausgeschlossen
cap drop cal_st
gen cal_st=.
replace cal_st=1 if calendar==1 & verwdauer>=1800
replace cal_st=0 if calendar==1 & verwdauer<1800
cap label val cal_st st_lb
label var cal_st "session timeout on calendar page"

tab wave if visit==1 & cal_st==1


*____ Bearbeitungszeit nach Modul ___________
cap bysort wave pid modul: egen moduldauer=total(verwdauer)
cap label var moduldauer "response time of module"

cap drop moduldauer_minutes
cap bysort wave: gen moduldauer_minutes = moduldauer / 60
lab var moduldauer_minutes "response time per module (in minutes)"

cap drop moduln
cap bysort wave modul: egen moduln=count(pid)


*____ Variable für Beginn-Status des Episodenmoduls ___________
cap drop epiStart
cap bysort pid: egen epiStart= max(calendar)
*cap replace epiStart=0 if epiStart==.
cap label define EpiStartLB 0 "episode module not started" 1 "episode module started" 
cap label val epiStart EpiStartLB
cap label var epiStart "Beginnstatus des Episodenmoduls"


*____ Variable für Beendigungs-Status des Episodenmoduls ___________
cap drop epiFinish
cap bysort pid: gen epiFinish=1 if page=="epi_end"
cap bysort pid: replace epiFinish=1 if page=="zwischen_k"
cap bysort pid: egen epifin=total(epiFinish)
cap bysort pid: replace epiFinish= 1 if epifin>=1
drop epifin
cap replace epiFinish=0 if epiFinish==.
cap label define EpiFinLB 0 "episode module not finished" 1 "episode module finished" 
cap label val epiFinish EpiFinLB
cap label var epiFinish "Beendigungsstatus des Episodenmoduls"


*___ Kontrolle von Start- und Endstatus ____
tab  token if epiStart==0 & epiFinish==1
// 5 Fälle aus 2018.3b mit epiStart==0 & epiFinish==1
// --> werden recodiert
replace epiFinish=0 if epiStart==0 & epiFinish==1


*____ Abbrüche im Episodenmodul ____
cap gen epiBreakoffs=.
bysort pid: replace epiBreakoffs=0 if calendar

cap replace epiBreakoffs=0 if epiStart==1 & epiFinish==1
cap replace epiBreakoffs=1 if epiStart==1 & epiFinish==0
cap label define epiBreakoffLB 0 "episodes started and ended" 1 "breakoff within episode module"
cap label val epiBreakoffs epiBreakoffLB
cap label var epiBreakoffs "breakoffs in episode module"



*************************************************************************
use "${datadir}history_2018w3bw4_enriched.dta", clear
*************************************************************************

*_________________________________________________________________
** Coefplot: Bearbeitungsdauer der Kalenderseite
*_________________________________________________________________

reg verwdauer i.wave##i.mobile_view if calendar==1 & visit==1 & calendarRange==2

margins, at(wave=(201803 201804) mobile_view=(0 1)) post
coefplot, groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap)  ///
        rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ///
        ciopts(recast(rcap)) vertical ytitle("Linear Prediction: Response Time LHC")

graph save Graph "${out}coefPlot_respTimeCalendar.gph", replace
graph export "${out}coefPlot_respTimeCalendar.svg", as(svg) replace




*_________________________________________________________________
** Coefplot: Bearbeitungsdauer der Episodenmodul
*_________________________________________________________________

reg moduldauer_minutes i.wave##i.mobile_view if visit==1 & calendarRange==2

margins, at(wave=(201803 201804) mobile_view=(0 1)) post
coefplot, groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap)  ///
        rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ///
        ciopts(recast(rcap)) vertical ytitle("Linear Prediction: Response Time LHM")

graph save Graph "${out}coefPlot_respTimeModule.gph", replace
graph export "${out}coefPlot_respTimeModule.svg", as(svg) replace




*_________________________________________________________________
** Coefplot: Abbrüche im Episodenmodul
*_________________________________________________________________

logit epiBreakoff i.wave##i.mobile_view if epiStart==1 & calendarRange==2

margins, at(wave=(201803 201804) mobile_view=(0 1)) post
coefplot, groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap)  ///
        rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ///
        ciopts(recast(rcap)) vertical ytitle("Predicted Probability: Break-Off")

graph save Graph "${out}coefPlot_breakOffs.gph", replace
graph export "${out}coefPlot_breakOffs.svg", as(svg) replace


 

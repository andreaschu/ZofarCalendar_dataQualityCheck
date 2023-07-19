cap log close

log using "${out}nls_coefPlots.smcl", replace

*_________________________________________________________________
** Regression zur Bearbeitunggsdauer der Kalenderseiten 
*_________________________________________________________________


use "${datadir}history_2018w3bw4_enriched.dta", clear

*_________________________________________________________________
// Datensatz reduzieren auf eine Zeile pro Person, pro Welle


 keep if calendarRange==2
 keep if epiStart==1
 keep(mobile_view epiBreakoff wave token part_id verwdauer calendar pid finished epiFinish modul visit calendarRange)




set scheme s2color
*set scheme s1color
*_________________________________________________________________
*____________  Coefplot: Bearbeitungsdauer der Kalenderseite ________
// nur Kalenderseiten
// nur Personen, die im Episodemodul gestartet sind (epiStart==1)
// nur Fälle mit Kalenderzeitraum von 2 Jahren 


reg 		verwdauer i.wave##i.mobile_view if calendar==1 & visit==1 & calendarRange==2, vce(cluster part_id) 
margins		, at(wave=(201803 201804) mobile_view=(0 1)) post
coefplot	, groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap labsize(small)) ///
	rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile " ) ///
	ciopts(recast(rcap) lcolor("10 125 148")) ///
	/// msymbol(diamond) ///
	mcolor("10 125 148")  ///
	vertical ytitle("Linear Prediction: Response Time", size(small))  ///
	xscale(lcolor("95 95 95")) ///
	ylabel( , labsize(vsmall))  ///
	xlabel( , labsize(vsmall)) ///
	graphregion(fcolor(white) ifcolor(white) ilcolor(white))


graph save Graph "${out}coefPlot_respTimeCalendar.gph", replace
graph export "${out}coefPlot_respTimeCalendar.svg", as(svg) replace



 
 
 *keep(mobile_view epiBreakoff wave token  pid finished epiFinish modul calendarRange epiStart)


collapse (mean) mobile_view epiBreakoff finished epiFinish (first) pid part_id, by(token wave)

*_________________________________________________________________
*____________ Coefplot: Abbrüche im Episodenmodul ________
// nur Personen, die im Episodemodul gestartet sind (epiStart==1)
// nur Fälle mit Kalenderzeitraum von 2 Jahren 

*logit epiBreakoff i.wave##i.mobile_view if epiStart==1 & calendarRange==2
logit epiBreakoff i.wave##i.mobile_view, vce(cluster part_id)

margins, 	at(wave=(201803 201804) mobile_view=(0 1)) post
coefplot	,groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap labsize(small)) ///
	rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ///
	ciopts(recast(rcap) lcolor("10 125 148")) ///
	/// msymbol(diamond) ///
	mcolor("10 125 148")  ///
	vertical ytitle("Predicted Probability: Break-Off", size(small))  ///
	xscale(lcolor("95 95 95")) ///
	ylabel( , labsize(vsmall))  ///
	xlabel( , labsize(vsmall)) ///
	graphregion(fcolor(white) ifcolor(white) ilcolor(white))


graph save Graph "${out}coefPlot_breakOffs.gph", replace
graph export "${out}coefPlot_breakOffs.svg", as(svg) replace


cap log close
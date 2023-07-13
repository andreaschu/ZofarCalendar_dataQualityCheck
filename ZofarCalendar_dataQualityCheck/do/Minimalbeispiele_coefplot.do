*Minimalbeispiel Lineare Regression generieren
set 		obs 1000
gen 		mobile=runiform()>.6
gen 		cal=runiform()>.5
gen 		t = 5+1*mobile+2*cal+3*mobile*cal+rnormal(0,1)

*Standardcoefplot
reg 		t i.mobile##i.cal
margins		, at(mobile=(0 1) cal=(0 1)) post
coefplot

*Einfachste Möglichkeit das ganze etwas aufzuhübschen
*hab die order-Option von coefplot nicht hinbekommen, aber so gehts auch
reg 		t i.cal##i.mobile //Reihenfolge der Coef. beeinflusst die Kombinationen bei margins
margins		, at(cal=(0 1) mobile=(0 1)) post
coefplot	,groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap)  rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ciopts(recast(rcap)) vertical ytitle("Linear Prediction: Response Time") //die Tilde steht für "nicht" ~cal könnte also static und cal dynamic sein

*Miniamlbeispiel logit
gen b = exp(5+1*mobile+2*cal+3*mobile*cal+rnormal(0,1))/(1+exp(5+1*mobile+2*cal+3*mobile*cal+rnormal(0,1)))>.5

logit 		b i.cal##i.mobile
margins		, at(cal=(0 1) mobile=(0 1)) post
coefplot	,groups("non-mobile" "mobile" = "static calendar" " non-mobile " " mobile " = "dynamic calendar", nogap)  rename(1._at="non-mobile" 2._at="mobile" 3._at=" non-mobile " 4._at=" mobile ") ciopts(recast(rcap)) vertical ytitle("Predicted Probability: Break-Off") 
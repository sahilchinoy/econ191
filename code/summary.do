cd "/Users/sahilchinoy/Documents/econ191/code"
set more off
clear

************************************************
* Summary statistics and spending correlations *
************************************************

insheet using ../data/all.csv

* Only Assembly candidates
keep if office == "A"
* In contested races
keep if contested == 1
* With nonzero spending
keep if tot > 0

la var tot "Total"
la var logtot "Total"
la var comm "Comm."
la var logcomm "Comm."
la var ads "Ads"
la var logads "Ads"
la var info "Info."
la var loginfo "Info."
la var fnd "Fund."
la var logfnd "Fund."
la var overhead "Overhead"
la var logoverhead "Overhead"
la var contrib "Contrib."
la var logcontrib "Contrib."

global exp_cols tot comm ads info fnd overhead contrib

* Spending variables in 1000s
foreach exp of global exp_cols {
	replace `exp' = `exp'/1000
}

* Summary statistics
bys incumbent: sum tot comm ads info overhead contrib fnd vote_share winner

gen win_pct = winner * 100

tabout incumbent party using "../tex/summary.tex", cells(count tot sd tot ///
	sd comm sd ads ///
	sd info sd fnd sd overhead ///
	sd contrib sd vote_share sd win_pct) ///
	f(0c 1m 1m 1m 1m 1m 1m 1m 0p 0p) replace sum ///
	style(tex) bt topf(../tex/top.tex) botf(../tex/bottom.tex)
	
* Correlation matrix
corr logtot logcomm logads loginfo logfnd logoverhead logcontrib
quietly corrtex logtot logcomm logads loginfo logfnd logoverhead logcontrib, ///
	file(../tex/corr.tex) replace
	
* Scatterplot of ad spending vs total spending
drop if logads == 0
scatter logads logtot, ytitle(Log ad spending) xtitle(Log total spending)
graph export ../charts/ads.pdf, replace

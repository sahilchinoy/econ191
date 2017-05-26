cd "/Users/sahilchinoy/Documents/econ191/code"
set more off
clear

insheet using ../data/races.csv

* Scatterplot of vote share versus spending difference

preserve

keep if incumbent_logtot != 0
keep if challenger_logtot != 0

gen diff = incumbent * (incumbent_logtot - challenger_logtot) + open_logtot

scatter dem_vote diff, ytitle(Democratic vote share) xtitle(Difference in log spending)
graph export ../charts/diff.pdf, replace

restore

drop if missing(dem_name)
drop if dem_name == ""

drop if missing(rep_name)
drop if rep_name == ""

gen const = 1

global exp_cols tot general

gen inc = .
gen chal = .
gen open = .

preserve

********************************
* Un-differenced specification *
********************************

eststo clear

gen d_incumbent = incumbent

foreach exp of global exp_cols {
	replace inc = incumbent_log`exp' * incumbent
	replace chal = challenger_log`exp' * incumbent
	replace open = open_log`exp'
	
	eststo `exp': quietly areg dem_vote inc chal open ///
		d_incumbent avg_vote, robust absorb(year)
}

restore

**********************************
* First-differenced by candidate *
**********************************

preserve

sort dem_name year

drop if missing(dem_name)
drop if dem_name == ""

bys dem_name: gen num = _n

encode dem_name, gen(dem_name_cd)
xtset dem_name_cd num

by dem_name_cd: gen d_dem_vote = dem_vote[_n] - dem_vote[_n-1]

foreach exp of global exp_cols {
	gen i_incumbent_log`exp' = incumbent_log`exp' * incumbent
	gen i_challenger_log`exp' = challenger_log`exp' * incumbent
	
	by dem_name_cd: gen d_incumbent_log`exp' = i_incumbent_log`exp'[_n] - i_incumbent_log`exp'[_n-1]
	by dem_name_cd: gen d_challenger_log`exp' = i_challenger_log`exp'[_n] - i_challenger_log`exp'[_n-1]
	by dem_name_cd: gen d_open_log`exp' = open_log`exp'[_n] - open_log`exp'[_n-1]
}

by dem_name_cd: gen d_incumbent = incumbent[_n] - incumbent[_n-1]

drop if num < 2

save ../temp/differenced_dem.dta, replace

restore

preserve

drop if missing(rep_name)
drop if rep_name == ""

sort rep_name year

bys rep_name: gen num = _n

encode rep_name, gen(rep_name_cd)
xtset rep_name_cd num

by rep_name_cd: gen d_dem_vote = dem_vote[_n] - dem_vote[_n-1]

foreach exp of global exp_cols {
	gen i_incumbent_log`exp' = incumbent_log`exp' * incumbent
	gen i_challenger_log`exp' = challenger_log`exp' * incumbent
	by rep_name_cd: gen d_incumbent_log`exp' = i_incumbent_log`exp'[_n] - i_incumbent_log`exp'[_n-1]
	by rep_name_cd: gen d_challenger_log`exp' = i_challenger_log`exp'[_n] - i_challenger_log`exp'[_n-1]
	by rep_name_cd: gen d_open_log`exp' = open_log`exp'[_n] - open_log`exp'[_n-1]
}

by rep_name_cd: gen d_incumbent = incumbent[_n] - incumbent[_n-1]

drop if num < 2
	
drop num

append using ../temp/differenced_dem.dta 

drop incumbent

foreach exp of global exp_cols {
	replace inc = d_incumbent_log`exp'
	replace chal = d_challenger_log`exp'
	replace open = d_open_log`exp'
	
	eststo two_`exp': quietly reg d_dem_vote d_incumbent inc chal open, robust noconstant
}

restore

********************************
* First-differenced by matchup *
********************************


gen matchup = dem_name + "/" + rep_name

sort matchup year
by matchup: gen num = _n

encode matchup, gen(matchup_cd)
xtset matchup_cd num

by matchup_cd: gen d_dem_vote = dem_vote[_n] - dem_vote[_n-1]

foreach exp of global exp_cols {
	gen i_incumbent_log`exp' = incumbent_log`exp' * incumbent
	gen i_challenger_log`exp' = challenger_log`exp' * incumbent
	by matchup_cd: gen d_incumbent_log`exp' = i_incumbent_log`exp'[_n] - i_incumbent_log`exp'[_n-1]
	by matchup_cd: gen d_challenger_log`exp' = i_challenger_log`exp'[_n] - i_challenger_log`exp'[_n-1]
	by matchup_cd: gen d_open_log`exp' = open_log`exp'[_n] - open_log`exp'[_n-1]
}

by matchup_cd: gen d_incumbent = incumbent[_n] - incumbent[_n-1]

drop if num < 2
	
foreach exp of global exp_cols {
	replace inc = d_incumbent_log`exp'
	replace chal = d_challenger_log`exp'
	replace open = d_open_log`exp'
	
	eststo three_`exp': quietly reg d_dem_vote d_incumbent inc chal open, robust noconstant
}

la var d_incumbent "Incumbency"
la var inc "Incumbent spending"
la var chal "Challenger spending"
la var open "Open-seat spending"
la var avg_vote "District alignment"

esttab, label
	
esttab using ../tex/general.tex, replace label ar2(2) b(2) se(2) ///
	addnote("Dependent variable is Democratic vote share. Year fixed effects absorbed.") booktabs ///
	title("Impact of campaign spending. \label{table:reg1}")

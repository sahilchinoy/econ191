cd "/Users/sahilchinoy/Documents/econ191/code"
set more off
clear

insheet using ../data/races.csv

drop if missing(dem_name)
drop if dem_name == ""

drop if missing(rep_name)
drop if rep_name == ""

gen const = 1

global exp_cols tot general comm ads info fnd overhead contrib

********************************
* Un-differenced specification *
********************************

preserve

gen inc = .
gen chal = .
gen open = .

la var inc "Incumbent spending"
la var chal "Challenger spending"
la var open "Open-seat spending"
la var avg_vote "District alignment"

eststo clear
foreach exp of global exp_cols {
	replace inc = incumbent_log`exp'
	replace chal = challenger_log`exp'
	replace open = open_log`exp'
	
	gen d_incumbent_log`exp' = incumbent_log`exp' * incumbent
	gen d_challenger_log`exp' = challenger_log`exp' * incumbent
	gen d_open_log`exp' = open_log`exp'
}

gen d_incumbent = incumbent

eststo: areg dem_vote d_incumbent_logcomm d_incumbent_logads d_incumbent_loginfo ///
		d_incumbent_logfnd d_incumbent_logoverhead d_incumbent_logcontrib ///
		d_challenger_logcomm d_challenger_logads d_challenger_loginfo ///
		d_challenger_logfnd d_challenger_logoverhead d_challenger_logcontrib ///
		d_open_logcomm d_open_logads d_open_loginfo d_open_logfnd d_open_logoverhead ///
		d_open_logcontrib d_incumbent avg_vote, robust absorb(year)

restore

**********************************
* First-differenced by candidate *
**********************************

preserve

* Repeated Democratic candidates

sort dem_name year

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

* Repeated Republican candidates

preserve

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

eststo: reg d_dem_vote c.d_incumbent_logcomm c.d_incumbent_logads c.d_incumbent_loginfo ///
		c.d_incumbent_logfnd c.d_incumbent_logoverhead c.d_incumbent_logcontrib ///
		c.d_challenger_logcomm c.d_challenger_logads c.d_challenger_loginfo ///
		c.d_challenger_logfnd c.d_challenger_logoverhead c.d_challenger_logcontrib ///
		d_open_logcomm d_open_logads d_open_loginfo d_open_logfnd d_open_logoverhead ///
		d_open_logcontrib d_incumbent, robust noconstant
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

eststo: reg d_dem_vote c.d_incumbent_logcomm c.d_incumbent_logads c.d_incumbent_loginfo ///
		c.d_incumbent_logfnd c.d_incumbent_logoverhead c.d_incumbent_logcontrib ///
		c.d_challenger_logcomm c.d_challenger_logads c.d_challenger_loginfo ///
		c.d_challenger_logfnd c.d_challenger_logoverhead c.d_challenger_logcontrib ///
		d_open_logcomm d_open_logads d_open_loginfo d_open_logfnd d_open_logoverhead ///
		d_open_logcontrib d_incumbent, robust noconstant

	
la var avg_vote "District alignment"
la var d_incumbent "Incumbency"
		
la var d_incumbent_logcomm "Incumbent communications"
la var d_incumbent_logads "Incumbent ads"
la var d_incumbent_loginfo "Incumbent information"
la var d_incumbent_logfnd "Incumbent fundraising"
la var d_incumbent_logoverhead "Incumbent overhead"
la var d_incumbent_logcontrib "Incumbent contributions"

la var d_challenger_logcomm "Challenger communications"
la var d_challenger_logads "Challenger ads"
la var d_challenger_loginfo "Challenger information"
la var d_challenger_logfnd "Challenger fundraising"
la var d_challenger_logoverhead "Challenger overhead"
la var d_challenger_logcontrib "Challenger contributions"

la var d_open_logcomm "Open-seat communications"
la var d_open_logads "Open-seat ads"
la var d_open_loginfo "Open-seat information"
la var d_open_logfnd "Open-seat fundraising"
la var d_open_logoverhead "Open-seat overhead"
la var d_open_logcontrib "Open-seat contributions"

esttab, label

esttab using ../tex/breakdown.tex, replace label ar2(2) b(2) se(2) ///
	addnote("Dependent variable is Democratic vote share. Year fixed effects absorbed.") booktabs ///
	title("Impact of campaign spending. \label{table:breakdown}") wide

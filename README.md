## Economics 191: Topics in Economic Research / Spring 2017 / UC Berkeley

For this research seminar, I conducted an analysis of the effectiveness of campaign spending in California using new data from the [California Civic Data Coalition](http://www.californiacivicdata.org/). The results corroborate findings at the federal level: campaign spending in California Assembly races, regardless of category and accounting for measurement error, is remarkably ineffective. This means that the puzzle of why candidates continue to spend money on campaigning remains. The sole exception is advertising spending for challengers, which lends support to theoretical models of campaign finance that see campaign spending as directly informative.

If you just want to see the final paper, head to `paper/paper.pdf`.

The directory structure is as follows:
- `data` contains raw and processed data from [CAL-ACCESS](http://cal-access.sos.ca.gov/) (cleaned up by CCDC) and [OpenElections](http://openelections.net/)
- `code` contains Jupyter notebooks and Stata code used to process and analyze the data
- `tex` contains some TeX tables used in the paper
- `charts` contains some charts used in the paper
- `paper` contains the TeX file used to produce the final paper, a bibliography, and the paper itself

Below, a description of the analysis code:
- `scrape_candidates.py`
  - scrape certified candidates from CAL-ACCESS site
  - produces `scraped_candidates.csv`
- `candidates.ipynb`
  - uses `scraped_candidates.csv`
  - produces `candidates.csv`, a list of candidates and filer ids
- `expenditures.ipynb`
  - uses `candidates.csv` and `committees.csv`
  - produces `expenditures.csv`, a list of candidates and a breakdown of their expenditures for each election cycle
- `votes.ipynb`
  - uses data from OpenElections to populate list of candidates with vote share, winning status, and incumbency
  - produces `votes.csv`
- `merge.ipynb`
  - merges expenditure and vote share data
  - produces `all.csv`, a list of all candidates with their expenditure breakdown and vote share
- `races.ipynb`
  - aggregates candidate expenditure at the race level, as required by the regression specification
  - produces `races.csv`
- `summary.do`
  - produces `summary.tex`, a table of summary statistics and `corr.tex`, a correlation matrix for the spending variables
- `general.do`
  - produces `general.tex`, a regression table for the effectiveness of campaign spending
- `breakdown.do`
  - produces `breakdown.tex`, a regression table for the effectiveness of campaign spending by category

This is not a fully robust analysis of campaign spending in California Assembly races; in particular, the subset of data used for the identification strategy I attempted to employ doesn't have quite enough variation to result in precise estimates. Still, the results are suggestive, and provide a direction in which to pursue further empirical and theoretical work. Comments and suggestions are welcome.

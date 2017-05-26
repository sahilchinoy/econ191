scrape_candidates.py
- scrape certified candidates from CAL-ACCESS site
- produces `scraped_candidates.csv`

candidates.ipynb
- uses scraped_candidates.csv
- produces `candidates.csv`, a list of candidates and filer ids

expenditures.ipynb
- uses candidates.csv and committees.csv
- produces `expenditures.csv`, a list of candidates and a breakdown of their expenditures for each election cycle

votes.ipynb
- uses data from OpenElections to populate list of candidates with vote share, winning status, and incumbency
- produces `votes.csv`

merge.ipynb
- merges expenditure and vote share data
- produces `all.csv`, a list of all candidates with their expenditure breakdown and vote share

races.ipynb
- aggregates candidate expenditure at the race level, as required by the regression specification
- produces `races.csv`

summary.do
- produces `summary.tex`, a table of summary statistics and `corr.tex`, a correlation matrix for the spending variables

general.do
- produces `general.tex`, a regression table for the effectiveness of campaign spending

breakdown.do
- produces `breakdown.tex`, a regression table for the effectiveness of campaign spending by category
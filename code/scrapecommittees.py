#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Scrape each certified candidate's committees from the CAL-ACCESS site.
"""
import re
import csv
import requests
from time import sleep
from bs4 import BeautifulSoup
from six.moves.urllib.parse import urljoin

def get_html(url):
    base_url = 'http://cal-access.ss.ca.gov/'
    full_url = urljoin(base_url, url)
    html = requests.get(full_url).text
    soup = BeautifulSoup(html, "html.parser")
    return soup

def scrape_candidate_page(url):
    """
    Pull the committees from a CAL-ACCESS candidate page.
    """
    soup = get_html(url)

    committees = []

    for table in soup.findAll('table')[2].findAll('table'):
        # Committees with a link
        c = table.find('a', {'class': 'sublink6'})
        if c:
            committees.append({
                'committee_name': c.text.strip(),
                'committee_id': re.match(r'.+id=(\d+)', c['href']).group(1).strip(),
                #'status': table.findAll('tr')[1].findAll('td')[1].text.strip()
            })
        # Committees with an ID but no link
        else:
            regex = re.compile(r'(.*)\(ID# (\d*)\)')
            c = table.find('span', string=regex)
            if c:
                matches = re.match(regex, c.text)
                committees.append({
                    'committee_name': matches.group(1).strip(),
                    'committee_id': matches.group(2).strip(),
                    #'status': table.findAll('tr')[1].findAll('td')[1].text.strip()
                })

    return committees

with open('data/scraped_committees.csv', 'w') as outfile, open('data/scraped_candidates.csv', 'r') as infile:
    reader = csv.DictReader(infile)
    writer = csv.DictWriter(outfile,
        fieldnames=['candidate_id','committee_name','committee_id'],
        quoting=csv.QUOTE_ALL)
    writer.writeheader()

    candidate_ids = set([row['candidate_id'] for row in reader])
    for candidate_id in candidate_ids:
        print(candidate_id)
        url = '/Campaign/Candidates/Detail.aspx?id={}'.format(
            candidate_id)
        committees = scrape_candidate_page(url)

        for committee in committees:
            writer.writerow({
                'candidate_id': candidate_id,
                'committee_name': committee['committee_name'],
                'committee_id': committee['committee_id'],
            })

        sleep(0.5)
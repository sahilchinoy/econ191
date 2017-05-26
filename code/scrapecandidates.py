#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Scrape list of certified candidates from the CAL-ACCESS site.
"""
from bs4 import BeautifulSoup
import re
import csv
import requests
from six.moves.urllib.parse import urljoin
from time import sleep

base_url = 'http://cal-access.ss.ca.gov/'

data = []

def get_html(url):
    html = requests.get(url).text
    soup = BeautifulSoup(html, "html.parser")
    return soup

def scrape_election_page(url, election_name):
    """
    Pull the elections and candidates from a CAL-ACCESS page.
    """
    # Go and get the page

    print(url)
    soup = get_html(url)

    races = {}
    # Loop through all the election sets on the page
    for section in soup.findAll('a', {'name': re.compile(r'[a-z]+')}):

        # Check that this data matches the structure we expect.
        section_name_el = section.find('span', {'class': 'hdr14'})

        # If it doesn't, skip this one
        if not section_name_el:
            continue

        # Loop through all the rows in the section table
        for office in section.findAll('td'):

            # Check that this data matches the structure we expect.
            title_el = office.find('span', {'class': 'hdr13'})

            # If it doesn't, skip
            if not title_el:
                continue

            office_name = title_el.text

            # Pull the candidates out
            candidates = []
            for c in office.findAll('a', {'class': 'sublink2'}):
                candidates.append({
                    'name': c.text,
                    'scraped_id': re.match(
                        r'.+id=(\d+)',
                        c['href']
                    ).group(1),
                    #'url': urljoin(base_url, url),
                })

            for c in office.findAll('span', {'class': 'txt7'}):
                candidates.append({
                    'name': c.text,
                    'scraped_id': '',
                    #'url': urljoin(base_url, url),
                })

            for candidate in candidates:
                data.append({
                    'candidate': candidate['name'],
                    'scraped_id': candidate['scraped_id'],
                    'election': election_name, 
                    'office': office_name
                })

# Put together the full URL
url = '/Campaign/Candidates/list.aspx?view=certified&electNav=93'
full_url = urljoin(base_url, url)

soup = get_html(full_url)

# Get all the links out
links = soup.findAll('a', href=re.compile(r'^.*&electNav=\d+'))

# Drop the link that says "prior elections" because it's a duplicate
links = [
    l for l in links
    if l.find_next_sibling('span').text != 'Prior Elections'
]

# Loop through the links

for i, link in enumerate(links):
    # Get each page and its data
    url = urljoin(base_url, link["href"])
    # Get the name of the election
    election_name = link.find_next_sibling('span').text.strip()
    if 'GENERAL' in election_name:
        scrape_election_page(url, election_name)
    
    sleep(0.5)

# Write it all out
with open('data/scraped_candidates.csv', 'w') as outfile:
    writer = csv.DictWriter(outfile, fieldnames=['candidate','candidate_id','election','office'])
    writer.writeheader()
    for row in data:
        writer.writerow(row)

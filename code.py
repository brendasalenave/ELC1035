#!/usr/bin/envpython3
import requests, bs4, re, csv

url = 'http://www.imdb.com/search/title?title_type=tv_series'
res=requests.get(url)
res.raise_for_status()
print('Updating Series Dataset ...')
soup=bs4.BeautifulSoup(res.text,"lxml")
name = ['Name']

for tag in soup.find_all('img', alt=True):
    name.append(tag['alt'])

name.pop(1)
name.pop(1)

rating = ['Rate']
for tag in soup.findAll(itemprop="ratingValue"):
    rating.append(tag['content'])

year = ['Year']
for tag in soup.findAll("span", { "class" : "lister-item-year text-muted unbold" }):
    p = re.match('^.*\((.*)\).*$', str(tag))
    year.append(p.group(1))

finished = ['Finished']    

with open('test.csv', 'w', newline='') as fp:
    a = csv.writer(fp, delimiter=',')
    data = []
    t = len(name)
    for u in range(0,t):
        data.append([name[u], rating[u], year[u]])

    a.writerows(data)

print('Done!')

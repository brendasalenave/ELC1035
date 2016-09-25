#!/usr/bin/envpython3

import os, requests, bs4

url = 'http://xkcd.com'
os.makedirs('xkcd', exist_ok=True)
print('Downling page %s...'% url)
res=requests.get(url)
res.raise_for_status()

soup=bs4.BeautifulSoup(res.text)

for fig in soup.select('#comic img'):
    comicUrl='http:' + fig.get('src')
    print('Downloading image %s...' % (comicUrl))
    res=requests.get(comicUrl)
    res.raise_for_status()
    imgFile=open(os.path.join('xkcd',
    os.path.basename(comicUrl)),'wb')
    for chunk in res.iter_content(100000):
        imgFile.write(chunk)
    imgFile.close()
print('Done!')

import json
import requests
import time

base_url = 'https://api.github.com'
base_uri = '/repos/kimchi-project/%s/stats/contributors'
user = 'pvital'
repos = ['kimchi', 'ginger', 'gingerbase', 'wok']

#def current_quarter():
#    today = time.gmtime()
#    if today.tm_mon in range(1,4):
#    elif today.tm_mon in range(4,7):
#    elif today.tm_mon in range(7,10):
#    elif today.tm_mon in range(10,13):
#    else:
#        print "Error"


for repo in repos:
    url = base_url + base_uri % repo
    resp = requests.get(url)
    for data in json.loads(resp.text):
        if data['author']['login'] == user:
            stats = data
    print stats

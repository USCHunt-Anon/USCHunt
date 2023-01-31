import json
import requests
import argparse
import sys


class GUrlShorten():
    def __init__(self, key):
        self.API_KEY = 'AIzaSyDV44le4lcd5sSrvqnKLTtb776zzocaA2Y'

    def google_url_shorten(self, url):
        req_url = 'https://www.googleapis.com/urlshortener/v1/url?key=' + self.API_KEY
        payload = {'longUrl': url}
        headers = {'content-type': 'application/json'}
        r = requests.post(req_url, json=payload, headers=headers)
        resp = json.loads(r.text)
        return resp['id']
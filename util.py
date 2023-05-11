import re
from m3u8 import M3U8
from urllib.request import getproxies
import httpx
headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/99.0.4844.74 Safari/537.36'}
def getporoxy():
    proxy = getproxies()
    if proxy:
        proxy['https'] = proxy['https'].replace('https','http')
        del proxy['ftp']
        return proxy
    return None
def gethttpxporoxy():
    proxy = getproxies()
    if proxy:
        proxy['https'] = proxy['https'].replace('https','http')
        del proxy['ftp']
        d = {}
        d['http://'] = proxy['http']
        d['https://'] = proxy['https']
        return d
    return None
def loadm3u8(url,b=False):
    r = httpx.get(url, verify=False, headers=headers,proxies=gethttpxporoxy())
    if b:
        # baseurl =r.url
        l = url.split("/")
        baseurl = l[0] + "//" + l[2]
    else:
        baseurl = "/".join(url.split("/")[:-1])+"/"
        # l = r.url.split("/")
        # baseurl = l[0] + "//" + l[2]
    # baseurl = urljoin(url, '.')
    return M3U8(r.text, base_uri=baseurl, custom_tags_parser=None)


def checkhentai(url):
    if "uncensoredhentai" in url:
        return True
    # elif "hentai.tv" in url:
    #     return True
    elif "animeidhentai" in url:
        return True


def checkNameValid(name=None):
    """
    检测Windows文件名称！
    """
    reg = re.compile(r'[\\/:*?"<>|\r\n]+')
    valid_name = reg.findall(name)
    if valid_name:
        for nv in valid_name:
            name = name.replace(nv, "_")
    return name








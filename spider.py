# coding=utf-8
import asyncio
import os
import re
import shutil
import subprocess
import sys
import time
import traceback
import threading
import httpx
from selenium.common.exceptions import SessionNotCreatedException
from selenium.webdriver.support.wait import WebDriverWait
import db
import urllib.parse
from Global import Global
from util import loadm3u8, getporoxy, gethttpxporoxy,checkNameValid
from selenium.webdriver.common.by import By
from seleniumwire import webdriver
import logging
logger = logging.getLogger("main.log")
headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/99.0.4844.74 Safari/537.36'}
load = 0


def parser(url, sig, sig1):
    dirname = "download_%s" % (int(time.time()*1000))
    basedir = db.getdatadir() + "/" + dirname
    os.mkdir(basedir)
    download = {'reset':0}
    Video = ""
    try:
        if p:=getporoxy():
            options = {
                'proxy': p
            }
        else:
            options = None
        basehost = urllib.parse.urlparse(url).netloc
        if basehost.count(".")>1:
            host = ".".join(basehost.split(".")[1:])
        else:
            host = basehost
        rule = getrule(host)
        if not rule:
            download['text'] = "缺少解析规则"
            download['reset'] = 1
            sig.emit(download)
            shutil.rmtree(basedir)
            return
        download['text'] = "页面解析中"
        download['type'] = rule.get('type')
        sig.emit(download)
        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_experimental_option("useAutomationExtension", False)
        chrome_options.add_experimental_option('excludeSwitches', ['enable-automation'])
        chrome_options.add_argument('--ignore-certificate-errors')
        pwd = os.getcwd()
        pwd = pwd.replace("\\", "/") + "/userdir"
        chrome_options.add_argument("--user-data-dir=" + pwd)
        if Global.headless:
            user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36'
            chrome_options.add_argument(f'user-agent={user_agent}')
            chrome_options.add_argument("--window-size=1920x1080")
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument('headless')
            chrome_options.add_argument('no-sandbox')
            chrome_options.add_argument("--start-maximized")
            chrome_options.page_load_strategy = 'none'
        else:
            chrome_options.add_experimental_option("detach", True)
        drive =webdriver.Chrome('chromedriver.exe',seleniumwire_options=options, options=chrome_options)
        drive.scopes = rule['video']
        bakclicks = rule.get('click-bak')
        b = False
        clicks = rule.get('click')
        s =time.time()
        if Global.headless:
            try:
                drive.get(url)
            except:
                print("time out")
            if clicks:
                bak = rule.get('bak')
                if existelement(bak, drive):
                    clickelement(bakclicks, drive)
                    b = True
                else:
                    clickelement(clicks, drive)
            t = 0
            while not Video:
                if b:
                    Video = getbakurl(drive, rule['video-bak'])
                else:
                    Video = geturl(drive, rule['video'])
                time.sleep(0.5)
                t += 0.5
                if t>30:
                    break
            Title = WebDriverWait(drive, 10, poll_frequency=0.5, ignored_exceptions=None).until(
                lambda x: x.find_element(By.XPATH, '/html/head/title')).get_attribute("textContent")
            Img = WebDriverWait(drive, 10, poll_frequency=0.5, ignored_exceptions=None).until(
                lambda x: x.find_element(By.XPATH, rule['pic']['re'])).get_attribute(rule['pic']['value'])
            e = time.time()
            download['time'] = e - s
            sig.emit(download)
        else:
            try:
                drive.get(url)
            except:
                print("drive quit")
            Title = drive.find_element(By.XPATH, '/html/head/title').get_attribute("textContent")
            try:
                Img = drive.find_element(By.XPATH, rule['pic']['re']).get_attribute(rule['pic']['value'])
            except:
                Img = None
            download['text'] = "标题已获取"
            sig.emit(download)
            while True:
                loglist = drive.get_log("driver")
                if checklog(loglist):
                    break
                time.sleep(1)
            Video = geturl(drive, rule['video'])
        threading.Thread(target=quitdrive,args=(drive,)).start()
        if not Video:
            download['text'] = "失败,无法找到视频路径"
            download['reset'] = 1
            sig.emit(download)
            return
        icopath = downloadico(rule['ico'],rule['iconame'])
        Title = Title.replace("\n", " - ")
        Title = Title.lstrip(" ")
        if Img:
            download['text'] = "封面下载中"
            sig.emit(download)
            imgname = Img.split("/")[-1]
            imgname = checkNameValid(imgname)
            imgpath = f"{basedir}/" + imgname
            if not Img.startswith("https"):
                Img = "https://"+basehost+Img
            r = httpx.get(Img, verify=False, proxies=gethttpxporoxy(),timeout=5)
            with open(imgpath, "wb") as f:
                f.write(r.content)
        else:
            pwd = os.getcwd()
            imgpath = pwd.replace("\\", "/") + "/icon/notfound.png"
            imgname = 'notfound.png'
        download['title'] = Title
        download['text'] = "解析成功"
        download['img'] = imgpath
        download['ico'] = rule['ico']
        sig.emit(download)
        b = rule.get('b')
        if rule.get('master'):
            Video = masterm3u8(Video,b)
        if rule['type'] == 'm3u8':
            video = downloadm3u8(Video, sig, sig1, basedir,b=b,m4s=rule.get('m4s'))
        else:
            video = downloadmp4(Video, sig, sig1, basedir)
        title = Title.replace('\'','')
        db.insertvideo(title, dirname + "/" + imgname, dirname + "/" + video,icopath)
    except SessionNotCreatedException as e:
        print(e.msg.split('\n')[1])
        download['text'] = "失败"
        download['error'] = e.msg.split('\n')[1]
        download['reset'] = 1
        sig.emit(download)
        shutil.rmtree(basedir)
    except Exception as e:
        logger.error(traceback.format_exc())
        download['text'] = "失败"
        download['reset'] = 1
        sig.emit(download)
        shutil.rmtree(basedir)



def downloadmp4(url, sig, sig1, basedir):
    download = {}
    with httpx.stream("GET",url,proxies=gethttpxporoxy(),verify=False) as req:
        videosize = round(int(req.headers['Content-Length']) / 1024 / 1024, 2)
        s = 0
        name = "download_" + str(int(time.time()))
        path = basedir + "/"
        download['text'] = "下载中"
        # download['load'] = 1
        sig.emit(download)
        # sig1.emit({"load": 1})
        with open(path + f"{name}.mp4", 'wb') as f:
            for i in req.iter_bytes(chunk_size=1024 * 10):
                if i:
                    f.write(i)
                    s += 1024 * 10
                    sig1.emit({"now": round(s / 1024 / 1024, 2), "total": videosize, "load": 0})
                    download['loading'] = {"now": round(s / 1024 / 1024, 2), "total": videosize}
        download['text'] = "完成"
        download['reset'] = 1
        sig.emit(download)
        return f"{name}.mp4"

def downloadm3u8(url, sig, sig1, basedir, b=False,m4s=False):
    download = {}
    f = loadm3u8(url, b)
    base_url = f.base_uri
    l = []
    T = []
    m4shead = ""
    for i in f.dumps().split("\n"):
        if i.startswith("#EXT-X-MAP"):
            m4shead = i.split("=")[1][1:-1]
        if not i.startswith("#") and i:
            l.append(i)
    if m4shead:
        if base_url.endswith("/") and m4shead.startswith("/"):
            base_url = base_url.rstrip("/")
        m4shead = base_url+m4shead
    download['text'] = "下载中"
    download['load'] = 1
    sig.emit(download)
    # sig1.emit({"load": 1})
    total = len(l)
    sig1.emit({"now": 0, "total": total, "load": 0})
    global load
    load = 0
    asyncio.run(main(l, sig1, base_url, basedir,T))
    m4sl = []
    with open(basedir + "/file.txt", 'w') as f:
        for i in range(total):
            if i+1 not in T:
                f.write(f"file 'tmp_{i + 1}.ts'\n")
                m4sl.append(f'tmp_{i + 1}.ts')
    videoname = "mp4_" + str(int(time.time()))
    path = os.path.abspath(sys.argv[0])
    ffmpegpath = path.rstrip(path.split("\\")[-1]) + "/ffmpeg.exe"
    download['text'] = "合成中"
    sig.emit(download)
    if m4s:
        mergem4s(m4shead,m4sl,videoname,ffmpegpath,basedir)
    else:
        p = subprocess.Popen(f'cd /d {basedir} && {ffmpegpath} -f concat -i file.txt -c copy {videoname}.mp4 && del *.ts',
                             stdout=subprocess.PIPE, shell=True,
                             stderr=subprocess.PIPE)
        p.communicate()
    download['text'] = "完成"
    download['reset'] = 1
    sig.emit(download)
    return f"{videoname}.mp4"


async def asyncdownload(l, sig1, base_url, basedir, total,sig,T):
    download = {}
    try:
        async with httpx.AsyncClient(proxies=gethttpxporoxy()) as client:
            while len(l) > 0:
                j = l.pop(0)
                sig['load'] += 1
                t = sig['load']
                if j.startswith("https://"):
                    url = j
                else:
                    if base_url.endswith("/") and j.startswith("/"):
                        base_url = base_url.rstrip("/")
                    url = base_url + j
                for i in range(3):
                    try:
                        r = await client.get(url)
                        break
                    except Exception as e:
                        traceback.print_exc()
                if r.content[0] == 71 or url.endswith(".m4s"):
                    with open(f"{basedir}/" + f"tmp_{t}.ts", 'wb') as f:
                        f.write(r.content)
                else:
                    T.append(t)
                sig1.emit({"now": sig['load'], "total": total, "load": 0})
                download['loading'] = {"now": load, "total": total}
    except Exception as e:
        traceback.print_exc()

def mergem4s(mp4head,l,name,ffmpegpath,basedir):
    r = httpx.get(mp4head,verify=False, proxies=gethttpxporoxy())
    mp4 = r.content
    mp4data = b''
    for i in l:
        with open(f'{basedir}/'+i,'rb') as f:
            mp4data += (mp4+f.read())
    with open(f'{basedir}/'+"tmp.mp4",'wb') as f:
        f.write(mp4data)
    p = subprocess.Popen(f'cd /d {basedir} && {ffmpegpath} -i tmp.mp4 -vcodec libx264 -acodec copy {name}.mp4 && del *.ts && del tmp.mp4',
                         stdout=subprocess.PIPE, shell=True,
                         stderr=subprocess.PIPE)
    p.communicate()




async def main(l, sig1, base_url, basedir,T):
    total = len(l)
    sig = {'load':0}
    await asyncio.gather(asyncdownload(l, sig1, base_url, basedir, total,sig,T),
                         asyncdownload(l, sig1, base_url, basedir, total,sig,T),
                         asyncdownload(l, sig1, base_url, basedir, total,sig,T),
                         asyncdownload(l, sig1, base_url, basedir, total,sig,T),
                         asyncdownload(l, sig1, base_url, basedir, total,sig,T))


def masterm3u8(url,b=False):
    f = loadm3u8(url,b)
    base_url = f.base_uri
    d = {"band": 0, "url": ""}
    for i in f.playlists:
        if i.stream_info.bandwidth > d['band']:
            d["band"] = i.stream_info.bandwidth
            d["url"] = i.uri
    if d['url'].startswith("https:"):
        url = d['url']
    else:
        if d['url'].startswith("/") or base_url.endswith("/"):
            url = base_url + d['url']
        else:
            url = base_url + "/" + d['url']
    return url

def getrule(host):
    for keys,value in Global.ruleset.items():
        for key in keys.split(','):
            if key == host:
                value['iconame'] = keys.split(',')[0]
                return value
    return None

def geturl(drive,rules):
    for rule in rules:
        for i in drive.requests:
            if re.match(rule, i.url):
                return i.url
    return None



def getbakurl(drive,videobak):
    if videobak['iframe']:
        drive.switch_to.frame(drive.find_element(By.TAG_NAME, 'iframe'))
    url = drive.find_element(By.XPATH, videobak['value']).get_attribute('href')
    if videobak['iframe']:
        drive.switch_to.default_content()
    return url

def clickelement(clicks,drive):
    for click in clicks:
        if click['type'] == "id":
            by = By.ID
        elif click['type'] == "class":
            by = By.CLASS_NAME
        elif click['type'] == 'xpath':
            by = By.XPATH
        iframe = click.get('iframe')
        if iframe:
            WebDriverWait(drive, 35, poll_frequency=0.5, ignored_exceptions=None).until(
                lambda x: x.find_element(By.TAG_NAME, 'iframe'))
            drive.switch_to.frame(drive.find_element(By.TAG_NAME, 'iframe'))
        if click.get('ignore'):
            try:
                button = WebDriverWait(drive, 5, poll_frequency=0.5, ignored_exceptions=None).until(
                    lambda x: x.find_element(by, click['value']))
                button.click()
            except:
                pass
            time.sleep(2)
        else:
            button = WebDriverWait(drive, 50, poll_frequency=0.5).until(
                lambda x: x.find_element(by, click['value']))
            button.click()
        if iframe:
            drive.switch_to.default_content()

def existelement(click,drive):
    b = False
    if click:
        iframe = click.get('iframe')
        if iframe:
            drive.switch_to.frame(drive.find_element(By.TAG_NAME, 'iframe'))
        try:
            WebDriverWait(drive, 10, poll_frequency=0.5, ignored_exceptions=None).until(
                lambda x: x.find_element(By.XPATH, click['value']))
            b = True
        except:
            pass
        if iframe:
            drive.switch_to.default_content()
    return b


def checklog(loglist):
    for i in loglist:
        if "target window already closed" in i['message']:
            return True

def downloadico(url,name):
    if not os.path.exists(f"./img/{name}.ico"):
        r = httpx.get(url, verify=False, proxies=gethttpxporoxy())
        with open(f"./img/{name}.ico", "wb") as f:
            f.write(r.content)
    return f'{name}.ico'

def quitdrive(driver):
    driver.close()
    driver.quit()




# coding=utf-8
import pathlib
from spider import *
import os
import subprocess
from time import strftime,gmtime
import sys
import toml
from PySide6.QtCore import QObject, Slot, Signal, QThread
from PySide6.QtWidgets import QApplication
from Global import Global
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine, QmlElement
import db
import time
from dirsync import sync
import logging
import threading
from PIL import Image
QML_IMPORT_NAME = "io.qt.textproperties"
QML_IMPORT_MAJOR_VERSION = 1

Log_Format = "%(levelname)s %(asctime)s - %(message)s"

logging.basicConfig(filename = "logfile.log",
                    filemode = "a",
                    format = Log_Format,
                    level = logging.ERROR)

logger = logging.getLogger("main.log")


@QmlElement
class Bridge(QObject):
    sig = Signal(str,arguments=['res'])
    sig1 = Signal("QVariant",arguments=['show'])
    sig2 = Signal("QVariant",arguments=['load'])
    sig3 = Signal(int,arguments=['ok'])
    num = 0
    @Slot(int, result=list)
    def getdata(self, num):
        Global.now_page += num
        return db.getdata()


    @Slot(result=int)
    def gettotal(self):
        return db.gettotal()

    @Slot(result=int)
    def getnowpage(self):
        return Global.now_page

    @Slot(int, result=list)
    def jump(self, num):
        Global.now_page = num
        return db.getdata()

    @Slot(str, int,result=list)
    def search(self, text,page):
        return db.getdata(text,page)

    @Slot(int, result=list)
    def love(self, num):
        if num == 0:
            Global.collect_page = 1
        else:
            Global.collect_page += 1
        return db.getcollectdata()

    @Slot(int)
    def history(self, id):
        db.recordhistory(id)

    @Slot(result=list)
    def getallhistory(self):
        return db.gethistorydata()

    @Slot(int, int)
    def uphistory(self, id, num):
        db.updatehistory(id, num)

    @Slot(result=list)
    def getalltags(self):
        return db.getalltags()

    @Slot(int, result=list)
    def gettagdata(self, num):
        return db.gettagdata(num)

    @Slot(str, str, str)
    def addtags(self, title, desc, imgpath):
        db.addtags(title, desc, imgpath)

    @Slot(int, str, str, str)
    def changetags(self, id, title, desc, imgpath):
        db.ctags(id, title, desc, imgpath)

    @Slot(int)
    def deltags(self, num):
        db.deltag(num)

    @Slot(int, int,int,str)
    def collect(self, id, num,ts,vpath):
        if num ==1:
            t = threading.Thread(target=gencpic,args=(id,ts,vpath,num))
            t.setDaemon(True)
            t.start()
        else:
            db.change_collect(id, num, "")

    @Slot(int,result="QVariant")
    def getdetail(self,id):
        return db.detail(id)

    @Slot(int,result="QVariant")
    def gettransfer(self,id):
        return db.transfer(id)

    @Slot(list,int)
    def changetag(self,l,id):
        s = ""
        nums = len(l)
        for i in l:
            s += f"{int(i)},"
        s =s.rstrip(",")
        db.changetags(s,id,nums)

    @Slot(str,str,str)
    def localimport(self,title,feng,video):
       db.insertvideo(title,feng,video)

    @Slot(str,str,str,str)
    def netimport(self,title,feng,video,mu):
        t = threading.Thread(target=download,args=(title,feng,video,mu))
        t.start()

    @Slot(str,int)
    def genimg(self,path,id):
        t = threading.Thread(target=genpreview, args=(path,id,self.sig))
        t.setDaemon(True)
        t.start()


    @Slot(result="QVariant")
    def getprocess(self):
        return Global.process

    @Slot(int,str,str)
    def update(self,id,title,img):
        if "notfound" not in img:
            img = img.lstrip('file:///')
            newpath = db.cpimg(img,id)
        else:
            newpath = ""
        db.updatedata(id,title,newpath)

    @Slot(str,str)
    def stredit(self,s):
        l = s.split('/')[0]
        return l.rstrip(".mp4")

    @Slot(str)
    def spider(self,url):
        Global.download['url'] = url
        Global.download['run'] = 1
        Global.download['text'] = "页面解析中"
        self.sig1.emit(Global.download)
        t = threading.Thread(target=parser,args=(url,self.sig1,self.sig2))
        t.setDaemon(True)
        t.start()


    @Slot(result="QVariant")
    def running(self):
        return Global.download

    @Slot()
    def clear(self):
        Global.download = {"url":"","text":"","img":"","run":0,"title":"","reset":0,"ico":"","load":0}

    @Slot(int,result=int)
    def getimgrun(self,id):
        return Global.genimg.get(id,0)

    @Slot(int)
    def delvideo(self,id):
        db.delvideo(id)

    @Slot()
    def syncchrome(self):
        if not Global.download['sync']:
            t = threading.Thread(target=syncdata,args=(self.sig3,))
            t.setDaemon(True)
            t.start()

    @Slot(QObject,str)
    def starttask(self,qml,url):
        task = ThreadTask(url)
        task.message.connect(qml.recvfromthread)
        task.download.connect(qml.downloaing)
        qml.mysig.connect(self.deltask)
        t = threading.Thread(target=task.run)
        t.setDaemon(True)
        t.start()

    @Slot()
    def deltask(self):
        print("------------")


class ThreadTask(QObject):
    message = Signal("QVariant")
    download = Signal("QVariant")
    def __init__(self,url):
        super(ThreadTask, self).__init__()
        self.url = url

    def destory(self):
        Bridge.num -= 1
        print(Bridge.num)

    def run(self):
        parser(self.url,self.message,self.download)






def syncdata(sig):
    Global.download['sync'] = True
    home = str(pathlib.Path.home()) + r"\AppData\Local\Google\Chrome\User Data"
    pwd = os.getcwd()
    pwd = pwd.replace("\\", "/") + "/userdir"
    sync(home, pwd, 'sync')
    Global.download['sync'] = False
    sig.emit(1)





def download(title,feng,video,mu):
    path = db.getdatadir()+f"/{mu}/"
    if not os.path.exists(path):
        os.mkdir(path)
    s = 0
    for i in (feng,video):
        rep = httpx.get(i,verify=False,proxies=gethttpxporoxy())
        if s==0:
            with open(path+f"{title}.jpg","wb") as f:
                f.write(rep.content)
            s += 1
        else:
            with open(path+f"{title}.mp4","wb") as f:
                f.write(rep.content)
    db.insertvideo(title, f"milker/{mu}/{title}.jpg", f"milker/{mu}/{title}.mp4")

def gencpic(id,ts,vpath,num):
    text = strftime("%H:%M:%S", gmtime(ts / 1000))
    cmd = f'ffmpeg.exe -ss "{text}" -i "{vpath}" img/img{id}.jpg -y'
    # os.system(cmd)
    o = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True,
                           stderr=subprocess.PIPE)
    o.wait()
    db.change_collect(id, num, f"img{id}.jpg")

def genpreview(path,id,sig):
    Global.genimg[id]=1
    yulan = ""
    try:
        basedirs = db.getdatadir()+"/"
        workpath = path.split("/")
        path = basedirs + path
        workdir = basedirs + workpath[0]
        out = subprocess.Popen('ffmpeg.exe -i "%s"' % path, stdout=subprocess.PIPE,shell=True,
                               stderr=subprocess.PIPE)
        out.wait()
        strout, strerr = out.communicate()
        l = strerr.decode('gb18030', 'ignore').split("\n")
        timedur = 60
        for i in l:
            i = i.strip(" ")
            if i.startswith("Duration"):
                d = i.split(',')[0].split(": ")[1]
                dd = d.split(":")
                dur = int(dd[1]) * 60 + int(dd[2].split(".")[0])
                timedur = int(dur / 25)
                break
        s = r'ffmpeg.exe -i "%s" -vf fps=1/%s "%s/%s"' % (path, timedur, workdir, "images-%d.png")
        out = subprocess.Popen(s, stdout=subprocess.PIPE,shell=True,
                               stderr=subprocess.PIPE)
        out.communicate()
        newimg = Image.new('RGB', (5 * 800, 5 * 500))
        for y in range(1, 6):
            for x in range(1, 6):
                im = Image.open(workdir + '/images-%s.png' % ((y - 1) * 5 + x))
                im = im.resize((800, 500))
                newimg.paste(im, ((x - 1) * 800, (y - 1) * 500))
        name = "yulan%s.png" % id
        namepath = workdir + "/" + name
        newimg.save(namepath)
        db.updatepreview(workpath,name,id)
        for ii in range(1, 26):
            os.remove(workdir + "/images-%s.png" % ii)
        yulan = workpath[0] + '/' + name
    except Exception as e:
        logging.error(e)
    finally:
        Global.genimg.pop(id)
        sig.emit(yulan)





@QmlElement
class Config(QObject):
    def __init__(self):
        super(Config, self).__init__()
        self.cfg = toml.load('config.toml')

    @Slot(str, result=str)
    def c(self, key):
        if '.' in key:
            o, t = key.split('.')
            return self.cfg[o][t]

    @Slot(int,result="QVariant")
    def lang(self,t):
        if t==9:
            t = db.getlang()
        if t==0:
            c = toml.load('en_US.toml')
            c['netdown']['tiptext'] = self.getnet()
            return c
        elif t==1:
            c = toml.load('zh_CN.toml')
            c['netdown']['tiptext'] = self.getnet()
            return c
        elif t==2:
            pass
        elif t==3:
            pass
            # t, encoding = locale.getdefaultlocale()


    @Slot(result=int)
    def getlock(self):
        return db.getswitch()

    @Slot(str,result=bool)
    def checkpwd(self,pwd):
        return db.checkpwd(pwd)

    @Slot(int)
    def updateswitch(self,c):
        db.updateswitch(c)

    @Slot(result=int)
    def getlang(self):
        return db.getlang()

    @Slot(int)
    def updatelang(self,n):
        db.updatelang(n)

    @Slot(str)
    def updatedatadir(self,dir):
        db.updatedatadir(dir)

    @Slot(result=str)
    def getdatadir(self):
        return db.getdatadir()

    @Slot(int)
    def headless(self,state):
        if state == 0:
            Global.headless = False
        else:
            Global.headless = True
        db.setheadless(int(Global.headless))

    @Slot(result=int)
    def getheadless(self):
        print("+++++++++++++++++++")
        return db.getheadless()

    @Slot(int)
    def mute(self,num):
        db.changemute(num)

    @Slot(float)
    def volvalue(self,num):
        db.changevalue(num)

    @Slot(result="QVariant")
    def loadvol(self):
        return db.getvol()

    @Slot(result=str)
    def getnet(self):
        t = toml.load("rule.toml")
        s = ",".join(t.keys())
        return s



if __name__ == "__main__":
    db.datadir()
    Global.ruleset = toml.load("rule.toml")
    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon('icon/box2-heart-fill.svg'))
    engine = QQmlApplicationEngine()
    bridge = Bridge()
    config = Config()
    engine.rootContext().setContextProperty('bridge', bridge)
    engine.rootContext().setContextProperty('cfg', config)
    engine.load("main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

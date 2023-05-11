# coding=utf-8
import hashlib
import os
import sqlite3
import shutil
import time
import pysrt
import httpx
from util import gethttpxporoxy
from Global import Global

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d
# if os.path.exists("db.sqlite3"):
CONN = sqlite3.connect('db.sqlite3',check_same_thread=False)
CONN.row_factory = dict_factory
# else:
#     CONN = sqlite3.connect('db.sqlite3', check_same_thread=False)
#     CONN.row_factory = dict_factory
#     cur = CONN.cursor()
#     cur.executescript('''create table config
# (
#     pwd      TEXT,
#     switch   INT  default 1,
#     vol      INT  default 0,
#     volvalue INT  default 100,
#     lang     INT  default 0,
#     datadir  TEXT default "",
#     headless INT  default 1
# );'''
#     )
#     cur.executescript("insert into config values('e10adc3949ba59abbe56e057f20f883e',0,0,100,1,'',1)")
#     cur.executescript('''
#     create table hentai_movies
# (
#     id          INTEGER not null
#         primary key autoincrement,
#     title       varchar(100),
#     feng        varchar(100),
#     tags        varchar(100),
#     chapters    INTEGER default 0 not null,
#     video       varchar(100),
#     company     varchar(100),
#     description TEXT,
#     zimu        varchar(100),
#     yulan       varchar(100),
#     collect     INT     default 0,
#     tagid       INT     default 0,
#     views       INT     default 0,
#     colpic      TEXT,
#     collecttime datetime
# );
#     ''')
#     cur.executescript('''
#     create table history
# (
#     id       INTEGER
#         constraint history_pk
#             primary key autoincrement,
#     hid      INT,
#     time     datetime,
#     viewtime INT
# );''')
#     cur.executescript('''
#     create table tags
# (
#     id   INTEGER not null
#         constraint tags_pk
#             primary key autoincrement,
#     name TEXT,
#     ids  TEXT,
#     num  INT default 0,
#     desc TEXT,
#     bg   TEXT
# );
#
# create unique index tags_id_uindex
#     on tags (id);
#     ''')
#     CONN.commit()
#     cur.close()
def getdata(text=None,page=1):
    if text:
        n = 25 * (page-1)
        sql_total = "select count(*) as total from hentai_movies where title like '%%%s%%'" % text
        sql = "select title,feng,video,id,collect,yulan,company from hentai_movies where title like '%%%s%%' limit 25 offset %s" % (
        text, n)
        cur = CONN.cursor()
        data = cur.execute(sql).fetchall()
        total = cur.execute(sql_total).fetchone()['total']
        t = total / 25
        TOTAL_PAGE = int(t)
        if t > TOTAL_PAGE:
            TOTAL_PAGE += 1
        if TOTAL_PAGE>1:
            Global.search = text
        return [data,TOTAL_PAGE]
    else:
        n = Global.now_page
        n = 25*(n-1)
        sql = "select title,feng,video,id,collect,yulan,company from hentai_movies limit 25 offset %s" % n
        cur = CONN.cursor()
        data = cur.execute(sql).fetchall()
        return data

def gettotal():
    sql = "select count(*) as total from hentai_movies"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchone()
    TOTAL = data['total']
    t = TOTAL / 25
    TOTAL_PAGE = int(t)
    if t > TOTAL_PAGE:
        TOTAL_PAGE += 1
    return TOTAL_PAGE

def getcollecttotal():
    sql = "select count(*) from hentai_movies where collect=1"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchone()
    TOTAL = data[0]
    t = TOTAL / 25
    TOTAL_PAGE = int(t)
    if t>TOTAL_PAGE:
        TOTAL_PAGE += 1
    return TOTAL_PAGE

def getcollectdata():
    n = Global.collect_page
    n = 5 * (n - 1)
    sql = "select title,feng,video,id,collect,yulan,views,colpic,collecttime from hentai_movies " \
          "where collect=1  order by collecttime desc limit 5 offset %s" % n
    cur = CONN.cursor()
    data = cur.execute(sql).fetchall()
    return data

def change_collect(id,num,path):
    cur = CONN.cursor()
    if num==1:
        sql = f"update hentai_movies set collect={num},colpic='{path}',collecttime=datetime('now','localtime') where id={id}"
    else:
        sql = f"update hentai_movies set collect={num} where id={id}"
    cur.execute(sql)
    CONN.commit()
    return

def search_data(text,n=1):
    n = 25*(n-1)
    sql_total = "select count(*) from hentai_movies where title like '%%%s%%'"%text
    sql = "select title,feng,video,id,collect,yulan,company from hentai_movies where title like '%%%s%%' limit 25 offset %s" % (text,n)
    cur = CONN.cursor()
    data = cur.execute(sql).fetchall()
    total = cur.execute(sql_total).fetchone()[0]
    total = int(total / 25) + 1
    return data,total

def recordhistory(id):
    sql = f"insert into history(hid,time) values ({id},datetime('now','localtime'))"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()
    sql = "select count(*) as total from history"
    cur.execute(sql)
    data = cur.fetchone()
    if data['total']>100:
        sql = "delete from history where id in (select id from history limit 10)"
        cur.execute(sql)
        CONN.commit()
    sql = f"update hentai_movies set views=views+1 where id={id}"
    cur.execute(sql)
    CONN.commit()

def gethistorydata():
    sql = f"select title,feng,company,video as videopath,viewtime,b.time,a.id as vid from hentai_movies as a,(select * from history order by id desc limit 30 ) as b where a.id=b.hid"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchall()
    return data

def getalltitle():
    sql = "select title from hentai_movies"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchall()
    l = []
    for i in data:
        l.append(i[0])
    return l

def getalltags():
    sql = "select * from tags"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchall()
    return data

def gettagdata(tagid):
    n = Global.tag_page
    n = 25 * (n - 1)
    cur = CONN.cursor()
    sql = "select ids from tags where id=%s"%tagid
    data = cur.execute(sql).fetchall()
    if not data[0]['ids']:
        return []
    ids = data[0]['ids']
    sql = "select title,feng,video,id,collect,yulan,company from hentai_movies  where id in (%s) limit 25 offset %s" % (ids,n)
    data = cur.execute(sql).fetchall()
    return data

def gettagname(id):
    sql = f"select name,ids,num from tags where id={id}"
    cur = CONN.cursor()
    data = cur.execute(sql).fetchone()
    return data

def checkpwd(pwd):
    h1 = hashlib.md5()
    h1.update(pwd.encode(encoding='utf-8'))
    sql = "select pwd from config"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()['pwd']
    if h1.hexdigest() == data:
        return True
    return False
def getswitch():
    sql = "select switch from config"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()['switch']
    return data

def changepwd(pwd):
    h1 = hashlib.md5()
    h1.update(pwd.encode(encoding='utf-8'))
    sql = f"update config set pwd='{h1.hexdigest()}'"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()


def getvol():
    sql = "select vol,volvalue from config"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()
    return data

def changemute(s):
    sql = f"update config set vol={s}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def changevalue(s):
    sql = f"update config set volvalue={s}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def checkauth():
    sql = "select auth from config"
    cur = CONN.cursor()
    cur.execute(sql)
    auth = cur.fetchone()[0]
    sha1 = hashlib.sha1()
    sha1.update(getcode().encode() + b"-hentaiboxforever")
    code = sha1.hexdigest()
    if auth == code:
        return True
    return False

def getcode():
    r = os.popen("wmic csproduct get uuid")
    txt = r.readlines()
    for i in txt:
        if '-' in i:
            return i.replace("\n","").replace(" ","").replace("-","")

def updatehistory(id,num):
    sql = f"update history set viewtime={num} where hid={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def addtags(title,desc,img):
    if not os.path.exists("./img"):
        os.mkdir("./img")
    src = img.lstrip("file:///")
    n = int(time.time())
    shutil.copy(src, f"./img/tag{n}.jpg")
    sql = f"insert into tags(name,ids,num,desc,bg) values('{title}','',0,'{desc}','img/tag{n}.jpg')"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def ctags(id,title,desc,img):   # 更新标签
    if img.startswith("file"):
        src = img.lstrip("file:///")
        shutil.copy(src,f"./img/tag{id}.jpg")
        sql = f"update tags set name='{title}',desc='{desc}',bg='img/tag{id}.jpg' where id={id}"
    else:
        sql = f"update tags set name='{title}',desc='{desc}' where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def deltag(id):
    cur = CONN.cursor()
    sql = "select bg from tags where id=%s"%id
    cur.execute(sql)
    bg = cur.fetchone()["bg"]
    try:
        os.remove(bg)
    except:
        pass
    sql = "delete from tags where id=%s"%id
    cur.execute(sql)
    CONN.commit()


def updatecolleect(id,picpath):
    sql = ""

def detail(id):
    sql = f"select * from hentai_movies where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()
    path = getdatadir()+"/"+data['video'].rstrip(".mp4") + ".srt"
    zimu = {}
    zimul = []
    if os.path.exists(path):
        try:
            srt = pysrt.open(path)
        except:
            srt = pysrt.open(path, encoding='gbk')
        try:
            for i in srt:
                zimu[f"{i.start.ordinal}-{i.end.ordinal}"] = i.text
                zimul.append(i.start.ordinal)
                zimul.append(i.end.ordinal)
        except Exception as e:
            pass
    data["zimu"] = zimu
    data["zimul"] = zimul
    return data

def transfer(id):
    sql = "select ids from tags where id=%s"%id
    cur = CONN.cursor()
    cur.execute(sql)
    datas = {}
    data = cur.fetchone()
    ids = data['ids']
    if ids:
        sql = f"select id as mid,title from hentai_movies where id in ({ids})"
        cur.execute(sql)
        data = cur.fetchall()
    else:
        data = []
    datas['check'] = data
    if ids:
       sql = f"select id as mid,title from hentai_movies where id not in ({ids})"
    else:
       sql = f"select id as mid,title from hentai_movies"
    cur.execute(sql)
    data = cur.fetchall()
    datas['all'] = data
    return datas

def changetags(s,id,nums):
    sql = f"update tags set ids='{s}',num={nums} where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def insertvideo(title,feng,video,ico):
    sql = f"insert into hentai_movies(title,feng,video,yulan,company) values('{title}','{feng}','{video}','','{ico}')"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def updatepreview(workpath,name,id):
    sql = f"update hentai_movies set yulan='{workpath[0] + '/' + name}' where id = {id}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def updatedata(id,title,newpath):
    sql = f"update hentai_movies set title='{title}',feng='{newpath}' where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def updateswitch(c):
    sql = f"update config set switch={c}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def cpimg(path,id):
    sql = f"select video,feng from hentai_movies where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()
    p = data['video']
    feng = data['feng']
    if feng in path and feng:
        return feng
    basepath = "/".join(p.split('/')[:-1])
    newpath = basepath+f"/img_{id}.jpg"
    datadirs = getdatadir()+"/"
    try:
        if path.startswith("http"):
            req = httpx.get(path, proxies=gethttpxporoxy(), verify=False)
            with open(datadirs+newpath,'wb') as f:
                f.write(req.content)
        else:
            shutil.copyfile(path,datadirs+newpath)
    except:
        newpath = ""
    return newpath

def getlang():
    sql = "select lang from config"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()
    return data['lang']

def updatelang(n):
    sql = f"update config set lang={n}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def updatedatadir(dir):
    dir = dir.replace("\\","/")
    sql = f"update config set datadir='{dir}'"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def getdatadir():
    sql = "select datadir from config"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()
    return data['datadir']


def delvideo(id):
    sql = f"select id,feng from hentai_movies where id={id}"
    cur = CONN.cursor()
    cur.execute(sql)
    data = cur.fetchone()['feng']
    path = data.split("/")[0]
    basedir = getdatadir()+"/"+path
    try:
        shutil.rmtree(basedir)
    except:
        pass
    sql = f"delete from hentai_movies where id={id}"
    cur.execute(sql)
    CONN.commit()
    sql = f"delete from history where hid={id}"
    cur.execute(sql)
    CONN.commit()


def datadir():
    sql = "select datadir from config"
    cur = CONN.cursor()
    cur.execute(sql)
    datadir = cur.fetchone()
    if not datadir["datadir"]:
        pwd = os.getcwd()
        pwd = pwd.replace("\\","/")+"/datadir"
        sql = f"update config set datadir='{pwd}'"
        cur.execute(sql)
        CONN.commit()

def setheadless(num):
    sql = f"update config set headless={num}"
    cur = CONN.cursor()
    cur.execute(sql)
    CONN.commit()

def getheadless():
    sql = "select headless from config"
    cur = CONN.cursor()
    cur.execute(sql)
    h = cur.fetchone()['headless']
    if h==1:
        Global.headless = True
    else:
        Global.headless = False
    return h



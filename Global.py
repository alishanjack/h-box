# coding=utf-8
class Global:
    now_page = 1
    collect_page = 0
    search_page = 1
    tag_page = 1
    search = None
    curtagid = 0
    process =  {"total":0,"now":0,"end":True}
    download = {"sync":False}
    genimg = {}
    hentai = {}
    ruleset = {}
    headless = True
    sock = None
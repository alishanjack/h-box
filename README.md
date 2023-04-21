[DOWNLOAD](https://github.com/alishanjack/h-box/releases) or [DOWNLOAD THIS](https://gofile.io/d/PVlrGg)
# V2.0.3 release
- 优化91，pornhub,xvideos,xnxx 解析速度。
- BUG fix -_-
# V2.0.2 release
- BUG fix
# V2.0.1 release
新功能:
- 支持20 站点解析
- 新增同步chrome数据
- BUG fix

# V2.0.0 release
新功能:
- 支持15+ 站点解析
- 新的使用规则解析站点方式
- BUG fix
# what is h-box?
h-box is a desktop application that currently only has a Windows side.<br>
h-box determined to be a private video collection software<br>




# h-box是什么？
h-box 是一个桌面应用程序，目前只有windows端。<br>
h-box 立志于做私密视频收藏软件<br>

# H-BOX 使用手册 | [English](https://github.com/alishanjack/h-box/blob/main/user.md)
## H-BOX的工作方式
- h-box主要从目标网站获取三种东西，视频标题，视频封面，视频的资源链接。
- h-box 获取视频链接并非像普通的爬虫一样解析html来获取资源链接，而是
  通过监控网页发出的所有链接并通过规则中的正则匹配来获取资源。所以你完全
  可以自己写规则来下载h-box中未支持的网站。标题与封面是通过解析html获取
  但也是基于编写的规则，这很简单。目前支持的视频链接格式为m3u8与mp4。
- h-box 使用selenium 工作方式为无头模式与非无头模式（界面可以选择）,
  一些网站在无头模式下根本无法加载出资源，只能选择非无头模式，手动触发网页发出视频链接。
  这就是主要原理。
## H-BOX的运行需要
- chrome,chrome driver,ffmpeg。（chrome driver,ffmpeg）安装包中已经附带了这些。
  如果chrome drive与你的chrome版本不符，请下载对应的驱动在安装目录替换。
## H-BOX的介绍
- 首页<br>
   下载过的视频会在这里显示<br>
    翻页功能，跳转功能，搜素功能，编辑功能，不多赘述。
  ![](https://github.com/alishanjack/h-box/blob/main/img/home.jpg)
- 自带播放器<br>
  点击首页的卡片弹出播放页面<br>
  点击图片按钮会在后台生成视频预览图<br>
  点击心形按钮收藏视频<br>
  快进，音量调节
  ![](https://github.com/alishanjack/h-box/blob/main/img/121441.jpg)
- 收藏<br>
  首页的收藏会在这里显示,点击同样可以播放<br>
  ![](https://github.com/alishanjack/h-box/blob/main/img/collect.jpg)
- 标签<br>
  给视频分类用<br>
  新增按钮，编辑按钮，删除按钮，标题描述，背景图。
  ![](https://github.com/alishanjack/h-box/blob/main/img/tag.jpg)
- 浏览历史<br>
  在首页播放过的视频记录在这里，点击同样可以播放，直接
  跳转到上次播放点
  ![](https://github.com/alishanjack/h-box/blob/main/img/history.jpg)
- 本地导入<br>
  将本地视频导入到软件，这个功能待完善。
  ![](https://github.com/alishanjack/h-box/blob/main/img/local.jpg)
- 网络下载<br>
  **下载的前提在于你的网络能访问到这个网站，软件不需要配置代理。**<br>
  从网站下载的界面,想要下载视频只需要将播放页的链接复制到
  输入框再点击回车即可。具体操作看下方gif。
  ![](https://github.com/alishanjack/h-box/blob/main/img/net.jpg)
  **！！！注意！！！**<br>
  记得点击最右边的同步按钮，会将你的chrome的用户数据同步到软件的目录下，
  这样selenium在请求网站的时候很容易躲过一些验证码的侦察，像cloudflare验证,
  twitter则需要登录cooikes 验证才能下载视频,你在chrome登录后再同步到selenium
  去请求twitter便是登录状态，很容易便能抓到视频链接
- 设置<br>
  语言切换目前支持中英文<br>
  数据目录控制下载的视频存在哪里，必须是绝对路径。建议不要改这个，改了比较麻烦。
  ![](https://github.com/alishanjack/h-box/blob/main/img/set.jpg)
- 规则解析<br>
  解析规则通过域名来判断对应的规则，一个网站有多个域名则用','隔开。<br>
  type 控制下载的是m3u8 链接还是mp4链接<br>
  video 资源路径的正则匹配，多种资源则用',' 隔开
  pic.re 封面的xpath 路径 pic.value 元素的值
  ico 对应的图标
  ...<br>
  开发更多的规则类型，以及应用 请加入讨论组一起讨论学习😁 [t.me/h-box](https://t.me/hboxapp)
  ![](https://github.com/alishanjack/h-box/blob/main/img/rule.jpg)
- 最后<br>
  志同道合欢迎一起交流。
- 视频<br>
  ![](https://github.com/alishanjack/h-box/blob/main/img/H-box.gif)  
  
  


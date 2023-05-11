import QtQuick 2.15
import QtMultimedia
import QtQuick.Controls

Window {
    id: root
    width: 800
    height: 560
    property string videopath: ""
    property int vid: 0
    property int collect: 0
    property int viewpro: 0
    property string videoname
    property var d
    property string now
    property int main: 1
    PreView{
      id:preview
    }
   Component.onCompleted: {
      let voldata = cfg.loadvol()
      if (voldata.vol===1){
          voloutput.setMuted(false)
          volb.icon.source="../icon/vol.svg"
      }else{
          voloutput.setMuted(true)
          volb.icon.source="../icon/mute.svg"
      }
      voloutput.setVolume(voldata.volvalue)
      vlobar.value=100*voldata.volvalue
   }
    onVidChanged: {
        playb.icon.source = "../icon/play.svg"
    }
    onVisibleChanged: {
        if(visible){
        d = bridge.getdetail(vid)
        playb.icon.source = "../icon/play.svg"
        title = d.title
        preview.path = d.yulan
        heart.icon.source=d.collect===1?"../icon/heart-fill.svg":"../icon/heart.svg"
        if (bridge.getimgrun(vid)===0){
            genrun.stop()
            previewb.icon.source = "../icon/card-image.svg"
            previewb.rotation=0
            previewb.enabled=true
        }else{
           genrun.start()
           previewb.enabled=false
           previewb.icon.source = "../icon/load.svg"
        }
      }
    }
    function searchInsert(nums, target) {
        let arr=nums
        arr.splice(0,0,target)
        let index = nums.indexOf(target)>0?nums.indexOf(target):arr.sort((a,b)=>a-b).indexOf(target)
        arr.splice(index,1)
        return index
    }
    function setHis(times = 0){
        if(typeof times ==='number'){
            if(times <= 0){
                return '00:00:00';
            }else{
                let hh = parseInt(times / 3600); //小时
                let shh = times - hh * 3600;
                let ii = parseInt(shh/ 60);
                let ss = parseInt(shh - ii * 60);
                return (hh < 10 ? '0'+hh : hh) + ':' + (ii < 10 ? '0'+ii : ii) +':'+(ss < 10 ? '0'+ss : ss);
            }
        }else{
            return '00:00:00';
        }
    }
    Column{
        anchors.fill: parent
        Rectangle{
            id: videoshow
            width: root.width
            height: root.height-90
            color: "black"
            VideoOutput {
                id: videoput
                anchors.fill: parent
            }
            MediaPlayer{
                id: player
                videoOutput: videoput
                audioOutput: voloutput
                source: "file:///"+datadir+"/"+videopath
                onMediaStatusChanged:{
                    if(status===MediaPlayer.EndOfMedia){
                           playb.icon.source = "../icon/play.svg"
                    }
                }
                onPositionChanged:function(n){
                    probar.value = n
                    protext.text = setHis(n/1000)     
                    if (d.zimul.length>0){
                        try{
                        let f = searchInsert(d.zimul,n)
                        if (f<d.zimul.length){
                            let qujian = d.zimul[f-1]+"-"+d.zimul[f]
                            if (qujian != now){
                                now = qujian
                                let zumi = d.zimu[now]
                                if (typeof(zumi) == "undefined"){
                                    subtitles.text=""
                                }else{
                                   subtitles.text=zumi
                                }
                            }
                        }
                      }catch(err){}
                    }
                }
            }

            AudioOutput{
                id:voloutput
            }
            Rectangle{   // 字幕
              anchors.horizontalCenter: videoshow.horizontalCenter
              y:videoshow.height-height-10
              radius: 15
              width:subtitles.width?subtitles.width+30:0
              Text{
                  id:subtitles
                  font.pixelSize: 16
                  font.family: "Arial"
                  anchors.centerIn: parent
              }
              height: 40
              color:Qt.rgba(255,255,255,0.7)
            }
        }
        Rectangle{
          id:con
          width: root.width
          height: 90
          Column{
             Slider {
                  id:probar
                  width: root.width-20
                  x:10
                  from:0
                  to:player.duration
                  handle: Rectangle {
                              id:h
                              x: probar.visualPosition * (probar.availableWidth - implicitWidth)
                              y: probar.availableHeight / 2 - implicitHeight / 2
                              implicitWidth: 18
                              implicitHeight: 18
                              radius: 9
                              color: probar.pressed ? "green" : "white"
                              border.color: "black"
                          }
                  background: Rectangle {
                              id: rect1
                              y:h.implicitHeight/4
                              width: probar.availableWidth
                              height: 8
                              radius: 5
                              color:"gray"
                              Rectangle {
                                  id: rect2
                                  width: probar.visualPosition * rect1.width
                                  height: rect1.height
                                  color: "orange"
                                  radius: 5
                              }
                          }
                  onMoved:{
                      player.setPosition(value)
                  }
              }
            Rectangle{
                id: controls
                width: root.width
                height: 100-probar.height
                Label{
                    x:10
                    y:10
                   id:protext
                   text:"00:00:00"
                }
                Label{
                    x:60
                    y:10
                   id:dur
                   verticalAlignment: Text.AlignVCenter
                   text:"/ "+setHis(player.duration/1000)
                }
                Rectangle{
                   x:130
                   width: playb.x-130
                   height: controls.height
                   clip:true
                }
                IconButton{
                    anchors.horizontalCenter: playb.horizontalCenter
                    anchors.horizontalCenterOffset: -60
                    anchors.verticalCenter: playb.verticalCenter
                   icon{
                       source:"../icon/bg-backward.svg"
                   }
                   onClicked: {player.position-=5000}
                }
                  IconButton{
                     id:playb
                     anchors.centerIn: controls
                     icon{
                         source:"../icon/play.svg"
                         width: 40
                         height:40
                     }
                     onClicked: {
                         if (player.playbackState !== MediaPlayer.PlayingState){
                             if(viewpro!=0 && main===0){
                                 player.setPosition(viewpro)
                             }
                             player.play()
                             playb.icon.source = "../icon/stop.svg"
                         }else{
                             player.pause()
                             playb.icon.source = "../icon/play.svg"
                         }
                     }
                  }
                  IconButton{
                      anchors.horizontalCenter: playb.horizontalCenter
                      anchors.horizontalCenterOffset: 60
                      anchors.verticalCenter: playb.verticalCenter
                     icon{
                         source:"../icon/bg-forward.svg"

                     }
                     onClicked: {player.position+=5000}
                  }
                  IconButton{
                     id:previewb
                     anchors.horizontalCenter: playb.horizontalCenter
                     anchors.horizontalCenterOffset: 160
                     anchors.verticalCenter: playb.verticalCenter
                     icon{
                         source:"../icon/card-image.svg"
                     }
                     RotationAnimator {
                             id:genrun
                             target: previewb
                             from: 0
                             to: 360
                             duration: 1000
                             loops: Animation.Infinite
                         }
                     onClicked: {
                         if(preview.path.length===0){
                             icon.source = "../icon/load.svg"
                             genrun.start()
                             bridge.genimg(videopath,vid)
                             enabled=false
                         }else{
                              preview.show()
                         }
                     }

                  }
                  IconButton{
                      id:heart
                      anchors.horizontalCenter: playb.horizontalCenter
                      anchors.horizontalCenterOffset: 200
                      anchors.verticalCenter: playb.verticalCenter
                      icon{
                          source:collect===1?"../icon/heart-fill.svg":"../icon/heart.svg"
                      }
                      onClicked: {
                         if(collect===0){
                             bridge.collect(vid,1,player.position,datadir+"/"+videopath)
                             collect = 1
                             heart.icon.source="../icon/heart-fill.svg"

                         }else{
                            bridge.collect(vid,0,0,"")
                             collect = 0
                             heart.icon.source="../icon/heart.svg"
                         }
                      }
                  }               
                IconButton{
                    id:volb
                    anchors.horizontalCenter: heart.horizontalCenter
                    anchors.horizontalCenterOffset: 30
                    anchors.verticalCenter: heart.verticalCenter
                    icon{
                        source:"../icon/vol.svg"
                    }
                    onClicked: {
                       if(voloutput.muted===true){
                           voloutput.setMuted(false)
                           volb.icon.source="../icon/vol.svg"
                           cfg.mute(1)

                       }else{
                          voloutput.setMuted(true)
                           volb.icon.source="../icon/mute.svg"
                           cfg.mute(0)
                       }
                    }
                }
                Slider {
                     id:vlobar
                     anchors.horizontalCenter: volb.horizontalCenter
                     anchors.horizontalCenterOffset: 70
                     anchors.verticalCenter: volb.verticalCenter
                     width: 100
                     from:0
                     value:100
                     to:100
                     onMoved:{
                         voloutput.setVolume((value/100).toFixed(2))
                         cfg.volvalue((value/100).toFixed(2))
                     }
                     handle: Rectangle {
                                  id:hh
                                 x: vlobar.visualPosition * (vlobar.availableWidth - implicitWidth)
                                 y: vlobar.availableHeight / 2 - implicitHeight / 2
                                 implicitWidth: 18
                                 implicitHeight: 18
                                 radius: 9
                                 color: vlobar.pressed ? "green" : "white"
                                 border.color: "black"
                             }
                     background: Rectangle {
                                 id: rect11
                                 y: hh.implicitHeight/4
                                 width: vlobar.availableWidth
                                 height: 8
                                 radius: 5
                                 color:"gray"
                                 Rectangle {
                                     id: rect22
                                     width: vlobar.visualPosition * rect11.width
                                     height: rect1.height
                                     color: "orange"
                                     radius: 5
                                 }
                             }
                 }
            }
          }
      }
    }

    onClosing: {
       bridge.uphistory(vid,player.position)
       player.stop()
    }
    Connections {
          target: bridge
          function onSig(res){
              genrun.stop()
              previewb.icon.source = "../icon/card-image.svg"
              previewb.rotation=0
              previewb.enabled=true
              preview.path = res

          }
      }

}

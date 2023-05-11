import QtQuick 2.15
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Rectangle {
    id: love
    ListModel {
       id: data
    }
    function pop(index){
       data.remove(index)
    }
    Component.onCompleted: {
        data.clear()
        var listdata = bridge.love(0)
        if (listdata.length===0){
            nolove.visible=true
        }else{
            data.append(bridge.love(0))
        }

    }

    Text{
       id:nolove
       anchors.centerIn: love
       text:config.collect.tip
       visible: false
    }
    ListView{
        id:list
       anchors.fill: parent
       model: data
       spacing: 10
       delegate: rollcard
       onMovementEnded:{
           if (list.contentY===data.count*200-list.height+(data.count-1)*10){
               data.append(bridge.love(1))
           }
       }
       Component {
          id: rollcard
          Rectangle{
              id: card
              width: love.width
              height: 200
//              color:"gray"            
              clip: true
              MouseArea{
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked:{
                      bridge.history(id)
                      videoviews.videopath = video
                      videoviews.vid = id
                      videoviews.collect=1
                      videoviews.show()
                  }
              }
              Image{
                 id:bg
                 height:300
                 width: 520
                 source:"../img/"+colpic
                 asynchronous: true
                 cache:false
                 x:card.width-bg.width
                 LinearGradient {
                             id: mask
                             anchors.fill: bg
                             start: Qt.point(300, 0)
                             end: Qt.point(0, 0)
                             gradient: Gradient {
                                 GradientStop { position: 0; color: "transparent"}
                                 GradientStop { position: 0.9; color: "white" }
                             }
                         }
              }
              Row{
                  anchors.verticalCenter: card.verticalCenter
                  spacing:20
                  Rectangle{
                      width: 60
                      height: 100
                      color:"transparent"
                  }

                 Rectangle{
                     id:aaa
                     width: 128
                     height: 160
                     color:"transparent"
                 Image{
                    id:images
                    width: 128
                    height: 170
                    source: "file:///"+datadir+"/"+feng
//                    visible: false
                    layer.enabled: true
                    layer.effect: OpacityMask {
                       maskSource: Rectangle {
                           width: 128
                           height:170
                           radius: 10
                       }
                   }
                 }
//                 Rectangle{
//                         id: rmask
//                         anchors.fill: aaa
//                         radius: 10
//                         visible: false
//                         }
//                 OpacityMask {
//                     anchors.fill: images
//                     source: images
//                     maskSource: rmask
//                     visible: true
//                   }
                 }

                 Rectangle{
                     width: 160
                     height: 160
                     color:"transparent"
                     Column{
                        spacing: 20

                        Text{
                           text:config.collect.title+title
                        }
                        Text{
                           text:config.collect.addtime+collecttime
                        }
                        Text{
                           text:config.collect.views+views
                        }
                        IconButton{
                           icon{
                              source:"../icon/unlove.svg"
                           }
                           Popup {
                               id:popup
                               x:60
                               width: 100
                               height: 30
                               closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                               Row{
                                   anchors.centerIn:  parent
                                   spacing:10
                                   SureButton{
                                      c:1
                                      onClicked: {
                                        bridge.collect(id,0,0,"")
                                         pop(index)
                                      }
                                   }
                                   SureButton{
                                      c:0
                                      onClicked: {popup.close()}
                                   }
                                }
                               }
                           onClicked: {
                               popup.open()
                           }

                        }
                     }
                 }
              }

          }
       }
    }


}

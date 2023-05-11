import QtQuick 2.15
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Rectangle {
    id: card
//    width: 160
//    height: 200
    property string imgpath: ""
    property string titletext: ""
    property string videopath: ""
    property string icopath: ""
    property int vid: 0
    property int col: 0
    property bool edit: false
    color:"transparent"
//    layer.effect: DropShadow {
//        transparentBorder: true
//    }
    onEditChanged: {
        if(edit){
          love.source="../icon/Edit.svg"
        }else{
          love.source="../icon/播放.svg"

        }
    }
    Column{
        Image{
            id: image
            width: card.width    // 160
            height: card.height-30  // 185
            source: imgpath
            asynchronous: true
//            fillMode: Image.PreserveAspectFit
            cache:false
            layer.enabled: true
            layer.effect: OpacityMask {
               maskSource: Rectangle {
                   width: card.width
                   height: card.height-30
                   radius: 10
               }
           }
            onStatusChanged: {
              if(image.status === Image.Error ){
                  source = "../icon/notfound.png"
               }
            }
            Image{
              id:love
              visible: false
              anchors.centerIn: parent
              source:"../icon/播放.svg"
              width:50
              height: 50
            }
            MouseArea{
                id:mousea
                anchors.fill: parent
                hoverEnabled: true
                onClicked:{
                     if (!edit){
                        bridge.history(vid)
                        videoviews.videopath = videopath
                        videoviews.vid = id
                        videoviews.main = 1
                        videoviews.collect = col
                        videoviews.show()
                     }else{
                         editcard.openme(vid,titletext,imgpath)
                     }
                }
                onEntered:{
                    love.visible = true
                }
                onExited:{
                    love.visible = false
                 }
            }
         }
        Rectangle{
            width: card.width
            height: 30
            clip: true
            radius: 4
//            color:"yellow"
            Row{
                spacing:5
                anchors.verticalCenter: parent.verticalCenter
                Image{
                   width: 18
                   height:18
                   source: "../img/"+icopath
                   layer.enabled: true
                   layer.effect: OpacityMask {
                      maskSource: Rectangle {
                          width: 18
                          height: 18
                          radius: 4
                      }
                  }
                }
            Text{
              text: titletext.trim().substring(0,30)
            }
          }
            ToolTip{
                background: Rectangle{
                    radius: 5
                   color:"white"
                }
                id: tt
                text: titletext
             }
            MouseArea{
               anchors.fill: parent
               hoverEnabled: true
               onEntered: tt.visible = true
               onExited:tt.visible = false
            }
        }

    }

}

//Rectangle {
//       id: mask
//       radius: 10
//       width: card.width    // 160
//       height: card.height-30  // 185
//       smooth: true
//       visible: false
//   }

//   OpacityMask {
//       anchors.fill: image
//       source: image
//       maskSource: mask
//   }

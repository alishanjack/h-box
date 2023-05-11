import QtQuick 2.0
import QtQuick.Controls
Button {
    width: 104
    height: 30
    flat : true
    property bool click: false
    property string nameb: ""
    property Component stackview: null
    property bool c:true
    property int page:0
    background: Rectangle {
            id:bg
            anchors.fill: parent
            color: "transparent"
            radius: 5
        }
    icon{
        width: 20
        height: 20
    }
    spacing:5
    font.pointSize: 10
    display: AbstractButton.TextBesideIcon
    MouseArea{
       cursorShape: Qt.PointingHandCursor
       anchors.fill: parent
       hoverEnabled: true
       onEntered: {
           if (!click){
               bg.color=cfg.c("left.b_hover")
           }
       }
       onExited: {
           if(!click){
              bg.color = "transparent"
           }
       }
       onPressed: {
           background.color= "#B1009B"
       }
       onClicked: {
          for (var i of [homebutton,collectbutton,tagsbutton,historybutton,settingbutton,downnet]){
              if (i.text===nameb){
                  if (i===downnet){
                      stack.pop()
                  }else{
                      if(stack.currentItem.objectName==="net"){
                          stack.push(stackview)
                      }else{
                          stack.replace(stackview)
                      }
                  }
                  bg.color= cfg.c("left.b_click")
                  click = true
              }else{
                  i.click = false
                  i.background.color= "transparent"
              }
          }
       }
    }
}

import QtQuick 2.15
import QtQuick.Window
import QtQuick.Controls 2.0
import "Mycomponent"
Window {
    id: root
    width: 1050
    height: 600
    visible: true
    title: qsTr("H-box")
    property var dict:({})
    property string datadir:cfg.getdatadir()
    property var config:({})
    Component.onCompleted: {
//        stack.push(netview)
//        stack.push(home)
        config = cfg.lang(9)
        let lock = cfg.getlock()
         if(lock===0){
            main.visible = true
            lockview.visible = false
         }else{
             main.visible = false
            lockview.visible = true
         }
    }
    VideoView{
      id: videoviews
    }
    MsgTip{
      id:msgtip
    }
    Row{
        id:main
        visible:false
        Rectangle {
            id: left
            height: root.height
            width: 130
            color: cfg.c("left.bg")
            Rectangle{
               id:version
               visible: false
               height: 30
               width:parent.width*2/3
               anchors.horizontalCenter: left.horizontalCenter
               y:root.height-70
               radius: 10
               color:"yellow"
               Text {
                   anchors.centerIn: parent
                   text: "new version"
               }
               MouseArea{
                   anchors.fill: parent
                   cursorShape: Qt.PointingHandCursor
                   onClicked: {
                       Qt.openUrlExternally("https://github.com/alishanjack/h-box")
                   }
               }
            }
            Label{
                anchors.horizontalCenter: left.horizontalCenter
                y:root.height-30
                text:cfg.c("config.version")
            }
            Column {
                anchors.horizontalCenter: left.horizontalCenter
                spacing: 10
                y:10
                MyButton {
                   id:homebutton
                   nameb:config.left.home
                   text: config.left.home
                   stackview: home
                   icon{
                       source: "./icon/home.svg"
                   }

                }
                MyButton {
                   id:collectbutton
                   text: config.left.collect
                   nameb:config.left.collect
                   stackview: collect
                   icon{
                     source: "./icon/love.svg"
                   }
                }
                MyButton {
                   id:tagsbutton
                   text: config.left.tags
                   nameb: config.left.tags
                   stackview: tags
                   icon{
                     source: "./icon/tag.svg"
                   }
                }
                MyButton {
                   id:historybutton
                   text: config.left.history
                   stackview: history
                   nameb:config.left.history
                   icon{
                     source: "./icon/history.svg"
                   }
                }
//                MyButton{
//                   id:daoru
//                   text:config.left.import
//                   nameb:config.left.import
//                   stackview: daoruview
//                   icon{
//                     source:"./icon/import.svg"
//                   }
//                }
                MyButton{
                   id:downnet
                   text:config.left.netdown
                   nameb:config.left.netdown
                   stackview: netview
                   icon{
                     source:"./icon/download.svg"
                   }
                }
                MyButton {
                    id:settingbutton
                   text: config.left.setting
                   nameb: config.left.setting
                   stackview: setting
                   icon{
                     source: "./icon/setting.svg"
                   }
                }
                Button{
                    width: 104
                    height: 30
                    spacing:5
                    font.pointSize: 10
                   text:"Join Us"
                   background: Rectangle {
                           anchors.fill: parent
                           color: "white"
                           radius: 5
                       }
                   icon{
                       width: 20
                       height: 20
                     source: "./icon/telegram.svg"
                   }
                   onClicked: {
                       Qt.openUrlExternally("https://t.me/hboxapp")
                   }
                }
               Button{
                   width: 104
                   height: 30
                   spacing:5
                   font.pointSize: 10
                  text:"Address"
                  background: Rectangle {
                          anchors.fill: parent
                          color: "white"
                          radius: 5
                      }
                  icon{
                      width: 20
                      height: 20
                    source: "./icon/github.svg"
                  }
                  onClicked: {
                      Qt.openUrlExternally("https://github.com/alishanjack/h-box")
                  }
               }
            }

        }
        Rectangle {
            id: right
            height: root.height
            width: root.width - 130
            StackView {
                 clip: true
                 id: stack
                 initialItem: netview
                 anchors.fill: parent
            }
        }
    }
    Component {
        id: home
        HomeView{}
    }
    Component {
        id: collect
        CollectView{}
    }
    Component {
        id: history
        HistoryView{}
    }
    Component {
        id: setting
        SettingView{}
    }
    Component {
        id: tags
        TagView{}
    }
//    Component {
//        id: daoruview
//        DownLoad{}
//    }
    Component {
        id: netview
        NetDown{objectName: "net"}
    }
    Rectangle {
        id:lockview
        anchors.fill: parent
        visible:false
        Column{
            anchors.centerIn: parent
        Text{
           id:err
           text:"passwd error"
           visible:false
        }
        TextField{
            id:pwd
           placeholderText: "password"

           onAccepted:{
               if(cfg.checkpwd(pwd.text)){
                   main.visible = true
                    lockview.visible = false
               }else{
                  err.visible=true
               }
           }
        }
      }
    }
    Connections{
        target: bgsig
        function onSig(ver){
           version.visible = true
        }
    }
}

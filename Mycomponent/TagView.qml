import QtQuick 2.15
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle{
    id:tagmain
    property bool hide: false
    property int tid: 0
    property int delte: 0
    property string editimg
    StackView {
         clip: true
         id: stack
         initialItem: main
         anchors.fill: parent
    }

Component{
   id:tagdesc
   TagdescView{
   }
}

Component{
    id:main

Rectangle{
    id:tag

    function pop(index){
        data.remove(index)
    }
    // 弹出层
    Popup{
      id:add
      anchors.centerIn: parent
      width: tagmain.width
      height: tagmain.height
      closePolicy: Popup.NoAutoClose
      background:Rectangle{opacity:0.5}
      FileDialog {
             id: fileDialog
             nameFilters: ["Image (*.jpg *.jpeg *.png)"]
             onAccepted: {
                 precon.visible = true
                 preimage.source=selectedFile
             }
         }
      Rectangle{
          width: 600
          height: 400
          anchors.centerIn: parent
      GridLayout {
        anchors.centerIn: parent
        columns: 2
        Label{text:config.tag.title}
        InputCom{
            id:title
        }
        Label{text:config.tag.desc}
        InputCom{
            id:descput
        }
        Label{text:config.tag.img}
        Button{
           text:"select"
           onClicked: {
               fileDialog.open()
           }
        }
        Rectangle{
            id: precon
            width: 200
            height: 100
            Layout.columnSpan: 2
            visible: false
        Image{
           id: preimage
           anchors.fill: parent
        }
        }
        SureButton{
            c:1
            onClicked: {
                if (tid===0){
               bridge.addtags(title.text,descput.text,preimage.source)
               add.close()
               data.clear()
               data.append(bridge.getalltags())
               }else{
                    bridge.changetags(tid,title.text,descput.text,preimage.source)
                    add.close()
                    data.clear()
                    data.append(bridge.getalltags())
              }

           }
        }
        SureButton{
          c:0
          onClicked: {
             add.close()
          }
        }
      }
    }
      }
    //
    Column{
        Rectangle{
            id: action
            width: tag.width
            height: 50
            color:"gray"
            Row{
                x:30
               spacing: 10
               layoutDirection: Qt.RightToLeft
               LayoutMirroring.enabled: true
               anchors.verticalCenter: action.verticalCenter
               IconButton{
                   icon{
                     source:"../icon/add.svg"
                   }
                   onClicked: {
                       title.text=""
                       descput.text=""
                       preimage.source= ""
                       precon.visible=false
                       tid = 0
                     add.open()
                   }
               }
               IconButton{
                   icon{
                     source:"../icon/Edit.svg"
                   }
                   onClicked: {
                        hide= !hide
                        delte = 0
                        editimg = "../icon/Edit.svg"
                   }
               }
               IconButton{
                   icon{
                     source:"../icon/delete.svg"
                   }
                   onClicked: {
                        hide= !hide
                        delte = 1
                       editimg = "../icon/delete.svg"
                   }
               }
            }
        }
   Rectangle{
       id: content
       width: tag.width
       height: tag.height-action.height
       ListModel{
          id:data
       }
      Component.onCompleted: {
         data.append(bridge.getalltags())
      }
   GridView{
       id: grid
       model: data
       anchors.fill: content
       delegate: cards
       anchors.margins: 20
       clip: true
       cellWidth: 400
       cellHeight: 200
       Component{
           id:cards
           Rectangle{
               id:bgimg
               width: grid.cellWidth-10
               height: grid.cellHeight-10
               radius:10
               clip:true
               MouseArea{
                 anchors.fill: parent
                 onClicked: {
                      stack.push(tagdesc,{tagid:id,tagtext:name})
                 }
               }
               Image{
                  id:img
                  anchors.fill: bgimg
                  cache:false
                  asynchronous: true
                  source: "../"+bg
//                  visible: false
                  LinearGradient {
                              id: mask
                              anchors.fill: img
                              start: Qt.point(450, 0)
                              end: Qt.point(0, 0)
                              gradient: Gradient {
                                  GradientStop { position: 0.1; color: "transparent"}
                                  GradientStop { position: 0.9; color: "gray" }
                              }
                          }
                  layer.enabled: true
                  layer.effect: OpacityMask {
                     maskSource: Rectangle {
                         width: img.width
                         height:img.height
                         radius: 10
                     }
                 }
               }
//               Rectangle{
//                       id: rmask
//                       anchors.fill: bgimg
//                       radius: 10
//                       visible: false
//                       }
//               OpacityMask {
//                   anchors.fill: img
//                   source: img
//                   maskSource: rmask
//                   visible: true
//                 }

               Rectangle{
                 id:edit
                 width:100
                 height: width
                 x:bgimg.width- width/2
                 y:-width/2
                 color:"gray"
                 radius:50
                 opacity:0.8
                  visible: hide
                  Popup {
                      id:popup
                      x:50
                      y:60
                      width: 100
                      height: 30
                      closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                      Row{
                          anchors.centerIn:  parent
                          spacing:10
                          SureButton{
                             c:1
                             onClicked: {
                                 bridge.deltags(id)
                                 pop(index)
                             }
                          }
                          SureButton{
                             c:0
                             onClicked: {popup.close()}
                          }
                       }
                      }

                  onVisibleChanged: {
                      anima.start()
                  }
                  PropertyAnimation{
                      id:anima
                      target: edit
                      properties: "width"
                      from:0
                      to:100
                      running: true
                 }
                 MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(delte===0){
                            title.text=name
                            descput.text=desc
                            preimage.source= "../"+bg
                            precon.visible=true
                            tid = id
                            add.open()
                      }else{
                            popup.open()

                        }
                    }
                 }
                 Image{    // edit  image
                    x:20
                    y:edit.width/2+10
                    width: 20
                    height: 20
                    source:editimg

                 }
               }



               Column{
                  x:20
                  y:20
                  spacing:5
                  Text{
                      id:nametext
                      font.pointSize: 17
                      font.family: "Arial"
                      text:name
                      color:"white"
                  }
                  Text{
                      width: 280
                      font.pointSize: 12
                      text:desc
                      color:"#f3c669"
                      wrapMode: Text.WrapAnywhere
                  }
              }
               Image {
                   id:videosvg
                   x:20
                   y:bgimg.height-50
                   width: 24
                   height:24
                   source: "../icon/video.svg"
               }
               Text{
                   anchors.horizontalCenter: videosvg.horizontalCenter
                   anchors.horizontalCenterOffset: 30
                   anchors.verticalCenter: videosvg.verticalCenter
                   color:"white"
                   font.pointSize: 15
                   text:num
               }
           }
       }
     }
    }
  }
}
}
}

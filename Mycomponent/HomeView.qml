import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
Rectangle {
    id: home
    property var tpg
    property int nowpage
    property bool ed :false
    property string seatext
    property int updateid
    function enablebutton(now){
       if(now===1){
          pre.enabled = false
       }else{
           if(pre.enabled===false){
               pre.enabled = true
           }
       }
       if(now===tpg || now===0){
         next.enabled = false
       }else{
           if(next.enabled===false){
               next.enabled = true
           }
       }
    }
    //
    Popup{
      id:editcard
      anchors.centerIn: parent
      width: home.width
      height: home.height
      closePolicy: Popup.NoAutoClose
      background:Rectangle{opacity: 0.5}
      function openme(vid,name,imgurl){
              updateid=vid
              img.source=imgurl
              title.text = name
              neturl.clear()
              open()
      }
      FileDialog {
             id: fileDialog
             nameFilters: ["Image (*.jpg *.jpeg *.png)"]
             onAccepted: {
                 img.source=selectedFile
             }
         }
      Rectangle{
          width: 600
          height: 400
          radius: 10
          anchors.centerIn: parent
          IconButton{
              x:540
              y:40
             icon.source: "../icon/delete.svg"
             onClicked: {
                bridge.delvideo(updateid)
                 editcard.close()
                 data.clear()
                 data.append(bridge.getdata(0))
             }
          }
      GridLayout {
        anchors.centerIn: parent
        columns: 2
        Label{text:config.home.title}
        InputCom{
            id:title
        }
        Label{text:config.home.img}
        Image{
           id:img
           sourceSize.width: 100
           sourceSize.height:150
           MouseArea{
               anchors.fill: parent
              onClicked: {
                  fileDialog.open()
              }
           }
        }
        Label{text:config.home.net}
        TextField{id:neturl}
        SureButton{
            c:1
            onClicked: {
                let imgpath = neturl.text.length>0?neturl.text:img.source
                bridge.update(updateid,title.text,imgpath)
                editcard.close()
           }
        }
        SureButton{
          c:0
          onClicked: {
             editcard.close()
          }
        }
      }
    }
      }
    //
    Column{
        Rectangle {
            id: daohang
            width: home.width
            height: 50
            color: "#FFB473"
            Row{
               spacing: 15
               anchors.centerIn: daohang
               Button{
                   id:pre
                   icon{
                      source:"../icon/previous.svg"
                   }
                   onClicked: {
                     if(seatext.length===0){
                       data.clear()
                       data.append(bridge.getdata(-1))
                       var now =bridge.getnowpage()
                       totalpage.text = now+"/"+tpg
                       enablebutton(now)
                      }else{
                           nowpage -= 1
                           var r = bridge.search(seatext,nowpage)
                           data.clear()
                           data.append(r[0])
                           tpg=r[1]
                           totalpage.text =nowpage+"/"+tpg
                           enablebutton(nowpage)
                       }
                   }
               }
               Label{
                   id:totalpage
                   height: parent.height
                   font.pixelSize: 16
                   verticalAlignment: Text.AlignVCenter
               }
               Button{
                   id:next
                   icon{
                      source:"../icon/next.svg"
                   }
                   onClicked: {
                       if (seatext.length===0){
                           data.clear()
                           data.append(bridge.getdata(1))
                           var now =bridge.getnowpage()
                           totalpage.text = now+"/"+tpg
                           enablebutton(now)
                       }else{
                           nowpage += 1
                           var r = bridge.search(seatext,nowpage)
                           data.clear()
                           data.append(r[0])
                           tpg=r[1]
                           totalpage.text =nowpage+"/"+tpg
                           enablebutton(nowpage)
                       }
                   }
               }
               Rectangle{
                   width: 50
                   height: 30
                   radius: 15
                   border.color:jump.activeFocus?"#3914B0":"grey"
                   Image{
                      width: 20
                      height:20
                      anchors.centerIn: parent
                      source: "../icon/skip.svg"
                      opacity: 0.4
                   }
                   TextInput {
                       id: jump
                       height: parent.height/2
                       width: parent.width/2
                       anchors.centerIn: parent
                       validator: IntValidator{ bottom: 1; top: tpg; }
                       onAccepted:{
                           data.clear()
                           data.append(bridge.jump(jump.text))
                           totalpage.text = bridge.getnowpage()+"/"+tpg
                           enablebutton(parseInt(jump.text))
                       }
                   }
               }
               Rectangle{
                   id:serachinput
                   width: 180
                   height: 30
                   radius: 10
                   border.color:sea.activeFocus?"#3914B0":"grey"
                   Image{
                      width: 20
                      height:20
                      anchors.centerIn: parent
                      source: "../icon/search.svg"
                      opacity: 0.4
                   }
                   TextInput {
                       id: sea
                       selectedTextColor: "blue"
                       height: parent.height/2
                       width: parent.width-20
                       anchors.centerIn: parent
                       clip:true
                       onAccepted:{
                           if(sea.text.length>0){
                               nowpage = 1
                               seatext = sea.text
                               var r = bridge.search(seatext,nowpage)
                               if (r[0].length===0){
                                   data.clear()
                                   totalpage.text ="1/1"
                                   tpg=1
                                   enablebutton(1)
                               }else{
                                   data.clear()
                                   data.append(r[0])
                                   tpg=r[1]
                                   totalpage.text ="1/"+tpg
                                   enablebutton(1)
                           }
                       }
                     }
                   }
               }
               IconButton{
                   icon{
                     source:"../icon/Edit.svg"
                 }
                   Rectangle{
                       radius: 5
                       color:"yellow"
                       id: tip
                       Text{
                           text:config.home.edit
                           anchors.centerIn: parent
                       }
                       x: 40
                       y: 00
                       height: 28
                       width: 108
                       visible:false
                   }
                  onClicked: {
                     ed=!ed
                      if(ed){
                        icon.color="yellow"
                          tip.visible=true
                      }else{
                         icon.color="black"
                          tip.visible=false
                      }
                  }
               }
            }
        }
        ScrollView {
            id: scroll
            width: home.width
            height: home.height-50
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true
            Image{
                x:home.width/2
                y:10
                width:home.width/2
                height:home.height-50
                source: "../icon/bg.jpg"
            }
            ListModel {
               id: data
            }
            Component.onCompleted:{
                data.append(bridge.getdata(0))
                tpg =bridge.gettotal()
                var now = bridge.getnowpage()
                totalpage.text=now+"/"+tpg
                enablebutton(now)
            }
            GridView {
                id: grid
                anchors.fill: parent
                anchors.centerIn: parent
                cellHeight: 255
                cellWidth: 170
                anchors.margins: 20
                model: data
               delegate: deleg
               Component {
                   id: deleg
                   Card{
                       edit:ed
                       vid: id
                       col:collect
                       videopath: video
                       titletext: title
                       icopath:company
                       width: grid.cellWidth-10
                       height: grid.cellHeight-10
                       imgpath:"file:///"+datadir+"/"+feng
                   }
               }
            }
        }
    }
}

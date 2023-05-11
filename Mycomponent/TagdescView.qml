import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Dialogs
Rectangle{
    id: tagdesc
   property int tagid: 0
   property string tagtext
   Column{
      Rectangle{
          id: top
          width: tagdesc.width
          height: 50
          color:"gray"
          Text{
             text:tagtext
             font.pointSize: 16
             anchors.centerIn: top
             font.family: "Arial"
          }
          Row{
              spacing:10
               x:30
              anchors.verticalCenter: top.verticalCenter
          IconButton{

            icon{
               source: "../icon/back.svg"
            }
            onClicked: {
              stack.pop()
          }
        }
          IconButton{
             icon{
                source:"../icon/tagadd.svg"
             }
             onClicked: {
               transfer.visible = true
             }
          }
        }
      }
      Rectangle{
          id: botom
          width: tagdesc.width
          height: tagdesc.height-50
          ListModel {
             id: data
          }
          function refresh(){
              data.clear()
              data.append(bridge.gettagdata(tagid))
          }
          Component.onCompleted:{
                 data.append(bridge.gettagdata(tagid))
                 transfer.tagid = tagid
          }
          GridView {
              id: grid
              anchors.fill: parent
              anchors.centerIn: parent
              cellHeight: 255
              cellWidth: 170
              anchors.margins: 20
              model: data
              clip: true
             delegate: deleg
             Component {
                 id: deleg
                 Card{
                     vid: id
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
   TransForm{
       id:transfer
       anchors.centerIn: tagdesc
       visible: false
   }
}

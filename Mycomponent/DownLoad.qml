import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle{
    FileDialog {
           id: fileDialog
           nameFilters: ["Image (*.mp4)"]
           onAccepted: {
               var path = selectedFile
               videourl.text = path
               let urltext = path.split("\n")[0]
               let l =urltext.split("/")
               let urlpath = l[l.length-1].slice(0,-4)
               titleedit.text = urlpath
               visible = false
               detail.visible = true
           }
       }
    GridLayout{
        id:detail
        anchors.centerIn: parent
        columns: 2
        visible:false
        Label{text:"文件标题"}
        TextField{id:titleedit}
        Label{
            id:prefeng
            text:"封面"
        }
        IconButton{
           icon{source:"../icon/qes.svg"}
        }
        Label{text:"视频路径"}
        Text{
            width:50
            id:videourl
            wrapMode: Text.Wrap
        }
        Button{
            text:"确认"
            onClicked: {
                bridge.localimport(titleedit.text,prefeng.text,videourl.text)
                drop.visible = true
                detail.visible = false
                msgtip.msg="导入成功"
                msgtip.open()
            }
        }
        Button{
            text:"取消"
            onClicked: {
                drop.visible = true
                detail.visible = false
            }
        }
    }

    DropArea{
       id:drop
       anchors.fill: parent
       Text{
          text: config.imp.tip
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenterOffset: -90
          anchors.verticalCenter: parent.verticalCenter
       }
       onDropped: (drop)=>{
             var path = drop.urls[0]
             videourl.text = path
             let urltext = drop.text.split("\n")[0]
             let l =urltext.split("/")
             let urlpath = l[l.length-1].slice(0,-4)
             titleedit.text = urlpath
             visible = false
             detail.visible = true
                  }
       Rectangle{
           width:90
           height:120
           border.color: "gray"
           border.width: 3
           radius:10
           anchors.centerIn: parent
           Image{
               id:preimg
              sourceSize.width: parent.width
              sourceSize.height: parent.height
              source: "../icon/addimg.svg"
           }
           MouseArea{
             anchors.fill: parent
             onClicked: {
                fileDialog.open()
             }
           }
       }
    }


}

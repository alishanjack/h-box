import QtQuick 2.15
import QtQuick.Controls
import Qt.labs.platform 1.1
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
Rectangle{
    id:task
    radius: 10
    height: 150
    border.color: "#747db4"
    border.width: 5
    color:"#a59f9f"
    width: parent.width*4/5
    property string url: ""
    property string tiptext:""
    property string titletext:""
    property string icotext:""
    property int nums: 1
    clip:true
    signal mysig()
    anchors.horizontalCenter: parent.horizontalCenter
    Rectangle{
        x: 10
        y: 15
        width: 120
        height: 120
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        Image {
            id:center
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: "../icon/image.svg"
        }
   }
        Column{
            id: column
            height: 120
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 150
            spacing:3
            Row {
                id: row
                width: 200
                height: 25
                spacing: 5
            Image {
                id: ico
                width: 25
                height: 25
                source: "../icon/网站.svg"
                layer.enabled: true
                layer.effect: OpacityMask {
                      maskSource: Rectangle {
                          width: 25
                          height: 25
                          radius: 5
                      }
                  }
            }
            Label {
                text: url
                color: "#7c225f"
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 14
            }
        }
            Label{
               id:title
               text:"标题获取中。。。"
               anchors.verticalCenter: parent.verticalCenter
               anchors.verticalCenterOffset: -20
               font.pointSize: 12
            }
      Row {
            id: row2
            width: 200
            height: 20
            anchors.top: parent.top
            spacing: 5
            anchors.topMargin: 60
            Image {
                id: image1
                width: 20
                height: 20
                source: "../icon/type.svg"
                fillMode: Image.PreserveAspectFit
            }
            Label {
                id: type
                text: "---"
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: image2
                width: 20
                height: 20
                source: "../icon/时间.svg"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: time
                text: "---"
                anchors.verticalCenter: parent.verticalCenter
            }
            BusyIndicator {
                id: busyIndicator
                anchors.verticalCenter: parent.verticalCenter
            }
        }

            Row {
            id: row1
            width: 200
            height: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            spacing:5
            ProgressBar {
                id:prob
                property color color: "#3498DB"
                anchors.top: parent.top
                anchors.topMargin: 0
                from: 0
                to: 100
                value:0
                indeterminate:true
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 20
                    color: "#EBEDEF"
                    radius: implicitHeight / 2
                }
                contentItem: Item {
                    implicitWidth: prob.background.implicitWidth
                    implicitHeight: prob.background.implicitHeight
                    Rectangle {
                        width: prob.visualPosition * parent.width
                        height: parent.height
                        color: prob.color
                        radius: parent.height / 2
                    }
                }
                Text{
                    id:loadtext
                    anchors.centerIn: parent
                    text:"---/---"
                    z:1
                }
            }
            Label{
                id:tip
                anchors.verticalCenter: parent.verticalCenter
            }
    }
   }
     IconButton {
        id:trash
        width: 30
        height: 30
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        icon.source: "../icon/delete.svg"
        visible: false
        onClicked:{
           mysig()
           task.destroy()
           if (col.children.length===1){
               showtip.visible = true
               taskwindow.visible = false
           }
        }
    }
     MessageDialog {
         id:error
     }
      function recvfromthread(show){
            tip.text = show.text
            if(typeof(show.title)!="undefined"){
                title.text = show.title
                busyIndicator.visible = false
            }
            if(typeof(show.ico)!="undefined"){
                ico.source=show.ico
            }
            if(typeof(show.img)!="undefined"){
                center.source="file:///"+show.img
            }
            if(typeof(show.type)!="undefined"){
                type.text=show.type
            }
            if(typeof(show.time)!="undefined"){
                time.text=show.time.toString().substring(0,4)+"s"
            }
            if(show.reset===1){
                trash.visible=true
            }
            if(typeof(show.error)!="undefined"){
                error.text = "chrome驱动与你当前chrome版本不匹配，请下载匹配版本chrome驱动\n"+show.error+
                        "\n下载地址 http://chromedriver.storage.googleapis.com/index.html"
                error.open()
            }
    }
    function downloaing(load){
          loadtext.text = `${load.now}/${load.total}`
          prob.value = load.now*100/load.total
          nums +=1
    }
}

import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle{
    id:netdown
    Label{
        y:10
        anchors.horizontalCenter: parent.horizontalCenter
        text:"github.com/alishanjack/h-box"
    }
    TextField{
       id:input
       y:30
       font.family: "Arial"
       font.pixelSize: 20
       font.weight: Font.Thin
       antialiasing: true
       placeholderText: config.netdown.urltext
       anchors.horizontalCenter: parent.horizontalCenter
       background: Rectangle {
           implicitWidth: root.width*2/3
           implicitHeight: 30
           radius: 15
//           color: input.hovered ? "orange" : "#F4F6F6"
           border.color: input.hovered ? "orange" : "black"
           border.width: 2
           opacity: right.enabled ? 1 : 0.7
           layer.enabled: input.hovered
           layer.effect: DropShadow {
               id: dropShadow
               transparentBorder: true
               color: "orange"
               samples: 10
           }
       }
       onAccepted: {
           showtip.visible = false
           taskwindow.visible=true
           if (col.children.length<3){
               let component = Qt.createComponent("TaskView.qml")
               let obj = component.createObject(col)
               obj.url=input.text
               bridge.starttask(obj,input.text)
           }else{
               msgtip.msg="最大任务数为3"
               msgtip.open()
           }


//           bridge.spider(input.text)
//           loading.visible=true
//           input.enabled = false
//           loadingimg.visible = true
//           showtip.visible = false
       }
    }
    Rectangle{
      y:80
      id: showtip
      height: parent.height-80
      width: parent.width
      Flow{
         id:flow
         anchors.fill: parent
         anchors.margins: 4
         spacing: 10
      }
    }
    IconButton{
        id:reset
        anchors.horizontalCenter: input.horizontalCenter
        anchors.horizontalCenterOffset: input.width/2+30
        anchors.verticalCenter: input.verticalCenter
        icon{
          source:"../icon/close.svg"
       }
        ToolTip{
            background: Rectangle{
                radius: 5
               color:"yellow"
            }
           text:config.netdown.clear
           visible: reset.hovered
        }
       onClicked: {
//           visible = false
           input.text = ""
//           input.enabled = true
//           loading.visible = false
//           center.source=""
//           ico.source=""
//           bridge.clear()
//           showtip.visible = true
       }
    }
    CheckBox {
        id:headless
        anchors.horizontalCenter: input.horizontalCenter
        anchors.horizontalCenterOffset: input.width/2+60
        anchors.verticalCenter: input.verticalCenter
        checked:true
        onToggled:{
            cfg.headless(checkState)
        }
        ToolTip{
            background: Rectangle{
                radius: 5
               color:"yellow"
            }
           text:config.netdown.headless
           visible: headless.hovered
        }
    }
    IconButton{
       id:sync
       icon.source: "../icon/同步.svg"
       anchors.horizontalCenter: input.horizontalCenter
       anchors.horizontalCenterOffset: input.width/2+85
       anchors.verticalCenter: input.verticalCenter
       RotationAnimator {
               id:syncrun
               target: sync
               from: 0
               to: 360
               duration: 1000
               loops: Animation.Infinite
      }
       onClicked: {
            bridge.syncchrome()
            syncrun.start()
            sync.enabled=false
            syncchrome.open()
       }
       ToolTip{
           background: Rectangle{
               radius: 5
              color:"yellow"
           }
          text:config.netdown.sync
          visible: sync.hovered
       }
    }

    Item{
         id:loading
         visible: false
         anchors.centerIn: parent
    MsgTip{
       id:syncchrome
       msg:"数据后台同步中"
    }

}

//多任务栏
Rectangle{
   id:taskwindow
   height: parent.height
   width: parent.width
   y:80
   visible:false
   Column{
       id:col
       anchors.fill: parent
       spacing:5
   }
}



    Component.onCompleted: {
        let c = cfg.getheadless()
        headless.checked = c
        let urls = cfg.getnet().split(",")
        for (var i of urls){
           let component = Qt.createComponent("Link.qml")
           let obj = component.createObject(flow)
           obj.url = i
        }
    }
    Connections {
          target: bridge
          function onSig1(show){
             tip.text = show.text
             input.text = show.url
              title.text = show.title
              ico.source=show.ico
             if(show.img.length>0){
                 center.source="file:///"+show.img
             }
             if(show.reset===1){
                 reset.visible=true
             }
          }
      }
    Connections{
        target: bridge
        function onSig2(load){
           if(load.load===1){
               loadingimg.visible = false
               prob.visible = true
           }else{
             loadtext.text = `${load.now}/${load.total}`
             prob.value = load.now*100/load.total
           }
        }
    }
    Connections{
        target: bridge
        function onSig3(ok){
           if(ok===1){
               syncrun.stop()
               sync.enabled=true
           }
        }
    }
}

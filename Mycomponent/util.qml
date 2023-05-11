import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts
Rectangle{
    function dictgetvalue(data,key){
       return data.hasOwnProperty(key)?data[key]:""
    }
    Timer{
       id:timer
       interval: 1000
       repeat: true
       onTriggered:{
          let d = bridge.getprocess()
          if(d.end){
             timer.stop()
             print("end---")
           }else{
               protext.text = `${d.now}/${d.total}MB`
               probar.value = (d.now/d.total)*100
           }
       }
    }
    GridLayout{
      anchors.centerIn: parent
      columns: 3
      Label{text:"标题"}
      TextField{
          Layout.columnSpan: 2
          id:nbt
          onTextChanged:{dict.title=nbt.text}
      }
      Label{text:"封面"}
      TextField{
          id:nf
          onTextChanged:{dict.feng=nf.text}
      }
      Image{
          sourceSize.width: 17
          sourceSize.height: 17
          source:"../icon/qes.svg"
      }
      Label{text:"视频路径"}
      TextField{
          id:nv
          onTextChanged:{dict.vp=nv.text}
      }
      Image{
          sourceSize.width: 17
          sourceSize.height: 17
          source:"../icon/qes.svg"}
      Label{text:"下载目录"}
      TextField{
          id:mu
          onTextChanged:{dict.path=mu.text}
      }
      Image{
          sourceSize.width: 17
          sourceSize.height: 17
          source:"../icon/qes.svg"}
      Label{text:"网络代理"}
      TextField{
          id:proiexs
          onTextChanged:{dict.proxy=proiexs.text}
      }
      Image{
          sourceSize.width: 17
          sourceSize.height: 17
          source:"../icon/qes.svg"}
      Button{
        text:"下载"
        onClicked: {
           bridge.spider(dict)
           timer.start()
        }
      }
      Button{
        text:"清除"
        onClicked: {
            nbt.text = ""
            nf.text = ""
            nv.text = ""
            mu.text = ""
            proiexs.text = ""
           dict = {}
        }
      }
      Row{
          Layout.columnSpan: 3
          ProgressBar {
              id:probar
              from:0
              to:100
          }
          Label{
              id:protext
          }
      }
      Component.onCompleted: {
          if (JSON.stringify(dict) != '{}') {
               nbt.text = dictgetvalue(dict,"title")
               nf.text = dictgetvalue(dict,"feng")
               nv.text = dictgetvalue(dict,"vp")
               mu.text = dictgetvalue(dict,"path")
               proiexs.text = dictgetvalue(dict,"proxy")
               timer.start()
          }
      }

    }

}

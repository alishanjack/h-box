import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts
Rectangle {
    color: "white"
    GridLayout{
      anchors.centerIn: parent
      columns: 3
      Label{text:config.setting.lang}
      ComboBox {
          Layout.columnSpan: 2
          id:combox
          model: ["English","中文"]
          currentIndex : 0
          onActivated:{
              if(index===0){
                  config = cfg.lang(0)
              }else if(index===1){
                  config = cfg.lang(1)
              }
              else if(index===2){
                  config = cfg.lang(2)
              }
              else if(index===3){
                  config = cfg.lang(3)
              }
              cfg.updatelang(index)
          }
      }
//      Label{text:config.setting.privacy}
//      Switch {
//          id:sw
//          Layout.columnSpan: 2
//         onToggled:{
//            if(checked){
//                cfg.updateswitch(1)
//            }else{
//                cfg.updateswitch(0)
//            }
//         }
//      }
      Label{text:config.setting.datadir}
      Label{id:datadirtext}
      TextField{
          visible: false
          id: datadir
      }
      IconButton{
         icon.source:"../icon/Edit.svg"
         onClicked: {
             if(datadir.visible === false){
                 datadir.visible = true
                 datadirtext.visible = false
                 icon.source = "../icon/sure.svg"
             }else{
                 datadir.visible = false
                 datadirtext.visible = true
                 icon.source = "../icon/Edit.svg"
                 cfg.updatedatadir(datadir.text)
                 datadirtext.text = datadir.text
             }
         }
      }
    }
    Component.onCompleted: {
//        let lock = cfg.getlock()
//        if(lock===1){
//            sw.checked=true
//        }else{
//            sw.checked=false
//        }
        let lang = cfg.getlang()
        combox.currentIndex = lang
        let dir = cfg.getdatadir()
        datadirtext.text=dir
    }
}

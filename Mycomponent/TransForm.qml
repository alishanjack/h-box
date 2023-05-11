import QtQuick 2.15
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Rectangle{
   id:roots
   width: 700
   height:500
   radius: 10
   property string transtitle
   property int tagid
   property var rightcheck : []
   property var leftcheck : []
   property var rightindex : []
   property var leftindex : []
   layer.enabled: true
   layer.effect: DropShadow {
       transparentBorder: true
   }
   onTagidChanged: {
       var dd = bridge.gettransfer(tagid)
       if(dd.check.length!==0){
          rightdata.append(dd.check)
       }
       if(dd.all.length!==0){
          leftdata.append(dd.all)
       }
   }
   function changetag(){

   }
     Rectangle{
         id:rightrel
         anchors.centerIn: roots
         anchors.horizontalCenterOffset: -(width/2+50)
         width: roots.width/3
         height: roots.height*4/5
         border.color:"gray"
         border.width: 2
         clip: true
         ListModel{
            id:leftdata
         }
         ListView{
             y:30
             anchors.fill: parent
             model:leftdata
             spacing: 10
             delegate: tagscoml
             Component{
               id:tagscoml
               Rectangle{
                 width: rightrel.width
                 height: 30
                 CheckBox{
                     id:checkb
                     x:25
                     anchors.verticalCenter: parent.verticalCenter
                     onToggled:{
                         if(checkState===Qt.Checked){
                             leftcheck.push({"mid":mid,"title":title})
                             leftindex.push(index)
                         }else{
                            leftcheck.pop({"mid":mid,"title":title})
                             leftindex.pop(index)
                         }
                     }
                 }
                 Text{
                     x:50
                     anchors.verticalCenter: checkb.verticalCenter
                    text:title
                 }
               }
             }
         }
     }
     Rectangle{
         id:rightrec
         anchors.centerIn: roots
         anchors.horizontalCenterOffset: width/2+50
         width: roots.width/3
         height: roots.height*4/5
         border.color:"gray"
         border.width: 3
         clip: true
         ListModel{
            id:rightdata
         }
         ListView{
             y:30
             anchors.fill: parent
             model:rightdata
             spacing: 10
             delegate: tagscom
             Component{
               id:tagscom
               Rectangle{
                 width: rightrec.width
                 height: 30
                 CheckBox{
                     id:checkb
                     x:25
                     anchors.verticalCenter: parent.verticalCenter
                     onToggled:{
                         if(checkState===Qt.Checked){
                             rightcheck.push({"mid":mid,"title":title})
                             rightindex.push(index)
                         }else{
                           rightcheck.pop({"mid":mid,"title":title})
                             rightindex.pop(index)
                         }
                     }
                 }
                 Text{
                     x:50
                     anchors.verticalCenter: checkb.verticalCenter
                    text:title
                 }
               }
             }
         }
     }
     Button{
        anchors.centerIn: roots
        anchors.verticalCenterOffset: 20
        icon{
           source:"../icon/rarrow.svg"
        }
        onClicked: {
            rightdata.append(leftcheck)
            for(var i of leftindex){
                leftdata.remove(i)
            }
            leftindex = []
            leftcheck = []
        }
     }
     Button{
        anchors.centerIn: roots
        anchors.verticalCenterOffset: -20
        icon{
           source:"../icon/larrow.svg"
        }
        onClicked: {
            leftdata.append(rightcheck)
            for(var i of rightindex){
                rightdata.remove(i)
            }
            rightindex =[]
            rightcheck = []
        }
     }
     Button{
         anchors.centerIn: roots
         anchors.verticalCenterOffset: 140
         text:"确认"
         onClicked: {
             let l = []
               print(rightdata)
               for (let i=0;i<rightdata.count;i++){
                   l.push(rightdata.get(i).mid)

               }
             bridge.changetag(l,tagid)
               roots.visible = false
              botom.refresh()
         }
     }
     Button{
         anchors.centerIn: roots
         anchors.verticalCenterOffset: 170
         text:"取消"
         onClicked: {
           roots.visible = false
         }
     }
}

import QtQuick 2.15
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
Rectangle {
    id:history
    color: "white"
    function setHis(times = 0){
        if(typeof times ==='number'){
            if(times <= 0){
                return '00:00:00';
            }else{
                let hh = parseInt(times / 3600); //小时
                let shh = times - hh * 3600;
                let ii = parseInt(shh/ 60);
                let ss = parseInt(shh - ii * 60);
                return (hh < 10 ? '0'+hh : hh) + ':' + (ii < 10 ? '0'+ii : ii) +':'+(ss < 10 ? '0'+ss : ss);
            }
        }else{
            return '00:00:00';
        }
    }
    ListModel {
       id: data
    }
    Text{
        id:noting
        visible: false
       anchors.centerIn: parent
       text:config.history.tip
    }
    Component.onCompleted: {
       data.append(bridge.getallhistory())
        if (data.count===0){
            noting.visible=true
        }
    }
    ListView{
        anchors.fill: parent
        model:data
        delegate: comp
        spacing:9
        anchors.margins: 10
        Component{
            id: comp
            Rectangle{
              id:his
              width: history.width-20
              height: 50
//              color: "gray"
              radius: 10
              layer.enabled: true
              layer.effect: DropShadow {
                  transparentBorder: true
//                  horizontalOffset: 2
//                  verticalOffset: 2
              }
              Row{
                spacing:10
                anchors.verticalCenter: his.verticalCenter
                Rectangle{
                    width: 30
                    height: 30
                    color:"transparent"
                }
                Image{
                   source:"../img/"+company
                   width: 30
                   height: 30
                   layer.enabled: true
                   layer.effect: OpacityMask {
                      maskSource: Rectangle {
                          width: 30
                          height: 30
                          radius: 4
                      }
                  }
                }
                Label{
                   anchors.verticalCenter: parent.verticalCenter
                   text:title.substring(0,50)
                }
                Button{
                   flat: true
                   icon{
                      source:"../icon/时间.svg"
                   }
                   text:setHis(viewtime/1000)
                }
                Button{
                   flat: true
                   icon{
                      source:"../icon/时间1.svg"
                   }
                   text:time
                }
              }
              MouseArea{
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: {
                     his.color= "gray"
                  }
                  onExited: {
                     his.color = "white"
                  }
                  onClicked: {
                      bridge.history(vid)
                      videoviews.videopath = videopath
                      videoviews.vid = vid
                      videoviews.main = 0
                      videoviews.viewpro = viewtime
                      videoviews.show()

                  }
              }
            }

        }

    }
}

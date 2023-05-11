import QtQuick 2.0
import Qt5Compat.GraphicalEffects

Image{
    id:bgimg
Image{
    id:img
   cache:false
   asynchronous: true
   visible: false
}
Rectangle{
        id: rmask
        anchors.fill: bgimg
        radius: 10
        visible: false
        }
OpacityMask {
    anchors.fill: img
    source: img
    maskSource: rmask
    visible: true
  }
}

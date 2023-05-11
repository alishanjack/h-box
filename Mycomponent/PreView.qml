import QtQuick 2.0
import QtQuick.Controls
Window{
    property string path
    width: 1200
    height: 800
    title:"预览"
   Image{
       anchors.fill: parent
       cache:false
       source:"file:///"+datadir+"/"+path
   }
}

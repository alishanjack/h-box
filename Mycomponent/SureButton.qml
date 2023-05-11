import QtQuick 2.0
import QtQuick.Controls

Button{
    property int c
    background: Rectangle{
        color:c==1?"#409EFF":"#F56C6C"
        radius: 5
         }
   icon{
       source:c==1?"../icon/sure.svg":"../icon/unsure.svg"
       width: 15
       height: 15
   }
}

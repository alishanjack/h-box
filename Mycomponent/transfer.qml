import QtQuick 2.15
import QtQuick.Controls

Rectangle{
   id:roots
   width: 800
   height:600

   Row{
    spacing:10
    anchors.centerIn: roots
     Rectangle{
         width: roots.width/3
         height: roots.height*4/5
         color:"blue"
     }
     Rectangle{
         width: roots.width/3
         height: roots.height*4/5
         color:"blue"
     }
   }
}

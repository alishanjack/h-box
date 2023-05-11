import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
Rectangle{
    property string url: ""
    height:30
    width:10*url.length
    color:"gray"
    radius:15
    Text{
       anchors.centerIn: parent
       text:url
    }
    MouseArea{
       anchors.fill: parent
       cursorShape: Qt.PointingHandCursor
       onClicked: {
                  Qt.openUrlExternally("https://www."+url)
              }
    }
}
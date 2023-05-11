import QtQuick 2.0
import QtQuick.Controls
Button {
    flat: true
    icon{
        width: 20
        height:20
        color:hovered?"#F00078":"black"
    }
    MouseArea{
       anchors.fill: parent
       cursorShape: Qt.PointingHandCursor
       acceptedButtons: Qt.NoButton

    }
}

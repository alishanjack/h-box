import QtQuick 2.0
import QtQuick.Controls
Button {

    background: Rectangle{
        anchors.fill: parent
//        color: "transparent"
        border.width: control.pressed ? 2: 1;
        border.color: (color.hovered || control.pressed) ?"green" :"red";
    }
}

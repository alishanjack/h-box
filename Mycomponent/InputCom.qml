import QtQuick 2.0
import QtQuick.Controls 2.0
import Qt5Compat.GraphicalEffects

TextField {
    id: root

    property color checkedColor: "#D5DBDB"

    signal doubleClicked(var/*MouseEvent*/ event)

    placeholderText: qsTr("请输入内容")
    font.family: "Arial"
    font.pixelSize: 15
    font.weight: Font.Thin
    antialiasing: true

    background: Rectangle {
        implicitWidth: 213
        implicitHeight: 24
        radius: 8
        color: root.enabled ? "transparent" : "#F4F6F6"
        border.color: root.enabled ? root.checkedColor : "#D5DBDB"
        border.width: 2
        opacity: root.enabled ? 1 : 0.7

        layer.enabled: root.hovered
        layer.effect: DropShadow {
            id: dropShadow
            transparentBorder: true
            color: root.checkedColor
            samples: 10 /*20*/
        }
    }

    cursorDelegate: Rectangle {
        width: 1
        height: parent.height*0.8
        color: root.checkedColor
        visible: root.focus

        Timer {
            interval: 600
            repeat: true
            running: root.focus
            onRunningChanged: parent.visible = running
            onTriggered: parent.visible = !parent.visible
        }
    }

    onDoubleClicked: selectAll()

    /* note: This signal was introduced in QtQuick.Controls 2.1 (Qt 5.8). */
    onPressed: {
        _private.mouseEvent = event
        _private.isCheckDoubleClickedEvent++

        if (! _checkDoubleClickedEventTimer.running)
            _checkDoubleClickedEventTimer.restart()
    }

    /* Private */
    Item {
        id: _private
        property int isCheckDoubleClickedEvent: 0
        property var/*MouseEvent*/ mouseEvent

        Timer {
            id: _checkDoubleClickedEventTimer
            running: false
            repeat: false
            interval: 180
            onTriggered: {
                if (_private.isCheckDoubleClickedEvent >= 2) {
                    /* Double Clicked Event */
                    root.doubleClicked(_private.mouseEvent)
                }

                stop()
                _private.isCheckDoubleClickedEvent = 0
            }
        }
    }
}

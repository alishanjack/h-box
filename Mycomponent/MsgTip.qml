import QtQuick 2.0
import QtQuick.Controls
Popup {
        id:pop
        width: 200
        height: 50
        modal: true
        focus: true
        property string msg
        anchors.centerIn: parent
        Text{
           anchors.centerIn: parent
           text: msg
        }
      onOpened: {
          timer.start()
      }
      Timer{
        id: timer
        interval: 1500
        onTriggered: {
            pop.close()
        }
      }

    }

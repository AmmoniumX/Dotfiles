import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../"

Rectangle {
    id: root

    Theme { id: theme }

    radius: theme.pillRadius
    color: theme.base
    implicitWidth: row.implicitWidth + 16
    implicitHeight: theme.barHeight - 8

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: SystemTray.items

            delegate: IconImage {
                required property var modelData
                implicitSize: 14
                source: modelData.icon

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) modelData.activate();
                        else modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}

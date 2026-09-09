import QtQuick
import Quickshell
import "../"

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: theme.barHeight
    color: "transparent"

    Theme { id: theme }

    Item {
        anchors.fill: parent

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Tray {}
            Media {}
        }

        Row {
            anchors.centerIn: parent
            spacing: 10

            Clock {}
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            GroupBackground {
                Backlight {}
                Pulseaudio {}
                Cpu {}
                Memory {}
                Battery {}
            }

            GroupBackground {
                Bluetooth {}
                Network {}
                KeyboardLayout {}
            }
        }
    }
}

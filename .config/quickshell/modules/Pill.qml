import QtQuick
import "../"

Rectangle {
    id: root

    property alias text: label.text
    property color fg: theme.lavender
    property real leftPad: 8
    property real rightPad: 8
    property bool interactive: true

    signal clicked()
    signal wheelUp()
    signal wheelDown()

    Theme { id: theme }

    radius: theme.pillRadius
    color: theme.base
    implicitWidth: label.implicitWidth + leftPad + rightPad
    implicitHeight: theme.barHeight - 8

    Text {
        id: label
        anchors.centerIn: parent
        color: root.fg
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton
        onClicked: root.clicked()
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) root.wheelUp();
            else if (wheel.angleDelta.y < 0) root.wheelDown();
        }
    }
}

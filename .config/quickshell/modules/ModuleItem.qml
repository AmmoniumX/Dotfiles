import QtQuick
import "../"

// A single icon+text item with no background of its own, meant to sit
// inside a GroupBackground pill alongside other ModuleItems
Item {
    id: root

    property alias text: label.text
    property color fg: theme.lavender
    property bool interactive: true

    signal clicked()
    signal wheelUp()
    signal wheelDown()

    Theme { id: theme }

    implicitWidth: label.implicitWidth + 16
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

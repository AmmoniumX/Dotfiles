import QtQuick
import "../"

// Text that clips to maxWidth and, only when the text is wider than that,
// scrolls it horizontally in a seamless loop.
Item {
    id: root

    property alias text: measure.text
    property color fg: theme.lavender
    property real maxWidth: 200
    readonly property int gap: 24
    readonly property int pixelsPerSecond: 20
    readonly property bool overflowing: measure.implicitWidth > maxWidth

    Theme { id: theme }

    implicitWidth: Math.min(measure.implicitWidth, maxWidth) + 16
    implicitHeight: theme.barHeight - 8
    clip: true

    Text {
        id: measure
        visible: false
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize
        font.bold: true
    }

    Text {
        visible: !root.overflowing
        anchors.centerIn: parent
        text: measure.text
        color: root.fg
        font: measure.font
    }

    Row {
        id: track
        visible: root.overflowing
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.gap
        x: 8

        Text {
            text: measure.text
            color: root.fg
            font: measure.font
        }

        Text {
            text: measure.text
            color: root.fg
            font: measure.font
        }

        NumberAnimation {
            id: anim
            target: track
            property: "x"
            running: root.overflowing
            loops: Animation.Infinite
            from: 8
            to: 8 - (measure.implicitWidth + root.gap)
            duration: Math.max(1, (measure.implicitWidth + root.gap) / root.pixelsPerSecond * 1000)
        }
    }

    Connections {
        target: measure
        function onTextChanged() {
            track.x = 8;
            if (root.overflowing) anim.restart();
        }
    }
}

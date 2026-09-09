import QtQuick
import "../"

Pill {
    id: root

    property var now: new Date()

    Theme { id: theme }
    Icons { id: icons }

    interactive: false
    fg: theme.sky
    text: icons.clock + " " + Qt.formatDateTime(now, "HH:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}

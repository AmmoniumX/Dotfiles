import QtQuick
import "../"

// Shared pill background for a cluster of ModuleItems
Rectangle {
    id: root

    default property alias content: row.children

    Theme { id: theme }

    radius: theme.pillRadius
    color: theme.base
    implicitWidth: row.implicitWidth
    implicitHeight: theme.barHeight - 8

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
    }
}

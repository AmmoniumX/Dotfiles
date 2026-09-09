import QtQuick
import "../"

ModuleItem {
    id: root

    property int capacity: 0
    property string status: ""
    property bool charging: status === "Charging"
    property bool critical: capacity <= 15 && !charging
    property bool blinkOn: true

    Theme { id: theme }
    Icons { id: icons }

    interactive: false
    text: icons.battery[Math.min(4, Math.max(0, Math.floor(capacity / 20)))]
        + " " + String(capacity).padStart(3, " ") + "%"

    fg: critical ? (blinkOn ? "#bf616a" : "#ed8796")
        : charging ? "#81a1c1"
        : "#d8dee9"

    Timer {
        interval: 500
        running: root.critical
        repeat: true
        onTriggered: root.blinkOn = !root.blinkOn
    }

    ScriptWatcher {
        script: "battery.sh"
        onLineReceived: (line) => {
            const parts = line.split("|");
            root.capacity = parseInt(parts[0]) || 0;
            root.status = parts[1] || "";
        }
    }
}

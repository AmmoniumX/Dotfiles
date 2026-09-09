import Quickshell.Io
import "../"

ModuleItem {
    id: root

    property int value: 0

    Theme { id: theme }
    Icons { id: icons }

    fg: theme.sky
    text: icons.cpu + " " + String(value).padStart(3, " ") + "%"

    ScriptWatcher {
        script: "cpu.sh"
        onLineReceived: (line) => root.value = parseInt(line) || 0
    }

    Process {
        id: htopProc
        command: ["kitty", "htop"]
    }

    onClicked: htopProc.startDetached()
}

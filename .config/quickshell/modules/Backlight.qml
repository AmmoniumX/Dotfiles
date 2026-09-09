import Quickshell.Io
import "../"

ModuleItem {
    id: root

    property int value: 0

    Theme { id: theme }
    Icons { id: icons }

    fg: theme.yellow
    text: icons.backlight + " " + String(value).padStart(3, " ") + "%"

    ScriptWatcher {
        script: "backlight.sh"
        onLineReceived: (line) => root.value = parseInt(line) || 0
    }

    Process {
        id: upProc
        command: ["brightnessctl", "-c", "backlight", "set", "+5%"]
    }
    Process {
        id: downProc
        command: ["brightnessctl", "-c", "backlight", "set", "5%-"]
    }

    onWheelUp: upProc.startDetached()
    onWheelDown: downProc.startDetached()
}

import Quickshell.Io
import "../"

ModuleItem {
    id: root

    property string state: "off"

    Icons { id: icons }

    text: icons.bluetooth + " " + (state === "connected" ? "on" : state)

    ScriptWatcher {
        script: "bluetooth.sh"
        onLineReceived: (line) => root.state = line || "off"
    }

    Process {
        id: blueberryProc
        command: ["blueberry"]
    }

    onClicked: blueberryProc.startDetached()
}

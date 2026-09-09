import Quickshell.Io
import "../"

ModuleItem {
    id: root

    property string state: "disconnected"
    property string name: ""

    Theme { id: theme }
    Icons { id: icons }

    fg: state === "disconnected" ? "#bf616a" : theme.green

    function truncate(s) {
        return s.length > 15 ? s.substring(0, 15) : s;
    }

    text: state === "wifi" ? icons.networkWifi + "  " + truncate(name)
        : state === "ethernet" ? icons.networkEthernet + "  Wired"
        : icons.networkDisconnected + "  Disconnected"

    ScriptWatcher {
        script: "network.sh"
        onLineReceived: (line) => {
            const parts = line.split("|");
            root.state = parts[0] || "disconnected";
            root.name = parts[1] || "";
        }
    }

    Process {
        id: guiProc
        command: ["nm-wifi-gui"]
    }

    onClicked: guiProc.startDetached()
}

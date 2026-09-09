import Quickshell.Io
import "../"

ModuleItem {
    id: root

    property int volume: 0
    property bool muted: false

    Theme { id: theme }
    Icons { id: icons }

    fg: muted ? "#3b4252" : theme.flamingo
    text: muted
        ? icons.volumeMuted + " muted"
        : (volume < 50 ? icons.volumeLow : icons.volumeHigh) + " " + String(volume).padStart(3, " ") + "%"

    ScriptWatcher {
        script: "pulseaudio.sh"
        onLineReceived: (line) => {
            const parts = line.split("|");
            root.volume = parseInt(parts[0]) || 0;
            root.muted = parts[1] === "true";
        }
    }

    Process {
        id: pavucontrolProc
        command: ["pavucontrol"]
    }
    Process {
        id: upProc
        command: ["bash", "-c", "pamixer -ui 2 && pamixer --get-volume > /tmp/wob.fifo"]
    }
    Process {
        id: downProc
        command: ["bash", "-c", "pamixer -ud 2 && pamixer --get-volume > /tmp/wob.fifo"]
    }

    onClicked: pavucontrolProc.startDetached()
    onWheelUp: upProc.startDetached()
    onWheelDown: downProc.startDetached()
}

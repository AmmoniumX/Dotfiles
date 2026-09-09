import "../"

ModuleItem {
    id: root

    property string layout: ""

    Theme { id: theme }
    Icons { id: icons }

    interactive: false
    fg: theme.flamingo
    text: icons.keyboard + " " + layout

    ScriptWatcher {
        script: "keyboard.sh"
        onLineReceived: (line) => root.layout = line
    }
}

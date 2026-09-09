import Quickshell.Io

Process {
    id: root

    // Name of a script under .config/quickshell/scripts/, expected to loop
    // forever and print one update per line on stdout.
    required property string script

    signal lineReceived(string line)

    command: ["bash", "-c", "exec \"$HOME\"/.config/quickshell/scripts/" + script]
    running: true

    stdout: SplitParser {
        splitMarker: "\n"
        onRead: (data) => root.lineReceived(data)
    }
}

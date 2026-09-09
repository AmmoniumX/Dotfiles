import QtQuick

QtObject {
    readonly property string cpu: ""
    readonly property string memory: ""
    readonly property string backlight: ""

    readonly property var battery: ["", "", "", "", ""]

    readonly property string networkWifi: ""
    readonly property string networkEthernet: ""
    readonly property string networkDisconnected: "⚠"

    readonly property string volumeLow: ""
    readonly property string volumeHigh: ""
    readonly property string volumeMuted: ""

    readonly property string bluetooth: ""

    readonly property string keyboard: ""
    readonly property string clock: ""

    // Media glyphs, matching the ones used by ../serpantinum's MediaWidget.
    readonly property string mediaNote: "󰎈"
    readonly property string mediaPrev: "󰒮"
    readonly property string mediaPlay: "󰐊"
    readonly property string mediaPause: "󰏤"
    readonly property string mediaNext: "󰒭"
}

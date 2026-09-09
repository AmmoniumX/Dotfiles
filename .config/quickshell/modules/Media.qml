import QtQuick
import Quickshell.Services.Mpris
import "../"

// Now-playing widget: info text followed by prev/play-pause/next buttons
Rectangle {
    id: root

    Theme { id: theme }
    Icons { id: icons }

    readonly property var player: {
        const players = Mpris.players.values;
        const playing = players.find(p => p.isPlaying);
        if (playing) return playing;
        const controllable = players.find(p => p.canControl);
        if (controllable) return controllable;
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool active: player !== null && player.playbackState !== MprisPlaybackState.Stopped

    function truncate(s) {
        return s.length > 30 ? s.substring(0, 30) + "…" : s;
    }

    readonly property string infoText: active
        ? icons.mediaNote + " " + truncate(player.trackTitle || "Unknown")
        : icons.mediaNote + " Nothing playing"

    radius: theme.pillRadius
    color: theme.base
    implicitWidth: row.implicitWidth
    implicitHeight: theme.barHeight - 8

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        ModuleItem {
            fg: theme.mauve
            text: root.infoText
            interactive: false
        }

        ModuleItem {
            fg: theme.lavender
            text: icons.mediaPrev
            interactive: root.active && root.player.canGoPrevious
            opacity: interactive ? 1.0 : 0.4
            onClicked: root.player.previous()
        }

        ModuleItem {
            fg: theme.mauve
            text: root.active && root.player.isPlaying ? icons.mediaPause : icons.mediaPlay
            interactive: root.active && root.player.canTogglePlaying
            opacity: interactive ? 1.0 : 0.4
            onClicked: root.player.togglePlaying()
        }

        ModuleItem {
            fg: theme.lavender
            text: icons.mediaNext
            interactive: root.active && root.player.canGoNext
            opacity: interactive ? 1.0 : 0.4
            onClicked: root.player.next()
        }
    }
}

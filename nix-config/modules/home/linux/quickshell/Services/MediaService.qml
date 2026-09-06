import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Scope {
    id: root

    property string state: "unknown"
    property string errorCode: ""
    readonly property var players: Mpris.players.values
    readonly property var player: players.length > 0 ? players[0] : null
    readonly property var hasPlayer: state === "ready" ? player !== null : null
    readonly property string identity: hasPlayer === true ? player.identity : "NO ACTIVE PLAYER"
    readonly property string title: hasPlayer === true ? (player.trackTitle || "UNTITLED MEDIA") : "MPRIS IDLE"
    readonly property string artist: hasPlayer === true ? (player.trackArtist || "UNKNOWN ARTIST") : "NO SESSION"
    readonly property string album: hasPlayer === true ? (player.trackAlbum || "ALBUM UNAVAILABLE") : ""
    readonly property bool playing: hasPlayer === true ? player.isPlaying : false
    readonly property real progress: hasPlayer === true && player.lengthSupported && player.length > 0 ? player.position / player.length : 0

    function togglePlaying() {
        if (hasPlayer === true && player.canTogglePlaying)
            player.isPlaying = !player.isPlaying;
    }

    function next() {
        if (hasPlayer === true && player.canGoNext)
            player.next();
    }

    function previous() {
        if (hasPlayer === true && player.canGoPrevious)
            player.previous();
    }

    function refreshState() {
        if (players === null || players === undefined || typeof players.length !== "number") {
            state = "error";
            errorCode = "MPRIS_PLAYER_MODEL_INVALID";
        } else {
            state = "ready";
            errorCode = "";
        }
    }

    Component.onCompleted: refreshState()
    onPlayersChanged: refreshState()
}

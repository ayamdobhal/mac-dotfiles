import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    property string state: "unknown"
    property string errorCode: ""
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property int volumePercent: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property var muted: sink && sink.audio ? sink.audio.muted : null
    readonly property var microphoneMuted: source && source.audio ? source.audio.muted : null
    readonly property string sinkName: sink ? (sink.description || sink.nickname || sink.name) : "NO DEFAULT SINK"
    readonly property string sourceName: source ? (source.description || source.nickname || source.name) : "NO DEFAULT SOURCE"
    readonly property string label: state === "ready" ? String(volumePercent) + "%" : state === "busy" ? "LOADING" : state.toUpperCase()

    function refreshState() {
        if (!Pipewire.ready) {
            if (state !== "unavailable")
                state = "busy";
            errorCode = state === "unavailable" ? "PIPEWIRE_SYNC_TIMEOUT" : "";
        } else if (!sink) {
            state = "unavailable";
            errorCode = "PIPEWIRE_SINK_ABSENT";
        } else if (!sink.audio) {
            state = "error";
            errorCode = "PIPEWIRE_SINK_NOT_AUDIO";
        } else {
            state = "ready";
            errorCode = "";
            timeout.stop();
        }
    }

    function setMuted(muted) {
        if (state !== "ready" || !sink || !sink.audio)
            return;
        state = "busy";
        sink.audio.muted = muted;
        confirmation.restart();
    }

    function setMicrophoneMuted(muted) {
        if (state !== "ready" || !source || !source.audio)
            return;
        state = "busy";
        source.audio.muted = muted;
        confirmation.restart();
    }

    function setVolumePercent(percent) {
        if (state !== "ready" || !sink || !sink.audio)
            return;
        state = "busy";
        sink.audio.volume = Math.max(0, Math.min(1, percent / 100));
        confirmation.restart();
    }

    Component.onCompleted: {
        timeout.start();
        refreshState();
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Connections {
        target: Pipewire
        function onReadyChanged() {
            root.refreshState();
        }
        function onDefaultAudioSinkChanged() {
            root.refreshState();
        }
        function onDefaultAudioSourceChanged() {
            root.refreshState();
        }
    }

    Timer {
        id: timeout
        interval: 4000
        onTriggered: {
            if (!Pipewire.ready) {
                root.state = "unavailable";
                root.errorCode = "PIPEWIRE_SYNC_TIMEOUT";
            }
        }
    }

    Timer {
        id: confirmation
        interval: 600
        onTriggered: root.refreshState()
    }
}

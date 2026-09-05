import QtQuick
import Quickshell
import Quickshell.Io
import "../js/BoundedJson.js" as BoundedJson

Scope {
    id: root

    required property var runtime

    property string state: "unknown"
    property string errorCode: ""
    property var activeIncidents: []
    property var historyIncidents: []
    property bool doNotDisturb: false
    readonly property var incidents: activeIncidents.concat(historyIncidents)

    function normalize(items, active) {
        return items.slice(0, 64).map(function (item) {
            return {
                id: Number(item.id) || 0,
                appName: item.app_name || "UNKNOWN APPLICATION",
                summary: item.summary || "UNTITLED INCIDENT",
                body: item.body || "",
                urgency: item.urgency || "normal",
                active: active,
                actions: item.actions || {}
            };
        });
    }

    function consume(text, active) {
        var result = BoundedJson.parse(text, 524288);
        if (!result.ok || !Array.isArray(result.value)) {
            state = "error";
            errorCode = result.error || "MAKO_SCHEMA";
            return;
        }
        if (active)
            activeIncidents = normalize(result.value, true);
        else
            historyIncidents = normalize(result.value, false);
        state = "ready";
        errorCode = "";
    }

    function refresh() {
        state = state === "unknown" ? "busy" : state;
        if (!activeProcess.running)
            activeProcess.running = true;
        if (!historyProcess.running)
            historyProcess.running = true;
        if (!modeProcess.running)
            modeProcess.running = true;
    }

    function dismiss(id) {
        actionProcess.exec([runtime.makoctl, "dismiss", "-n", String(id)]);
    }

    function setDoNotDisturb(enabled) {
        doNotDisturb = enabled;
        actionProcess.exec([runtime.makoctl, "mode", enabled ? "-a" : "-r", "do-not-disturb"]);
    }

    Component.onCompleted: refresh()

    Process {
        id: activeProcess
        command: [root.runtime.makoctl, "list", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.consume(text, true)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.state = "unavailable";
                root.errorCode = "MAKO_LIST_EXIT_" + exitCode;
            }
        }
    }
    Process {
        id: historyProcess
        command: [root.runtime.makoctl, "history", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.consume(text, false)
        }
    }
    Process {
        id: modeProcess
        command: [root.runtime.makoctl, "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.doNotDisturb = text.split("\n").indexOf("do-not-disturb") !== -1
        }
    }
    Process {
        id: actionProcess
        onExited: refreshTimer.restart()
    }
    Timer {
        id: refreshTimer
        interval: 250
        onTriggered: root.refresh()
    }
    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }
}

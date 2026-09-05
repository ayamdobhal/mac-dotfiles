import QtQuick
import Quickshell
import Quickshell.Io
import "../js/BoundedJson.js" as BoundedJson

Scope {
    id: root

    required property var runtime

    property string state: "unknown"
    property string errorCode: ""
    property var workspaces: []
    property var windows: []
    property string focusedOutput: ""
    property string focusedApp: "NO FOCUSED APPLICATION"
    property string focusedTitle: "NIRI FIELD IDLE"
    property int focusedWorkspaceIndex: 0
    property int columnIndex: 0
    property int stackIndex: 0
    property int columnCount: 0
    property int stackCount: 0
    property string workspaceSnapshotState: "unknown"
    property string windowSnapshotState: "unknown"

    function refresh() {
        workspaceSnapshotState = "busy";
        windowSnapshotState = "busy";
        if (!workspaceProcess.running)
            workspaceProcess.running = true;
        if (!windowProcess.running)
            windowProcess.running = true;
        if (state === "unknown" || state === "error")
            state = "busy";
    }

    function consumeWorkspaces(text) {
        var result = BoundedJson.parse(text, 262144);
        if (!result.ok || !Array.isArray(result.value)) {
            state = "error";
            errorCode = result.error || "WORKSPACE_SCHEMA";
            return;
        }

        workspaces = result.value.slice(0, 64).map(function (workspace) {
            return {
                id: Number(workspace.id) || 0,
                idx: Number(workspace.idx) || 0,
                name: workspace.name || "",
                output: workspace.output || "",
                isActive: workspace.is_active === true,
                isFocused: workspace.is_focused === true,
                isUrgent: workspace.is_urgent === true
            };
        });
        var focused = workspaces.find(function (workspace) {
            return workspace.isFocused;
        });
        focusedOutput = focused ? focused.output : "";
        focusedWorkspaceIndex = focused ? focused.idx : 0;
        workspaceSnapshotState = "ready";
        finishSnapshot();
    }

    function consumeWindows(text) {
        var result = BoundedJson.parse(text, 1048576);
        if (!result.ok || !Array.isArray(result.value)) {
            state = "error";
            errorCode = result.error || "WINDOW_SCHEMA";
            return;
        }

        windows = result.value.slice(0, 512);
        var focused = windows.find(function (window) {
            return window.is_focused === true;
        });
        if (focused) {
            focusedApp = focused.app_id || "UNKNOWN APPLICATION";
            focusedTitle = focused.title || "UNTITLED WINDOW";
            var position = focused.layout && focused.layout.pos_in_scrolling_layout;
            columnIndex = position && position.length > 0 ? Number(position[0]) : 0;
            stackIndex = position && position.length > 1 ? Number(position[1]) : 0;
            var activeWindows = windows.filter(function (window) {
                return Number(window.workspace_id) === Number(focused.workspace_id);
            });
            var columns = {};
            activeWindows.forEach(function (window) {
                var candidate = window.layout && window.layout.pos_in_scrolling_layout;
                if (candidate && candidate.length > 0)
                    columns[String(candidate[0])] = true;
            });
            columnCount = Object.keys(columns).length;
            stackCount = activeWindows.filter(function (window) {
                var candidate = window.layout && window.layout.pos_in_scrolling_layout;
                return candidate && Number(candidate[0]) === columnIndex;
            }).length;
        } else {
            focusedApp = "NO FOCUSED APPLICATION";
            focusedTitle = "NIRI FIELD IDLE";
            columnIndex = 0;
            stackIndex = 0;
            columnCount = 0;
            stackCount = 0;
        }
        windowSnapshotState = "ready";
        finishSnapshot();
    }

    function finishSnapshot() {
        if (workspaceSnapshotState === "ready" && windowSnapshotState === "ready") {
            state = "ready";
            errorCode = "";
        }
    }

    function focusWorkspace(index) {
        workspaceAction.exec([runtime.niri, "msg", "action", "focus-workspace", String(index)]);
    }

    Component.onCompleted: refresh()

    Process {
        id: workspaceProcess
        command: [root.runtime.niri, "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: root.consumeWorkspaces(text)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.state = "unavailable";
                root.errorCode = "NIRI_WORKSPACES_EXIT_" + exitCode;
            }
        }
    }

    Process {
        id: windowProcess
        command: [root.runtime.niri, "msg", "--json", "windows"]
        stdout: StdioCollector {
            onStreamFinished: root.consumeWindows(text)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.state = "unavailable";
                root.errorCode = "NIRI_WINDOWS_EXIT_" + exitCode;
            }
        }
    }

    Process {
        id: eventStream
        command: [root.runtime.niri, "msg", "event-stream"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function (data) {
                if (data.length <= 262144)
                    refreshDebounce.restart();
            }
        }
        onExited: reconnectTimer.restart()
    }

    Process {
        id: workspaceAction
    }

    Timer {
        id: refreshDebounce
        interval: 80
        onTriggered: root.refresh()
    }

    Timer {
        id: reconnectTimer
        interval: 2000
        onTriggered: eventStream.running = true
    }
}

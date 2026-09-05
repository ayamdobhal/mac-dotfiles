import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Scope {
    id: root

    required property var runtime

    property string state: "unknown"
    property string errorCode: ""
    property string brightnessState: "unknown"
    property string inhibitorState: "ready"
    property int brightnessPercent: 0
    property bool keepAwake: false
    readonly property var device: UPower.displayDevice
    readonly property var batteries: UPower.devices.values.filter(function (candidate) {
        return candidate.isLaptopBattery && candidate.isPresent;
    })
    readonly property var healthBatteries: batteries.filter(function (candidate) {
        return candidate.healthSupported;
    })
    readonly property int batteryCount: batteries.length
    // Quickshell normalizes UPower percentages to 0..1 even though upower(1)
    // prints 0..100. DisplayDevice is the correct aggregate for BAT0 + BAT1.
    readonly property int percentage: device && device.ready ? Math.round(device.percentage * 100) : 0
    readonly property var onBattery: state === "ready" ? UPower.onBattery : null
    readonly property int healthPercent: healthBatteries.length > 0 ? Math.round(healthBatteries.reduce(function (total, battery) {
        return total + battery.healthPercentage;
    }, 0) / healthBatteries.length) : 0
    readonly property int secondsRemaining: device && device.ready ? Math.round(device.timeToEmpty) : 0
    readonly property string batterySummary: batteries.map(function (battery) {
        return Math.round(battery.percentage * 100) + "%";
    }).join("/")
    readonly property string label: state === "ready" ? (onBattery ? "BAT " : "AC ") + (batteryCount > 1 ? batterySummary : percentage + "%") : state === "busy" ? "LOADING" : state.toUpperCase()

    function batteryPercentage(battery) {
        return battery && battery.ready ? Math.round(battery.percentage * 100) : 0;
    }

    function batteryHealth(battery) {
        return battery && battery.ready && battery.healthSupported ? Math.round(battery.healthPercentage) : 0;
    }

    function refreshState() {
        if (device && device.ready) {
            if (device.percentage < 0 || device.percentage > 100) {
                state = "error";
                errorCode = "UPOWER_PERCENTAGE_INVALID";
            } else {
                state = device.isPresent ? "ready" : "unavailable";
                errorCode = device.isPresent ? "" : "UPOWER_DEVICE_ABSENT";
            }
            timeout.stop();
        } else {
            if (state !== "unavailable")
                state = "busy";
            errorCode = state === "unavailable" ? "UPOWER_SYNC_TIMEOUT" : "";
        }
    }

    function consumeBrightness(text) {
        var fields = text.trim().split(",");
        if (fields.length < 4) {
            brightnessState = "unavailable";
            return;
        }
        var value = Number(fields[3].replace("%", ""));
        if (isNaN(value)) {
            brightnessState = "error";
            return;
        }
        brightnessPercent = value;
        brightnessState = "ready";
    }

    function setBrightness(percent) {
        brightnessState = "busy";
        brightnessAction.exec([runtime.brightnessctl, "set", String(Math.max(1, Math.min(100, percent))) + "%"]);
    }

    function setKeepAwake(enabled) {
        inhibitorState = "busy";
        if (enabled) {
            inhibitor.running = true;
        } else {
            keepAwake = false;
            inhibitor.running = false;
            inhibitorState = "ready";
        }
    }

    Component.onCompleted: {
        timeout.start();
        refreshState();
        brightnessRead.running = true;
    }

    Connections {
        target: root.device
        enabled: root.device !== null
        function onReadyChanged() {
            root.refreshState();
        }
        function onPercentageChanged() {
            root.refreshState();
        }
        function onIsPresentChanged() {
            root.refreshState();
        }
    }

    Timer {
        id: timeout
        interval: 4000
        onTriggered: {
            if (!root.device || !root.device.ready) {
                root.state = "unavailable";
                root.errorCode = "UPOWER_SYNC_TIMEOUT";
            }
        }
    }

    Process {
        id: brightnessRead
        command: [root.runtime.brightnessctl, "-m"]
        stdout: StdioCollector {
            onStreamFinished: root.consumeBrightness(text)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0)
                root.brightnessState = "unavailable";
        }
    }

    Process {
        id: brightnessAction
        onExited: function (exitCode) {
            if (exitCode === 0)
                brightnessRead.running = true;
            else
                root.brightnessState = "error";
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            if (!brightnessRead.running && !brightnessAction.running)
                brightnessRead.running = true;
        }
    }

    Process {
        id: inhibitor
        command: [root.runtime.systemdInhibit, "--what=idle", "--who=NERV Command Surface", "--why=Operator keep-awake gate", root.runtime.sleep, "infinity"]
        onStarted: {
            root.keepAwake = true;
            root.inhibitorState = "ready";
        }
        onExited: function (exitCode) {
            var wasExpected = !root.keepAwake;
            root.keepAwake = false;
            if (!wasExpected && exitCode !== 0)
                root.inhibitorState = "error";
        }
    }
}

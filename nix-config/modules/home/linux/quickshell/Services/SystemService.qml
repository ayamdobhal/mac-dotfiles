import QtQuick
import Quickshell
import Quickshell.Io
import "../js/BoundedJson.js" as BoundedJson
import "../js/SystemMetrics.js" as Metrics

Scope {
    id: root

    required property var runtime

    property string cpuState: "unknown"
    property string memoryState: "unknown"
    property real cpuPercent: 0
    property real memoryPercent: 0
    property string temperatureState: "unknown"
    property real temperatureCelsius: 0
    property string hostname: "UNKNOWN HOST"
    property string kernel: "UNKNOWN KERNEL"
    property string generation: "UNKNOWN GENERATION"
    property int uptimeSeconds: 0
    property var cpuHistory: []
    property var memoryHistory: []
    property var temperatureHistory: []
    property var previousCpuSample: null
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string timeWithSeconds: Qt.formatDateTime(clock.date, "HH:mm:ss")
    readonly property string date: Qt.formatDateTime(clock.date, "dd MMM")
    readonly property string longDate: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
    readonly property string dayOfWeek: Qt.formatDateTime(clock.date, "dddd").toUpperCase()
    readonly property string dayNumber: Qt.formatDateTime(clock.date, "dd")
    readonly property string monthYear: Qt.formatDateTime(clock.date, "MMMM yyyy").toUpperCase()

    function consumeCpu(text) {
        var sample = Metrics.cpuSample(text);
        if (!sample) {
            cpuState = "error";
            return;
        }
        var value = Metrics.cpuPercent(previousCpuSample, sample);
        previousCpuSample = sample;
        if (value === null) {
            cpuState = "busy";
            return;
        }
        cpuPercent = value;
        cpuHistory = cpuHistory.concat([value]).slice(-48);
        cpuState = value >= 90 ? "error" : value >= 75 ? "warning" : "ready";
    }

    function consumeMemory(text) {
        var value = Metrics.memoryPercent(text);
        if (value === null) {
            memoryState = "error";
            return;
        }
        memoryPercent = value;
        memoryHistory = memoryHistory.concat([value]).slice(-48);
        memoryState = value >= 95 ? "error" : value >= 85 ? "warning" : "ready";
    }

    function consumeTemperature(text) {
        var result = BoundedJson.parse(text, 262144);
        var value = result.ok ? Metrics.firstTemperature(result.value) : null;
        if (value === null) {
            temperatureState = "unavailable";
            return;
        }
        temperatureCelsius = value;
        temperatureHistory = temperatureHistory.concat([value]).slice(-48);
        temperatureState = value >= 90 ? "error" : value >= 78 ? "warning" : "ready";
    }

    function consumeUptime(text) {
        var value = Number(text.trim().split(/\s+/)[0]);
        if (!isNaN(value))
            uptimeSeconds = Math.floor(value);
    }

    function formatUptime() {
        var days = Math.floor(uptimeSeconds / 86400);
        var hours = Math.floor((uptimeSeconds % 86400) / 3600);
        var minutes = Math.floor((uptimeSeconds % 3600) / 60);
        return days + "D " + String(hours).padStart(2, "0") + "H " + String(minutes).padStart(2, "0") + "M";
    }

    Component.onCompleted: {
        kernelProcess.running = true;
        generationProcess.running = true;
        sensorsProcess.running = true;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    FileView {
        id: cpuFile
        path: "/proc/stat"
        preload: true
        printErrors: false
        onLoaded: root.consumeCpu(text())
        onLoadFailed: root.cpuState = "error"
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        preload: true
        printErrors: false
        onLoaded: root.consumeUptime(text())
    }

    FileView {
        path: "/etc/hostname"
        preload: true
        printErrors: false
        onLoaded: root.hostname = text().trim().toUpperCase()
    }

    Process {
        id: kernelProcess
        command: [root.runtime.uname, "-r"]
        stdout: StdioCollector {
            onStreamFinished: root.kernel = text.trim()
        }
    }

    Process {
        id: generationProcess
        command: [root.runtime.readlink, "-f", "/run/current-system"]
        stdout: StdioCollector {
            onStreamFinished: root.generation = text.trim().split("/").pop()
        }
    }

    Process {
        id: sensorsProcess
        command: [root.runtime.sensors, "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.consumeTemperature(text)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0)
                root.temperatureState = "unavailable";
        }
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        preload: true
        printErrors: false
        onLoaded: root.consumeMemory(text())
        onLoadFailed: root.memoryState = "error"
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            cpuFile.reload();
            memoryFile.reload();
            uptimeFile.reload();
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: true
        onTriggered: sensorsProcess.running = true
    }
}

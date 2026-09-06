import QtQuick
import Quickshell
import Quickshell.Bluetooth

Scope {
    id: root

    property string state: "unknown"
    property string errorCode: ""
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []
    readonly property int connectedCount: devices.filter(function (device) {
        return device.connected;
    }).length
    readonly property int pairedCount: devices.filter(function (device) {
        return device.paired;
    }).length
    readonly property var enabled: adapter ? adapter.enabled : null
    readonly property string label: state === "ready" ? (enabled ? "ON / " + connectedCount + " LINK" : "RADIO OFF") : state === "busy" ? "LOADING" : state.toUpperCase()

    function setEnabled(enabled) {
        if (!adapter || (state !== "ready" && state !== "warning"))
            return;
        state = "busy";
        adapter.enabled = enabled;
        actionTimeout.restart();
    }

    function setDiscovering(discovering) {
        if (!adapter || !adapter.enabled)
            return;
        adapter.discovering = discovering;
        refreshState();
    }

    function setDeviceConnected(device, connected) {
        if (!device || !device.paired)
            return;
        device.connected = connected;
    }

    function refreshState() {
        if (!adapter) {
            state = "unavailable";
            errorCode = "BLUEZ_ADAPTER_ABSENT";
        } else if (adapter.state === BluetoothAdapterState.Enabling || adapter.state === BluetoothAdapterState.Disabling || adapter.discovering) {
            state = "busy";
            errorCode = "";
        } else if (adapter.state === BluetoothAdapterState.Blocked) {
            state = "warning";
            errorCode = "BLUEZ_ADAPTER_BLOCKED";
        } else if (adapter.state === BluetoothAdapterState.Enabled || adapter.state === BluetoothAdapterState.Disabled) {
            state = "ready";
            errorCode = "";
        } else {
            state = "error";
            errorCode = "BLUEZ_ADAPTER_STATE_INVALID";
        }
    }

    Component.onCompleted: refreshState()
    onAdapterChanged: refreshState()

    Connections {
        target: root.adapter
        enabled: root.adapter !== null
        function onStateChanged() {
            root.refreshState();
        }
        function onDiscoveringChanged() {
            root.refreshState();
        }
    }

    Timer {
        id: actionTimeout
        interval: 5000
        onTriggered: {
            if (root.state === "busy" && root.adapter && !root.adapter.discovering) {
                root.state = "error";
                root.errorCode = "BLUEZ_CONFIRMATION_TIMEOUT";
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Networking

Scope {
    id: root

    property string state: "unknown"
    property string errorCode: ""
    property var pendingWifi: null
    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(function (device) {
        return device.type === DeviceType.Wifi;
    }) || null
    readonly property var wiredDevice: devices.find(function (device) {
        return device.type === DeviceType.Wired;
    }) || null
    readonly property var wifiNetworks: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
    readonly property var wifiEnabled: state === "ready" || state === "warning" ? Networking.wifiEnabled : null
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property string address: wifiDevice && wifiDevice.address ? wifiDevice.address : wiredDevice && wiredDevice.address ? wiredDevice.address : "UNASSIGNED"
    readonly property bool ethernetLinked: wiredDevice ? wiredDevice.connected : false
    readonly property int ethernetSpeed: wiredDevice && wiredDevice.linkSpeed ? wiredDevice.linkSpeed : 0
    readonly property string connectivity: NetworkConnectivity.toString(Networking.connectivity).toUpperCase()
    readonly property string label: state === "ready" ? connectivity : state === "busy" ? "LOADING" : state.toUpperCase()

    function refreshState() {
        if (Networking.backend === NetworkBackendType.None) {
            state = "unavailable";
            errorCode = "NETWORKMANAGER_BACKEND_ABSENT";
        } else if (Networking.backend !== NetworkBackendType.NetworkManager) {
            state = "error";
            errorCode = "NETWORKMANAGER_BACKEND_INVALID";
        } else if (Networking.connectivity === NetworkConnectivity.Unknown) {
            state = "busy";
            errorCode = "";
        } else {
            state = Networking.connectivity === NetworkConnectivity.Limited || Networking.connectivity === NetworkConnectivity.Portal ? "warning" : "ready";
            errorCode = "";
        }
        if (pendingWifi !== null && Networking.wifiEnabled === pendingWifi) {
            pendingWifi = null;
            actionTimeout.stop();
        }
    }

    function setWifiEnabled(enabled) {
        if (state !== "ready" && state !== "warning")
            return;
        pendingWifi = enabled;
        state = "busy";
        Networking.wifiEnabled = enabled;
        actionTimeout.restart();
    }

    Component.onCompleted: refreshState()

    Connections {
        target: Networking
        function onConnectivityChanged() {
            root.refreshState();
        }
        function onWifiEnabledChanged() {
            root.refreshState();
        }
    }

    Timer {
        id: actionTimeout
        interval: 5000
        onTriggered: {
            if (root.pendingWifi !== null) {
                root.pendingWifi = null;
                root.state = "error";
                root.errorCode = "WIFI_CONFIRMATION_TIMEOUT";
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Services" as Services
import "Surfaces" as Surfaces

ShellRoot {
    id: root

    property string activeSurface: ""
    property bool incidentsVisible: false
    property int wallpaperRevision: 0

    function toggleSurface(name) {
        activeSurface = activeSurface === name ? "" : name;
    }

    function closePrimarySurface() {
        activeSurface = "";
    }

    function isFocusedScreen(screen) {
        return niriService.focusedOutput.length === 0 || screen.name === niriService.focusedOutput;
    }

    function launch(command) {
        var arguments = Array.isArray(command) ? command : [command];
        launchProcess.exec([runtime.app2unit, "--"].concat(arguments));
        activeSurface = "";
    }

    Tokens {
        id: tokens
    }
    Runtime {
        id: runtime
    }

    Services.NiriService {
        id: niriService
        runtime: runtime
    }
    Services.SystemService {
        id: systemService
        runtime: runtime
    }
    Services.NetworkService {
        id: networkService
    }
    Services.BluetoothService {
        id: bluetoothService
    }
    Services.AudioService {
        id: audioService
    }
    Services.PowerService {
        id: powerService
        runtime: runtime
    }
    Services.MediaService {
        id: mediaService
    }
    Services.IncidentService {
        id: incidentService
        runtime: runtime
    }

    IpcHandler {
        target: "nerv"

        function toggleQuickView(): void {
            root.toggleSurface("quickView");
        }
        function toggleQuickToggles(): void {
            root.toggleSurface("quickToggles");
        }
        function toggleMaintenance(): void {
            root.toggleSurface("maintenance");
        }
        function toggleLauncher(): void {
            root.toggleSurface("launcher");
        }
        function toggleIncidents(): void {
            root.incidentsVisible = !root.incidentsVisible;
        }
        function closePrimary(): void {
            root.closePrimarySurface();
        }
        function toggleTransparency(): void {
            tokens.reducedTransparency = !tokens.reducedTransparency;
        }
        function reloadWallpaper(): void {
            root.wallpaperRevision += 1;
        }
        function status(): string {
            return JSON.stringify({
                "niri": niriService.state,
                "cpu": systemService.cpuState,
                "memory": systemService.memoryState,
                "thermal": systemService.temperatureState,
                "networkManager": networkService.state,
                "wifiNetworks": networkService.wifiNetworks.length,
                "bluez": bluetoothService.state,
                "bluetoothDevices": bluetoothService.devices.length,
                "pipewire": audioService.state,
                "upower": powerService.state,
                "batteryPercent": powerService.percentage,
                "batteryCount": powerService.batteryCount,
                "batterySummary": powerService.batterySummary,
                "batteryHealthPercent": powerService.healthPercent,
                "brightness": powerService.brightnessState,
                "mpris": mediaService.state,
                "incidents": incidentService.state,
                "incidentCount": incidentService.incidents.length,
                "reducedMotion": tokens.reducedMotion,
                "reducedTransparency": tokens.reducedTransparency
            });
        }
    }

    Process {
        id: launchProcess
    }

    // The personal wallpaper is an ignored local override. Watch it directly
    // so replacing the PNG invalidates Qt's decoded-image cache without a
    // Home Manager rebuild or a full shell reload.
    FileView {
        path: runtime.wallpaperPath
        watchChanges: true
        preload: false
        printErrors: false
        onFileChanged: root.wallpaperRevision += 1
    }

    // Wallpaper and registration surfaces are click-through and sit beneath
    // niri's actual windows. No production QML draws managed-window replicas.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            mask: Region {}
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-background"

            Surfaces.Background {
                anchors.fill: parent
                tokens: tokens
                wallpaperSource: runtime.wallpaper + "?revision=" + root.wallpaperRevision
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: spineWindow
            required property var modelData

            screen: modelData
            anchors {
                top: true
                bottom: true
                left: true
            }
            implicitWidth: tokens.spineWidth
            exclusiveZone: tokens.spineWidth
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "nerv-spine"

            Surfaces.Spine {
                anchors.fill: parent
                tokens: tokens
                niri: niriService
                system: systemService
                network: networkService
                power: powerService
                outputWorkspaces: niriService.workspaces.filter(function (workspace) {
                    return workspace.output === spineWindow.modelData.name;
                })
                onQuickViewRequested: root.toggleSurface("quickView")
                onQuickTogglesRequested: root.toggleSurface("quickToggles")
                onMaintenanceRequested: root.toggleSurface("maintenance")
                onLauncherRequested: root.toggleSurface("launcher")
                onWorkspaceRequested: function (index) {
                    niriService.focusWorkspace(index);
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: quickViewWindow
            required property var modelData

            screen: modelData
            visible: root.activeSurface === "quickView" && root.isFocusedScreen(modelData)
            anchors {
                top: true
                bottom: true
                left: true
            }
            margins {
                top: 18
                bottom: 18
                left: tokens.spineWidth + tokens.space12
            }
            implicitWidth: Math.min(860, modelData.width - tokens.spineWidth - 30)
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-quick-view"
            onVisibleChanged: {
                if (visible)
                    quickView.requestFocus();
            }

            Surfaces.QuickView {
                id: quickView
                anchors.fill: parent
                tokens: tokens
                system: systemService
                media: mediaService
                onCloseRequested: root.closePrimarySurface()
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.activeSurface === "quickToggles" && root.isFocusedScreen(modelData)
            anchors {
                top: true
                bottom: true
                left: true
            }
            margins {
                top: 18
                bottom: 18
                left: tokens.spineWidth + tokens.space12
            }
            implicitWidth: 420
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-quick-toggles"
            onVisibleChanged: {
                if (visible)
                    quickToggles.requestFocus();
            }

            Surfaces.QuickToggles {
                id: quickToggles
                anchors.fill: parent
                tokens: tokens
                network: networkService
                bluetooth: bluetoothService
                audio: audioService
                power: powerService
                onCloseRequested: root.closePrimarySurface()
                onMaintenanceRequested: root.toggleSurface("maintenance")
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.activeSurface === "maintenance" && root.isFocusedScreen(modelData)
            anchors {
                top: true
                bottom: true
                left: true
            }
            margins {
                top: 18
                bottom: 18
                left: tokens.spineWidth + tokens.space12
            }
            implicitWidth: Math.min(820, modelData.width - tokens.spineWidth - 30)
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-maintenance"
            onVisibleChanged: {
                if (visible)
                    maintenance.requestFocus();
            }

            Surfaces.MaintenanceBay {
                id: maintenance
                anchors.fill: parent
                tokens: tokens
                niri: niriService
                system: systemService
                network: networkService
                bluetooth: bluetoothService
                audio: audioService
                power: powerService
                media: mediaService
                onCloseRequested: root.closePrimarySurface()
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.activeSurface === "launcher" && root.isFocusedScreen(modelData)
            anchors {
                top: true
                bottom: true
                left: true
            }
            margins {
                top: 94
                bottom: 112
                left: tokens.spineWidth + Math.round((modelData.width - tokens.spineWidth) * 0.24) - 22
            }
            implicitWidth: Math.min(570, modelData.width - margins.left - 20)
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-insertion-gate"
            onVisibleChanged: {
                if (visible)
                    launcher.requestFocus();
            }

            Surfaces.Launcher {
                id: launcher
                anchors.fill: parent
                tokens: tokens
                targets: runtime.launchTargets
                applications: DesktopEntries.applications.values
                onCloseRequested: root.closePrimarySurface()
                onLaunchRequested: function (command) {
                    root.launch(command);
                }
            }
        }
    }

    // Incident history is independent from the mutually-exclusive primary
    // overlays and stays registered to the physical upper-right screen edge.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.incidentsVisible && root.isFocusedScreen(modelData)
            anchors {
                top: true
                bottom: true
                right: true
            }
            margins {
                top: 18
                right: 18
                bottom: 18
            }
            implicitWidth: 420
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nerv-incidents"
            onVisibleChanged: {
                if (visible)
                    incidents.requestFocus();
            }

            Surfaces.IncidentEchelon {
                id: incidents
                anchors.fill: parent
                tokens: tokens
                incidents: incidentService
                onCloseRequested: root.incidentsVisible = false
            }
        }
    }
}

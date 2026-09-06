import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components

FocusScope {
    id: root
    required property var tokens
    required property var niri
    required property var system
    required property var network
    required property var bluetooth
    required property var audio
    required property var power
    required property var media
    property int category: 0
    signal closeRequested

    function requestFocus() {
        closeButton.forceActiveFocus();
    }
    Keys.onEscapePressed: closeRequested()

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialDenseColor
        strokeWidth: 2
        strokeColor: root.tokens.signalRed
        profile: "dogleg"
        cutSmall: root.tokens.cutSmall
        cutMedium: root.tokens.cutMedium
        cutLarge: root.tokens.cutLarge
    }

    Components.Chassis {
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width - root.tokens.cutMedium
        height: 64
        fillColor: root.tokens.signalRed
        profile: "header"
        cutSmall: root.tokens.cutSmall
        cutMedium: root.tokens.cutMedium
        cutLarge: root.tokens.cutLarge

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 18
            color: root.tokens.signalRedDeep
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 34
        anchors.rightMargin: root.tokens.space16
        anchors.topMargin: 10
        anchors.bottomMargin: root.tokens.space16
        spacing: root.tokens.space12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary
            ColumnLayout {
                Layout.fillWidth: true
                Components.EvidenceLabel {
                    tokens: root.tokens
                    color: root.tokens.inkColor
                    text: "MAINTENANCE BAY / AUTHORITATIVE SERVICE LEDGER"
                }
                Text {
                    color: root.tokens.inkColor
                    text: "SYSTEM AUTHORITY MAP"
                    font.family: root.tokens.displayFont
                    font.pixelSize: 25
                    font.weight: Font.DemiBold
                }
            }
            Components.ActionButton {
                id: closeButton
                tokens: root.tokens
                text: "CLOSE"
                evidence: "ESC"
                implicitWidth: 82
                onClicked: root.closeRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.tokens.space12

            ColumnLayout {
                Layout.preferredWidth: 142
                Layout.fillHeight: true
                spacing: root.tokens.space4
                Repeater {
                    model: [
                        {
                            label: "NETWORK",
                            code: "01 / NM"
                        },
                        {
                            label: "BLUETOOTH",
                            code: "02 / BZ"
                        },
                        {
                            label: "ETHERNET",
                            code: "03 / ETH"
                        },
                        {
                            label: "AUDIO",
                            code: "04 / PW"
                        },
                        {
                            label: "POWER",
                            code: "05 / UP"
                        },
                        {
                            label: "SYSTEM",
                            code: "06 / NIX"
                        }
                    ]
                    delegate: Components.CategoryButton {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        tokens: root.tokens
                        text: modelData.label
                        code: modelData.code
                        selected: root.category === index
                        onClicked: root.category = index
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
                Components.StateIndicator {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    state: root.niri.state
                    label: "NIRI FIELD"
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: root.tokens.signalOrange
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.category

                ScrollView {
                    clip: true
                    contentWidth: availableWidth
                    ColumnLayout {
                        width: parent.width
                        spacing: root.tokens.space8
                        Components.EvidenceLabel {
                            text: "NETWORK AUTHORITY / LIVE ACCESS POINT EVIDENCE"
                            tokens: root.tokens
                        }
                        Components.DiagnosticRow {
                            Layout.fillWidth: true
                            tokens: root.tokens
                            title: "NetworkManager"
                            detail: root.network.address + " / WIFI " + (root.network.wifiEnabled ? "ON" : "OFF")
                            state: root.network.state
                            value: root.network.connectivity
                        }
                        Repeater {
                            model: root.network.wifiNetworks.slice(0, 10)
                            delegate: Components.DiagnosticRow {
                                required property var modelData
                                Layout.fillWidth: true
                                tokens: root.tokens
                                title: modelData.name || "HIDDEN NETWORK"
                                detail: (modelData.known ? "KNOWN" : "UNSAVED") + " / SIGNAL " + (modelData.signalStrength || 0) + "%"
                                state: modelData.connected ? root.tokens.stateReady : root.tokens.stateUnknown
                                value: modelData.connected ? "CONNECTED" : "AVAILABLE"
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: root.network.wifiNetworks.length === 0
                            color: root.tokens.mutedColor
                            text: "NO ACCESS POINTS REPORTED / SCANNER MAY BE IDLE"
                            font.family: root.tokens.monoFont
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                    }
                }

                ScrollView {
                    clip: true
                    contentWidth: availableWidth
                    ColumnLayout {
                        width: parent.width
                        spacing: root.tokens.space8
                        Components.EvidenceLabel {
                            text: "BLUEZ AUTHORITY / PAIRED AND DISCOVERED DEVICES"
                            tokens: root.tokens
                        }
                        Components.ToggleRow {
                            Layout.fillWidth: true
                            tokens: root.tokens
                            title: "Discovery sweep"
                            detail: root.bluetooth.adapter ? root.bluetooth.adapter.name : "NO ADAPTER"
                            state: root.bluetooth.state
                            checkedState: root.bluetooth.adapter ? root.bluetooth.adapter.discovering : null
                            enabled: root.bluetooth.enabled === true
                            onClicked: root.bluetooth.setDiscovering(!root.bluetooth.adapter.discovering)
                        }
                        Repeater {
                            model: root.bluetooth.devices
                            delegate: Components.ToggleRow {
                                required property var modelData
                                Layout.fillWidth: true
                                tokens: root.tokens
                                title: modelData.name || modelData.deviceName || modelData.address
                                detail: (modelData.paired ? "PAIRED" : "UNPAIRED") + (modelData.batteryAvailable ? " / BAT " + Math.round(modelData.battery * 100) + "%" : "")
                                state: modelData.pairing ? root.tokens.stateBusy : root.tokens.stateReady
                                checkedState: modelData.connected
                                value: modelData.connected ? "CONNECTED" : "DISCONNECTED"
                                enabled: modelData.paired
                                onClicked: root.bluetooth.setDeviceConnected(modelData, !modelData.connected)
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: root.bluetooth.devices.length === 0
                            color: root.tokens.mutedColor
                            text: "NO BLUEZ DEVICES REPORTED"
                            font.family: root.tokens.monoFont
                            font.pixelSize: 10
                        }
                    }
                }

                ColumnLayout {
                    spacing: root.tokens.space8
                    Components.EvidenceLabel {
                        text: "ETHERNET LINK / NON-ERROR ABSENCE"
                        tokens: root.tokens
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: root.network.wiredDevice ? root.network.wiredDevice.name : "Ethernet adapter"
                        detail: root.network.wiredDevice ? root.network.wiredDevice.address : "NO WIRED DEVICE PRESENT"
                        state: root.network.wiredDevice ? root.tokens.stateReady : root.tokens.stateUnavailable
                        value: root.network.ethernetLinked ? root.network.ethernetSpeed + " MB/S" : "UNPLUGGED"
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                ColumnLayout {
                    spacing: root.tokens.space8
                    Components.EvidenceLabel {
                        text: "PIPEWIRE ROUTING / PRIVACY AUTHORITY"
                        tokens: root.tokens
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Default output"
                        detail: root.audio.sinkName
                        state: root.audio.state
                        value: root.audio.volumePercent + "%"
                    }
                    Components.ToggleRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Output mute"
                        detail: root.audio.sinkName
                        state: root.audio.state
                        checkedState: root.audio.muted
                        value: root.audio.muted ? "MUTED" : "LIVE"
                        onClicked: root.audio.setMuted(!root.audio.muted)
                    }
                    Components.ToggleRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Microphone seal"
                        detail: root.audio.sourceName
                        state: root.audio.state
                        checkedState: root.audio.microphoneMuted
                        value: root.audio.microphoneMuted ? "SEALED" : "PRIVACY LIVE"
                        accent: root.audio.microphoneMuted ? root.tokens.signalOrange : root.tokens.signalRed
                        onClicked: root.audio.setMicrophoneMuted(!root.audio.microphoneMuted)
                    }
                    Components.MagiVote {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        approved: root.audio.microphoneMuted === true
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                ColumnLayout {
                    spacing: root.tokens.space8
                    Components.EvidenceLabel {
                        text: "POWER / BRIGHTNESS / SESSION INHIBITION"
                        tokens: root.tokens
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "UPower display device"
                        detail: root.power.onBattery ? "AGGREGATE / " + root.power.secondsRemaining + " SEC REMAIN" : "AGGREGATE / EXTERNAL POWER"
                        state: root.power.state
                        value: root.power.label
                    }
                    Repeater {
                        model: root.power.batteries
                        delegate: Components.DiagnosticRow {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            tokens: root.tokens
                            title: index === 0 ? "Internal battery / " + modelData.nativePath : "Backup battery / " + modelData.nativePath
                            detail: (modelData.model || "MODEL UNAVAILABLE") + (modelData.healthSupported ? " / HEALTH " + root.power.batteryHealth(modelData) + "%" : " / HEALTH UNAVAILABLE")
                            state: modelData.ready ? root.tokens.stateReady : root.tokens.stateBusy
                            value: root.power.batteryPercentage(modelData) + "%"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Components.EvidenceLabel {
                            Layout.fillWidth: true
                            tokens: root.tokens
                            text: "PANEL BRIGHTNESS"
                        }
                        Text {
                            color: root.tokens.boneColor
                            text: root.power.brightnessPercent + "%"
                            font.family: root.tokens.displayFont
                            font.pixelSize: 22
                        }
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 100
                        value: root.power.brightnessPercent
                        enabled: root.power.brightnessState === root.tokens.stateReady
                        onPressedChanged: {
                            if (!pressed)
                                root.power.setBrightness(value);
                        }
                        Accessible.name: "Display brightness"
                    }
                    Components.ToggleRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Keep awake"
                        detail: "SESSION IDLE INHIBITOR"
                        state: root.power.inhibitorState
                        checkedState: root.power.keepAwake
                        onClicked: root.power.setKeepAwake(!root.power.keepAwake)
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                ColumnLayout {
                    spacing: root.tokens.space8
                    Components.EvidenceLabel {
                        text: "IMMUTABLE NIXOS EVIDENCE / READ ONLY"
                        tokens: root.tokens
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Host"
                        detail: root.system.kernel
                        state: root.tokens.stateReady
                        value: root.system.hostname
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "System generation"
                        detail: "/RUN/CURRENT-SYSTEM"
                        state: root.tokens.stateReady
                        value: root.system.generation
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "Uptime"
                        detail: "PROCFS MONOTONIC EVIDENCE"
                        state: root.tokens.stateReady
                        value: root.system.formatUptime()
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "niri field"
                        detail: "WORKSPACES " + root.niri.workspaces.length + " / COLUMNS " + root.niri.columnCount + " / STACK " + root.niri.stackCount
                        state: root.niri.state
                        value: root.niri.focusedApp
                    }
                    Components.DiagnosticRow {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        title: "MPRIS"
                        detail: root.media.hasPlayer ? root.media.title : "NO PLAYER IS A VALID READY STATE"
                        state: root.media.state
                        value: root.media.hasPlayer ? root.media.identity : "READY / IDLE"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        color: root.tokens.signalRed
                        Text {
                            anchors.fill: parent
                            anchors.margins: root.tokens.space12
                            color: root.tokens.inkColor
                            text: "PERSISTENT POLICY OWNER\n/HOME/AYAM/NIX\nRUNTIME SURFACES DO NOT MUTATE DECLARATIVE POLICY"
                            font.family: root.tokens.monoFont
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}

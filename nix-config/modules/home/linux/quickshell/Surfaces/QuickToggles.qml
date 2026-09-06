import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components

FocusScope {
    id: root
    required property var tokens
    required property var network
    required property var bluetooth
    required property var audio
    required property var power
    signal closeRequested
    signal maintenanceRequested

    function requestFocus() {
        closeButton.forceActiveFocus();
    }
    Keys.onEscapePressed: closeRequested()

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialPrimaryColor
        strokeWidth: 2
        strokeColor: root.tokens.signalRed
        profile: "toggles"
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
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space16
        anchors.topMargin: 10
        spacing: root.tokens.space4

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary
            ColumnLayout {
                Layout.fillWidth: true
                Components.EvidenceLabel {
                    tokens: root.tokens
                    color: root.tokens.inkColor
                    text: "QUICK TOGGLES / AUTHORITATIVE GATES"
                }
                Text {
                    color: root.tokens.inkColor
                    text: "MAGI SERVICE CONTROL"
                    font.family: root.tokens.displayFont
                    font.pixelSize: 23
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 116
            color: root.tokens.surfaceRaisedColor
            Components.MagiVote {
                anchors.fill: parent
                anchors.margins: root.tokens.space8
                tokens: root.tokens
                approved: root.audio.microphoneMuted !== null
            }
        }

        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Wi-Fi radio"
            detail: root.network.address + " / " + root.network.connectivity
            state: root.network.state
            checkedState: root.network.wifiEnabled
            enabled: root.network.wifiEnabled !== null && root.network.wifiHardwareEnabled
            onClicked: root.network.setWifiEnabled(!root.network.wifiEnabled)
        }
        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Bluetooth radio"
            detail: root.bluetooth.pairedCount + " PAIRED / " + root.bluetooth.connectedCount + " CONNECTED"
            state: root.bluetooth.state
            checkedState: root.bluetooth.enabled
            enabled: root.bluetooth.enabled !== null
            onClicked: root.bluetooth.setEnabled(!root.bluetooth.enabled)
        }
        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Output mute"
            detail: root.audio.sinkName
            state: root.audio.state
            checkedState: root.audio.muted
            value: root.audio.muted === null ? root.audio.state.toUpperCase() : root.audio.muted ? "MUTED" : "LIVE"
            enabled: root.audio.muted !== null
            onClicked: root.audio.setMuted(!root.audio.muted)
        }
        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Microphone privacy"
            detail: root.audio.sourceName
            state: root.audio.state
            checkedState: root.audio.microphoneMuted
            value: root.audio.microphoneMuted === null ? root.audio.state.toUpperCase() : root.audio.microphoneMuted ? "SEALED" : "LIVE"
            accent: root.audio.microphoneMuted === false ? root.tokens.signalRed : root.tokens.signalOrange
            enabled: root.audio.microphoneMuted !== null
            onClicked: root.audio.setMicrophoneMuted(!root.audio.microphoneMuted)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.tokens.space4
            RowLayout {
                Layout.fillWidth: true
                Components.EvidenceLabel {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    text: "OUTPUT GAIN / AUTHORITATIVE PIPEWIRE"
                }
                Text {
                    color: root.tokens.boneColor
                    text: root.audio.volumePercent + "%"
                    font.family: root.tokens.displayFont
                    font.pixelSize: 20
                }
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 2
                value: root.audio.volumePercent
                enabled: root.audio.state === root.tokens.stateReady
                onPressedChanged: {
                    if (!pressed)
                        root.audio.setVolumePercent(value);
                }
                Accessible.name: "Output volume"
            }
        }

        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Keep awake"
            detail: "SYSTEMD IDLE INHIBITOR / SESSION ONLY"
            state: root.power.inhibitorState
            checkedState: root.power.keepAwake
            onClicked: root.power.setKeepAwake(!root.power.keepAwake)
        }
        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Material / trans"
            detail: root.tokens.reducedTransparency ? "SOLID WARM UMBER / BLUR-INDEPENDENT" : "HIGH / SMOKED AMBER POLYCARBONATE"
            state: root.tokens.stateReady
            checkedState: !root.tokens.reducedTransparency
            value: root.tokens.reducedTransparency ? "SOLID" : "HIGH"
            accent: root.tokens.signalOrange
            onClicked: root.tokens.reducedTransparency = !root.tokens.reducedTransparency
        }
        Item {
            Layout.fillHeight: true
        }
        Components.ActionButton {
            Layout.fillWidth: true
            tokens: root.tokens
            text: "OPEN MAINTENANCE BAY"
            evidence: "DEVICE AND SYSTEM LEDGER"
            accent: root.tokens.signalRed
            onClicked: root.maintenanceRequested()
        }
    }
}

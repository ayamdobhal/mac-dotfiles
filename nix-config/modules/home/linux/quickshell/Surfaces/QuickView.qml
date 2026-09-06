import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components
import "../Widgets" as Widgets

FocusScope {
    id: root

    required property var tokens
    required property var system
    required property var media
    signal closeRequested

    function requestFocus() {
        closeButton.forceActiveFocus();
    }

    Keys.onEscapePressed: closeRequested()

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialPrimaryColor
        strokeWidth: 2
        strokeColor: root.tokens.signalRed
        profile: "quickView"
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
        anchors.leftMargin: root.tokens.space24
        anchors.rightMargin: root.tokens.space24 + root.tokens.cutLarge
        anchors.topMargin: 10
        anchors.bottomMargin: root.tokens.space32
        spacing: root.tokens.space12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Components.EvidenceLabel {
                    tokens: root.tokens
                    color: root.tokens.inkColor
                    text: "QUICK VIEW / CHRONO ENVIRONMENT SIDECAR"
                }
                Text {
                    color: root.tokens.inkColor
                    text: "SYNCHROGRAPH OVERVIEW"
                    font.family: root.tokens.displayFont
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                }
            }

            Components.ActionButton {
                id: closeButton
                tokens: root.tokens
                text: "CLOSE"
                evidence: "ESC"
                accent: root.tokens.inkColor
                implicitWidth: 82
                onClicked: root.closeRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.tokens.space12

            Rectangle {
                Layout.preferredWidth: 315
                Layout.fillHeight: true
                color: root.tokens.materialSecondaryColor
                border.width: 1
                border.color: root.tokens.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.tokens.space16
                    spacing: root.tokens.space8

                    Components.EvidenceLabel {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        text: root.system.dayOfWeek + " / LOCAL DATE"
                    }
                    Text {
                        Layout.fillWidth: true
                        color: root.tokens.boneColor
                        text: root.system.dayNumber
                        font.family: root.tokens.displayFont
                        font.pixelSize: 92
                        font.weight: Font.DemiBold
                        lineHeight: 0.82
                    }
                    Text {
                        Layout.fillWidth: true
                        color: root.tokens.signalOrange
                        text: root.system.monthYear
                        font.family: root.tokens.displayFont
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.fillWidth: true
                        color: root.tokens.boneColor
                        text: root.system.timeWithSeconds + "  IST"
                        font.family: root.tokens.displayFont
                        font.pixelSize: 29
                        font.weight: Font.DemiBold
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: root.tokens.signalOrange
                    }
                    Widgets.CalendarGrid {
                        Layout.fillWidth: true
                        tokens: root.tokens
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                    Components.EvidenceLabel {
                        Layout.fillWidth: true
                        tokens: root.tokens
                        text: root.system.hostname + " / " + root.system.formatUptime()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.tokens.space8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 82
                    color: root.tokens.materialEvidenceColor
                    border.width: 1
                    border.color: root.tokens.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.tokens.space12

                        Components.StateIndicator {
                            Layout.fillWidth: true
                            tokens: root.tokens
                            state: root.tokens.stateUnavailable
                            label: "ENVIRONMENT / PROVIDER NOT CONFIGURED"
                        }
                        Text {
                            color: root.tokens.mutedColor
                            text: "NO CONDITION\nINVENTED"
                            horizontalAlignment: Text.AlignRight
                            font.family: root.tokens.monoFont
                            font.pixelSize: 8
                        }
                    }
                }

                Widgets.TelemetryTrace {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    label: "CPU / PROCFS DELTA"
                    value: root.system.cpuPercent
                    state: root.system.cpuState
                    history: root.system.cpuHistory
                    traceColor: root.tokens.recoveryCobalt
                }
                Widgets.TelemetryTrace {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    label: "MEMORY / MEMAVAILABLE"
                    value: root.system.memoryPercent
                    state: root.system.memoryState
                    history: root.system.memoryHistory
                    traceColor: root.tokens.identityPurple
                }
                Widgets.TelemetryTrace {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    label: "THERMAL / FIRST VALID SENSOR"
                    value: root.system.temperatureCelsius
                    state: root.system.temperatureState
                    history: root.system.temperatureHistory
                    maximum: 110
                    suffix: "°C"
                    traceColor: root.tokens.signalOrange
                }
                Widgets.MediaDeck {
                    Layout.fillWidth: true
                    tokens: root.tokens
                    media: root.media
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components

FocusScope {
    id: root
    required property var tokens
    required property var incidents
    property string filter: "all"
    readonly property var filtered: incidents.incidents.filter(function (item) {
        return filter === "all" || filter === "critical" && item.urgency === "critical" || filter === "active" && item.active;
    })
    signal closeRequested

    function requestFocus() {
        closeButton.forceActiveFocus();
    }
    Keys.onEscapePressed: closeRequested()

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialPrimaryColor
        strokeWidth: 2
        strokeColor: root.tokens.signalOrange
        profile: "history"
        cutSmall: root.tokens.cutSmall
        cutMedium: root.tokens.cutMedium
        cutLarge: root.tokens.cutLarge
    }
    Components.Chassis {
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
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
        spacing: root.tokens.space8
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary
            ColumnLayout {
                Layout.fillWidth: true
                Components.EvidenceLabel {
                    tokens: root.tokens
                    color: root.tokens.inkColor
                    text: "INCIDENT ECHELON / MAKO HISTORY ADAPTER"
                }
                Text {
                    color: root.tokens.inkColor
                    text: "INCIDENT LOG / " + root.filtered.length
                    font.family: root.tokens.displayFont
                    font.pixelSize: 21
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
        Components.ToggleRow {
            Layout.fillWidth: true
            tokens: root.tokens
            title: "Do not disturb"
            detail: "LOW + NORMAL ROUTE TO MAKO HISTORY / CRITICAL REMAINS VISIBLE"
            state: root.incidents.state
            checkedState: root.incidents.doNotDisturb
            onClicked: root.incidents.setDoNotDisturb(!root.incidents.doNotDisturb)
        }
        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: [
                    {
                        label: "ALL",
                        value: "all"
                    },
                    {
                        label: "CRITICAL",
                        value: "critical"
                    },
                    {
                        label: "ACTIVE",
                        value: "active"
                    }
                ]
                delegate: Components.ActionButton {
                    required property var modelData
                    Layout.fillWidth: true
                    tokens: root.tokens
                    text: modelData.label
                    accent: root.filter === modelData.value ? root.tokens.signalRed : root.tokens.borderColor
                    onClicked: root.filter = modelData.value
                }
            }
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: root.tokens.space8
            model: root.filtered
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 88
                color: root.tokens.materialNoticeColor
                border.width: 1
                border.color: modelData.urgency === "critical" ? root.tokens.signalRed : root.tokens.borderColor
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: root.tokens.space12
                    Rectangle {
                        Layout.preferredWidth: 5
                        Layout.fillHeight: true
                        color: modelData.urgency === "critical" ? root.tokens.signalRed : modelData.active ? root.tokens.signalOrange : root.tokens.recoveryCobalt
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Components.EvidenceLabel {
                            tokens: root.tokens
                            text: modelData.appName + " / " + modelData.urgency + (modelData.active ? " / ACTIVE" : " / HISTORY")
                        }
                        Text {
                            Layout.fillWidth: true
                            color: root.tokens.boneColor
                            text: modelData.summary
                            font.family: root.tokens.displayFont
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            color: root.tokens.mutedColor
                            text: modelData.body
                            font.family: root.tokens.monoFont
                            font.pixelSize: 8
                            elide: Text.ElideRight
                        }
                    }
                    Components.ActionButton {
                        visible: modelData.active
                        tokens: root.tokens
                        text: "DISMISS"
                        implicitWidth: 84
                        onClicked: root.incidents.dismiss(modelData.id)
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            visible: root.filtered.length === 0
            color: root.tokens.mutedColor
            text: "NO INCIDENTS IN SELECTED CHANNEL"
            horizontalAlignment: Text.AlignHCenter
            font.family: root.tokens.monoFont
            font.pixelSize: 10
        }
        Components.EvidenceLabel {
            Layout.fillWidth: true
            tokens: root.tokens
            text: "POPUP OWNER / MAKO / PHYSICAL UPPER-RIGHT / FALLBACK RETAINED"
        }
    }
}

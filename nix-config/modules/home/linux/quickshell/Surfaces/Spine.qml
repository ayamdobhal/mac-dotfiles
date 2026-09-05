import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components

Item {
    id: root

    required property var tokens
    required property var niri
    required property var system
    required property var network
    required property var power
    property var outputWorkspaces: []

    signal quickViewRequested
    signal quickTogglesRequested
    signal maintenanceRequested
    signal launcherRequested
    signal workspaceRequested(int index)

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialSpineColor
        profile: "rect"
        cutSmall: root.tokens.cutSmall
        cutMedium: root.tokens.cutMedium
        cutLarge: root.tokens.cutLarge

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 6
            color: root.tokens.signalRed
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 6
        spacing: 0

        Button {
            id: identityButton
            Layout.fillWidth: true
            Layout.preferredHeight: 78
            hoverEnabled: true
            onClicked: root.quickViewRequested()
            Accessible.name: "Open Quick View"

            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.tokens.boneColor
                    text: "NIXOS"
                    font.family: root.tokens.identityFont
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.tokens.signalOrange
                    text: "MAGI / 01"
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                }
            }

            background: Rectangle {
                color: identityButton.down ? root.tokens.signalRedDeep : root.tokens.signalRed
                border.width: identityButton.activeFocus ? 2 : 0
                border.color: root.tokens.hazardYellow
                radius: 0
            }
        }

        Components.StateIndicator {
            Layout.fillWidth: true
            Layout.leftMargin: root.tokens.space8
            Layout.rightMargin: root.tokens.space8
            Layout.topMargin: root.tokens.space8
            Layout.bottomMargin: root.tokens.space4
            tokens: root.tokens
            state: root.niri.state
            label: root.niri.state === root.tokens.stateBusy ? "NIRI LOADING" : "NIRI " + root.niri.state.toUpperCase()
        }

        ListView {
            id: workspaceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 88
            clip: true
            model: root.outputWorkspaces
            spacing: 3
            boundsBehavior: Flickable.StopAtBounds
            preferredHighlightBegin: height / 2 - 18
            preferredHighlightEnd: height / 2 + 18

            delegate: Components.WorkspaceStation {
                required property var modelData
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                tokens: root.tokens
                workspaceIndex: modelData.idx
                active: modelData.isActive
                urgent: modelData.isUrgent
                onClicked: root.workspaceRequested(workspaceIndex)
            }
        }

        Button {
            id: focusButton
            Layout.fillWidth: true
            Layout.preferredHeight: 74
            hoverEnabled: true
            onClicked: root.launcherRequested()
            Accessible.name: "Open Column Insertion Gate"

            contentItem: Column {
                anchors.fill: parent
                anchors.margins: root.tokens.space8
                spacing: 3

                Text {
                    width: parent.width
                    color: root.tokens.signalOrange
                    text: "FOCUS / APP"
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                }
                Text {
                    width: parent.width
                    color: root.tokens.boneColor
                    text: root.niri.focusedApp.toUpperCase()
                    font.family: root.tokens.displayFont
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    color: root.tokens.mutedColor
                    text: "C" + String(root.niri.columnIndex).padStart(2, "0") + "/" + String(root.niri.columnCount).padStart(2, "0") + " S" + String(root.niri.stackIndex).padStart(2, "0") + "/" + String(root.niri.stackCount).padStart(2, "0")
                    font.family: root.tokens.monoFont
                    font.pixelSize: 9
                }
            }

            background: Rectangle {
                color: focusButton.hovered ? root.tokens.surfaceRaisedColor : root.tokens.surfaceColor
                border.width: focusButton.activeFocus ? 2 : 1
                border.color: focusButton.activeFocus ? root.tokens.hazardYellow : root.tokens.borderColor
                radius: 0
            }
        }

        Button {
            id: networkButton
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary
            onClicked: root.quickTogglesRequested()
            Accessible.name: "Open Quick Toggles"

            contentItem: Components.StateIndicator {
                anchors.fill: parent
                anchors.margins: root.tokens.space8
                tokens: root.tokens
                state: root.network.state
                label: "NET " + root.network.label
            }
            background: Rectangle {
                color: networkButton.hovered ? root.tokens.surfaceRaisedColor : root.tokens.inkColor
                border.width: networkButton.activeFocus ? 2 : 1
                border.color: networkButton.activeFocus ? root.tokens.hazardYellow : root.tokens.borderColor
                radius: 0
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.tokens.space8
            Layout.rightMargin: root.tokens.space8
            columns: 2
            rowSpacing: 2
            columnSpacing: 4

            Text {
                color: root.tokens.stateColor(root.system.cpuState)
                text: "C " + Math.round(root.system.cpuPercent)
                font.family: root.tokens.monoFont
                font.pixelSize: 9
            }
            Text {
                color: root.tokens.stateColor(root.system.memoryState)
                text: "M " + Math.round(root.system.memoryPercent)
                font.family: root.tokens.monoFont
                font.pixelSize: 9
            }
        }

        Components.StateIndicator {
            Layout.fillWidth: true
            Layout.margins: root.tokens.space8
            tokens: root.tokens
            state: root.power.state
            label: root.power.label
        }

        Button {
            id: timeButton
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            onClicked: root.maintenanceRequested()
            Accessible.name: "Open Maintenance Bay"

            contentItem: Column {
                anchors.centerIn: parent
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.tokens.boneColor
                    text: root.system.time
                    font.family: root.tokens.displayFont
                    font.pixelSize: 25
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.tokens.signalOrange
                    text: root.system.date.toUpperCase()
                    font.family: root.tokens.monoFont
                    font.pixelSize: 9
                }
            }
            background: Rectangle {
                color: timeButton.hovered ? root.tokens.surfaceRaisedColor : root.tokens.inkColor
                border.width: timeButton.activeFocus ? 2 : 0
                border.color: root.tokens.hazardYellow
            }
        }
    }
}

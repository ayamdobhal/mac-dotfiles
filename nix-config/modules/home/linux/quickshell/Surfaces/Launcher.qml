import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components
import "../js/Search.js" as Search

FocusScope {
    id: root
    required property var tokens
    required property var targets
    required property var applications
    property int selectedIndex: 0
    property string insertionMode: "column"
    readonly property var applicationTargets: applications.filter(function (entry) {
        return !entry.noDisplay;
    }).map(function (entry) {
        return {
            label: entry.name,
            detail: (entry.genericName || entry.comment || entry.id) + " / DESKTOP ENTRY",
            kind: "APPLICATION",
            command: entry.command
        };
    })
    readonly property var filteredTargets: Search.filterTargets(targets.concat(applicationTargets), query.text).slice(0, 12)
    signal closeRequested
    signal launchRequested(var command)

    function requestFocus() {
        query.forceActiveFocus();
    }
    function moveSelection(delta) {
        selectedIndex = Math.max(0, Math.min(filteredTargets.length - 1, selectedIndex + delta));
    }
    function launchSelected() {
        if (filteredTargets.length > 0)
            launchRequested(filteredTargets[selectedIndex].command);
    }

    Keys.onEscapePressed: closeRequested()
    Keys.onUpPressed: moveSelection(-1)
    Keys.onDownPressed: moveSelection(1)

    onFilteredTargetsChanged: selectedIndex = 0

    Components.Chassis {
        anchors.fill: parent
        fillColor: root.tokens.materialDenseColor
        strokeWidth: 2
        strokeColor: root.tokens.signalRed
        profile: "spear"
        cutSmall: root.tokens.cutSmall
        cutMedium: root.tokens.cutMedium
        cutLarge: root.tokens.cutLarge
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 16
            color: root.tokens.signalRed
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space24
        anchors.rightMargin: root.tokens.space24 + root.tokens.cutLarge
        spacing: root.tokens.space12
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                Components.EvidenceLabel {
                    tokens: root.tokens
                    text: "COLUMN INSERTION GATE / DESKTOP ENTRY COVERAGE"
                }
                Text {
                    color: root.tokens.boneColor
                    text: "INSERT RIGHT OF FOCUS"
                    font.family: root.tokens.displayFont
                    font.pixelSize: 25
                    font.weight: Font.DemiBold
                }
            }
            Components.ActionButton {
                tokens: root.tokens
                text: "CLOSE"
                evidence: "ESC"
                implicitWidth: 82
                onClicked: root.closeRequested()
            }
        }
        TextField {
            id: query
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.targetPrimary
            placeholderText: "SEARCH APPLICATIONS, FILES, SETTINGS / > COMMANDS"
            color: root.tokens.boneColor
            placeholderTextColor: root.tokens.mutedColor
            selectionColor: root.tokens.signalRed
            selectedTextColor: root.tokens.boneColor
            font.family: root.tokens.monoFont
            font.pixelSize: 11
            onAccepted: root.launchSelected()
            background: Rectangle {
                color: root.tokens.surfaceColor
                border.width: query.activeFocus ? 2 : 1
                border.color: query.activeFocus ? root.tokens.hazardYellow : root.tokens.signalOrange
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Components.ActionButton {
                Layout.fillWidth: true
                tokens: root.tokens
                text: "NEW COLUMN"
                evidence: "SUPPORTED / NIRI DEFAULT"
                accent: root.insertionMode === "column" ? root.tokens.signalRed : root.tokens.borderColor
                onClicked: root.insertionMode = "column"
            }
            Components.ActionButton {
                Layout.fillWidth: true
                tokens: root.tokens
                text: "CURRENT STACK"
                evidence: "UNAVAILABLE / NO SAFE WINDOW TOKEN"
                enabled: false
            }
        }
        ListView {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: root.tokens.space4
            model: root.filteredTargets
            currentIndex: root.selectedIndex
            delegate: Components.ActionButton {
                required property var modelData
                required property int index
                width: ListView.view.width
                tokens: root.tokens
                text: modelData.label
                evidence: (modelData.kind || "APPLICATION") + " / " + modelData.detail
                accent: index === root.selectedIndex ? root.tokens.signalRed : root.tokens.borderColor
                silhouette: index === root.selectedIndex ? "wedgeRight" : "rect"
                onHoveredChanged: {
                    if (hovered)
                        root.selectedIndex = index;
                }
                onClicked: root.launchRequested(modelData.command)
            }
        }
        Text {
            Layout.fillWidth: true
            visible: root.filteredTargets.length === 0
            color: root.tokens.signalOrange
            text: "NO MATCHING INSERTION TARGETS"
            font.family: root.tokens.monoFont
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            color: root.tokens.materialEvidenceColor
            RowLayout {
                anchors.fill: parent
                anchors.margins: root.tokens.space12
                Rectangle {
                    Layout.preferredWidth: 12
                    Layout.preferredHeight: 30
                    color: root.tokens.signalRed
                }
                Text {
                    Layout.fillWidth: true
                    color: root.tokens.mutedColor
                    text: "APP2UNIT → NIRI FOCUSED WORKSPACE → NEW COLUMN\nNO MANAGED WINDOW IS SIMULATED BY THE SHELL"
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                }
            }
        }
        Components.EvidenceLabel {
            Layout.fillWidth: true
            tokens: root.tokens
            text: "FALLBACK / MOD+SHIFT+D / FUZZEL REMAINS AVAILABLE"
        }
    }
}

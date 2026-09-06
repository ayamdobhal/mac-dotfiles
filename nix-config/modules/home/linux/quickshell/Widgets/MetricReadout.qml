import QtQuick
import QtQuick.Layouts
import "../Components" as Components

Rectangle {
    id: root

    required property var tokens
    required property string label
    required property real value
    required property string state
    property string suffix: "%"

    implicitHeight: 76
    color: tokens.materialEvidenceColor
    border.width: 1
    border.color: tokens.borderColor
    radius: 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space12

        ColumnLayout {
            Layout.fillWidth: true

            Components.EvidenceLabel {
                tokens: root.tokens
                text: root.label
            }

            Components.StateIndicator {
                tokens: root.tokens
                state: root.state
            }
        }

        Text {
            color: root.tokens.boneColor
            text: Math.round(root.value) + root.suffix
            font.family: root.tokens.displayFont
            font.pixelSize: 34
            font.weight: Font.DemiBold
        }
    }
}

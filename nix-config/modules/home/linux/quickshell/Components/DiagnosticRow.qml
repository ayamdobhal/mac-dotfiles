import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property var tokens
    required property string title
    required property string detail
    required property string state
    property string value: state.toUpperCase()

    implicitHeight: 62
    color: tokens.materialEvidenceColor
    border.width: 1
    border.color: tokens.borderColor
    radius: 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space12
        spacing: root.tokens.space12

        Rectangle {
            Layout.preferredWidth: 4
            Layout.fillHeight: true
            color: root.tokens.stateColor(root.state)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                Layout.fillWidth: true
                color: root.tokens.boneColor
                text: root.title
                font.family: root.tokens.displayFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                color: root.tokens.mutedColor
                text: root.detail
                font.family: root.tokens.monoFont
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }

        StateIndicator {
            Layout.preferredWidth: 118
            tokens: root.tokens
            state: root.state
            label: root.value
        }
    }
}

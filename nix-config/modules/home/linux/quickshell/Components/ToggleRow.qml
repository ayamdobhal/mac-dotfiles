import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    required property var tokens
    required property string title
    required property string detail
    required property string state
    property var checkedState: null
    property string value: checkedState === null ? state.toUpperCase() : checkedState ? "ENABLED" : "DISABLED"
    property color accent: tokens.signalOrange

    implicitHeight: 68
    hoverEnabled: true
    Accessible.name: title + ", " + value

    contentItem: RowLayout {
        spacing: control.tokens.space12

        Rectangle {
            Layout.preferredWidth: 5
            Layout.fillHeight: true
            color: control.tokens.stateColor(control.state)
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Text {
                Layout.fillWidth: true
                color: control.tokens.boneColor
                text: control.title
                font.family: control.tokens.displayFont
                font.pixelSize: 17
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                color: control.tokens.mutedColor
                text: control.detail
                font.family: control.tokens.monoFont
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }
        Text {
            Layout.preferredWidth: 92
            color: control.checkedState === true ? control.tokens.acidGreen : control.checkedState === false ? control.tokens.mutedColor : control.tokens.stateColor(control.state)
            text: control.value
            horizontalAlignment: Text.AlignRight
            font.family: control.tokens.monoFont
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            color: control.checkedState === true ? control.tokens.signalRed : control.tokens.inkColor
            border.width: 2
            border.color: control.activeFocus ? control.tokens.hazardYellow : control.accent

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                visible: control.checkedState === true
                color: control.tokens.inkColor
                rotation: 45
            }
        }
    }

    background: Rectangle {
        color: control.down ? control.tokens.signalRedDeep : control.hovered ? control.tokens.surfaceRaisedColor : control.tokens.materialEvidenceColor
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? control.tokens.hazardYellow : control.tokens.borderColor
    }
}

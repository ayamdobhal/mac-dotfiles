import QtQuick
import QtQuick.Controls

Button {
    id: control

    required property var tokens
    required property string code
    property bool selected: false

    implicitHeight: 52
    hoverEnabled: true

    contentItem: Column {
        anchors.fill: parent
        anchors.margins: control.tokens.space8
        spacing: 3
        Text {
            width: parent.width
            color: control.selected ? control.tokens.inkColor : control.tokens.signalOrange
            text: control.code
            font.family: control.tokens.monoFont
            font.pixelSize: 8
            font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            color: control.selected ? control.tokens.inkColor : control.tokens.boneColor
            text: control.text
            font.family: control.tokens.displayFont
            font.pixelSize: 14
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
        }
    }
    background: Chassis {
        fillColor: control.selected ? control.tokens.signalRed : control.hovered ? control.tokens.surfaceRaisedColor : control.tokens.materialSecondaryColor
        strokeWidth: control.activeFocus ? 2 : 1
        strokeColor: control.activeFocus ? control.tokens.hazardYellow : control.tokens.borderColor
        profile: control.selected ? "wedgeRight" : "rect"
        cutSmall: control.tokens.cutSmall
        cutMedium: control.tokens.cutMedium
        cutLarge: control.tokens.cutLarge
        motionDuration: control.tokens.motionFast
    }
}

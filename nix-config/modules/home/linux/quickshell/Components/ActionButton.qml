import QtQuick
import QtQuick.Controls

Button {
    id: control

    required property var tokens
    property string evidence: ""
    property color accent: tokens.signalOrange
    property string silhouette: "rect"

    implicitHeight: tokens.targetPrimary
    implicitWidth: 120
    padding: tokens.space8
    hoverEnabled: true

    contentItem: Column {
        spacing: 2

        Text {
            width: parent.width
            color: control.enabled ? control.tokens.boneColor : control.tokens.mutedColor
            text: control.text
            font.family: control.tokens.displayFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: control.evidence.length > 0
            color: control.tokens.mutedColor
            text: control.evidence
            font.family: control.tokens.monoFont
            font.pixelSize: 8
            elide: Text.ElideRight
        }
    }

    background: Chassis {
        fillColor: control.down ? control.tokens.signalRedDeep : control.hovered ? control.tokens.surfaceRaisedColor : control.tokens.surfaceColor
        strokeWidth: control.activeFocus ? 2 : 1
        strokeColor: control.activeFocus ? control.tokens.hazardYellow : control.accent
        profile: control.silhouette
        cutSmall: control.tokens.cutSmall
        cutMedium: control.tokens.cutMedium
        cutLarge: control.tokens.cutLarge
        motionDuration: control.tokens.motionFast
    }
}

import QtQuick
import QtQuick.Controls

Button {
    id: control

    required property var tokens
    required property int workspaceIndex
    property bool active: false
    property bool urgent: false

    implicitWidth: tokens.target
    implicitHeight: tokens.target
    text: String(workspaceIndex).padStart(2, "0")
    hoverEnabled: true
    Accessible.name: "Focus workspace " + workspaceIndex

    contentItem: Text {
        color: control.active ? control.tokens.inkColor : control.tokens.boneColor
        text: control.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: control.tokens.displayFont
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    background: Chassis {
        fillColor: control.active ? control.tokens.signalRed : control.hovered ? control.tokens.surfaceRaisedColor : control.tokens.materialEvidenceColor
        strokeWidth: control.activeFocus ? 2 : 1
        strokeColor: control.activeFocus ? control.tokens.hazardYellow : control.urgent ? control.tokens.signalOrange : control.tokens.borderColor
        profile: control.active ? "activeStation" : "rect"
        cutSmall: control.tokens.cutSmall
        cutMedium: control.tokens.cutMedium
        cutLarge: control.tokens.cutLarge
        motionDuration: control.tokens.motionFast
    }
}

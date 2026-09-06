import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var tokens
    required property string state
    property string label: state === tokens.stateBusy ? "LOADING / BUSY" : state.toUpperCase()

    spacing: tokens.space4

    Rectangle {
        Layout.preferredWidth: 8
        Layout.preferredHeight: 8
        color: root.tokens.stateColor(root.state)
        rotation: root.state === root.tokens.stateBusy ? 45 : 0
        radius: 0
    }

    Text {
        Layout.fillWidth: true
        color: root.tokens.stateColor(root.state)
        text: root.label
        font.family: root.tokens.monoFont
        font.pixelSize: 9
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
}

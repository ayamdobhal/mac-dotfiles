import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var tokens
    property bool approved: false
    property string evidence: "AWAITING AUTHORITY"

    spacing: root.tokens.space4

    Repeater {
        model: ["MELCHIOR / POLICY", "BALTHASAR / DEVICE", "CASPER / OPERATOR"]
        delegate: Item {
            required property string modelData
            required property int index
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            Chassis {
                anchors.fill: parent
                fillColor: index < 2 && root.approved ? root.tokens.boneColor : index === 2 ? root.tokens.recoveryCobalt : root.tokens.signalOrange
                profile: "magi"
                cutSmall: root.tokens.cutSmall
                cutMedium: root.tokens.cutMedium
                cutLarge: root.tokens.cutLarge
                motionDuration: root.tokens.motionFast
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: root.tokens.space12
                anchors.rightMargin: root.tokens.space12
                Text {
                    Layout.fillWidth: true
                    color: root.tokens.inkColor
                    text: modelData
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                    font.weight: Font.Bold
                }
                Text {
                    color: index < 2 && root.approved ? root.tokens.signalRedDeep : root.tokens.inkColor
                    text: index < 2 && root.approved ? "CONFIRM" : index === 2 ? "RECORD" : "STANDBY"
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                }
            }
        }
    }
}

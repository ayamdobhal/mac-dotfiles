import QtQuick
import QtQuick.Layouts
import "../Components" as Components

Rectangle {
    id: root

    required property var tokens
    required property string label
    required property real value
    required property string state
    property var history: []
    property real maximum: 100
    property string suffix: "%"
    property color traceColor: tokens.recoveryCobalt

    implicitHeight: 80
    color: root.tokens.materialEvidenceColor
    border.width: 1
    border.color: root.tokens.borderColor

    onHistoryChanged: trace.requestPaint()
    onMaximumChanged: trace.requestPaint()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space12
        spacing: root.tokens.space4

        RowLayout {
            Layout.fillWidth: true
            Components.StateIndicator {
                Layout.fillWidth: true
                tokens: root.tokens
                state: root.state
                label: root.label
            }
            Text {
                color: root.tokens.boneColor
                text: Math.round(root.value) + root.suffix
                font.family: root.tokens.displayFont
                font.pixelSize: 25
                font.weight: Font.DemiBold
            }
        }
        Canvas {
            id: trace
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            renderTarget: Canvas.Image
            onPaint: {
                var context = getContext("2d");
                context.clearRect(0, 0, width, height);
                context.strokeStyle = root.traceColor;
                context.lineWidth = 1.5;
                if (root.history.length < 2)
                    return;
                context.beginPath();
                for (var index = 0; index < root.history.length; index++) {
                    var x = index * width / Math.max(1, root.history.length - 1);
                    var y = height - Math.max(0, Math.min(1, root.history[index] / root.maximum)) * height;
                    if (index === 0)
                        context.moveTo(x, y);
                    else
                        context.lineTo(x, y);
                }
                context.stroke();
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components" as Components

FocusScope {
    id: root

    required property var tokens
    property date displayedMonth: new Date()
    property date selectedDate: new Date()
    readonly property var cells: buildCells(displayedMonth)

    function buildCells(date) {
        var year = date.getFullYear();
        var month = date.getMonth();
        var first = new Date(year, month, 1);
        var offset = (first.getDay() + 6) % 7;
        var start = new Date(year, month, 1 - offset);
        var output = [];
        for (var index = 0; index < 42; index++) {
            var day = new Date(start.getFullYear(), start.getMonth(), start.getDate() + index);
            output.push({
                date: day,
                day: day.getDate(),
                currentMonth: day.getMonth() === month,
                today: day.toDateString() === new Date().toDateString()
            });
        }
        return output;
    }

    function moveMonth(delta) {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + delta, 1);
    }

    implicitHeight: 282

    ColumnLayout {
        anchors.fill: parent
        spacing: root.tokens.space4
        RowLayout {
            Layout.fillWidth: true
            Components.ActionButton {
                tokens: root.tokens
                text: "PREV"
                evidence: "MONTH"
                implicitWidth: 72
                onClicked: root.moveMonth(-1)
            }
            Text {
                Layout.fillWidth: true
                color: root.tokens.boneColor
                text: Qt.formatDate(root.displayedMonth, "MMMM yyyy").toUpperCase()
                horizontalAlignment: Text.AlignHCenter
                font.family: root.tokens.displayFont
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
            Components.ActionButton {
                tokens: root.tokens
                text: "NEXT"
                evidence: "MONTH"
                implicitWidth: 72
                onClicked: root.moveMonth(1)
            }
        }
        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 2
            Repeater {
                model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
                delegate: Text {
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    color: root.tokens.signalOrange
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    font.family: root.tokens.monoFont
                    font.pixelSize: 8
                }
            }
            Repeater {
                model: root.cells
                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    hoverEnabled: true
                    onClicked: root.selectedDate = modelData.date
                    Accessible.name: Qt.formatDate(modelData.date, "dddd d MMMM yyyy")
                    contentItem: Text {
                        color: modelData.today ? root.tokens.inkColor : modelData.currentMonth ? root.tokens.boneColor : root.tokens.mutedColor
                        text: modelData.day
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: root.tokens.monoFont
                        font.pixelSize: 9
                        font.weight: modelData.today ? Font.Bold : Font.Normal
                    }
                    background: Rectangle {
                        color: modelData.today ? root.tokens.signalRed : parent.hovered ? root.tokens.surfaceRaisedColor : root.tokens.inkColor
                        border.width: parent.activeFocus ? 2 : 1
                        border.color: parent.activeFocus ? root.tokens.hazardYellow : root.tokens.borderColor
                    }
                }
            }
        }
    }
}

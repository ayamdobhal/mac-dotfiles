import QtQuick

Text {
    required property var tokens

    color: tokens.signalOrange
    font.family: tokens.monoFont
    font.pixelSize: 9
    font.weight: Font.DemiBold
    font.letterSpacing: 0.8
    font.capitalization: Font.AllUppercase
    wrapMode: Text.Wrap
}

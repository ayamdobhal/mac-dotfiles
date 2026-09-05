import QtQuick
import QtQuick.Layouts
import "../Components" as Components

Rectangle {
    id: root

    required property var tokens
    required property var media

    implicitHeight: 150
    color: root.tokens.materialEvidenceColor
    border.width: 1
    border.color: root.media.hasPlayer === true ? root.tokens.identityPurple : root.tokens.borderColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.tokens.space12
        spacing: root.tokens.space8
        Components.StateIndicator {
            Layout.fillWidth: true
            tokens: root.tokens
            state: root.media.state
            label: "MPRIS / " + root.media.identity.toUpperCase()
        }
        Text {
            Layout.fillWidth: true
            color: root.tokens.boneColor
            text: root.media.title
            font.family: root.tokens.displayFont
            font.pixelSize: 20
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            color: root.tokens.mutedColor
            text: root.media.artist + (root.media.album.length > 0 ? " / " + root.media.album : "")
            font.family: root.tokens.monoFont
            font.pixelSize: 9
            elide: Text.ElideRight
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 3
            color: root.tokens.borderColor
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.media.progress))
                height: parent.height
                color: root.tokens.identityPurple
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Components.ActionButton {
                tokens: root.tokens
                text: "PREVIOUS"
                enabled: root.media.hasPlayer === true && root.media.player.canGoPrevious
                onClicked: root.media.previous()
            }
            Components.ActionButton {
                Layout.fillWidth: true
                tokens: root.tokens
                text: root.media.playing ? "PAUSE" : "PLAY"
                accent: root.tokens.identityPurple
                enabled: root.media.hasPlayer === true && root.media.player.canTogglePlaying
                onClicked: root.media.togglePlaying()
            }
            Components.ActionButton {
                tokens: root.tokens
                text: "NEXT"
                enabled: root.media.hasPlayer === true && root.media.player.canGoNext
                onClicked: root.media.next()
            }
        }
    }
}

import QtQuick

Item {
    id: root

    required property var tokens
    required property url wallpaperSource

    Rectangle {
        anchors.fill: parent
        color: root.tokens.voidColor
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        opacity: 1.0
        smooth: true
        asynchronous: true
        cache: false
    }

    Rectangle {
        anchors.fill: wallpaper
        color: "#271811"
        opacity: 0.16
    }

    // The gate is behind managed windows. It registers the fixed datum on an
    // empty field but disappears naturally beneath real niri columns.
    Rectangle {
        x: root.tokens.spineWidth + Math.round((parent.width - root.tokens.spineWidth) * 0.31)
        y: root.tokens.space32
        width: 2
        height: parent.height - root.tokens.space32 * 2
        color: root.tokens.signalRed
        opacity: 0.34

        Text {
            anchors.left: parent.right
            anchors.leftMargin: root.tokens.space8
            anchors.top: parent.top
            color: root.tokens.signalOrange
            text: "SYNC GATE / PHYSICAL DATUM"
            font.family: root.tokens.monoFont
            font.pixelSize: 8
        }
    }

    Repeater {
        model: [0.14, 0.50, 0.86]

        delegate: Item {
            required property real modelData
            x: root.tokens.spineWidth + root.tokens.space16
            y: Math.round(root.height * modelData)
            width: 26
            height: 26

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 1
                height: parent.height
                color: root.tokens.signalOrange
                opacity: 0.42
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 1
                color: root.tokens.signalOrange
                opacity: 0.42
            }
        }
    }
}

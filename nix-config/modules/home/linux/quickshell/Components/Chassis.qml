import QtQuick

// Shared 45-degree shell chassis. Profiles encode attachment or consequence;
// they are never selected as arbitrary decoration. The canvas is visual only
// so interactive children retain their normal rectangular keyboard geometry.
Canvas {
    id: root

    property color fillColor: "transparent"
    property color strokeColor: "transparent"
    property real strokeWidth: 0
    property string profile: "rect"
    property real cutSmall: 8
    property real cutMedium: 14
    property real cutLarge: 26
    property int motionDuration: 0

    antialiasing: true
    renderTarget: Canvas.Image

    onFillColorChanged: requestPaint()
    onStrokeColorChanged: requestPaint()
    onStrokeWidthChanged: requestPaint()
    onProfileChanged: requestPaint()
    onCutSmallChanged: requestPaint()
    onCutMediumChanged: requestPaint()
    onCutLargeChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Behavior on fillColor {
        ColorAnimation {
            duration: root.motionDuration
        }
    }

    onPaint: {
        var context = getContext("2d");
        var widthInside = Math.max(0, width - root.strokeWidth / 2);
        var heightInside = Math.max(0, height - root.strokeWidth / 2);
        var inset = root.strokeWidth / 2;
        var small = Math.min(root.cutSmall, widthInside / 3, heightInside / 3);
        var medium = Math.min(root.cutMedium, widthInside / 3, heightInside / 3);
        var large = Math.min(root.cutLarge, widthInside / 3, heightInside / 3);

        function move(x, y) {
            context.moveTo(inset + x, inset + y);
        }
        function line(x, y) {
            context.lineTo(inset + x, inset + y);
        }

        context.clearRect(0, 0, width, height);
        context.beginPath();

        if (root.profile === "quickView") {
            move(0, 0);
            line(widthInside, 0);
            line(widthInside, heightInside - 52);
            line(widthInside - large, heightInside - large);
            line(widthInside - large, heightInside);
            line(0, heightInside);
        } else if (root.profile === "dogleg") {
            move(0, 0);
            line(widthInside, 0);
            line(widthInside, heightInside * 0.35 - medium);
            line(widthInside - medium, heightInside * 0.35);
            line(widthInside - medium, heightInside - large);
            line(widthInside - 40, heightInside);
            line(0, heightInside);
        } else if (root.profile === "toggles") {
            move(0, 0);
            line(widthInside, 0);
            line(widthInside, heightInside * 0.58 - medium);
            line(widthInside - medium, heightInside * 0.58);
            line(widthInside - medium, heightInside - large);
            line(widthInside - 52, heightInside);
            line(0, heightInside);
        } else if (root.profile === "history") {
            move(medium, 0);
            line(widthInside, 0);
            line(widthInside, heightInside);
            line(0, heightInside);
            line(0, Math.min(92, heightInside - medium));
            line(medium, Math.min(78, heightInside - medium * 2));
        } else if (root.profile === "spear" || root.profile === "wedgeRight") {
            var cut = root.profile === "spear" ? large : medium;
            move(0, 0);
            line(widthInside - cut, 0);
            line(widthInside, heightInside / 2);
            line(widthInside - cut, heightInside);
            line(0, heightInside);
        } else if (root.profile === "header") {
            move(0, 0);
            line(widthInside, 0);
            line(widthInside, heightInside - small);
            line(widthInside - small, heightInside);
            line(0, heightInside);
        } else if (root.profile === "activeStation") {
            move(0, 0);
            line(widthInside - small, 0);
            line(widthInside, small);
            line(widthInside, heightInside - medium);
            line(widthInside - medium, heightInside);
            line(0, heightInside);
        } else if (root.profile === "magi") {
            move(small, 0);
            line(widthInside, 0);
            line(widthInside, heightInside - small);
            line(widthInside - small, heightInside);
            line(0, heightInside);
            line(0, small);
        } else {
            move(0, 0);
            line(widthInside, 0);
            line(widthInside, heightInside);
            line(0, heightInside);
        }

        context.closePath();
        context.fillStyle = root.fillColor;
        context.fill();
        if (root.strokeWidth > 0) {
            context.lineWidth = root.strokeWidth;
            context.strokeStyle = root.strokeColor;
            context.lineJoin = "miter";
            context.stroke();
        }
    }
}

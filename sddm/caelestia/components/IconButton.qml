import QtQuick
import QtQuick.Controls.Basic

// Round Material-style icon button. `glyph` is a Material Symbols ligature name.
Button {
    id: root

    required property string glyph
    property color fill
    property color ink
    property real diameter: 56

    implicitWidth: diameter
    implicitHeight: diameter
    hoverEnabled: true
    focusPolicy: Qt.NoFocus

    background: Rectangle {
        radius: root.diameter / 2
        color: root.fill
        opacity: root.down ? 0.7 : root.hovered ? 0.85 : 1
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    contentItem: Text {
        text: root.glyph
        font.family: "Material Symbols Rounded"
        font.pixelSize: root.diameter * 0.45
        color: root.ink
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }
}

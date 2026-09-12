import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import "components"

Item {
    id: root

    width: Screen.width
    height: Screen.height

    // theme.conf colours may be bare hex or #-prefixed; missing keys fall back
    // to the Caelestia default scheme so the greeter renders before the first sync.
    function hex(key, fallback) {
        var v = config[key]
        if (v === undefined || v === "")
            v = fallback
        return v.charAt(0) === "#" ? v : "#" + v
    }

    // Foreground tokens are "ink", not Material's on*: QML reads a property
    // named onSurface next to a property surface as a signal handler, and the
    // colour silently stays black.
    readonly property color primary: hex("Primary", "c2c1ff")
    readonly property color primaryInk: hex("OnPrimary", "2a2a60")
    readonly property color primaryContainer: hex("PrimaryContainer", "7171ac")
    readonly property color primaryContainerInk: hex("OnPrimaryContainer", "ffffff")
    readonly property color surface: hex("Surface", "131317")
    readonly property color surfaceInk: hex("OnSurface", "e5e1e7")
    readonly property color surfaceContainer: hex("SurfaceContainer", "201f23")
    readonly property color surfaceContainerHigh: hex("SurfaceContainerHigh", "2a292e")
    readonly property color surfaceVariantInk: hex("OnSurfaceVariant", "c8c5d1")
    readonly property color outline: hex("Outline", "918f9a")
    readonly property color outlineVariant: hex("OutlineVariant", "47464f")
    readonly property color error: hex("Error", "ffb4ab")
    readonly property string fontFamily: config.Font || "JetBrainsMono Nerd Font"
    readonly property string timeFormat: config.TimeFormat || "hh:mm"
    readonly property string dateFormat: config.DateFormat || "dddd, MMMM d"

    readonly property real scale: Math.min(Screen.height / 1080, Screen.width / 1920)
    readonly property real fieldWidth: 360 * scale
    readonly property real fieldHeight: 56 * scale

    property date now: new Date()
    property bool failed: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // Background: wallpaper with a scrim, or the surface colour alone
    Rectangle {
        anchors.fill: parent
        color: root.surface
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.Background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: root.surface
        opacity: wallpaper.visible ? 0.55 : 0
    }

    // Centred column
    Column {
        id: column
        anchors.centerIn: parent
        spacing: 12 * root.scale

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, root.timeFormat)
            font.family: root.fontFamily
            font.pixelSize: 120 * root.scale
            font.weight: Font.Bold
            color: root.surfaceInk
            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, root.dateFormat)
            font.family: root.fontFamily
            font.pixelSize: 22 * root.scale
            color: root.surfaceVariantInk
            renderType: Text.NativeRendering
        }

        Item { width: 1; height: 24 * root.scale }

        // Avatar
        Item {
            id: avatar
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120 * root.scale
            height: width

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.primaryContainer
                visible: face.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: (username.text || "?").charAt(0).toUpperCase()
                    font.family: root.fontFamily
                    font.pixelSize: parent.width * 0.45
                    font.weight: Font.Bold
                    color: root.primaryContainerInk
                    renderType: Text.NativeRendering
                }
            }

            Image {
                id: face
                anchors.fill: parent
                source: root.faceFor(username.text)
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(width, height)
                visible: false
            }

            MultiEffect {
                anchors.fill: face
                source: face
                visible: face.status === Image.Ready
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: avatar.width
                        height: avatar.height
                        radius: width / 2
                        color: "black"
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 3 * root.scale
                border.color: root.primary
            }
        }

        // Username, editable but styled as a label
        TextField {
            id: username
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.fieldWidth
            height: 40 * root.scale
            text: userModel.lastUser
            horizontalAlignment: TextInput.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 18 * root.scale
            font.weight: Font.Medium
            color: root.surfaceInk
            placeholderText: "Username"
            placeholderTextColor: root.outline
            selectByMouse: true
            background: Rectangle {
                color: username.activeFocus ? root.surfaceContainer : "transparent"
                radius: 12 * root.scale
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            KeyNavigation.tab: password
            onAccepted: password.forceActiveFocus()
        }

        // Password
        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.fieldWidth
            height: root.fieldHeight
            focus: true
            echoMode: TextInput.Password
            passwordCharacter: "•"
            horizontalAlignment: TextInput.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 18 * root.scale
            color: root.surfaceInk
            placeholderText: "Password"
            placeholderTextColor: root.outline
            selectByMouse: true
            selectionColor: root.primary
            selectedTextColor: root.primaryInk

            background: Rectangle {
                id: passwordBg
                color: root.surfaceContainerHigh
                radius: 16 * root.scale
                border.width: password.activeFocus ? 2 * root.scale : 0
                border.color: root.failed ? root.error : root.primary
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            onAccepted: root.login()
            onTextChanged: root.failed = false

            SequentialAnimation {
                id: shake
                loops: 1
                NumberAnimation { target: password; property: "anchors.horizontalCenterOffset"; to: -12; duration: 40 }
                NumberAnimation { target: password; property: "anchors.horizontalCenterOffset"; to: 12; duration: 60 }
                NumberAnimation { target: password; property: "anchors.horizontalCenterOffset"; to: -8; duration: 60 }
                NumberAnimation { target: password; property: "anchors.horizontalCenterOffset"; to: 0; duration: 40 }
            }
        }

        // Status line: caps lock or failure
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 20 * root.scale
            text: root.failed ? "Wrong password" : (keyboard.capsLock ? "Caps Lock is on" : "")
            font.family: root.fontFamily
            font.pixelSize: 14 * root.scale
            color: root.error
            renderType: Text.NativeRendering
        }

        Item { width: 1; height: 8 * root.scale }

        // Session picker
        ComboBox {
            id: session
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220 * root.scale
            height: 36 * root.scale
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            focusPolicy: Qt.NoFocus
            font.family: root.fontFamily
            font.pixelSize: 14 * root.scale

            contentItem: Text {
                text: session.displayText
                font: session.font
                color: root.surfaceVariantInk
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            indicator: Text {
                x: session.width - width - 10 * root.scale
                anchors.verticalCenter: parent.verticalCenter
                text: "expand_more"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18 * root.scale
                color: root.surfaceVariantInk
            }

            background: Rectangle {
                color: session.hovered || session.popup.visible ? root.surfaceContainer : "transparent"
                radius: 12 * root.scale
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            delegate: ItemDelegate {
                id: sessionItem
                required property int index
                required property string name
                width: session.width
                height: 36 * root.scale
                highlighted: session.highlightedIndex === index

                contentItem: Text {
                    text: sessionItem.name
                    font: session.font
                    color: sessionItem.highlighted ? root.primaryContainerInk : root.surfaceInk
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }

                background: Rectangle {
                    color: sessionItem.highlighted ? root.primaryContainer : "transparent"
                    radius: 10 * root.scale
                }
            }

            popup: Popup {
                y: session.height + 4 * root.scale
                width: session.width
                padding: 6 * root.scale
                implicitHeight: contentItem.implicitHeight + padding * 2

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: session.popup.visible ? session.delegateModel : null
                    currentIndex: session.highlightedIndex
                }

                background: Rectangle {
                    color: root.surfaceContainerHigh
                    radius: 14 * root.scale
                }
            }
        }
    }

    // Power buttons, bottom centre
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48 * root.scale
        spacing: 16 * root.scale

        IconButton {
            glyph: "bedtime"
            diameter: 52 * root.scale
            fill: root.surfaceContainerHigh
            ink: root.surfaceVariantInk
            visible: sddm.canSuspend
            onClicked: sddm.suspend()
        }

        IconButton {
            glyph: "restart_alt"
            diameter: 52 * root.scale
            fill: root.surfaceContainerHigh
            ink: root.surfaceVariantInk
            visible: sddm.canReboot
            onClicked: sddm.reboot()
        }

        IconButton {
            glyph: "power_settings_new"
            diameter: 52 * root.scale
            fill: root.primaryContainer
            ink: root.primaryContainerInk
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    // Fade to surface colour once the session starts
    Rectangle {
        id: cover
        anchors.fill: parent
        color: root.surface
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InQuad } }
    }

    // userModel.data() is not invokable from QML; a hidden Repeater exposes
    // each user's icon path instead.
    Item {
        id: faces
        visible: false
        Repeater {
            id: faceList
            model: userModel
            delegate: Item {
                required property string name
                required property string icon
            }
        }
    }

    function faceFor(user) {
        for (var i = 0; i < faceList.count; i++) {
            var item = faceList.itemAt(i)
            if (item && item.name === user)
                return item.icon
        }
        return ""
    }

    function login() {
        if (username.text === "" || password.text === "")
            return
        sddm.login(username.text, password.text, session.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            cover.opacity = 1
        }
        function onLoginFailed() {
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
            shake.start()
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}


import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

Row {
    id: root

    spacing: 0

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume:
        sink && sink.audio ? sink.audio.volume : 0

    readonly property bool muted:
        !sink || !sink.audio || sink.audio.muted


    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Rectangle {
        id: volumeButton

        implicitWidth: volumeLabel.implicitWidth + 20
        width: implicitWidth
        height: 30
        radius: 7

        color: buttonMouse.containsMouse
            ? "#45475a"
            : "#313244"

        Text {
            id: volumeLabel

            anchors.centerIn: parent

            text: root.muted
                ? "× ♪"
                : "♪ " + Math.round(root.volume * 100) + "%"

            color: root.muted ? "#f38ba8" : "#cdd6f4"
            font.pixelSize: 13
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (volumePopup.visible)
                    volumePopup.close()
                else
                    volumePopup.open()
            }
        }
    }

    Popup {
        id: volumePopup
        popupType: Popup.Window

        parent: root
        x: 0
        y: root.height + 6

        width: 230
        height: 100

        padding: 12
        closePolicy: Popup.CloseOnEscape
            | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 12
            color: "#1e1e2e"
            border.width: 1
            border.color: "#45475a"
        }

        Column {
            anchors.fill: parent
            spacing: 8

            Row {
                width: parent.width
                spacing: 8

                Text {
                    width: parent.width - muteButton.width - 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Volumen de salida"
                    color: "#cdd6f4"
                    font.pixelSize: 13
                }

                Rectangle {
                    id: muteButton

                    width: 54
                    height: 24
                    radius: 6

                    color: muteMouse.containsMouse
                        ? "#585b70"
                        : "#313244"

                    Text {
                        anchors.centerIn: parent
                        text: root.muted ? "Activar" : "Silenciar"
                        color: "#cdd6f4"
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: muteMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (root.sink && root.sink.audio)
                                root.sink.audio.muted =
                                    !root.sink.audio.muted
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 8

                Text {
                    width: 32
                    anchors.verticalCenter: parent.verticalCenter

                    text: Math.round(root.volume * 100) + "%"
                    color: "#cdd6f4"
                    font.pixelSize: 12
                }

                Slider {
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter

                    from: 0
                    to: 100
                    value: Math.min(100, root.volume * 100)

                    enabled: root.sink !== null
                        && root.sink.audio !== null

                    onMoved: {
                        if (root.sink && root.sink.audio)
                            root.sink.audio.volume = value / 100
                    }
                }
            }
        }
    }
}

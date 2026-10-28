
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property string networkText: "Red: consultando..."
    property bool wifiEnabled: true
    property var networks: []
    property var wifiCommand: []

    width: Math.min(networkLabel.implicitWidth + 20, 190)
    height: 30
    radius: 7

    color: networkMouse.containsMouse
        ? "#45475a"
        : "#313244"

    Process {
        id: networkProcess

        command: [
            "nmcli", "-t",
            "-f", "DEVICE,TYPE,STATE,CONNECTION",
            "device", "status"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let result = "Sin conexión"

                for (const line of lines) {
                    const fields = line.split(":")
                    if (fields.length < 4)
                        continue

                    if (fields[2] !== "connected")
                        continue

                    if (fields[1] === "wifi") {
                        result = "Wi-Fi: " +
                            fields.slice(3).join(":")
                        break
                    }

                    if (fields[1] === "ethernet") {
                        result = "Ethernet"
                        break
                    }
                }

                root.networkText = result
            }
        }
    }

    Process {
        id: wifiStatusProcess

        command: ["nmcli", "radio", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled =
                    text.trim() === "enabled"
            }
        }
    }

    Process {
        id: wifiListProcess

        command: [
            "nmcli", "-t",
            "-f", "IN-USE,SSID,SIGNAL,SECURITY",
            "device", "wifi", "list"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const entries = []

                for (const line of text.trim().split("\n")) {
                    const fields = line.split(":")

                    if (fields.length < 4)
                        continue

                    const ssid = fields[1]
                    if (!ssid)
                        continue

                    entries.push({
                        active: fields[0] === "*",
                        ssid: ssid,
                        signal: Number(fields[2]),
                        security: fields.slice(3).join(":")
                    })
                }

                root.networks = entries
            }
        }
    }

    Process {
        id: wifiToggleProcess

        command: root.wifiCommand

        onExited: {
            wifiStatusProcess.running = true
            networkProcess.running = true
            wifiListProcess.running = true
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            networkProcess.running = true
            wifiStatusProcess.running = true
            wifiListProcess.running = true
        }
    }

    Text {
        id: networkLabel

        anchors.centerIn: parent
        width: parent.width - 12

        text: root.networkText
        color: "#cdd6f4"
        font.pixelSize: 11
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    MouseArea {
        id: networkMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (networkPopup.visible) {
                networkPopup.close()
            } else {
                wifiStatusProcess.running = true
                wifiListProcess.running = true
                networkPopup.open()
            }
        }
    }

    Popup {
        id: networkPopup

        parent: Overlay.overlay
        popupType: Popup.Window

        x: root.mapToItem(
            Overlay.overlay, 0, root.height
        ).x

        y: root.mapToItem(
            Overlay.overlay, 0, root.height
        ).y + 6

        width: 320
        height: 390
        padding: 14

        closePolicy: Popup.CloseOnEscape
            | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 14
            color: "#1e1e2e"
            border.width: 1
            border.color: "#45475a"
        }

        Column {
            anchors.fill: parent
            spacing: 12

            Row {
                width: parent.width
                height: 34
                spacing: 8

                Column {
                    width: parent.width - wifiSwitch.width - 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "Wi-Fi"
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: root.wifiEnabled
                            ? "Activado"
                            : "Desactivado"

                        color: "#a6adc8"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    id: wifiSwitch

                    width: 62
                    height: 30
                    radius: 15

                    color: root.wifiEnabled
                        ? "#a6e3a1"
                        : "#45475a"

                    Text {
                        anchors.centerIn: parent

                        text: root.wifiEnabled ? "ON" : "OFF"
                        color: root.wifiEnabled
                            ? "#1e1e2e"
                            : "#cdd6f4"

                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.wifiCommand = [
                                "nmcli", "radio", "wifi",
                                root.wifiEnabled ? "off" : "on"
                            ]

                            wifiToggleProcess.running = true
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#45475a"
            }

            Row {
                width: parent.width
                height: 24
                spacing: 8

                Text {
                    text: "Redes disponibles"
                    color: "#cba6f7"
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - 145
                    height: 1
                }

                Text {
                    text: root.networks.length + " redes"
                    color: "#a6adc8"
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListView {
                id: networkList

                width: parent.width
                height: 245
                clip: true
                spacing: 4

                model: root.wifiEnabled ? root.networks : []

                delegate: Rectangle {
                    id: networkItem

                    required property var modelData

                    width: networkList.width
                    height: 48
                    radius: 8

                    color: modelData.active
                        ? "#313244"
                        : networkItemMouse.containsMouse
                            ? "#45475a"
                            : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Column {
                            width: parent.width - signalLabel.width - 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                width: parent.width
                                text: networkItem.modelData.ssid
                                color: "#cdd6f4"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            Text {
                                text: networkItem.modelData.active
                                    ? "Conectado"
                                    : networkItem.modelData.security
                                        ? networkItem.modelData.security
                                        : "Red abierta"

                                color: "#a6adc8"
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            id: signalLabel

                            anchors.verticalCenter: parent.verticalCenter

                            text: networkItem.modelData.signal + "%"
                            color: networkItem.modelData.signal >= 60
                                ? "#a6e3a1"
                                : "#cdd6f4"

                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: networkItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.ArrowCursor
                    }
                }
            }

            Text {
                width: parent.width
                wrapMode: Text.Wrap

                text: root.wifiEnabled
                    ? "La conexión a otras redes se añadirá en el siguiente paso."
                    : "Activa el Wi-Fi para consultar las redes."

                color: "#a6adc8"
                font.pixelSize: 11
            }
        }
    }
}

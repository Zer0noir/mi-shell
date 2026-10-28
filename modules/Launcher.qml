
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    property bool opened: false
    property string searchText: ""

    screen: Quickshell.screens.find(
        s => Quickshell.Hyprland.monitorFor(s)
             === Hyprland.focusedMonitor
    )

    visible: opened
    focusable: opened

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: 50
    implicitHeight: 470
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "mi-shell-launcher"

    onOpenedChanged: {
        if (opened) {
            searchText = ""
            searchField.forceActiveFocus()
        }
    }

    Rectangle {
        anchors {
            fill: parent
            leftMargin: 20
            rightMargin: 20
            topMargin: 8
            bottomMargin: 8
        }

        radius: 16
        color: "#1e1e2e"
        border.width: 1
        border.color: "#45475a"

        Column {
            anchors {
                fill: parent
                margins: 18
            }

            spacing: 14

            Text {
                text: "Aplicaciones"
                color: "#cba6f7"
                font.pixelSize: 20
                font.bold: true
            }

            TextField {
                id: searchField

                width: parent.width
                placeholderText: "Buscar aplicaciones..."
                text: root.searchText
                color: "#cdd6f4"
                placeholderTextColor: "#7f849c"
                font.pixelSize: 15
                selectByMouse: true

                background: Rectangle {
                    radius: 9
                    color: "#313244"
                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: "#cba6f7"
                }

                onTextChanged: {
                    root.searchText = text
                    appGrid.currentIndex = 0
                }

                onAccepted: {
                    if (appGrid.count > 0) {
                        appGrid.currentIndex = 0
                        appGrid.launchCurrent()
                    }
                }

                Keys.onEscapePressed: root.opened = false

                Keys.onDownPressed: {
                    if (appGrid.count > 0) {
                        appGrid.currentIndex = 0
                        appGrid.forceActiveFocus()
                    }
                }
            }

            GridView {
                id: appGrid

                width: parent.width
                height: parent.height - 85

                cellWidth: 92
                cellHeight: 100
                clip: true
                focus: true

                property var selectedApp: null

                function launchCurrent() {
                    if (count > 0 && currentItem) {
                        currentItem.launch()
                    }
                }

                model: ScriptModel {
                    values: {
                        const query = root.searchText
                            .trim().toLowerCase()

                        return [...DesktopEntries.applications.values]
                            .filter(app => {
                                if (!query)
                                    return true

                                return (
                                    app.name.toLowerCase().includes(query)
                                    || app.genericName.toLowerCase().includes(query)
                                    || app.comment.toLowerCase().includes(query)
                                    || app.keywords.some(
                                        word => word.toLowerCase().includes(query)
                                    )
                                )
                            })
                    }
                }

                delegate: Item {
                    id: appItem

                    required property var modelData
                    required property int index

                    width: appGrid.cellWidth
                    height: appGrid.cellHeight

                    function launch() {
                        modelData.execute()
                        root.opened = false
                    }

                    Rectangle {
                        anchors {
                            fill: parent
                            margins: 3
                        }

                        radius: 10

                        color: appMouse.containsMouse
                            || appGrid.currentIndex === appItem.index
                            ? "#45475a"
                            : "transparent"

                        Column {
                            anchors {
                                fill: parent
                                margins: 5
                            }

                            spacing: 5

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter

                                width: 42
                                height: 42

                                source: Quickshell.iconPath(
                                    appItem.modelData.icon,
                                    "application-x-executable"
                                )

                                sourceSize.width: 64
                                sourceSize.height: 64
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                width: parent.width
                                text: appItem.modelData.name
                                color: "#cdd6f4"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }
                        }

                        MouseArea {
                            id: appMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: appGrid.currentIndex = appItem.index
                            onClicked: appItem.launch()
                        }
                    }
                }

                Keys.onEscapePressed: root.opened = false

                Keys.onReturnPressed: launchCurrent()

                Keys.onEnterPressed: launchCurrent()

                Keys.onUpPressed: {
                    if (currentIndex < 0 || currentIndex < 7) {
                        searchField.forceActiveFocus()
                    } else {
                        currentIndex -= 7
                    }
                }

                Keys.onDownPressed: {
                    if (currentIndex + 7 < count)
                        currentIndex += 7
                }

                Keys.onLeftPressed: {
                    if (currentIndex > 0)
                        currentIndex--
                }

                Keys.onRightPressed: {
                    if (currentIndex + 1 < count)
                        currentIndex++
                }
            }
        }
    }
}


import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "components"
import "modules"
//import "assets"
//import "services"
//import "styles"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 42
            color: "#1e1e2e"

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "mi-shell"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }

                text: "Mi Shell"
                color: "#cba6f7"
                font.pixelSize: 15
                font.bold: true
            }

            Workspaces {
                anchors.centerIn: parent
            }
            
            Clock {
                anchors {
                    right: parent.right
                    rightMargin: 215
                    verticalCenter: parent.verticalCenter
                }
            }
            
            Volume {
                anchors {
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            Network {
                anchors {
                    right: parent.right
                    rightMargin: 85
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    
    Launcher {
        id: launcher
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcher.opened = !launcher.opened
        }

        function open(): void {
            launcher.opened = true
        }

        function close(): void {
            launcher.opened = false
        }
    }



}

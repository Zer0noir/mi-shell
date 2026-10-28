
import QtQuick
import Quickshell.Hyprland
import QtQuick.Controls

Row {
    id: root

    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: workspaceButton

            required property var modelData

            width: 32
            height: 28
            radius: 7

            color: modelData.focused
                ? "#cba6f7"
                : mouseArea.containsMouse
                    ? "#45475a"
                    : "#313244"

            border.width: modelData.urgent ? 1 : 0
            border.color: "#f38ba8"

            Text {
                anchors.centerIn: parent

                text: workspaceButton.modelData.name
                color: workspaceButton.modelData.focused
                    ? "#1e1e2e"
                    : "#cdd6f4"

                font.pixelSize: 13
                font.bold: workspaceButton.modelData.focused
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: workspaceButton.modelData.activate()
            }

            ToolTip.visible: mouseArea.containsMouse
            ToolTip.text: "Workspace " + workspaceButton.modelData.name
            ToolTip.delay: 500
        }
    }
}

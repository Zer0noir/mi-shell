
import QtQuick

Item {
    id: root

    property date currentDate: new Date()

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    Text {
        id: clockText

        anchors.centerIn: parent

        text: Qt.formatDateTime(
            root.currentDate,
            "ddd dd MMM  HH:mm"
        )

        color: "#cdd6f4"
        font.pixelSize: 14
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.currentDate = new Date()
    }
}

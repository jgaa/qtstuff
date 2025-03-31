import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtStuff

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("QT stuff!")

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        RowLayout {
            Label {
                text: qsTr("Server version:")
            }
            Text {
                text: DataModel.version
                font.pointSize: 18
                font.bold: true
            }
        }

        Text {
            text: DataModel.status
        }

        Button {
            text: qsTr("Start gRPC")
            onClicked: DataModel.start()
        }
    }
}

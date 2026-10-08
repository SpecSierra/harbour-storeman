import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

// Asked before installing or updating to a build Coastguard flagged
Dialog {
    property string appName
    property string version
    property var detections: []

    readonly property color _errorColor: Theme.errorColor ? Theme.errorColor : "#ff4d4d"

    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                //% "Install anyway"
                acceptText: qsTrId("orn-coastguard-install-anyway")
            }

            CoastguardText {
                font.pixelSize: Theme.fontSizeLarge
                color: _errorColor
                //% "Flagged as malware"
                text: qsTrId("orn-coastguard-verdict-detected")
            }

            CoastguardText {
                //: %0 is the app name, %1 its version
                //% "The Coastguard scan flagged %0 %1 as malware. Installing it may harm your device and your data."
                text: qsTrId("orn-coastguard-warning").arg(appName).arg(version)
            }

            Repeater {
                model: detections
                CoastguardText {
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: modelData
                }
            }
        }

        VerticalScrollDecorator { }
    }
}

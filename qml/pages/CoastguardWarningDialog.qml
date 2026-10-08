import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

// Asked before installing or updating to a build that Coastguard recognised
// as malware or graded as high risk
Dialog {
    property string appName
    property string version
    property bool malware
    // Detections or risk reasons, as written by the scanner (in English)
    property var reasons: []

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
                color: malware ? _errorColor : Theme.highlightColor
                text: malware ?
                          //% "Known malware"
                          qsTrId("orn-coastguard-headline-malware") :
                          //% "High risk"
                          qsTrId("orn-coastguard-headline-high")
            }

            CoastguardText {
                text: malware ?
                          //: %0 is the app name, %1 its version
                          //% "The Coastguard scan recognised %0 %1 as malware. Installing it may harm your device and your data."
                          qsTrId("orn-coastguard-warning-malware").arg(appName).arg(version) :
                          //: %0 is the app name, %1 its version
                          //% "%0 %1 gets far-reaching access to your device. Install it only if you trust its author and understand why it needs this:"
                          qsTrId("orn-coastguard-warning-high").arg(appName).arg(version)
            }

            Repeater {
                model: reasons
                CoastguardText {
                    color: malware ? Theme.secondaryColor : Theme.primaryColor
                    font.pixelSize: malware ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    text: "• " + modelData
                }
            }
        }

        VerticalScrollDecorator { }
    }
}

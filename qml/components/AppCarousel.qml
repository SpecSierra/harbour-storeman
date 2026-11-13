import QtQuick 2.5
import Sailfish.Silica 1.0
import harbour.orn 1.0

// A horizontally scrolling row of applications: icon above title
SilicaListView {
    id: carousel
    width: parent.width
    height: Theme.iconSizeLauncher + titleMetrics.height * 2 + Theme.paddingMedium * 2 + Theme.paddingSmall
    orientation: ListView.Horizontal
    clip: true

    header: Item {
        width: Theme.horizontalPageMargin - Theme.paddingMedium
        height: 1
    }
    footer: header

    delegate: BackgroundItem {
        id: appItem
        width: Theme.iconSizeLauncher + Theme.paddingMedium * 2
        height: carousel.height

        onClicked: {
            if (model.isValid) {
                pageStack.push(Qt.resolvedUrl("../pages/AppPage.qml"), {
                                   appId: model.appId
                               })
            }
        }

        Image {
            id: appIcon
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.paddingMedium
            width: Theme.iconSizeLauncher
            height: Theme.iconSizeLauncher
            fillMode: Image.PreserveAspectFit
            source: model.iconSource || "image://theme/icon-launcher-default"
        }

        Image {
            anchors {
                top: appIcon.top
                right: appIcon.right
            }
            source: model.packageStatus === OrnPm.PackageInstalled ?
                        "image://theme/icon-s-installed" :
                        model.packageStatus === OrnPm.PackageUpdateAvailable ?
                            "image://theme/icon-s-update" : ""
        }

        Label {
            anchors {
                top: appIcon.bottom
                topMargin: Theme.paddingSmall
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingSmall
                rightMargin: Theme.paddingSmall
            }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeTiny
            color: appItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            text: model.title
        }
    }

    FontMetrics {
        id: titleMetrics
        font.pixelSize: Theme.fontSizeTiny
    }

    HorizontalScrollDecorator { }
}

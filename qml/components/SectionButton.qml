import QtQuick 2.0
import Sailfish.Silica 1.0

// The title of a main page section, which opens the full list
BackgroundItem {
    property alias text: label.text

    height: Theme.itemSizeSmall

    Label {
        id: label
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: icon.left
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: Theme.fontSizeLarge
        truncationMode: TruncationMode.Fade
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Icon {
        id: icon
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        source: "image://theme/icon-m-right"
        highlighted: parent.highlighted
    }
}

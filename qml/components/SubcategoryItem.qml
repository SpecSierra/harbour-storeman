import QtQuick 2.0
import Sailfish.Silica 1.0

// A subcategory on the main page, aligned with the name of its category
BackgroundItem {
    property alias text: label.text

    height: Theme.itemSizeExtraSmall

    Label {
        id: label
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium + Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        color: highlighted ? Theme.highlightColor : Theme.secondaryColor
    }
}

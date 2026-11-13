import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/CategoryIcons.js" as CategoryIcons

// A subcategory on the main page, aligned with the name of its category.
// The entry of "all" has the icon of a list instead of that of a category.
BackgroundItem {
    id: item

    property alias text: label.text
    property int categoryId
    property bool isAll: false

    height: Theme.itemSizeExtraSmall

    CategoryIcon {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium + Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        width: Theme.iconSizeSmall + Theme.paddingSmall
        glyph: item.isAll ? CategoryIcons.all : CategoryIcons.glyph(item.categoryId)
        color: item.highlighted ? Theme.highlightColor : Theme.secondaryColor
    }

    Label {
        id: label
        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        color: item.highlighted ? Theme.highlightColor : Theme.secondaryColor
    }
}

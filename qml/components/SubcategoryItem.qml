import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/CategoryIcons.js" as CategoryIcons

// A row of the list of subcategories: its icon and name.
// The entry of "all" has the icon of a list instead of that of a category.
ListItem {
    id: item

    property alias text: label.text
    property int categoryId
    property bool isAll: false

    contentHeight: Theme.itemSizeSmall

    CategoryIcon {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        width: Theme.iconSizeMedium
        glyph: item.isAll ? CategoryIcons.all : CategoryIcons.glyph(item.categoryId)
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: label
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}

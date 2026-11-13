import QtQuick 2.0
import Sailfish.Silica 1.0

// A row of a list of categories: its icon and name, and an arrow
// if tapping it lists subcategories
ListItem {
    id: item

    property int categoryId
    property alias text: label.text
    property bool hasSubcategories: false

    contentHeight: Theme.itemSizeSmall

    CategoryIcon {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        categoryId: item.categoryId
        highlighted: item.highlighted
    }

    Label {
        id: label
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge
            right: arrow.left
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Icon {
        id: arrow
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        visible: item.hasSubcategories
        source: "image://theme/icon-m-right"
        highlighted: item.highlighted
    }
}

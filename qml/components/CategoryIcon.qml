import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/CategoryIcons.js" as CategoryIcons

// The icon of a category. iconFontFamily is the family of the Font Awesome
// font that the application window loads.
Label {
    property int categoryId
    property bool highlighted

    width: Theme.iconSizeMedium
    horizontalAlignment: Text.AlignHCenter
    font {
        family: iconFontFamily
        pixelSize: Theme.iconSizeSmall
    }
    color: highlighted ? Theme.highlightColor : Theme.primaryColor
    text: CategoryIcons.glyph(categoryId)
}

import QtQuick 2.0
import Sailfish.Silica 1.0

// A wrapped paragraph on the Coastguard pages. The text comes from the scan
// of an untrusted package, so it is never interpreted as markup.
Label {
    anchors {
        left: parent.left
        right: parent.right
        leftMargin: Theme.horizontalPageMargin
        rightMargin: Theme.horizontalPageMargin
    }
    color: Theme.primaryColor
    font.pixelSize: Theme.fontSizeSmall
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    textFormat: Text.PlainText
}

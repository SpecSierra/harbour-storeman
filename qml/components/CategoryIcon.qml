import QtQuick 2.0
import Sailfish.Silica 1.0

// An icon from the Font Awesome font, which the application window loads
// (iconFontFamily). The glyph is a character of that font.
Label {
    property string glyph

    horizontalAlignment: Text.AlignHCenter
    font {
        family: iconFontFamily
        pixelSize: Theme.iconSizeSmall
    }
    text: glyph
}

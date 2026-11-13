import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "../components"

TabItem {
    flickable: view
    allowDeletion: false

    // The tab is created on its first selection, before the search field exists
    Component.onCompleted: _focusSearchField()
    onIsCurrentItemChanged: _focusSearchField()

    // Selecting the tab opens the keyboard unless there are results to look at
    function _focusSearchField() {
        if (isCurrentItem && !view.searchText) {
            view.focusSearchField()
        }
    }

    SearchView {
        id: view
        anchors.fill: parent
    }
}

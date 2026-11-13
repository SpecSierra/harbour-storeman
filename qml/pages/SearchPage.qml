import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    property string initialSearch

    id: page
    allowedOrientations: defaultAllowedOrientations

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (initialSearch) {
                view.search(initialSearch)
                initialSearch = ""
            } else if (!view.searchText) {
                view.focusSearchField()
            }
        }
    }

    SearchView {
        id: view
        anchors.fill: parent
    }
}

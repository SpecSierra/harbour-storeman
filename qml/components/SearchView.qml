import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.orn 1.0

// The search field and its results, shared by the search tab and the search page
SilicaListView {
    id: view

    readonly property string searchText: headerItem ? headerItem.searchField.text : ""

    function reset() {
        searchModel.searchKey = ""
        //% "Search results will be shown here"
        viewPlaceholder.text = qsTrId("orn-searchpage-placeholder-default")
        //% "Type some keywords in the field above"
        viewPlaceholder.hintText = qsTrId("orn-searchpage-placeholder-default-hint")
    }

    function search(text) {
        headerItem.searchField.text = text
        searchModel.searchKey = text
        viewPlaceholder.text = ""
        viewPlaceholder.hintText = ""
        view.forceActiveFocus()
    }

    function focusSearchField() {
        if (headerItem) {
            headerItem.searchField.forceActiveFocus()
        }
    }

    Component.onCompleted: reset()

    model: OrnProxyModel {
        id: proxyModel
        sourceModel: OrnSearchAppsModel {
            id: searchModel
            onFetchingChanged: {
                if (!fetching && proxyModel.rowCount() === 0) {
                    //% "Nothing found"
                    viewPlaceholder.text = qsTrId("orn-searchpage-placeholder-noresults")
                    //% "Try to change search keywords"
                    viewPlaceholder.hintText = qsTrId("orn-searchpage-placeholder-noresults-hint")
                }
            }
        }
        filterRole: OrnSearchAppsModel.VisibilityRole
    }

    header: Column {
        property alias searchField: searchField

        width: parent.width

        PageHeader {
            //: The search menu item and the search page header text - should be a noun
            //% "Search"
            title: qsTrId("orn-search")
        }

        SearchField {
            id: searchField
            width: parent.width
            //: The search field placeholder text - should be a verb
            //% "Search"
            placeholderText: qsTrId("orn-searchfield-placeholder")

            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: view.search(text)

            onTextChanged: if (!text) view.reset()
        }
    }

    delegate: AppListDelegate { }

    VerticalScrollDecorator { }

    ViewPlaceholder {
        id: viewPlaceholder
        enabled: text
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: view.count === 0 && !viewPlaceholder.enabled
    }
}

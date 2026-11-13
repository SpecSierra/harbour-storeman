import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.orn 1.0
import "../components"

// The subcategories of a category, one plain row each
Page {
    id: page

    // The categories (an OrnProxyModel of an OrnCategoriesModel)
    property OrnProxyModel model
    property int categoryId
    property string categoryName
    // The identifiers of the subcategories
    property var subcategoryIds: []

    function _open(id, name) {
        pageStack.push(Qt.resolvedUrl("CategoryPage.qml"), {
                           categoryId: id,
                           categoryName: name
                       })
    }

    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: categoryName
            }

            // The applications of all the subcategories
            SubcategoryItem {
                isAll: true
                //: The entry of a category which lists the applications of all its subcategories
                //% "All"
                text: qsTrId("orn-category-all")
                onClicked: _open(categoryId, categoryName)
            }

            Repeater {
                model: page.model

                delegate: SubcategoryItem {
                    visible: subcategoryIds.indexOf(model.categoryId) !== -1
                    categoryId: model.categoryId
                    text: model.name
                    onClicked: _open(model.categoryId, model.name)
                }
            }
        }

        VerticalScrollDecorator { }
    }
}

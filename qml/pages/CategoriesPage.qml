import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.orn 1.0
import "../components"

// The list of the main categories or, with parentId, of the subcategories of one
Page {
    // The categories (an OrnProxyModel of an OrnCategoriesModel)
    property OrnProxyModel model
    property string title
    // The category whose subcategories are listed; 0 lists the main categories
    property int parentId: 0
    property var subcategoryIds: []

    function _open(id, name) {
        pageStack.push(Qt.resolvedUrl("CategoryPage.qml"), {
                           categoryId: id,
                           categoryName: name
                       })
    }

    id: page
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: page.title
            }

            // The applications of all the subcategories
            CategoryItem {
                visible: parentId !== 0
                categoryId: parentId
                //: The entry that lists the applications of all the subcategories of a category
                //% "All"
                text: qsTrId("orn-category-all")
                onClicked: _open(parentId, title)
            }

            Repeater {
                model: page.model

                delegate: CategoryItem {
                    visible: parentId === 0 ? model.depth === 0
                                            : subcategoryIds.indexOf(model.categoryId) !== -1
                    categoryId: model.categoryId
                    text: model.name
                    hasSubcategories: model.children.length > 0
                    onClicked: {
                        if (hasSubcategories) {
                            pageStack.push(Qt.resolvedUrl("CategoriesPage.qml"), {
                                               model: page.model,
                                               title: model.name,
                                               parentId: model.categoryId,
                                               subcategoryIds: model.children
                                           })
                        } else {
                            _open(model.categoryId, model.name)
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: page.model.rowCount() === 0 && networkManager.connected
        }

        ViewPlaceholder {
            enabled: !networkManager.connected && page.model.rowCount() === 0
            text: qsTrId("orn-network-idle")
        }
    }
}

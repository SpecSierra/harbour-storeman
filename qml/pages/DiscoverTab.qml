import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import harbour.orn 1.0
import "../components"

TabItem {
    // The identifier of the top level category "Games" at OpenRepos.net
    readonly property int _gamesCategoryId: 12
    // Categories can be hidden in the settings
    property bool _showGames: OrnClient.categoryVisible(_gamesCategoryId)

    // Theme icons for the top level categories at OpenRepos.net
    readonly property var _categoryIcons: ({
        1: "icon-m-add-to-grid",        // Applications
        12: "icon-m-game-controller",   // Games
        247: "icon-m-levels",           // Libraries
        3092: "icon-m-computer",        // Coding Competition
        3155: "icon-m-font-size",       // Fonts
        3413: "icon-m-region"           // Translations
    })

    function _openCategory(id, name) {
        pageStack.push(Qt.resolvedUrl("CategoryPage.qml"), {
                           categoryId: id,
                           categoryName: name
                       })
    }

    function _refresh() {
        recentAppsModel.reset()
        gamesModel.reset()
        categoriesModel.reset()
    }

    flickable: view
    allowDeletion: false

    Connections {
        target: Storeman
        onRecentAppsChanged: recentAppsModel.reset()
    }

    Connections {
        target: OrnClient
        onCategoryVisibilityChanged: {
            if (categoryId === _gamesCategoryId) {
                _showGames = visible
            }
        }
    }

    Connections {
        target: networkManager
        onStateChanged: {
            if (networkManager.connected && categoriesModel.rowCount() === 0) {
                _refresh()
            }
        }
    }

    OrnProxyModel {
        id: recentAppsModel
        sourceModel: OrnAppsModel {
            resource: "apps"
        }
        filterRole: OrnAppsModel.VisibilityRole
    }

    OrnProxyModel {
        id: gamesModel
        limit: 20
        sourceModel: OrnAppsModel {
            resource: "categories/%0/apps".arg(_gamesCategoryId)
        }
        filterRole: OrnAppsModel.VisibilityRole
    }

    OrnProxyModel {
        id: categoriesModel
        sourceModel: OrnCategoriesModel { }
        filterRole: OrnCategoriesModel.VisibilityRole
    }

    SilicaFlickable {
        id: view
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTrId("orn-about")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTrId("orn-settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }

            MenuItem {
                visible: OrnClient.isPublisher
                enabled: OrnPm.initialised
                //% "My repository"
                text: qsTrId("orn-myrepository")
                onClicked: pageStack.push(Qt.resolvedUrl("RepositoryPage.qml"), {
                                              userId: OrnClient.userId,
                                              userName: OrnClient.userName,
                                              userIcon: OrnClient.userIconSource
                                          })
            }

            MenuItem {
                enabled: OrnPm.initialised
                text: qsTrId("orn-repositories")
                onClicked: pageStack.push(Qt.resolvedUrl("RepositoriesPage.qml"))
            }

            MenuItem {
                enabled: networkManager.connected
                text: qsTrId("orn-refresh")
                onClicked: _refresh()
            }

            MenuStatusLabel { }
        }

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: applicationDisplayName
            }

            Column {
                width: parent.width
                visible: networkManager.connected

                SectionButton {
                    text: qsTrId("orn-recently-updated")
                    onClicked: pageStack.push(Qt.resolvedUrl("RecentAppsPage.qml"), {
                                                  model: recentAppsModel
                                              })
                }

                AppCarousel {
                    model: OrnProxyModel {
                        limit: 20
                        sourceModel: recentAppsModel
                    }
                }

                SectionButton {
                    visible: _showGames
                    //% "Games"
                    text: qsTrId("orn-games")
                    onClicked: _openCategory(_gamesCategoryId, text)
                }

                AppCarousel {
                    visible: _showGames
                    model: gamesModel
                }

                Label {
                    x: Theme.horizontalPageMargin
                    height: Theme.itemSizeSmall
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeLarge
                    //% "Categories"
                    text: qsTrId("orn-categories")
                }

                Repeater {
                    model: categoriesModel

                    // A top level category: one that has subcategories expands to show them
                    delegate: Column {
                        id: category

                        readonly property int categoryId: model.categoryId
                        readonly property string categoryName: model.name
                        readonly property var subcategoryIds: model.children
                        readonly property bool expandable: subcategoryIds.length > 0
                        property bool expanded: false

                        width: parent.width
                        visible: model.depth === 0

                        BackgroundItem {
                            id: categoryItem
                            height: Theme.itemSizeSmall
                            onClicked: {
                                if (category.expandable) {
                                    category.expanded = !category.expanded
                                } else {
                                    _openCategory(category.categoryId, category.categoryName)
                                }
                            }

                            Icon {
                                id: categoryIcon
                                anchors {
                                    left: parent.left
                                    leftMargin: Theme.horizontalPageMargin
                                    verticalCenter: parent.verticalCenter
                                }
                                source: "image://theme/" + (_categoryIcons[category.categoryId] || "icon-m-other")
                                highlighted: categoryItem.highlighted
                            }

                            Label {
                                anchors {
                                    left: categoryIcon.right
                                    leftMargin: Theme.paddingLarge
                                    right: stateIcon.left
                                    rightMargin: Theme.paddingMedium
                                    verticalCenter: parent.verticalCenter
                                }
                                truncationMode: TruncationMode.Fade
                                color: categoryItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                                text: category.categoryName
                            }

                            Icon {
                                id: stateIcon
                                anchors {
                                    right: parent.right
                                    rightMargin: Theme.horizontalPageMargin
                                    verticalCenter: parent.verticalCenter
                                }
                                source: "image://theme/icon-m-" + (!category.expandable ? "right" :
                                                                   category.expanded ? "up" : "down")
                                highlighted: categoryItem.highlighted
                            }
                        }

                        Item {
                            width: parent.width
                            height: category.expanded ? subcategories.height : 0
                            visible: height > 0
                            clip: true

                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Column {
                                id: subcategories
                                width: parent.width

                                SubcategoryItem {
                                    isAll: true
                                    //: The entry of a category which lists the applications of all its subcategories
                                    //% "All"
                                    text: qsTrId("orn-category-all")
                                    onClicked: _openCategory(category.categoryId, category.categoryName)
                                }

                                Repeater {
                                    model: category.expandable ? categoriesModel : null
                                    delegate: SubcategoryItem {
                                        visible: category.subcategoryIds.indexOf(model.categoryId) !== -1
                                        categoryId: model.categoryId
                                        text: model.name
                                        onClicked: _openCategory(model.categoryId, text)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { }

        ViewPlaceholder {
            enabled: !networkManager.connected
            text: qsTrId("orn-network-idle")
        }
    }
}

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
            if (networkManager.connected && recentAppsModel.rowCount() === 0) {
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

                SectionButton {
                    //% "Categories"
                    text: qsTrId("orn-categories")
                    onClicked: pageStack.push(Qt.resolvedUrl("CategoriesPage.qml"), {
                                                  model: categoriesModel,
                                                  title: text
                                              })
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

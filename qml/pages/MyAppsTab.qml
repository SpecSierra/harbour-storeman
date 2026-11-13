import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import harbour.orn 1.0
import "../components"

TabItem {
    property bool _working: false

    flickable: appsList
    allowDeletion: false

    SilicaListView {
        id: appsList
        anchors.fill: parent
        model: OrnProxyModel {
            id: proxyModel
            sortRole: OrnInstalledAppsModel.SortRole
            sortCaseSensitivity: Qt.CaseInsensitive
            sourceModel: OrnInstalledAppsModel {
                id: installedAppsModel
                onModelAboutToBeReset: _working = true
                onModelReset: {
                    _working = false
                    proxyModel.sort(Qt.AscendingOrder)
                }
            }
        }

        header: Column {
            width: parent.width

            PageHeader {
                //% "My apps"
                title: qsTrId("orn-my-apps")
                //% "Only from enabled repositories"
                description: qsTrId("orn-installed-apps-description")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: OrnPm.updatesAvailable
                enabled: networkManager.connected && _operations && _operations.length === 0
                //% "Update all"
                text: qsTrId("orn-update-all")
                onClicked: _updateAll()
            }
        }

        section {
            property: "updateAvailable"
            delegate: SectionHeader {
                text: section === '1' ? qsTrId("orn-update-available") :
                                        qsTrId("orn-installed")
            }
        }

        delegate: ListItem {
            id: item
            contentHeight: Theme.itemSizeMedium
            onClicked: openMenu()

            menu: ContextMenu {

                MenuItem {
                    //% "Search on OpenRepos.net"
                    text: qsTrId("orn-search-on-openrepos")
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"),
                                              { initialSearch: packageTitleUnlocalized })
                }

                MenuItem {
                    visible: updateAvailable
                    enabled: networkManager.connected && !itemInProgress(packageName)
                    text: qsTrId("orn-update")
                    onClicked: OrnPm.updatePackage(packageName)
                }

                MenuItem {
                    text: qsTrId("orn-remove")
                    enabled: !itemInProgress(packageName)
                    onClicked: Remorse.itemAction(item, qsTrId("orn-removing"), function() {
                        OrnPm.removePackage(packageId)
                    })
                }
            }

            ListView.onAdd: AddAnimation {
                target: item
            }

            ListView.onRemove: RemoveAnimation {
                target: item
            }

            Image {
                id: appIcon
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                fillMode: Image.PreserveAspectFit
                source: packageIcon ? packageIcon : "image://theme/icon-launcher-default"
            }

            Column {
                anchors {
                    left: appIcon.right
                    leftMargin: Theme.paddingMedium
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: packageTitle
                }

                Label {
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: item.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: updateAvailable ? packageVersion + " ➝ " + updateVersion :
                                            packageVersion
                }
            }
        }

        PullDownMenu {
            id: menu

            MenuItem {
                text: qsTrId("orn-local-rpms")
                onClicked: pageStack.push(Qt.resolvedUrl("LocalRpmsPage.qml"))
            }

            MenuItem {
                enabled: networkManager.connected
                text: qsTrId("orn-bookmarks")
                onClicked: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"))
            }

            RefreshMenuItem {
                model: installedAppsModel
            }

            MenuStatusLabel { }
        }

        VerticalScrollDecorator { }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: _working && !menu.active
        }

        ViewPlaceholder {
            enabled: appsList.count === 0 && !_working
            //% "Could not find any applications installed from OpenRepos"
            text: qsTrId("orn-no-installed-apps")
        }
    }
}

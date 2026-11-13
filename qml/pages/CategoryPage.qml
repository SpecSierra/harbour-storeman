import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.orn 1.0
import "../components"

Page {
    property int categoryId
    property string categoryName

    allowedOrientations: defaultAllowedOrientations

    OrnAppsModel {
        id: categoryModel
        resource: "categories/%0/apps".arg(categoryId)
    }

    // Leaves out the applications hidden by the settings
    OrnProxyModel {
        id: proxyModel
        sourceModel: categoryModel
        filterRole: OrnAppsModel.VisibilityRole
    }

    SilicaListView {
        id: categoryList
        anchors.fill: parent

        header: PageHeader {
            title: categoryName
        }

        model: networkManager.connected ? proxyModel : null

        delegate: AppListDelegate { }

        PullDownMenu {
            id: menu

            RefreshMenuItem {
                model: categoryModel
            }

            MenuSearchItem {}

            MenuStatusLabel {}
        }

        VerticalScrollDecorator {}

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: !viewPlaceholder.enabled &&
                     categoryList.count === 0 &&
                     !menu.active
        }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: text
            text: {
                hintText = ""
                if (!networkManager.connected) {
                    return qsTrId("orn-network-idle")
                }
                if (categoryModel.networkError) {
                    hintText = qsTrId("orn-pull-refresh")
                    return qsTrId("orn-network-error")
                }
                if (categoryModel.allFetched && !categoryModel.fetching && categoryList.count === 0) {
                    //% "Currently there are no apps in this category"
                    return qsTrId("orn-category-noapps")
                }
                return ""
            }
        }
    }
}

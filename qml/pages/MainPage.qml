import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import harbour.orn 1.0

Page {
    property int _updatesCount: 0

    function showTab(index) {
        tabs.moveTo(index, TabViewAction.Immediate)
    }

    function _countUpdates() {
        _updatesCount = OrnPm.initialised ? OrnPm.updatablePackages().length : 0
    }

    id: page
    objectName: "MainPage"
    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: _countUpdates()

    Connections {
        target: OrnPm
        onInitialisedChanged: _countUpdates()
        onUpdatablePackagesChanged: _countUpdates()
    }

    TabView {
        id: tabs
        anchors.fill: parent
        // Swiping is left to the lists of applications
        interactive: false
        model: [
            Qt.resolvedUrl("DiscoverTab.qml"),
            Qt.resolvedUrl("SearchTab.qml"),
            Qt.resolvedUrl("MyAppsTab.qml")
        ]

        footer: TabBar {
            model: [ {
                    //% "Discover"
                    title: qsTrId("orn-discover"),
                    icon: "image://theme/icon-m-home",
                    count: 0
                }, {
                    title: qsTrId("orn-search"),
                    icon: "image://theme/icon-m-search",
                    count: 0
                }, {
                    title: qsTrId("orn-my-apps"),
                    icon: "image://theme/icon-m-device-download",
                    count: _updatesCount
                } ]

            delegate: TabButton {
                // Share the bar equally. The bar scrolls to the selected button when its
                // buttons are wider than the screen, so they must not exceed it.
                width: Math.floor(tabs.width / 3)
                tabCount: 0
                tabIndex: index
                title: modelData.title
                icon.source: modelData.icon
                count: modelData.count
            }
        }
    }
}

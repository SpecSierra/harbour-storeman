import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.orn 1.0

// Shows what the Coastguard scanner (https://github.com/SpecSierra/Coastguard)
// found in the package of this app, for the version that is installed or
// would be installed. Only the package name is sent, in the request URL.
//
// The row leads with the risk grade: how much the package gets to do on the
// device. A scan cannot prove an app safe, so there is deliberately no
// "all good" tick; known malware is the one case shown as an alarm.
BackgroundItem {
    id: coastguard

    // Name of the RPM, and the PackageKit ID ("name;version;arch;repo") of the
    // build the verdict should be about. When the ID carries no version (the
    // repository is not enabled), fallbackVersion is used, for any architecture.
    property string packageName
    property string packageId
    property string fallbackVersion

    readonly property string version: {
        var v = packageId.split(";")[1] || fallbackVersion
        // Coastguard stores version-release without the epoch
        return v.replace(/^\d+:/, "")
    }
    readonly property string arch: packageId.split(";")[2] || ""

    // "", "loading", "error", "unknown" (package never scanned),
    // "unscanned" (this version not scanned), "clean" or "detected"
    property string scanState: ""
    // Every scanned build of the package, oldest first
    property var builds: []
    // The build matching version and arch, or null
    readonly property var build: _pick(builds, version, arch)
    // The most recently built one that was scanned, for "last scanned" hints
    readonly property var latestBuild: builds.length ? builds[builds.length - 1] : null
    readonly property bool detected: scanState === "detected"
    // { grade: "low"|"medium"|"high", reasons: [{ level, text }] }, or null
    // for a scan stored before grades existed
    readonly property var risk: build && build.summary && build.summary.risk ?
                                    build.summary.risk : null
    readonly property string grade: risk ? risk.grade : ""
    // Reasons a careful user may want to read before installing
    readonly property var reviewReasons: {
        var list = []
        if (risk) {
            for (var i = 0; i < risk.reasons.length; ++i) {
                if (risk.reasons[i].level !== "info") {
                    list.push(risk.reasons[i].text)
                }
            }
        }
        return list
    }
    readonly property bool warnBeforeInstall: detected || grade === "high"

    readonly property string _baseUrl:
        "https://raw.githubusercontent.com/SpecSierra/Coastguard/results/packages/"
    readonly property color _errorColor: Theme.errorColor ? Theme.errorColor : "#ff4d4d"
    property var _request

    function _pick(list, version, arch) {
        var found = null
        for (var i = 0; i < list.length; ++i) {
            var b = list[i]
            if (b.version === version &&
                    (!arch || b.arch === arch || b.arch === "noarch")) {
                found = b
            }
        }
        return found
    }

    function _updateState() {
        if (scanState === "loading" || scanState === "error" || scanState === "") {
            return
        }
        if (!builds.length) {
            scanState = "unknown"
        } else if (!build) {
            scanState = "unscanned"
        } else {
            scanState = build.verdict === "detected" ? "detected" : "clean"
        }
    }

    function reload() {
        if (_request) {
            _request.abort()
            _request = null
        }
        builds = []
        // The name ends up in a URL: accept only what an RPM name can be
        if (!Storeman.showCoastguard || !networkManager.connected ||
                !/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(packageName)) {
            scanState = ""
            return
        }
        scanState = "loading"
        var req = new XMLHttpRequest()
        _request = req
        req.onreadystatechange = function() {
            if (req.readyState !== XMLHttpRequest.DONE || req !== _request) {
                return
            }
            _request = null
            if (req.status === 404) {
                scanState = "unknown"
            } else if (req.status === 200) {
                try {
                    var list = JSON.parse(req.responseText)
                    builds = list instanceof Array ? list : []
                    scanState = "unknown"
                    _updateState()
                } catch (e) {
                    scanState = "error"
                }
            } else {
                scanState = "error"
            }
        }
        req.open("GET", _baseUrl + encodeURIComponent(packageName) + "/index.json")
        req.send()
    }

    onPackageNameChanged: reload()
    // An app page opened a second time has its package name from the start
    Component.onCompleted: reload()
    onBuildChanged: _updateState()

    Connections {
        target: Storeman
        onShowCoastguardChanged: coastguard.reload()
    }

    width: parent.width
    height: visible ? Math.max(Theme.itemSizeSmall, labels.height + 2 * Theme.paddingSmall) : 0
    visible: scanState !== ""
    enabled: scanState === "clean" || scanState === "detected" || scanState === "unscanned"

    onClicked: pageStack.push(Qt.resolvedUrl("../pages/CoastguardPage.qml"), {
                                  appName: app.title,
                                  appIconSource: app.iconSource,
                                  packageName: packageName,
                                  version: version,
                                  build: build,
                                  latestBuild: latestBuild
                              })

    Image {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        visible: !busy.running
        source: coastguard.warnBeforeInstall ?
                    "image://theme/icon-s-high-importance?" +
                    (coastguard.detected ? coastguard._errorColor :
                     coastguard.highlighted ? Theme.highlightColor : Theme.primaryColor) : ""
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: icon
        size: BusyIndicatorSize.ExtraSmall
        running: coastguard.scanState === "loading"
    }

    Column {
        id: labels
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin +
                        (coastguard.warnBeforeInstall || busy.running ?
                             Theme.iconSizeSmall + Theme.paddingMedium : 0)
            right: arrow.left
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeSmall
            color: coastguard.detected ? coastguard._errorColor :
                   coastguard.highlighted ? Theme.highlightColor : Theme.primaryColor
            text: {
                switch (coastguard.scanState) {
                case "loading":
                    //% "Coastguard: checking"
                    return qsTrId("orn-coastguard-checking")
                case "detected":
                    //% "Coastguard: known malware"
                    return qsTrId("orn-coastguard-detected")
                case "clean":
                    switch (coastguard.grade) {
                    case "high":
                        //% "Coastguard: high risk"
                        return qsTrId("orn-coastguard-grade-high")
                    case "medium":
                        //% "Coastguard: %n thing(s) to review"
                        return qsTrId("orn-coastguard-grade-medium", coastguard.reviewReasons.length)
                    case "low":
                        //% "Coastguard: nothing unusual"
                        return qsTrId("orn-coastguard-grade-low")
                    default:
                        //% "Coastguard: scanned"
                        return qsTrId("orn-coastguard-scanned-nograde")
                    }
                case "unscanned":
                    //% "Coastguard: this version is not scanned"
                    return qsTrId("orn-coastguard-unscanned")
                case "unknown":
                    //% "Coastguard: not scanned"
                    return qsTrId("orn-coastguard-unknown")
                default:
                    //% "Coastguard: result not available"
                    return qsTrId("orn-coastguard-error")
                }
            }
        }

        Label {
            width: parent.width
            visible: text
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeExtraSmall
            color: coastguard.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            text: {
                if (coastguard.scanState === "clean" && coastguard.reviewReasons.length) {
                    // The most serious reason, as written by the scanner (in English)
                    return coastguard.reviewReasons[0]
                }
                if (coastguard.scanState === "unscanned" && coastguard.latestBuild) {
                    // Both versions, so a mismatch explains itself
                    //: %0 is the version of this app, %1 the last version that was scanned
                    //% "%0 is not scanned, the last scan is of %1"
                    return qsTrId("orn-coastguard-last-scanned")
                            .arg(coastguard.version + (coastguard.arch ? " " + coastguard.arch : ""))
                            .arg(coastguard.latestBuild.version + " " + coastguard.latestBuild.arch)
                }
                return ""
            }
        }
    }

    Image {
        id: arrow
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        visible: coastguard.enabled
        source: "image://theme/icon-m-right?" +
                (coastguard.highlighted ? Theme.highlightColor : Theme.primaryColor)
    }
}

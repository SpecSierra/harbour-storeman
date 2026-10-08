import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

// Details of a Coastguard scan, see ../components/CoastguardInfo.qml
Page {
    property string appName
    property string appIconSource
    property string packageName
    // The version the app page is about
    property string version
    // Its scan, or null when that version was not scanned
    property var build
    property var latestBuild

    // What is shown: the scan of this version, else of the last scanned one
    readonly property var _shown: build ? build : latestBuild
    readonly property var _summary: _shown && _shown.summary ? _shown.summary : null
    readonly property bool _detected: !!_shown && _shown.verdict === "detected"
    readonly property color _errorColor: Theme.errorColor ? Theme.errorColor : "#ff4d4d"

    function _reviewLines(s) {
        var lines = []
        if (!s) {
            return lines
        }
        if (s.sandbox === "disabled") {
            //% "Runs without the Sailjail sandbox (disabled by the package)"
            lines.push(qsTrId("orn-coastguard-sandbox-disabled"))
        } else if (s.sandbox === "none") {
            //% "Declares no Sailjail sandbox profile"
            lines.push(qsTrId("orn-coastguard-sandbox-none"))
        }
        if (s.own_sandbox_profile) {
            //% "Ships its own sandbox profile"
            lines.push(qsTrId("orn-coastguard-own-profile"))
        }
        if (s.root_services > 0) {
            //% "Installs %n background service(s) running as root"
            lines.push(qsTrId("orn-coastguard-root-services", s.root_services))
        }
        if (s.privileged_files > 0) {
            //% "Installs %n file(s) with elevated privileges (setuid or capabilities)"
            lines.push(qsTrId("orn-coastguard-privileged-files", s.privileged_files))
        }
        for (var i = 0; i < s.system_hooks.length; ++i) {
            //% "Hooks into the system: %0"
            lines.push(qsTrId("orn-coastguard-system-hook").arg(s.system_hooks[i]))
        }
        for (i = 0; i < s.indicators.length; ++i) {
            //: %0 is a capability found in the package, in English, e.g. "Reads Contacts Database"
            //% "Contains code for: %0"
            lines.push(qsTrId("orn-coastguard-indicator").arg(s.indicators[i]))
        }
        return lines
    }

    function _changeLines(s) {
        var lines = []
        if (!s || !s.changes) {
            return lines
        }
        var items = s.changes.attention
        for (var i = 0; i < items.length; ++i) {
            lines.push(items[i].area + " " + items[i].change + ": " + items[i].item)
        }
        if (s.changes.attention_count > items.length) {
            //% "and %n more"
            lines.push(qsTrId("orn-coastguard-more", s.changes.attention_count - items.length))
        }
        var f = s.changes.files
        if (f) {
            //% "Files: %0 added, %1 removed, %2 changed"
            lines.push(qsTrId("orn-coastguard-files").arg(f.added).arg(f.removed).arg(f.changed))
        }
        return lines
    }

    function _reputationLine(name, status) {
        if (!status || status === "not configured") {
            return ""
        }
        return status === "ok" ?
                    //% "%0: not known as malware"
                    qsTrId("orn-coastguard-reputation-ok").arg(name) :
                    //% "%0: lookup failed (%1)"
                    qsTrId("orn-coastguard-reputation-failed").arg(name).arg(status)
    }

    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            FancyPageHeader {
                //% "Coastguard scan"
                title: qsTrId("orn-coastguard-title")
                description: appName
                iconSource: appIconSource
            }

            CoastguardText {
                visible: !build && !!_shown
                color: Theme.highlightColor
                //% "Version %0 has not been scanned. Below is the scan of version %1."
                text: _shown ? qsTrId("orn-coastguard-other-version").arg(version).arg(_shown.version) : ""
            }

            CoastguardText {
                visible: !_shown
                //% "No version of this package has been scanned."
                text: qsTrId("orn-coastguard-never-scanned")
            }

            CoastguardText {
                visible: !!_shown
                font.pixelSize: Theme.fontSizeLarge
                color: _detected ? _errorColor : Theme.highlightColor
                text: _detected ?
                          //% "Flagged as malware"
                          qsTrId("orn-coastguard-verdict-detected") :
                          //% "No known malware found"
                          qsTrId("orn-coastguard-verdict-clean")
            }

            CoastguardText {
                visible: !!_shown
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //: %0 is package name and version, %1 the architecture, %2 a date
                //% "%0 (%1), scanned %2"
                text: _shown ? qsTrId("orn-coastguard-scanned")
                               .arg(packageName + " " + _shown.version)
                               .arg(_shown.arch)
                               .arg(new Date(_shown.last_scanned).toLocaleDateString(_locale, Locale.ShortFormat)) : ""
            }

            SectionHeader {
                visible: detections.count
                //% "Detections"
                text: qsTrId("orn-coastguard-detections")
            }

            Repeater {
                id: detections
                model: _summary ? _summary.detections : []
                CoastguardText {
                    color: _errorColor
                    text: modelData
                }
            }

            SectionHeader {
                visible: review.count
                //% "Worth reviewing"
                text: qsTrId("orn-coastguard-review")
            }

            Repeater {
                id: review
                model: _reviewLines(_summary)
                CoastguardText { text: "• " + modelData }
            }

            SectionHeader {
                visible: !!_summary && _summary.sandbox === "declared"
                //% "Sandbox permissions"
                text: qsTrId("orn-coastguard-permissions")
            }

            CoastguardText {
                visible: !!_summary && _summary.sandbox === "declared"
                text: _summary && _summary.permissions.length ? _summary.permissions.join(", ") :
                          //% "None"
                          qsTrId("orn-coastguard-none")
            }

            SectionHeader {
                visible: changes.count
                //: %0 is the package file name of the previous version
                //% "Changes since %0"
                text: _summary && _summary.changes ?
                          qsTrId("orn-coastguard-changes").arg(_summary.changes.since) : ""
            }

            Repeater {
                id: changes
                model: _changeLines(_summary)
                CoastguardText { text: "• " + modelData }
            }

            SectionHeader {
                visible: virustotal.visible || malwarebazaar.visible
                //% "Known-malware databases"
                text: qsTrId("orn-coastguard-reputation")
            }

            CoastguardText {
                id: virustotal
                visible: text
                text: _summary ? _reputationLine("VirusTotal", _summary.reputation.virustotal) : ""
            }

            CoastguardText {
                id: malwarebazaar
                visible: text
                text: _summary ? _reputationLine("MalwareBazaar", _summary.reputation.malwarebazaar) : ""
            }

            SectionHeader {
                //% "About this check"
                text: qsTrId("orn-coastguard-about")
            }

            CoastguardText {
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Coastguard is an independent, automatic scan of packages published on OpenRepos. It looks for known malware signatures and describes what a package sets up on the device. It cannot detect new or targeted malware: a clean result is not a guarantee that the package is safe."
                text: qsTrId("orn-coastguard-disclaimer")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !!_summary && !!_summary.run
                //% "Full report"
                text: qsTrId("orn-coastguard-full-report")
                onClicked: Qt.openUrlExternally(_summary.run)
            }
        }

        VerticalScrollDecorator { }
    }
}

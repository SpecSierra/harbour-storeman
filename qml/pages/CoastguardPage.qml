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
    // { grade, reasons: [{ level, text }] }; null for scans stored before grades existed
    readonly property var _risk: _summary && _summary.risk ? _summary.risk : null
    readonly property color _errorColor: Theme.errorColor ? Theme.errorColor : "#ff4d4d"

    // Reasons that count towards the grade; informational ones are left
    // to the full report
    function _reasons(risk) {
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

    // The changes worth reviewing, a handful at most
    function _changeLines(s) {
        var lines = []
        if (!s || !s.changes) {
            return lines
        }
        var items = s.changes.attention
        var shown = Math.min(items.length, 5)
        for (var i = 0; i < shown; ++i) {
            lines.push(items[i].area + " " + items[i].change + ": " + items[i].item)
        }
        if (s.changes.attention_count > shown) {
            //% "and %n more"
            lines.push(qsTrId("orn-coastguard-more", s.changes.attention_count - shown))
        }
        return lines
    }

    // The four known-malware checks as [{ name, status }]
    function _checks(s) {
        var list = []
        if (!s || !s.checks) {
            return list
        }
        var names = [["clamav", "ClamAV"], ["yara", "YARA"],
                     ["virustotal", "VirusTotal"], ["malwarebazaar", "MalwareBazaar"]]
        for (var i = 0; i < names.length; ++i) {
            list.push({ name: names[i][1], status: s.checks[names[i][0]] })
        }
        return list
    }

    function _checkStatus(status) {
        switch (status) {
        case "pass":
            //: Result of one malware check
            //% "Pass"
            return qsTrId("orn-coastguard-check-pass")
        case "fail":
            //: Result of one malware check
            //% "Fail"
            return qsTrId("orn-coastguard-check-fail")
        case "not run":
            //: Result of one malware check
            //% "Not run"
            return qsTrId("orn-coastguard-check-notrun")
        default:
            //: Result of one malware check
            //% "Error"
            return qsTrId("orn-coastguard-check-error")
        }
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
                visible: !build && !!_shown && version !== ""
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
                text: {
                    if (_detected) {
                        //% "Known malware"
                        return qsTrId("orn-coastguard-headline-malware")
                    }
                    switch (_risk ? _risk.grade : "") {
                    case "high":
                        //% "High risk"
                        return qsTrId("orn-coastguard-headline-high")
                    case "medium":
                        //% "Worth a look"
                        return qsTrId("orn-coastguard-headline-medium")
                    case "low":
                        //% "Nothing unusual"
                        return qsTrId("orn-coastguard-headline-low")
                    default:
                        //% "Scanned"
                        return qsTrId("orn-coastguard-headline-nograde")
                    }
                }
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
                visible: reasons.count
                //% "What it gets to do"
                text: qsTrId("orn-coastguard-reasons")
            }

            Repeater {
                id: reasons
                model: _reasons(_risk)
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
                visible: !!_shown
                //% "Known-malware check"
                text: qsTrId("orn-coastguard-malware-check")
            }

            Repeater {
                model: _checks(_summary)
                CoastguardText {
                    color: modelData.status === "fail" ? _errorColor : Theme.primaryColor
                    text: modelData.name + ": " + _checkStatus(modelData.status)
                }
            }

            Repeater {
                model: _summary ? _summary.detections : []
                CoastguardText {
                    color: _errorColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: "• " + modelData
                }
            }

            CoastguardText {
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Automatic scan. It cannot recognise new malware and is no guarantee of safety."
                text: qsTrId("orn-coastguard-disclaimer")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                // The report page opens without a GitHub account
                visible: !!_summary && !!_summary.report
                //% "Full report"
                text: qsTrId("orn-coastguard-full-report")
                onClicked: Qt.openUrlExternally(_summary.report)
            }
        }

        VerticalScrollDecorator { }
    }
}

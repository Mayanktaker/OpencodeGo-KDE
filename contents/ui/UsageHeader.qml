// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Header component displaying OpenCode Go subscription metadata, quota burn-rate estimate, usage summary badge, and 1-click layout mode switcher toggle

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: headerRoot

    // Data properties bound from root plasmoid state
    property string planName: "OpenCode Go"
    property string billingPeriod: "Current Cycle"
    property int usagePercent: 0
    property bool isMock: false
    // Raw usage data model used for burn-rate estimate and reset countdown display
    property var usageData: null

    // Color tokens bound from configuration
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 34

    // Formulates the reset countdown when real data carries it, otherwise estimates burn-rate velocity
    function getDurationLabel() {
        if (usageData && usageData.resetLabel) {
            return i18n("resets in %1", usageData.resetLabel);
        }
        return headerRoot.getEstimatedDaysLeft();
    }

    // Calculates estimated days remaining based on daily consumption velocity
    function getEstimatedDaysLeft() {
        if (!usageData || !usageData.weekly) return i18n("Est. ~14 days left");
        var weekly = usageData.weekly;
        var total = 0;
        for (var i = 0; i < weekly.length; i++) {
            total += (weekly[i].value || 0);
        }
        var avgDaily = total / Math.max(1, weekly.length);
        var currentUsed = usageData.currentUsed || 3650;
        var currentLimit = usageData.currentLimit || 5000;
        var remaining = Math.max(0, currentLimit - currentUsed);
        if (avgDaily <= 0) return i18n("Est. ~14 days left");
        var days = Math.round(remaining / avgDaily);
        return i18n("Est. ~%1 days left", Math.max(1, days));
    }

    // Helper function to cycle layout mode between tabbed, horizontal, and all_in_one
    function cycleLayoutMode() {
        var current = Plasmoid.configuration.displayLayout || "tabbed";
        if (current === "tabbed") {
            Plasmoid.configuration.displayLayout = "horizontal";
        } else if (current === "horizontal") {
            Plasmoid.configuration.displayLayout = "all_in_one";
        } else {
            Plasmoid.configuration.displayLayout = "tabbed";
        }
    }

    // Row layout for header alignment
    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing / 2

        // Left column containing plan title, billing cycle dates, and burn-rate velocity estimate
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            // Row containing plan title label and optional demo mode indicator
            RowLayout {
                spacing: 4

                // Plan title text label
                PlasmaComponents.Label {
                    text: planName
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.7
                    color: textColor
                }

                // Demo mode badge indicator
                Rectangle {
                    visible: isMock
                    implicitWidth: demoText.implicitWidth + 6
                    implicitHeight: demoText.implicitHeight + 2
                    radius: 2
                    color: Qt.alpha(accentColor, 0.2)

                    Text {
                        id: demoText
                        anchors.centerIn: parent
                        text: i18n("DEMO")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.4
                        font.bold: true
                        color: accentColor
                    }
                }
            }

            // Billing cycle range plus reset countdown or burn-rate velocity estimate text label
            PlasmaComponents.Label {
                text: billingPeriod + " • " + headerRoot.getDurationLabel()
                font.pixelSize: Kirigami.Units.gridUnit * 0.5
                opacity: 0.75
                color: textColor
            }
        }

        // Quick 1-click Layout Mode Switcher Icon Button
        Rectangle {
            implicitWidth: 22
            implicitHeight: 22
            radius: 11
            color: layoutToggleMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : Qt.alpha(textColor, 0.08)

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitWidth: 12
                implicitHeight: 12
                source: {
                    var mode = Plasmoid.configuration.displayLayout || "tabbed";
                    if (mode === "tabbed") return "view-list-details";
                    if (mode === "horizontal") return "view-grid";
                    return "view-choose";
                }
                color: layoutToggleMouse.containsMouse ? accentColor : textColor
            }

            MouseArea {
                id: layoutToggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: headerRoot.cycleLayoutMode()
            }

            QQC2.ToolTip.visible: layoutToggleMouse.containsMouse
            QQC2.ToolTip.text: {
                var mode = Plasmoid.configuration.displayLayout || "tabbed";
                if (mode === "tabbed") return i18n("Switch to Horizontal Progress Bars");
                if (mode === "horizontal") return i18n("Switch to All-in-One Dashboard");
                return i18n("Switch to Tabbed View");
            }
        }

        // Right container displaying subscription quota usage percentage pill
        Rectangle {
            implicitWidth: percentLabel.implicitWidth + 10
            implicitHeight: 22
            radius: 11
            color: usagePercent >= 90 ? "#ff5555" : (usagePercent >= 75 ? "#ffb86c" : accentColor)

            // Usage percentage text label
            Text {
                id: percentLabel
                anchors.centerIn: parent
                text: usagePercent + "% Used"
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.5
                color: "#11111b"
            }
        }
    }
}

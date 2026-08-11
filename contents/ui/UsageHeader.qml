// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Header component displaying OpenCode Go subscription metadata, usage summary badge, and 1-click layout mode switcher toggle

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
    property bool isMock: true

    // Color tokens bound from configuration
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 46

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
        spacing: Kirigami.Units.smallSpacing

        // Left column containing plan title and billing cycle dates
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            // Row containing plan title label and optional demo mode indicator
            RowLayout {
                spacing: 6

                // Plan title text label
                PlasmaComponents.Label {
                    text: planName
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.85
                    color: textColor
                }

                // Demo mode badge indicator
                Rectangle {
                    visible: isMock
                    implicitWidth: demoText.implicitWidth + 8
                    implicitHeight: demoText.implicitHeight + 2
                    radius: 3
                    color: Qt.alpha(accentColor, 0.2)

                    Text {
                        id: demoText
                        anchors.centerIn: parent
                        text: i18n("DEMO")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.45
                        font.bold: true
                        color: accentColor
                    }
                }
            }

            // Billing cycle range text label
            PlasmaComponents.Label {
                text: billingPeriod
                font.pixelSize: Kirigami.Units.gridUnit * 0.6
                opacity: 0.7
                color: textColor
            }
        }

        // Quick 1-click Layout Mode Switcher Icon Button
        Rectangle {
            implicitWidth: 28
            implicitHeight: 28
            radius: 14
            color: layoutToggleMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : Qt.alpha(textColor, 0.08)

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitWidth: 16
                implicitHeight: 16
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
            implicitWidth: percentLabel.implicitWidth + 14
            implicitHeight: 28
            radius: 14
            color: usagePercent >= 90 ? "#ff5555" : (usagePercent >= 75 ? "#ffb86c" : accentColor)

            // Usage percentage text label
            Text {
                id: percentLabel
                anchors.centerIn: parent
                text: usagePercent + "% Used"
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.6
                color: "#11111b"
            }
        }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Full expanded representation component displaying metrics, vertical charts, horizontal bars, export, and settings shortcut

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../code/api.js" as Api

Rectangle {
    id: fullRoot

    // Layout mode flags bound from Plasmoid configuration ("tabbed", "all_in_one", "horizontal")
    property string layoutMode: Plasmoid.configuration.displayLayout || "tabbed"
    property bool isTabbed: layoutMode === "tabbed"
    property bool isAllInOne: layoutMode === "all_in_one"
    property bool isHorizontal: layoutMode === "horizontal"

    // Preferred layout dimensions for Plasma expanded popup representation
    Layout.minimumWidth: 380
    Layout.minimumHeight: isAllInOne ? 540 : (isHorizontal ? 350 : 380)
    Layout.preferredWidth: 420
    Layout.preferredHeight: isAllInOne ? 580 : (isHorizontal ? 360 : 400)

    // Currently selected chart view mode ("hourly", "weekly", "monthly")
    property string activeView: "weekly"

    // Custom theme colors bound from Plasmoid configuration
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    color: backgroundColor
    radius: 8
    border.width: Plasmoid.configuration.showBorder ? 1 : 0
    border.color: Qt.alpha(textColor, 0.25)

    // Exports usage statistics to CSV file
    function handleExport() {
        if (!root.usageData) return;
        var csvContent = Api.generateCSV(root.usageData);
        // Print CSV data overview to log output
        console.log("Exported CSV Usage Data:\n" + csvContent);
    }

    // Main column layout holding header, view selector, bar chart / horizontal bars, and footer
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit
        spacing: Kirigami.Units.smallSpacing

        // Usage header component displaying plan metadata and total percentage
        UsageHeader {
            id: usageHeader
            visible: Plasmoid.configuration.showTitle !== false
            Layout.fillWidth: true
            planName: root.usageData ? root.usageData.planName : "OpenCode Go"
            billingPeriod: root.usageData ? root.usageData.billingPeriod : "Current Cycle"
            usagePercent: root.usagePercent || 0
            isMock: root.usageData ? root.usageData.isMock : true
        }

        // View selector tab bar (visible only in Tabbed layout mode)
        ViewSelector {
            id: viewSelector
            visible: isTabbed
            Layout.fillWidth: true
            activeView: fullRoot.activeView
            onViewSelected: function(viewName) {
                fullRoot.activeView = viewName;
            }
        }

        // Error message banner displayed when network or auth fails
        Rectangle {
            visible: root.errorMessage !== ""
            Layout.fillWidth: true
            implicitHeight: errorText.implicitHeight + 8
            radius: 4
            color: Qt.alpha("#ff5555", 0.15)
            border.color: "#ff5555"
            border.width: 1

            Text {
                id: errorText
                anchors.centerIn: parent
                width: parent.width - 16
                wrapMode: Text.WordWrap
                text: root.errorMessage
                font.pixelSize: Kirigami.Units.gridUnit * 0.5
                color: "#ff5555"
            }
        }

        // Single vertical bar chart representation for Tabbed layout mode
        UsageBarChart {
            id: singleBarChart
            visible: isTabbed
            Layout.fillWidth: true
            Layout.fillHeight: true
            chartData: {
                if (!root.usageData) return [];
                if (fullRoot.activeView === "hourly") return root.usageData.hourly || [];
                if (fullRoot.activeView === "monthly") return root.usageData.monthly || [];
                return root.usageData.weekly || [];
            }
        }

        // Scrollable All-in-One Dashboard container showing all 3 vertical charts together
        QQC2.ScrollView {
            visible: isAllInOne
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Vertical column layout organizing all 3 usage section charts
            ColumnLayout {
                width: parent.width
                spacing: 12

                // Hourly Usage Section
                PlasmaComponents.Label {
                    text: i18n("📊 Hourly Usage (24 Hours)")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: root.usageData ? root.usageData.hourly || [] : []
                }

                // Weekly Usage Section
                PlasmaComponents.Label {
                    text: i18n("📅 Weekly Usage (7 Days)")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: root.usageData ? root.usageData.weekly || [] : []
                }

                // Monthly Usage Section
                PlasmaComponents.Label {
                    text: i18n("🗓️ Monthly Usage (4 Weeks)")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: root.usageData ? root.usageData.monthly || [] : []
                }
            }
        }

        // Horizontal Usage Bars Layout mode
        HorizontalUsageBars {
            visible: isHorizontal
            Layout.fillWidth: true
            Layout.fillHeight: true
            usageData: root.usageData
        }

        // Footer status bar row containing refresh details, export, and manual triggers
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            // Busy indicator spinner when fetching data
            QQC2.BusyIndicator {
                implicitWidth: 16
                implicitHeight: 16
                running: root.isLoading
                visible: root.isLoading
            }

            // Text label displaying last refreshed timestamp
            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: root.usageData ? i18n("Last updated: %1", root.usageData.lastRefreshed) : i18n("Loading...")
                font.pixelSize: Kirigami.Units.gridUnit * 0.5
                opacity: 0.6
                color: textColor
            }

            // Data export button trigger
            QQC2.Button {
                icon.name: "document-export"
                flat: true
                onClicked: fullRoot.handleExport()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Export Usage CSV")
            }

            // Manual refresh button trigger
            QQC2.Button {
                icon.name: "view-refresh"
                flat: true
                onClicked: root.refreshData()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Refresh Now")
            }

            // Configure widget settings button trigger
            QQC2.Button {
                icon.name: "configure"
                flat: true
                onClicked: {
                    var act = Plasmoid.action("configure");
                    if (act) act.trigger();
                }
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Configure Widget")
            }
        }
    }
}

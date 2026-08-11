// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Full expanded representation component displaying complete metrics, interactive charts, export, and settings shortcut

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../code/api.js" as Api

Rectangle {
    id: fullRoot

    // Preferred layout dimensions for Plasma expanded popup representation
    Layout.minimumWidth: 360
    Layout.minimumHeight: 380
    Layout.preferredWidth: 380
    Layout.preferredHeight: 400

    // Currently selected chart view mode ("hourly", "weekly", "monthly")
    property string activeView: "weekly"

    // Custom theme colors bound from Plasmoid configuration
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    color: backgroundColor
    radius: 8

    // Exports usage statistics to CSV file
    function handleExport() {
        if (!root.usageData) return;
        var csvContent = Api.generateCSV(root.usageData);
        // Print CSV data overview to log output
        console.log("Exported CSV Usage Data:\n" + csvContent);
    }

    // Main column layout holding header, view selector, bar chart, and footer
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit
        spacing: Kirigami.Units.smallSpacing

        // Usage header component displaying plan metadata and total percentage
        UsageHeader {
            id: usageHeader
            Layout.fillWidth: true
            planName: root.usageData ? root.usageData.planName : "OpenCode Go"
            billingPeriod: root.usageData ? root.usageData.billingPeriod : "Current Cycle"
            usagePercent: root.usagePercent || 0
            isMock: root.usageData ? root.usageData.isMock : true
        }

        // View selector tab bar for toggling chart intervals
        ViewSelector {
            id: viewSelector
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

        // Main bar chart visualization component
        UsageBarChart {
            id: barChart
            Layout.fillWidth: true
            Layout.fillHeight: true
            chartData: {
                if (!root.usageData) return [];
                if (fullRoot.activeView === "hourly") return root.usageData.hourly || [];
                if (fullRoot.activeView === "monthly") return root.usageData.monthly || [];
                return root.usageData.weekly || [];
            }
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

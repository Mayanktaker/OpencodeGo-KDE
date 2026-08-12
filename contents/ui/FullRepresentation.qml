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

    // Layout mode is fixed to horizontal (tabbed/all-in-one views disabled)
    property string layoutMode: "horizontal"
    property bool isTabbed: false
    property bool isAllInOne: false
    property bool isHorizontal: true

    // State properties populated from main.qml
    property var usageData: null
    property int usagePercent: 0
    property string errorMessage: ""
    property bool isLoading: false
    signal requestRefresh()

    // Preferred layout dimensions for Plasma expanded popup representation
    Layout.minimumWidth: 200
    Layout.minimumHeight: isAllInOne ? 300 : (isHorizontal ? 110 : 200)
    Layout.preferredWidth: 260
    Layout.preferredHeight: contentColumn.implicitHeight + Math.max(12, Math.round(12 * uiScale)) * 2

    // Currently selected chart view mode ("hourly", "weekly", "monthly")
    property string activeView: "weekly"

    // Custom theme colors bound from Plasmoid configuration
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    // Layout-aware scale factor shared by responsive child components
    property real baseWidth: 260
    property real baseHeight: 140
    property real widthScale: width / baseWidth
    property real heightScale: height > 0 ? height / baseHeight : widthScale
    property real uiScale: Math.max(0.75, Math.min(1.5, Math.min(widthScale, heightScale)))

    color: backgroundColor
    radius: 8
    border.width: (Plasmoid.configuration.showBorder === true) ? 1 : 0
    border.color: (Plasmoid.configuration.showBorder === true) ? Qt.alpha(textColor, 0.3) : "transparent"

    // Subtle top-to-bottom gradient for depth across all themes
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.lighter(backgroundColor, 1.08) }
        GradientStop { position: 1.0; color: Qt.darker(backgroundColor, 1.05) }
    }

    // Connections listening for live configuration property updates
    Connections {
        target: Plasmoid.configuration
        function onDisplayLayoutChanged() {
            fullRoot.layoutMode = Plasmoid.configuration.displayLayout || "tabbed";
        }
    }

    // Exports usage statistics to CSV file
    function handleExport() {
        if (!usageData) return;
        var csvContent = Api.generateCSV(usageData);
        // Display CSV data in export dialog
        csvTextArea.text = csvContent;
        exportDialog.open();
    }

    // Main column layout holding header, view selector, bar chart / horizontal bars, and footer
    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Math.max(8, Math.round(8 * fullRoot.uiScale))
        spacing: 0

        // Usage header component displaying plan metadata and total percentage
        UsageHeader {
            id: usageHeader
            visible: Plasmoid.configuration.showTitle !== false
            Layout.fillWidth: true
            planName: fullRoot.usageData ? fullRoot.usageData.planName : "OpenCode Go Usage Tracker"
            billingPeriod: fullRoot.usageData ? fullRoot.usageData.billingPeriod : "Current Cycle"
            usagePercent: fullRoot.usagePercent || 0
            isMock: fullRoot.usageData ? Boolean(fullRoot.usageData.isMock) : false
            usageData: fullRoot.usageData
            uiScale: fullRoot.uiScale
            onRequestRefresh: fullRoot.requestRefresh()
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
            visible: errorMessage !== ""
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
                text: errorMessage
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
                if (!fullRoot.usageData) return [];
                if (fullRoot.activeView === "hourly") return fullRoot.usageData.hourly || [];
                if (fullRoot.activeView === "monthly") return fullRoot.usageData.monthly || [];
                return fullRoot.usageData.weekly || [];
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
                    color: fullRoot.accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: fullRoot.usageData ? fullRoot.usageData.hourly || [] : []
                }

                // Weekly Usage Section
                PlasmaComponents.Label {
                    text: i18n("📅 Weekly Usage (7 Days)")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: fullRoot.accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: fullRoot.usageData ? fullRoot.usageData.weekly || [] : []
                }

                // Monthly Usage Section
                PlasmaComponents.Label {
                    text: i18n("🗓️ Monthly Usage (4 Weeks)")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: fullRoot.accentColor
                }
                UsageBarChart {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    chartData: fullRoot.usageData ? fullRoot.usageData.monthly || [] : []
                }
            }
        }

        // Horizontal Usage Bars Layout mode
        HorizontalUsageBars {
            id: horizontalBars
            visible: isHorizontal
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: horizontalBars.implicitHeight
            usageData: fullRoot.usageData
            uiScale: fullRoot.uiScale
        }

        // Footer — timestamp only
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing / 2

            // Busy indicator spinner when fetching data
            QQC2.BusyIndicator {
                implicitWidth: 10
                implicitHeight: 10
                running: isLoading
                visible: isLoading
            }

            // Text label displaying last refreshed timestamp
            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: fullRoot.usageData ? i18n("Last updated: %1", fullRoot.usageData.lastRefreshed) : i18n("Loading...")
                font.pixelSize: Kirigami.Units.gridUnit * 0.48
                opacity: 0.6
                color: fullRoot.textColor
            }
        }
    }

    // Export CSV Dialog overlay
    QQC2.Dialog {
        id: exportDialog
        anchors.centerIn: parent
        width: 400
        height: 300
        title: i18n("Export CSV Data")
        modal: true
        standardButtons: QQC2.Dialog.Close

        ColumnLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextArea {
                id: csvTextArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: ""
                readOnly: true
                wrapMode: Text.NoWrap
                font.family: "monospace"
            }

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Copy to Clipboard")
                icon.name: "edit-copy"
                onClicked: {
                    csvTextArea.selectAll();
                    csvTextArea.copy();
                    exportDialog.close();
                }
            }
        }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Horizontal usage progress bars component displaying usage metrics as horizontal progress rows

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: horizontalRoot

    // Input data object containing {hourly, weekly, monthly, usagePercent}
    property var usageData: null

    // Custom theme colors bound from Plasmoid configuration
    property color barColor: Plasmoid.configuration.barColor || "#89b4fa"
    property color barSecondaryColor: Plasmoid.configuration.barSecondaryColor || "#74c7ec"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"

    implicitHeight: 220

    // Calculates current aggregate used vs max limit for interval dataset
    function getIntervalMetrics(dataset) {
        if (!dataset || dataset.length === 0) return { used: 0, max: 100, pct: 0 };
        var lastItem = dataset[dataset.length - 1];
        var used = lastItem.value || 0;
        var max = lastItem.maxValue || 100;
        var pct = Math.min(100, Math.max(0, Math.round((used / max) * 100)));
        return { used: used, max: max, pct: pct };
    }

    // Column layout organizing 3 horizontal progress bar rows
    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Repeater generating horizontal progress rows for Hourly, Weekly, and Monthly metrics
        Repeater {
            model: [
                { id: "hourly", title: i18n("Hourly Usage"), icon: "preferences-system-time", data: usageData ? usageData.hourly : [] },
                { id: "weekly", title: i18n("Weekly Quota"), icon: "office-calendar", data: usageData ? usageData.weekly : [] },
                { id: "monthly", title: i18n("Monthly Limit"), icon: "view-calendar", data: usageData ? usageData.monthly : [] }
            ]

            // Progress row container column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // Extract metrics object for current interval row
                property var metrics: getIntervalMetrics(modelData.data)

                // Row header containing category icon, title, used count, and percentage
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Kirigami.Icon {
                        source: modelData.icon
                        implicitWidth: 16
                        implicitHeight: 16
                    }

                    PlasmaComponents.Label {
                        text: modelData.title
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.65
                        color: textColor
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: metrics.used + " / " + metrics.max
                        font.pixelSize: Kirigami.Units.gridUnit * 0.55
                        opacity: 0.7
                        color: textColor
                    }

                    Rectangle {
                        implicitWidth: pctText.implicitWidth + 8
                        implicitHeight: pctText.implicitHeight + 2
                        radius: 3
                        color: metrics.pct >= 90 ? "#ff5555" : (metrics.pct >= 75 ? "#ffb86c" : accentColor)

                        Text {
                            id: pctText
                            anchors.centerIn: parent
                            text: metrics.pct + "%"
                            font.bold: true
                            font.pixelSize: Kirigami.Units.gridUnit * 0.5
                            color: "#11111b"
                        }
                    }
                }

                // Interactive MouseArea for horizontal bar container
                MouseArea {
                    id: barMouseArea
                    Layout.fillWidth: true
                    implicitHeight: 22
                    hoverEnabled: true

                    // Bar background Track rectangle
                    Rectangle {
                        anchors.fill: parent
                        radius: 11
                        color: Qt.darker(backgroundColor, 1.4)
                        border.color: Qt.alpha(textColor, 0.1)
                        border.width: 1

                        // Animated horizontal progress fill bar rectangle
                        Rectangle {
                            id: fillBar
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 2
                            radius: 9
                            width: Math.max(18, (parent.width - 4) * (metrics.pct / 100))

                            // Gradient fill using primary and secondary theme bar colors
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: barColor }
                                GradientStop { position: 1.0; color: barSecondaryColor }
                            }

                            // Behavior animation for smooth horizontal fill width transition
                            Behavior on width {
                                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    // Tooltip displaying detailed statistics on bar hover
                    QQC2.ToolTip.visible: barMouseArea.containsMouse
                    QQC2.ToolTip.text: modelData.title + ": " + metrics.used + " of " + metrics.max + " (" + metrics.pct + "% used)"
                }
            }
        }
    }
}

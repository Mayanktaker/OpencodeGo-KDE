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

    property var usageData: null
    property bool showIcons: Plasmoid.configuration.showBarIcons !== false
    property real uiScale: 1.0

    property color barColor: Plasmoid.configuration.barColor || "#89b4fa"
    property color barSecondaryColor: Plasmoid.configuration.barSecondaryColor || "#74c7ec"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"

    implicitHeight: barsColumn.implicitHeight

    // Distinct colors per interval for visual differentiation
    property color rollingColor: Qt.alpha(textColor, 0.6)
    property color weeklyColor: accentColor
    property color monthlyColor: "#ffb86c"

    function getIntervalMetrics(dataset) {
        if (!dataset || dataset.length === 0) return { used: 0, max: 100, pct: 0 };
        var lastItem = dataset[dataset.length - 1];
        var used = lastItem.value || 0;
        var max = lastItem.maxValue || 100;
        var pct = Math.min(100, Math.max(0, Math.round((used / max) * 100)));
        return { used: used, max: max, pct: pct };
    }

    // Returns the color for a given bar index (0=rolling, 1=weekly, 2=monthly)
    function barTextColor(index) {
        if (index === 0) return rollingColor;
        if (index === 1) return weeklyColor;
        return monthlyColor;
    }

    ColumnLayout {
        id: barsColumn
        anchors.fill: parent
        spacing: Math.round(4 * uiScale)

        Repeater {
            model: [
                { id: "hourly", title: i18n("Rolling"), icon: "preferences-system-time", data: usageData ? usageData.hourly : [] },
                { id: "weekly", title: i18n("Weekly"), icon: "office-calendar", data: usageData ? usageData.weekly : [] },
                { id: "monthly", title: i18n("Monthly"), icon: "view-calendar", data: usageData ? usageData.monthly : [] }
            ]

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Math.round(uiScale)

                property var metrics: getIntervalMetrics(modelData.data)

                // Row header: title + colored percentage text
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Math.round(3 * uiScale)

                    // Optional icon (hidden by default)
                    Kirigami.Icon {
                        source: modelData.icon
                        implicitWidth: Math.round(10 * uiScale)
                        implicitHeight: Math.round(10 * uiScale)
                        color: textColor
                        visible: horizontalRoot.showIcons
                    }

                    PlasmaComponents.Label {
                        text: modelData.title
                        font.bold: true
                        font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.59 * uiScale)
                        color: textColor
                    }

                    Item { Layout.fillWidth: true }

                    // Colored percentage text (no background)
                    Text {
                        text: metrics.pct + "%"
                        font.bold: true
                        font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.48 * uiScale)
                        color: barTextColor(index)
                    }
                }

                // Bar track
                MouseArea {
                    id: barMouseArea
                    Layout.fillWidth: true
                    implicitHeight: Math.round(8 * uiScale)
                    hoverEnabled: true

                    Rectangle {
                        anchors.fill: parent
                        radius: Math.round(3 * uiScale)
                        color: Qt.darker(backgroundColor, 1.4)
                        border.color: barMouseArea.containsMouse ? accentColor : Qt.alpha(textColor, 0.15)
                        border.width: 1

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.darker(backgroundColor, 1.2) }
                            GradientStop { position: 1.0; color: Qt.darker(backgroundColor, 1.5) }
                        }

                        Rectangle {
                            id: fillBar
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: Math.max(1, Math.round(uiScale))
                            radius: Math.round(2 * uiScale)
                            width: Math.max(Math.round(4 * uiScale), (parent.width - 2 * Math.max(1, Math.round(uiScale))) * (metrics.pct / 100))

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: barColor }
                                GradientStop { position: 1.0; color: barSecondaryColor }
                            }

                            Behavior on width {
                                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    QQC2.ToolTip.visible: barMouseArea.containsMouse
                    QQC2.ToolTip.delay: 100
                    QQC2.ToolTip.text: modelData.title + ": " + metrics.used + " of " + metrics.max + " (" + metrics.pct + "% used)"
                }
            }
        }
    }
}

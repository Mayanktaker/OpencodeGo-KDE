// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Compact panel representation displaying icon with dynamic color-coded usage percentage badge overlay

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    // Preferred width and height for panel layout integration
    implicitWidth: panelRow.implicitWidth
    implicitHeight: panelRow.implicitHeight
    Layout.minimumWidth: panelRow.implicitWidth
    Layout.minimumHeight: panelRow.implicitHeight

    // State properties populated from main.qml
    property int usagePercent: 0

    // Computes dynamic status color based on percentage threshold
    function getBadgeColor(pct) {
        if (pct >= 90) return "#ff5555";
        if (pct >= 75) return "#ffb86c";
        return Plasmoid.configuration.accentColor || "#f38ba8";
    }

    // MouseArea handling click to expand full widget popup representation
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Plasmoid.expanded = !Plasmoid.expanded

        // Row container holding widget icon and usage percentage badge
        RowLayout {
            id: panelRow
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            // Plasma system icon component
            Kirigami.Icon {
                id: widgetIcon
                source: "com.mayanktaker.opencodego-usage"
                fallback: "office-chart-bar"
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
            }

            // Usage percentage badge indicator container
            Rectangle {
                id: badgeContainer
                implicitWidth: badgeLabel.implicitWidth + 8
                implicitHeight: badgeLabel.implicitHeight + 4
                radius: Kirigami.Units.smallSpacing
                color: compactRoot.getBadgeColor(usagePercent || 0)

                // Behavior animation for smooth badge color transitions
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                // Label displaying usage percentage value
                PlasmaComponents.Label {
                    id: badgeLabel
                    anchors.centerIn: parent
                    text: usagePercent !== undefined ? usagePercent + "%" : "--%"
                    font.pixelSize: Kirigami.Units.gridUnit * 0.55
                    font.bold: true
                    color: "#11111b"
                }
            }
        }

        // Tooltip displaying hover overview details
        QQC2.ToolTip.visible: mouseArea.containsMouse
        QQC2.ToolTip.text: i18n("OpenCode Go Usage: %1%\nClick to open usage chart", usagePercent || 0)
    }
}

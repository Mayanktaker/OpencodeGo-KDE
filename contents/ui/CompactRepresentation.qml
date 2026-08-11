// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Compact panel representation displaying icon with usage percentage badge overlay

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    // Preferred width and height for panel layout integration
    Layout.minimumWidth: panelRow.implicitWidth
    Layout.minimumHeight: panelRow.implicitHeight

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
                source: Plasmoid.icon || "office-chart-bar"
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
            }

            // Usage percentage badge indicator container
            Rectangle {
                id: badgeContainer
                implicitWidth: badgeLabel.implicitWidth + 8
                implicitHeight: badgeLabel.implicitHeight + 4
                radius: Kirigami.Units.smallSpacing
                color: Plasmoid.configuration.accentColor || "#f38ba8"

                // Label displaying usage percentage value
                PlasmaComponents.Label {
                    id: badgeLabel
                    anchors.centerIn: parent
                    text: root.usagePercent !== undefined ? root.usagePercent + "%" : "--%"
                    font.pixelSize: Kirigami.Units.gridUnit * 0.55
                    font.bold: true
                    color: "#11111b"
                }
            }
        }

        // Tooltip displaying hover overview details
        QQC2.ToolTip.visible: mouseArea.containsMouse
        QQC2.ToolTip.text: i18n("OpenCode Go Usage: %1%\nClick to open usage chart", root.usagePercent || 0)
    }
}

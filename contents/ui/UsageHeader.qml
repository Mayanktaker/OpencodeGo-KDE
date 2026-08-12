// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Header component displaying OpenCode Go subscription metadata and usage summary badge

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: headerRoot

    property string planName: "OpenCode Go Usage Tracker"
    property string billingPeriod: "Current Cycle"
    property int usagePercent: 0
    property bool isMock: false
    property var usageData: null
    property real uiScale: 1.0
    signal requestRefresh()

    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: Math.round(38 * uiScale)

    function getDurationLabel() {
        if (usageData && usageData.resetLabel) {
            return i18n("Usage resets in %1", usageData.resetLabel);
        }
        return i18n("Usage data");
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Row 1: title (left) + refresh (right)
        RowLayout {
            Layout.fillWidth: true
            spacing: Math.round(4 * uiScale)

            // Plan icon
            Kirigami.Icon {
                source: "com.mayanktaker.opencodego-usage"
                implicitWidth: Math.round(16 * uiScale)
                implicitHeight: Math.round(16 * uiScale)
            }

            // Title: "OpenCode Go" full size + "Usage Tracker" smaller
            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(4 * uiScale)

                PlasmaComponents.Label {
                    text: "OpenCode Go"
                    font.bold: true
                    font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.8 * uiScale)
                    color: textColor
                }

                PlasmaComponents.Label {
                    text: "Usage Tracker"
                    font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.46 * uiScale)
                    opacity: 0.6
                    color: textColor
                }
            }

            // Refresh button (smaller)
            Rectangle {
                implicitWidth: Math.round(14 * uiScale)
                implicitHeight: Math.round(14 * uiScale)
                radius: Math.round(3 * uiScale)
                color: refreshMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitWidth: Math.round(8 * uiScale)
                    implicitHeight: Math.round(8 * uiScale)
                    source: "view-refresh"
                    color: refreshMouse.containsMouse ? accentColor : textColor
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: headerRoot.requestRefresh()
                }

                QQC2.ToolTip.visible: refreshMouse.containsMouse
                QQC2.ToolTip.delay: 100
                QQC2.ToolTip.text: i18n("Refresh Now")
            }
        }

        // Row 2: subtitle
        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.topMargin: Math.round(uiScale)
            text: headerRoot.getDurationLabel()
            font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.53 * uiScale)
            opacity: 0.55
            color: textColor
        }
    }
}

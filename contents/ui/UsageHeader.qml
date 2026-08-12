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
    signal requestRefresh()

    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 38

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
            spacing: 4

            // Plan icon
            Kirigami.Icon {
                source: "com.mayanktaker.opencodego-usage"
                implicitWidth: 16
                implicitHeight: 16
            }

            // Title: "OpenCode Go" full size + "Usage Tracker" smaller
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                PlasmaComponents.Label {
                    text: "OpenCode Go"
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    color: textColor
                }

                PlasmaComponents.Label {
                    text: "Usage Tracker"
                    font.pixelSize: Kirigami.Units.gridUnit * 0.4
                    opacity: 0.6
                    color: textColor
                }
            }

            // Refresh button (smaller)
            Rectangle {
                implicitWidth: 14
                implicitHeight: 14
                radius: 3
                color: refreshMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitWidth: 8
                    implicitHeight: 8
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
            Layout.topMargin: 1
            text: headerRoot.getDurationLabel()
            font.pixelSize: Kirigami.Units.gridUnit * 0.45
            opacity: 0.55
            color: textColor
        }
    }
}

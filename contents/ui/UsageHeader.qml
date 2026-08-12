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

    implicitHeight: 36

    function getDurationLabel() {
        if (usageData && usageData.resetLabel) {
            return i18n("Usage resets in %1", usageData.resetLabel);
        }
        return i18n("Usage data");
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Row 1: icon + title + refresh + badge
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Kirigami.Icon {
                source: "com.mayanktaker.opencodego-usage"
                implicitWidth: 14
                implicitHeight: 14
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: planName
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.7
                color: textColor
                elide: Text.ElideRight
            }

            // Refresh
            Rectangle {
                implicitWidth: 16
                implicitHeight: 16
                radius: 3
                color: refreshMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitWidth: 10
                    implicitHeight: 10
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

            // Badge
            Rectangle {
                implicitWidth: percentLabel.implicitWidth + 8
                implicitHeight: 18
                radius: 3
                color: usagePercent >= 90 ? "#ff5555" : (usagePercent >= 75 ? "#ffb86c" : accentColor)

                Text {
                    id: percentLabel
                    anchors.centerIn: parent
                    text: usagePercent + "%"
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.5
                    color: "#11111b"
                }
            }
        }

        // Row 2: subtitle
        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.topMargin: 1
            text: headerRoot.getDurationLabel()
            font.pixelSize: Kirigami.Units.gridUnit * 0.45
            opacity: 0.6
            color: textColor
        }
    }
}

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

    // Data properties bound from root plasmoid state
    property string planName: "OpenCode Go"
    property string billingPeriod: "Current Cycle"
    property int usagePercent: 0
    property bool isMock: false
    property var usageData: null
    signal requestRefresh()

    // Color tokens bound from configuration
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 34

    // Formulates the reset countdown text
    function getDurationLabel() {
        if (usageData && usageData.resetLabel) {
            return i18n("Usage resets in %1", usageData.resetLabel);
        }
        return i18n("Usage data");
    }

    // Row layout for header alignment
    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing / 2

        // Left column containing plan title and reset countdown
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            // Plan title
            PlasmaComponents.Label {
                text: planName
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.75
                color: textColor
            }

            // Reset countdown label
            PlasmaComponents.Label {
                text: headerRoot.getDurationLabel()
                font.pixelSize: Kirigami.Units.gridUnit * 0.5
                opacity: 0.75
                color: textColor
            }
        }

        // Refresh button (near the badge)
        Rectangle {
            implicitWidth: 18
            implicitHeight: 18
            radius: 4
            color: refreshMouse.containsMouse ? Qt.alpha(accentColor, 0.25) : "transparent"

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitWidth: 12
                implicitHeight: 12
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

        // Usage percentage pill
        Rectangle {
            implicitWidth: percentLabel.implicitWidth + 10
            implicitHeight: 22
            radius: 4
            color: usagePercent >= 90 ? "#ff5555" : (usagePercent >= 75 ? "#ffb86c" : accentColor)

            Text {
                id: percentLabel
                anchors.centerIn: parent
                text: usagePercent + "%"
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.55
                color: "#11111b"
            }
        }
    }
}

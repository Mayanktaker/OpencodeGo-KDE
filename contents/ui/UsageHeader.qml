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

    // Public properties passed from FullRepresentation
    property string planName: "OpenCode Go Usage Tracker"
    property string billingPeriod: "Current Cycle"
    property int usagePercent: 0
    property bool isMock: false
    property bool isLoading: false
    property var usageData: null
    property real uiScale: 1.0
    // Corner radius of the parent card so the full-bleed stripe matches the widget's rounded top
    property real cardCornerRadius: Math.round(12 * uiScale)
    signal requestRefresh()

    // Theme color properties with configurable header background color
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"
    property color headerBackgroundColor: Plasmoid.configuration.headerBackgroundColor || Qt.darker(backgroundColor, 1.25)

    implicitHeight: Math.round(46 * uiScale)
    // Collapse to zero height when the title block is hidden in settings
    height: visible ? implicitHeight : 0
    // Clip the background's corner extension so only the top corners stay rounded
    clip: true

    // Full-bleed header stripe: spans full width, top corners match the card radius, straight bottom edge
    Rectangle {
        width: parent.width
        height: parent.height + headerRoot.cardCornerRadius
        color: headerRoot.headerBackgroundColor
        radius: headerRoot.cardCornerRadius
    }

    // Header inner layout row spanning the visible stripe (sibling of the stripe so it can anchor to headerRoot)
    RowLayout {
        anchors.fill: headerRoot
        anchors.leftMargin: Math.round(10 * uiScale)
        anchors.rightMargin: Math.round(10 * uiScale)
        anchors.topMargin: Math.round(6 * uiScale)
        anchors.bottomMargin: Math.round(6 * uiScale)
        spacing: Math.round(8 * uiScale)

        // Brand icon on the left vertically centered
        Kirigami.Icon {
            source: "com.mayanktaker.opencodego-usage"
            implicitWidth: Math.round(24 * uiScale)
            implicitHeight: Math.round(24 * uiScale)
            Layout.alignment: Qt.AlignVCenter
        }

        // Column containing title "OpenCode Go" and subtitle "Usage Tracker"
        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            // Title label
            PlasmaComponents.Label {
                text: "OpenCode Go"
                font.bold: true
                font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.85 * uiScale)
                color: headerRoot.textColor
                Layout.alignment: Qt.AlignLeft
            }

            // Subtitle label
            PlasmaComponents.Label {
                text: "Usage Tracker"
                font.pixelSize: Math.round(Kirigami.Units.gridUnit * 0.52 * uiScale)
                opacity: 0.55
                color: headerRoot.textColor
                Layout.alignment: Qt.AlignLeft
            }
        }

        // Flexible spacer pushing the refresh button to the far right edge
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // Circular refresh button container on top-right, aligned right & centered vertically
        Rectangle {
            id: refreshBtnContainer
            implicitWidth: Math.round(28 * uiScale)
            implicitHeight: Math.round(28 * uiScale)
            radius: width / 2
            color: refreshMouse.containsMouse ? Qt.alpha(headerRoot.accentColor, 0.2) : Qt.alpha(headerRoot.textColor, 0.08)
            border.color: refreshMouse.containsMouse ? headerRoot.accentColor : Qt.alpha(headerRoot.textColor, 0.18)
            border.width: 1
            scale: refreshMouse.containsMouse ? 1.08 : 1.0
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            // Smooth scale hover pulse transition animation
            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }

            // Refresh icon centered inside circle with rotation animation when loading
            Kirigami.Icon {
                id: refreshIcon
                anchors.centerIn: parent
                implicitWidth: Math.round(13 * uiScale)
                implicitHeight: Math.round(13 * uiScale)
                source: "view-refresh"
                color: refreshMouse.containsMouse ? headerRoot.accentColor : headerRoot.textColor

                // Continuous rotation animation when data fetching is active
                NumberAnimation on rotation {
                    running: headerRoot.isLoading
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 900
                }
            }

            // Mouse interaction for refresh button
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

    // Bottom hairline divider separating the full-bleed header stripe from card content
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.alpha(headerRoot.textColor, 0.1)
    }
}
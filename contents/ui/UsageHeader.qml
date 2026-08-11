// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Header component displaying OpenCode Go subscription metadata and usage summary badge

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: headerRoot

    // Data properties bound from root plasmoid state
    property string planName: "OpenCode Go"
    property string billingPeriod: "Current Cycle"
    property int usagePercent: 0
    property bool isMock: true

    // Color tokens bound from configuration
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 46

    // Row layout for header alignment
    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // Left column containing plan title and billing cycle dates
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            // Row containing plan title label and optional demo mode indicator
            RowLayout {
                spacing: 6

                // Plan title text label
                PlasmaComponents.Label {
                    text: planName
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.85
                    color: textColor
                }

                // Demo mode badge indicator
                Rectangle {
                    visible: isMock
                    implicitWidth: demoText.implicitWidth + 8
                    implicitHeight: demoText.implicitHeight + 2
                    radius: 3
                    color: Qt.alpha(accentColor, 0.2)

                    Text {
                        id: demoText
                        anchors.centerIn: parent
                        text: i18n("DEMO")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.45
                        font.bold: true
                        color: accentColor
                    }
                }
            }

            // Billing cycle range text label
            PlasmaComponents.Label {
                text: billingPeriod
                font.pixelSize: Kirigami.Units.gridUnit * 0.6
                opacity: 0.7
                color: textColor
            }
        }

        // Right container displaying subscription quota usage percentage pill
        Rectangle {
            implicitWidth: percentLabel.implicitWidth + 14
            implicitHeight: 28
            radius: 14
            color: accentColor

            // Usage percentage text label
            Text {
                id: percentLabel
                anchors.centerIn: parent
                text: usagePercent + "% Used"
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.6
                color: "#11111b"
            }
        }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// View selector tab bar component for switching between Hourly, Weekly, and Monthly usage views

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami

Rectangle {
    id: viewSelectorRoot

    // Signal emitted when selected view tab changes
    signal viewSelected(string viewName)

    // Currently active view mode ("hourly", "weekly", "monthly")
    property string activeView: "weekly"

    // Custom styling properties bound to Plasmoid configuration
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#1e1e2e"

    implicitHeight: 34
    radius: 6
    color: Qt.darker(backgroundColor, 1.2)

    // Row layout distributing tab selector buttons evenly
    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 4

        // Repeater generating tab buttons for available interval options
        Repeater {
            model: [
                { id: "hourly", label: i18n("Hourly") },
                { id: "weekly", label: i18n("Weekly") },
                { id: "monthly", label: i18n("Monthly") }
            ]

            // Tab button container rectangle
            Rectangle {
                id: tabBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 4
                color: activeView === modelData.id ? accentColor : "transparent"

                // Behavior animation for tab background color transition
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                // MouseArea for handling click interactions on tab button
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        activeView = modelData.id;
                        viewSelectorRoot.viewSelected(modelData.id);
                    }
                }

                // Text label displaying tab title
                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    font.bold: activeView === modelData.id
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    color: activeView === modelData.id ? "#11111b" : textColor
                }
            }
        }
    }
}

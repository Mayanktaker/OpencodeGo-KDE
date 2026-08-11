// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Pure QML bar chart component with dynamic responsive X-axis labels, gradient fill, smooth animations, and in-chart hover feedback

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: chartRoot
    clip: true

    // Input data array [{label: "Mon", value: 45, maxValue: 100}]
    property var chartData: []

    // Currently hovered data point item for in-chart feedback display
    property var activeHoverItem: null

    // Custom theme colors bound from Plasmoid configuration
    property color barColor: Plasmoid.configuration.barColor || "#89b4fa"
    property color barSecondaryColor: Plasmoid.configuration.barSecondaryColor || "#74c7ec"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 180

    // Calculates peak maximum value across all items in dataset safely
    function getPeakMax() {
        if (!chartData || chartData.length === 0) return 100;
        var peak = 0;
        for (var i = 0; i < chartData.length; i++) {
            if (chartData[i].value > peak) peak = chartData[i].value;
            if (chartData[i].maxValue > peak) peak = chartData[i].maxValue;
        }
        return peak > 0 ? peak : 100;
    }

    // Calculates visible label text interval step to prevent X-axis text overlap
    function getLabelStep() {
        if (!chartData || chartData.length <= 8) return 1;
        return Math.ceil(chartData.length / 8);
    }

    // Main column layout holding hover details banner, bar chart canvas, gridlines, and X-axis labels
    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // In-chart hover details feedback banner
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 20
            radius: 3
            color: activeHoverItem ? Qt.alpha(accentColor, 0.15) : "transparent"

            PlasmaComponents.Label {
                anchors.centerIn: parent
                visible: activeHoverItem !== null
                text: activeHoverItem ? (activeHoverItem.label + " — " + activeHoverItem.value + " / " + (activeHoverItem.maxValue || 1000) + " requests (" + Math.round((activeHoverItem.value / (activeHoverItem.maxValue || 1000)) * 100) + "% used)" + (activeHoverItem.resetLabel ? " — resets in " + activeHoverItem.resetLabel : "")) : ""
                font.bold: true
                font.pixelSize: Kirigami.Units.gridUnit * 0.55
                color: accentColor
            }
        }

        // Main bar chart canvas container area
        Item {
            id: graphArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Horizontal reference gridline at 50% peak capacity
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.5
                height: 1
                color: Qt.alpha(textColor, 0.15)

                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 2
                    text: Math.round(getPeakMax() * 0.5)
                    font.pixelSize: Kirigami.Units.gridUnit * 0.4
                    color: textColor
                    opacity: 0.4
                }
            }

            // Bars container row layout distributing vertical bars across available width
            RowLayout {
                anchors.fill: parent
                spacing: 2

                Repeater {
                    model: chartData

                    // Single bar item column containing interactive bar rectangle
                    Item {
                        id: barItem
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Interactive MouseArea for hover detection and details banner update
                        MouseArea {
                            id: barMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: chartRoot.activeHoverItem = modelData
                            onExited: {
                                if (chartRoot.activeHoverItem === modelData) {
                                    chartRoot.activeHoverItem = null;
                                }
                            }

                            // Bar fill rectangle anchored to bottom of graph area
                            Rectangle {
                                id: barRect
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                width: Math.max(3, Math.min(22, parent.width * 0.75))
                                radius: Math.min(width / 2, 4)

                                // Dynamic height calculation based on dataset value ratio
                                height: Math.max(4, (modelData.value / getPeakMax()) * graphArea.height)

                                // Gradient fill using primary and secondary theme bar colors
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: barMouseArea.containsMouse ? accentColor : barColor }
                                    GradientStop { position: 1.0; color: barSecondaryColor }
                                }

                                // Behavior animation for smooth height change transitions
                                Behavior on height {
                                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Responsive X-axis labels row layout with smart step filtering
        RowLayout {
            Layout.fillWidth: true
            implicitHeight: 18
            spacing: 2

            Repeater {
                model: chartData

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 18

                    Text {
                        anchors.centerIn: parent
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        // Display label text only at interval steps or end items to prevent overlap
                        text: (index % getLabelStep() === 0 || index === chartData.length - 1) ? modelData.label : ""
                        font.pixelSize: chartData.length > 12 ? Kirigami.Units.gridUnit * 0.4 : Kirigami.Units.gridUnit * 0.5
                        color: textColor
                        opacity: (index % getLabelStep() === 0 || index === chartData.length - 1) ? 0.75 : 0
                    }
                }
            }
        }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Pure QML bar chart component with gradient fill, smooth animations, and hover tooltips

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami

Item {
    id: chartRoot

    // Input data array containing objects with {label, value, maxValue}
    property var chartData: []

    // Custom theme colors bound from Plasmoid configuration
    property color barColor: Plasmoid.configuration.barColor || "#89b4fa"
    property color barSecondaryColor: Plasmoid.configuration.barSecondaryColor || "#74c7ec"
    property color textColor: Plasmoid.configuration.textColor || "#cdd6f4"
    property color accentColor: Plasmoid.configuration.accentColor || "#f38ba8"

    implicitHeight: 180

    // Calculates maximum upper bound across dataset for proportional scaling
    function getPeakMax() {
        if (!chartData || chartData.length === 0) return 100;
        var max = 1;
        for (var i = 0; i < chartData.length; i++) {
            if (chartData[i].maxValue > max) max = chartData[i].maxValue;
            if (chartData[i].value > max) max = chartData[i].value;
        }
        return max;
    }

    // Main column layout organizing graph drawing area and horizontal axis labels
    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Graph drawing area container
        Item {
            id: graphArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Reference grid dashed baseline at 50% capacity mark
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.5
                height: 1
                color: Qt.alpha(textColor, 0.15)
            }

            // Reference text label showing peak max scale value
            Text {
                anchors.right: parent.right
                anchors.top: parent.top
                text: getPeakMax()
                font.pixelSize: Kirigami.Units.gridUnit * 0.45
                color: textColor
                opacity: 0.5
            }

            // Row layout arranging bar elements horizontally across width
            Row {
                anchors.fill: parent
                spacing: Math.max(2, (width - (chartData.length * barWidthCalculated())) / Math.max(1, chartData.length - 1))

                // Helper function calculating dynamic bar width based on dataset count
                function barWidthCalculated() {
                    if (!chartData || chartData.length === 0) return 10;
                    return Math.max(6, Math.min(32, (graphArea.width / chartData.length) - 4));
                }

                // Repeater instantiating individual bar items from chartData model
                Repeater {
                    model: chartData

                    // Single bar item column containing interactive bar rectangle
                    Item {
                        id: barItem
                        width: parent.barWidthCalculated()
                        height: graphArea.height

                        // Interactive MouseArea for hover detection and tooltip display
                        MouseArea {
                            id: barMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            // Bar fill rectangle anchored to bottom of graph area
                            Rectangle {
                                id: barRect
                                width: parent.width
                                anchors.bottom: parent.bottom
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

                            // Tooltip displaying exact usage details on bar hover
                            QQC2.ToolTip.visible: barMouseArea.containsMouse
                            QQC2.ToolTip.text: modelData.label + "\nUsage: " + modelData.value + " / " + modelData.maxValue + " requests"
                        }
                    }
                }
            }
        }

        // Horizontal axis labels row
        Row {
            Layout.fillWidth: true
            height: 18
            spacing: Math.max(2, (width - (chartData.length * 24)) / Math.max(1, chartData.length - 1))

            // Repeater instantiating category labels under bars
            Repeater {
                model: chartData

                // Axis label text container
                Item {
                    width: 24
                    height: 18

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: chartData.length > 12 ? Kirigami.Units.gridUnit * 0.4 : Kirigami.Units.gridUnit * 0.5
                        color: textColor
                        opacity: 0.7
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}

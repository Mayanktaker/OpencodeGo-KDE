// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Keyboard shortcuts information page

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

QQC2.ScrollView {
    id: configShortcutsRoot
    clip: true

    ColumnLayout {
        width: Math.max(320, configShortcutsRoot.width - 32)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Item { implicitHeight: 4 }

        // Header
        QQC2.Label {
            text: i18n("Keyboard Shortcuts")
            font.bold: true
            font.pixelSize: Kirigami.Units.gridUnit * 0.9
            Layout.fillWidth: true
        }

        QQC2.Label {
            text: i18n("Use these shortcuts when the widget is focused:")
            font.pixelSize: Kirigami.Units.gridUnit * 0.6
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Shortcuts list
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: shortcutsCol.implicitHeight + 20
            radius: 6
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.15)
            border.width: 1

            ColumnLayout {
                id: shortcutsCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                // Refresh
                RowLayout {
                    spacing: 12
                    QQC2.Label {
                        text: "F5"
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        color: Kirigami.Theme.highlightColor
                        Layout.minimumWidth: 40
                    }
                    QQC2.Label {
                        text: i18n("Refresh usage data")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        Layout.fillWidth: true
                    }
                }

                // Configure
                RowLayout {
                    spacing: 12
                    QQC2.Label {
                        text: "F4"
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        color: Kirigami.Theme.highlightColor
                        Layout.minimumWidth: 40
                    }
                    QQC2.Label {
                        text: i18n("Open widget settings")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        Layout.fillWidth: true
                    }
                }

                // Close popup
                RowLayout {
                    spacing: 12
                    QQC2.Label {
                        text: "Esc"
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        color: Kirigami.Theme.highlightColor
                        Layout.minimumWidth: 40
                    }
                    QQC2.Label {
                        text: i18n("Close widget popup")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Item { implicitHeight: 4 }
    }
}

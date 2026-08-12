// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// About page displaying app identity, developer credits, and PayPal donation

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

QQC2.ScrollView {
    id: configAboutRoot
    clip: true

    ColumnLayout {
        width: Math.max(320, configAboutRoot.width - 32)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Item { implicitHeight: 4 }

        // App identity card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: appColumn.implicitHeight + 24
            radius: 8
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.08)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.25)
            border.width: 1

            ColumnLayout {
                id: appColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    source: "com.mayanktaker.opencodego-usage"
                    implicitWidth: 48
                    implicitHeight: 48
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("OpenCode Go Usage Tracker")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 1.0
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Version 1.0.0 • KDE Plasma 6.5+ & Wayland Native")
                    opacity: 0.6
                    font.pixelSize: Kirigami.Units.gridUnit * 0.55
                }
            }
        }

        // Developer credits
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: devCol.implicitHeight + 20
            radius: 6
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.15)
            border.width: 1

            ColumnLayout {
                id: devCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6

                RowLayout {
                    spacing: 6
                    Kirigami.Icon {
                        source: "user"
                        implicitWidth: 16
                        implicitHeight: 16
                    }
                    QQC2.Label {
                        text: i18n("Developer")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                    }
                }

                QQC2.Label {
                    text: i18n("Created by Mayanktaker")
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    opacity: 0.8
                }

                QQC2.Label {
                    text: i18n("© Mayanktaker Computers & Web Development")
                    font.pixelSize: Kirigami.Units.gridUnit * 0.55
                    opacity: 0.6
                }

                QQC2.Button {
                    icon.name: "globe"
                    text: i18n("mayanktaker.com")
                    onClicked: Qt.openUrlExternally("https://mayanktaker.com")
                }
            }
        }

        // Support / PayPal
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: payCol.implicitHeight + 20
            radius: 6
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.15)
            border.width: 1

            ColumnLayout {
                id: payCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6

                RowLayout {
                    spacing: 6
                    Kirigami.Icon {
                        source: "help-donate"
                        implicitWidth: 16
                        implicitHeight: 16
                    }
                    QQC2.Label {
                        text: i18n("Support Development")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                    }
                }

                QQC2.Label {
                    text: i18n("If you enjoy this widget, consider supporting future updates!")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                    opacity: 0.8
                }

                RowLayout {
                    spacing: 4
                    Kirigami.Icon {
                        source: "mail-message-new"
                        implicitWidth: 14
                        implicitHeight: 14
                    }
                    QQC2.Label {
                        text: "mayanktaker_hell@yahoo.co.in"
                        font.pixelSize: Kirigami.Units.gridUnit * 0.55
                        opacity: 0.7
                    }
                }

                QQC2.Button {
                    icon.name: "help-donate"
                    text: i18n("Donate via PayPal")
                    onClicked: Qt.openUrlExternally("https://paypal.me/mayanktaker")
                }
            }
        }

        Item { implicitHeight: 4 }
    }
}

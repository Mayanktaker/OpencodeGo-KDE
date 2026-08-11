// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// About settings tab QML page showing widget info, developer credits, website hyperlink, and PayPal donation card

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configAboutRoot

    // Main column layout holding application info, developer credit card, and donation card
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // App identity overview card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: appColumn.implicitHeight + 24
            radius: 8
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.08)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.2)
            border.width: 1

            ColumnLayout {
                id: appColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    source: "office-chart-bar"
                    implicitWidth: 48
                    implicitHeight: 48
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("OpenCode Go Usage Tracker")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 1.05
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Version 1.0.0 • KDE Plasma 6.5+ & Wayland Native")
                    opacity: 0.7
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                }
            }
        }

        // Developer Credit Card Section with distinct background color & icons
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: devColumn.implicitHeight + 24
            radius: 8
            color: "#181825"
            border.color: "#313244"
            border.width: 1

            ColumnLayout {
                id: devColumn
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    spacing: 8
                    Kirigami.Icon {
                        source: "user-identity"
                        implicitWidth: 22
                        implicitHeight: 22
                    }
                    QQC2.Label {
                        text: i18n("Developer Credits")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                        color: "#cdd6f4"
                    }
                }

                QQC2.Label {
                    text: i18n("Created by Mayanktaker")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 0.75
                    color: "#cba6f7"
                }

                QQC2.Label {
                    text: i18n("© Mayanktaker Computers & Web Development")
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                    color: "#a6adc8"
                }

                QQC2.Button {
                    icon.name: "internet-services"
                    text: i18n("Visit Website (mayanktaker.com)")
                    onClicked: Qt.openUrlExternally("https://mayanktaker.com")
                }
            }
        }

        // PayPal Donation Card Section with distinct brand background & PayPal email
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: paypalColumn.implicitHeight + 24
            radius: 8
            color: "#001c38"
            border.color: "#00457c"
            border.width: 1

            ColumnLayout {
                id: paypalColumn
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    spacing: 8
                    Kirigami.Icon {
                        source: "payment-card"
                        implicitWidth: 22
                        implicitHeight: 22
                    }
                    QQC2.Label {
                        text: i18n("Support Development (PayPal Donation)")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                        color: "#38bdf8"
                    }
                }

                QQC2.Label {
                    text: i18n("If you enjoy this widget, consider supporting future updates!")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                    color: "#e0f2fe"
                }

                RowLayout {
                    spacing: 6
                    Kirigami.Icon {
                        source: "mail-send"
                        implicitWidth: 16
                        implicitHeight: 16
                    }
                    QQC2.Label {
                        text: "PayPal Email: mayanktaker_hell@yahoo.co.in"
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        font.bold: true
                        color: "#7dd3fc"
                    }
                }

                QQC2.Button {
                    icon.name: "wallet"
                    text: i18n("Donate via PayPal")
                    onClicked: Qt.openUrlExternally("https://paypal.me/mayanktaker")
                }
            }
        }
    }
}

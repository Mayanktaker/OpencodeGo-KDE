// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Credits and support settings page displaying developer information, website hyperlink, and PayPal donation card

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

QQC2.ScrollView {
    id: configAboutRoot
    clip: true

    // Scrollable column layout containing app identity, developer credits, and PayPal donation card
    ColumnLayout {
        width: Math.max(320, configAboutRoot.width - 32)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        // Spacer padding top
        Item { implicitHeight: 4 }

        // App identity overview card
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
                spacing: 8

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    source: "com.mayanktaker.opencodego-usage"
                    implicitWidth: 56
                    implicitHeight: 56
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("OpenCode Go Usage Tracker")
                    font.bold: true
                    font.pixelSize: Kirigami.Units.gridUnit * 1.1
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Version 1.0.0 • KDE Plasma 6.5+ & Wayland Native")
                    opacity: 0.7
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                }
            }
        }

        // Developer Credit Card Section with distinct dark card background & icons
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
                anchors.margins: 16
                spacing: 10

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
                        font.pixelSize: Kirigami.Units.gridUnit * 0.85
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
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
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
                anchors.margins: 16
                spacing: 10

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
                        font.pixelSize: Kirigami.Units.gridUnit * 0.85
                        color: "#38bdf8"
                    }
                }

                QQC2.Label {
                    text: i18n("If you enjoy this widget, consider supporting future updates!")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
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
                        font.pixelSize: Kirigami.Units.gridUnit * 0.65
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

        // Spacer padding bottom
        Item { implicitHeight: 8 }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// About page displaying app identity, developer credits, and PayPal donation

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid 2.0

QQC2.ScrollView {
    id: configAboutRoot
    clip: true

    ColumnLayout {
        width: Math.max(320, configAboutRoot.width - 32)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        Item { implicitHeight: 4 }

        // App identity hero card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: heroCol.implicitHeight + 28
            radius: 12
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.10)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.30)
            border.width: 1

            ColumnLayout {
                id: heroCol
                anchors.fill: parent
                anchors.margins: 18
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
                    // Dynamic version from metadata.json — no manual updates needed
                    text: i18n("Version %1 • KDE Plasma 6 & Wayland Native", Plasmoid.metaData.version || "2.2.0")
                    opacity: 0.6
                    font.pixelSize: Kirigami.Units.gridUnit * 0.55
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    Kirigami.Icon {
                        source: "favorite"
                        implicitWidth: 14
                        implicitHeight: 14
                        color: Kirigami.Theme.negativeTextColor
                    }
                    QQC2.Label {
                        text: i18n("Crafted by Mayanktaker")
                        opacity: 0.7
                        font.pixelSize: Kirigami.Units.gridUnit * 0.55
                    }
                }
            }
        }

        // Developer credits
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: devCol.implicitHeight + 22
            radius: 10
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.18)
            border.width: 1

            ColumnLayout {
                id: devCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

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
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    }
                }

                RowLayout {
                    spacing: 10
                    Kirigami.Icon {
                        source: "user-identity"
                        implicitWidth: 22
                        implicitHeight: 22
                        color: Kirigami.Theme.highlightColor
                    }
                    ColumnLayout {
                        spacing: 2
                        QQC2.Label {
                            text: i18n("Mayanktaker")
                            font.bold: true
                            font.pixelSize: Kirigami.Units.gridUnit * 0.7
                        }
                        QQC2.Label {
                            text: i18n("© Mayanktaker Computers & Web Development")
                            opacity: 0.6
                            font.pixelSize: Kirigami.Units.gridUnit * 0.55
                        }
                    }
                }

                QQC2.Button {
                    Layout.fillWidth: true
                    icon.name: "globe"
                    text: i18n("Visit mayanktaker.com")
                    onClicked: Qt.openUrlExternally("https://mayanktaker.com")
                }
            }
        }

        // Open source repository card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: repoCol.implicitHeight + 22
            radius: 10
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.18)
            border.width: 1

            ColumnLayout {
                id: repoCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    spacing: 6
                    Kirigami.Icon {
                        source: "code-block"
                        implicitWidth: 16
                        implicitHeight: 16
                    }
                    QQC2.Label {
                        text: i18n("Open Source")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    }
                }

                RowLayout {
                    spacing: 10
                    Kirigami.Icon {
                        source: "code-class"
                        implicitWidth: 22
                        implicitHeight: 22
                        color: Kirigami.Theme.highlightColor
                    }
                    ColumnLayout {
                        spacing: 2
                        QQC2.Label {
                            text: i18n("GitHub Repository")
                            font.bold: true
                            font.pixelSize: Kirigami.Units.gridUnit * 0.7
                        }
                        QQC2.Label {
                            text: "github.com/Mayanktaker/OpencodeGo-KDE"
                            opacity: 0.6
                            font.pixelSize: Kirigami.Units.gridUnit * 0.55
                        }
                    }
                }

                QQC2.Button {
                    Layout.fillWidth: true
                    icon.name: "internet-services"
                    text: i18n("View Source on GitHub")
                    onClicked: Qt.openUrlExternally("https://github.com/Mayanktaker/OpencodeGo-KDE")
                }

                QQC2.Button {
                    Layout.fillWidth: true
                    icon.name: "tools-report-bug"
                    text: i18n("Report an Issue")
                    onClicked: Qt.openUrlExternally("https://github.com/Mayanktaker/OpencodeGo-KDE/issues")
                }
            }
        }

        // Support / PayPal
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: payCol.implicitHeight + 22
            radius: 10
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.06)
            border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.18)
            border.width: 1

            ColumnLayout {
                id: payCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

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
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                    }
                }

                QQC2.Label {
                    text: i18n("If you enjoy this widget, consider supporting future updates!")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                    opacity: 0.85
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 4
                    Kirigami.Icon {
                        source: "mail-message-new"
                        implicitWidth: 14
                        implicitHeight: 14
                        opacity: 0.8
                    }
                    QQC2.Label {
                        text: "mayanktaker_hell@yahoo.co.in"
                        font.pixelSize: Kirigami.Units.gridUnit * 0.55
                        opacity: 0.7
                    }
                }

                QQC2.Button {
                    Layout.fillWidth: true
                    icon.name: "help-donate"
                    text: i18n("Donate via PayPal")
                    onClicked: Qt.openUrlExternally("https://paypal.me/mayanktaker")
                }
            }
        }

        Item { implicitHeight: 4 }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// About settings tab QML page showing widget info, version, and developer credits

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configAboutRoot

    // Main column layout holding application logo, title, description, and link
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // App logo icon display
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            source: "office-chart-bar"
            implicitWidth: 64
            implicitHeight: 64
        }

        // Widget title label
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("OpenCode Go Usage Tracker")
            font.bold: true
            font.pixelSize: Kirigami.Units.gridUnit * 1.1
        }

        // Version text label
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Version 1.0.0 (KDE Plasma 6.5+ / Wayland)")
            opacity: 0.7
            font.pixelSize: Kirigami.Units.gridUnit * 0.7
        }

        // Description text label
        QQC2.Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: i18n("Track your OpenCode Go subscription quotas by hourly, weekly, and monthly intervals directly from your KDE desktop taskbar or panel.")
        }

        // Horizontal divider line
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Developer copyright & credits label
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("© Mayanktaker Computers & Web Development")
            font.bold: true
        }

        // Website link text label
        QQC2.UrlButton {
            Layout.alignment: Qt.AlignHCenter
            text: "https://mayanktaker.com"
            url: "https://mayanktaker.com"
        }
    }
}

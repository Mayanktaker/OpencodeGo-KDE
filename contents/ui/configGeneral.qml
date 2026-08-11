// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// General settings tab QML layout for Workspace ID, Auth Cookie, Refresh interval, and Notifications

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configGeneralRoot
    Layout.fillWidth: true
    topPadding: 20
    bottomPadding: 20
    leftPadding: 16
    rightPadding: 16

    // Configuration property aliases bound automatically via cfg_ prefix to main.xml
    property alias cfg_workspaceId: workspaceIdField.text
    property alias cfg_authCookie: authCookieField.text
    property int cfg_refreshInterval: 60000
    property alias cfg_enableNotifications: enableNotifyCheckBox.checked
    property alias cfg_notificationThreshold: thresholdSpinBox.value

    // Workspace ID input field
    QQC2.TextField {
        id: workspaceIdField
        Kirigami.FormData.label: i18n("Workspace ID:")
        placeholderText: i18n("e.g. ws_123456789")
        Layout.fillWidth: true
    }

    // Auth session cookie input field
    QQC2.TextField {
        id: authCookieField
        Kirigami.FormData.label: i18n("Auth Cookie:")
        placeholderText: i18n("Paste session auth cookie from opencode.ai")
        echoMode: QQC2.TextField.Password
        Layout.fillWidth: true
    }

    // Auto-refresh interval selection combo box
    QQC2.ComboBox {
        id: refreshIntervalCombo
        Kirigami.FormData.label: i18n("Refresh Interval:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("30 Seconds"), value: 30000 },
            { text: i18n("1 Minute"), value: 60000 },
            { text: i18n("5 Minutes"), value: 300000 },
            { text: i18n("10 Minutes"), value: 600000 }
        ]
        
        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i].value === cfg_refreshInterval) {
                    currentIndex = i;
                    break;
                }
            }
        }

        onActivated: {
            cfg_refreshInterval = currentValue;
        }
    }

    // Enable desktop quota alerts checkbox
    QQC2.CheckBox {
        id: enableNotifyCheckBox
        Kirigami.FormData.label: i18n("Quota Alerts:")
        text: i18n("Send desktop notification when usage threshold is exceeded")
    }

    // Quota alert percentage threshold spinbox
    RowLayout {
        Kirigami.FormData.label: i18n("Alert Threshold:")
        visible: enableNotifyCheckBox.checked
        spacing: 6

        QQC2.SpinBox {
            id: thresholdSpinBox
            from: 10
            to: 100
            stepSize: 5
            editable: true
        }

        QQC2.Label {
            text: i18n("% of plan quota")
        }
    }

    // Help instruction card box
    Kirigami.InlineMessage {
        Layout.fillWidth: true
        type: Kirigami.Information
        visible: true
        text: i18n("To obtain your Auth Cookie:\n1. Open opencode.ai in browser and log in.\n2. Open DevTools (F12) -> Application -> Cookies.\n3. Copy the value of the 'auth' cookie.\n4. Leave empty to use built-in Demo Mode.")
    }
}

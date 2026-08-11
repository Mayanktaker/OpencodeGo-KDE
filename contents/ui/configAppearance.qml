// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Appearance configuration page with layout mode selector, border toggle, dark & white theme presets, and custom color pickers

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configAppearanceRoot

    // Configuration property aliases bound automatically via cfg_ prefix to main.xml
    property alias cfg_displayLayout: layoutCombo.currentValue
    property alias cfg_showBorder: showBorderCheckBox.checked
    property alias cfg_activePreset: presetCombo.currentValue
    property alias cfg_backgroundColor: bgColorField.text
    property alias cfg_textColor: textColorField.text
    property alias cfg_barColor: barColorField.text
    property alias cfg_barSecondaryColor: bar2ColorField.text
    property alias cfg_accentColor: accentColorField.text

    // Apply color preset helper function with dark & white developer theme palettes
    function applyPreset(presetId) {
        if (presetId === "catppuccin_mocha") {
            cfg_backgroundColor = "#1e1e2e";
            cfg_textColor = "#cdd6f4";
            cfg_barColor = "#89b4fa";
            cfg_barSecondaryColor = "#74c7ec";
            cfg_accentColor = "#f38ba8";
        } else if (presetId === "breeze_dark") {
            cfg_backgroundColor = "#232629";
            cfg_textColor = "#eff0f1";
            cfg_barColor = "#3daee9";
            cfg_barSecondaryColor = "#2980b9";
            cfg_accentColor = "#fd971f";
        } else if (presetId === "nord_dark") {
            cfg_backgroundColor = "#2e3440";
            cfg_textColor = "#eceff4";
            cfg_barColor = "#88c0d0";
            cfg_barSecondaryColor = "#81a1c1";
            cfg_accentColor = "#bf616a";
        } else if (presetId === "dracula") {
            cfg_backgroundColor = "#282a36";
            cfg_textColor = "#f8f8f2";
            cfg_barColor = "#bd93f9";
            cfg_barSecondaryColor = "#8be9fd";
            cfg_accentColor = "#ff5555";
        } else if (presetId === "solarized_dark") {
            cfg_backgroundColor = "#002b36";
            cfg_textColor = "#839496";
            cfg_barColor = "#268bd2";
            cfg_barSecondaryColor = "#2aa198";
            cfg_accentColor = "#b58900";
        } else if (presetId === "gruvbox_dark") {
            cfg_backgroundColor = "#282828";
            cfg_textColor = "#ebdbb2";
            cfg_barColor = "#83a598";
            cfg_barSecondaryColor = "#8ec07c";
            cfg_accentColor = "#fabd2f";
        } else if (presetId === "tokyo_night") {
            cfg_backgroundColor = "#1a1b26";
            cfg_textColor = "#c0caf5";
            cfg_barColor = "#7aa2f7";
            cfg_barSecondaryColor = "#7dcfff";
            cfg_accentColor = "#f7768e";
        } else if (presetId === "one_dark") {
            cfg_backgroundColor = "#282c34";
            cfg_textColor = "#abb2bf";
            cfg_barColor = "#61afef";
            cfg_barSecondaryColor = "#56b6c2";
            cfg_accentColor = "#e06c75";
        } else if (presetId === "breeze_light") {
            cfg_backgroundColor = "#ffffff";
            cfg_textColor = "#232629";
            cfg_barColor = "#3daee9";
            cfg_barSecondaryColor = "#2980b9";
            cfg_accentColor = "#da4453";
        } else if (presetId === "catppuccin_latte") {
            cfg_backgroundColor = "#eff1f5";
            cfg_textColor = "#4c4f69";
            cfg_barColor = "#1e66f5";
            cfg_barSecondaryColor = "#209fb5";
            cfg_accentColor = "#8839ef";
        } else if (presetId === "solarized_light") {
            cfg_backgroundColor = "#fdf6e3";
            cfg_textColor = "#657b83";
            cfg_barColor = "#268bd2";
            cfg_barSecondaryColor = "#2aa198";
            cfg_accentColor = "#b58900";
        } else if (presetId === "paper_white") {
            cfg_backgroundColor = "#f8f9fa";
            cfg_textColor = "#212529";
            cfg_barColor = "#0d6efd";
            cfg_barSecondaryColor = "#0dcaf0";
            cfg_accentColor = "#d63384";
        }
    }

    // Layout style mode combo box selector
    QQC2.ComboBox {
        id: layoutCombo
        Kirigami.FormData.label: i18n("Display Layout:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Tabbed View (Hourly / Weekly / Monthly Tabs)"), value: "tabbed" },
            { text: i18n("All-in-One Dashboard (All 3 Charts Together)"), value: "all_in_one" },
            { text: i18n("Horizontal Progress Bars (Compact Progress Rows)"), value: "horizontal" }
        ]
    }

    // Outer card border toggle checkbox
    QQC2.CheckBox {
        id: showBorderCheckBox
        Kirigami.FormData.label: i18n("Outer Border:")
        text: i18n("Enable outer border outline on widget card")
    }

    // Theme preset combo box selector with 12 dark & light developer palettes
    QQC2.ComboBox {
        id: presetCombo
        Kirigami.FormData.label: i18n("Theme Preset:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Catppuccin Mocha (Default)"), value: "catppuccin_mocha" },
            { text: i18n("Breeze Dark"), value: "breeze_dark" },
            { text: i18n("Nord Dark"), value: "nord_dark" },
            { text: i18n("Dracula"), value: "dracula" },
            { text: i18n("Solarized Dark"), value: "solarized_dark" },
            { text: i18n("Gruvbox Dark"), value: "gruvbox_dark" },
            { text: i18n("Tokyo Night"), value: "tokyo_night" },
            { text: i18n("One Dark (VS Code)"), value: "one_dark" },
            { text: i18n("☀️ Breeze Light (White)"), value: "breeze_light" },
            { text: i18n("☀️ Catppuccin Latte (White)"), value: "catppuccin_latte" },
            { text: i18n("☀️ Solarized Light (White)"), value: "solarized_light" },
            { text: i18n("☀️ Paper White"), value: "paper_white" },
            { text: i18n("Custom Palette"), value: "custom" }
        ]

        onActivated: {
            if (currentValue !== "custom") {
                applyPreset(currentValue);
            }
        }
    }

    // Background color configuration row
    RowLayout {
        Kirigami.FormData.label: i18n("Background Color:")
        spacing: 8

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: 4
            color: cfg_backgroundColor
            border.color: "#666"
            border.width: 1
        }

        QQC2.TextField {
            id: bgColorField
            Layout.fillWidth: true
            onTextChanged: presetCombo.currentIndex = 12
        }

        QQC2.Button {
            text: i18n("Pick...")
            onClicked: bgDialog.open()
        }

        ColorDialog {
            id: bgDialog
            title: i18n("Select Background Color")
            selectedColor: cfg_backgroundColor
            onAccepted: cfg_backgroundColor = selectedColor.toString()
        }
    }

    // Text color configuration row
    RowLayout {
        Kirigami.FormData.label: i18n("Text Color:")
        spacing: 8

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: 4
            color: cfg_textColor
            border.color: "#666"
            border.width: 1
        }

        QQC2.TextField {
            id: textColorField
            Layout.fillWidth: true
            onTextChanged: presetCombo.currentIndex = 12
        }

        QQC2.Button {
            text: i18n("Pick...")
            onClicked: textDialog.open()
        }

        ColorDialog {
            id: textDialog
            title: i18n("Select Text Color")
            selectedColor: cfg_textColor
            onAccepted: cfg_textColor = selectedColor.toString()
        }
    }

    // Primary bar color configuration row
    RowLayout {
        Kirigami.FormData.label: i18n("Bar Primary Color:")
        spacing: 8

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: 4
            color: cfg_barColor
            border.color: "#666"
            border.width: 1
        }

        QQC2.TextField {
            id: barColorField
            Layout.fillWidth: true
            onTextChanged: presetCombo.currentIndex = 12
        }

        QQC2.Button {
            text: i18n("Pick...")
            onClicked: barDialog.open()
        }

        ColorDialog {
            id: barDialog
            title: i18n("Select Bar Primary Color")
            selectedColor: cfg_barColor
            onAccepted: cfg_barColor = selectedColor.toString()
        }
    }

    // Secondary bar gradient color configuration row
    RowLayout {
        Kirigami.FormData.label: i18n("Bar Secondary Color:")
        spacing: 8

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: 4
            color: cfg_barSecondaryColor
            border.color: "#666"
            border.width: 1
        }

        QQC2.TextField {
            id: bar2ColorField
            Layout.fillWidth: true
            onTextChanged: presetCombo.currentIndex = 12
        }

        QQC2.Button {
            text: i18n("Pick...")
            onClicked: bar2Dialog.open()
        }

        ColorDialog {
            id: bar2Dialog
            title: i18n("Select Bar Secondary Color")
            selectedColor: cfg_barSecondaryColor
            onAccepted: cfg_barSecondaryColor = selectedColor.toString()
        }
    }

    // Accent color configuration row
    RowLayout {
        Kirigami.FormData.label: i18n("Accent Color:")
        spacing: 8

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: 4
            color: cfg_accentColor
            border.color: "#666"
            border.width: 1
        }

        QQC2.TextField {
            id: accentColorField
            Layout.fillWidth: true
            onTextChanged: presetCombo.currentIndex = 12
        }

        QQC2.Button {
            text: i18n("Pick...")
            onClicked: accentDialog.open()
        }

        ColorDialog {
            id: accentDialog
            title: i18n("Select Accent Color")
            selectedColor: cfg_accentColor
            onAccepted: cfg_accentColor = selectedColor.toString()
        }
    }
}

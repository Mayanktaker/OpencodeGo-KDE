// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Configuration model defining settings tabs for Plasmoid configuration dialog

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    // General tab for Workspace ID, Auth Cookie, and Refresh interval settings
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system-network"
        source: "configGeneral.qml"
    }

    // Appearance tab for Theme presets and custom color selection
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "configAppearance.qml"
    }

    // Keyboard Shortcuts tab showing available shortcuts
    ConfigCategory {
        name: i18n("Keyboard Shortcuts")
        icon: "input-keyboard"
        source: "configKeyboardShortcuts.qml"
    }

    // Credits & Support tab displaying developer info, website, and PayPal donation link
    ConfigCategory {
        name: i18n("Credits & Support")
        icon: "help-about"
        source: "configAbout.qml"
    }
}

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

    // About tab displaying app information and developer credits
    ConfigCategory {
        name: i18n("About")
        icon: "help-about"
        source: "configAbout.qml"
    }
}

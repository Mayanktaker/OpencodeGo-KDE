// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Root PlasmoidItem entry point managing state, data fetching timer, and representations

import QtQuick
import QtQml
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../code/api.js" as Api

PlasmoidItem {
    id: root

    // Plasmoid identity properties
    title: i18n("OpenCode Go Usage Tracker")
    icon: "office-chart-bar"

    // State properties storing loaded usage data and UI flags
    property var usageData: null
    property int usagePercent: 0
    property bool isLoading: false
    property string errorMessage: ""

    // Compact representation component for panel tray placement
    compactRepresentation: CompactRepresentation {}

    // Full representation component for expanded desktop popup view
    fullRepresentation: FullRepresentation {}

    // Function to execute async usage data refresh from OpenCode API
    function refreshData() {
        isLoading = true;
        errorMessage = "";
        
        var wsId = Plasmoid.configuration.workspaceId || "";
        var cookie = Plasmoid.configuration.authCookie || "";

        Api.fetchUsageData(wsId, cookie, function(err, data) {
            isLoading = false;
            if (err) {
                errorMessage = err;
            }
            if (data) {
                usageData = data;
                usagePercent = data.usagePercent || 0;
            }
        });
    }

    // Timer handling periodic background data updates
    Timer {
        id: refreshTimer
        interval: Plasmoid.configuration.refreshInterval || 60000
        running: true
        repeat: true
        onTriggered: root.refreshData()
    }

    // Component initialization trigger
    Component.onCompleted: {
        root.refreshData();
    }

    // Connections listening for configuration updates from settings dialog
    Connections {
        target: Plasmoid.configuration

        // Handler for workspaceId configuration change
        function onWorkspaceIdChanged() {
            root.refreshData();
        }

        // Handler for authCookie configuration change
        function onAuthCookieChanged() {
            root.refreshData();
        }

        // Handler for refreshInterval configuration change
        function onRefreshIntervalChanged() {
            refreshTimer.interval = Plasmoid.configuration.refreshInterval || 60000;
            refreshTimer.restart();
        }
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Root PlasmoidItem entry point managing state, data fetching timer, notifications, and representations

import QtQuick
import QtQml
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmoidItem {
    id: root

    // Shared curl-based network transport (QML XHR cannot send the Cookie header)
    UsageFetcher { id: usageFetcher }

    // Disable default Plasma popup frame to eliminate unwanted outer borders
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // State properties storing loaded usage data and UI flags
    property var usageData: null
    property int usagePercent: 0
    property bool isLoading: false
    property string errorMessage: ""
    property int lastAlertedPercent: 0

    // Compact representation component for panel tray placement
    compactRepresentation: Component {
        CompactRepresentation {
            usagePercent: root.usagePercent
        }
    }

    // Full representation component for expanded desktop popup view
    fullRepresentation: Component {
        FullRepresentation {
            usageData: root.usageData
            usagePercent: root.usagePercent
            errorMessage: root.errorMessage
            isLoading: root.isLoading
            onRequestRefresh: root.refreshData()
        }
    }

    // Function to execute async usage data refresh from OpenCode API
    function refreshData() {
        isLoading = true;
        errorMessage = "";
        
        var wsId = Plasmoid.configuration.workspaceId || "";
        var cookie = Plasmoid.configuration.authCookie || "";

        usageFetcher.fetch(wsId, cookie, function(err, data) {
            isLoading = false;
            if (err) {
                errorMessage = err;
                // If a real error occurred, clear mock data so the UI doesn't say "Demo Mode"
                if (usageData && usageData.isMock) {
                    usageData = null;
                    usagePercent = 0;
                }
            } else {
                errorMessage = "";
            }
            if (data) {
                usageData = data;
                usagePercent = data.usagePercent || 0;

                // Send native desktop notification when usage threshold is exceeded
                var notifyEnabled = Plasmoid.configuration.enableNotifications !== false;
                var threshold = Plasmoid.configuration.notificationThreshold || 80;
                
                if (notifyEnabled && usagePercent >= threshold && lastAlertedPercent < threshold) {
                    lastAlertedPercent = usagePercent;
                    var title = "OpenCode Go Quota Warning";
                    var msg = "Subscription usage has reached " + usagePercent + "% (threshold: " + threshold + "%).";
                    if (typeof Plasmoid.showNotification === "function") {
                        Plasmoid.showNotification(title, msg, "dialog-warning");
                    } else if (typeof root.showPassiveNotification === "function") {
                        root.showPassiveNotification(msg, "short", "dialog-warning");
                    }
                    console.warn(title + ": " + msg);
                } else if (usagePercent < threshold) {
                    lastAlertedPercent = 0;
                }
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

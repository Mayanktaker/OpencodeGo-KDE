// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Shared network transport: runs the curl command via the Plasma executable dataengine
// (Qt's QML XMLHttpRequest strips the Cookie header, so we shell out to curl instead)

import QtQuick
import org.kde.plasma.plasma5support as P5S
import "../code/api.js" as Api

Item {
    id: fetcher
    visible: false
    width: 0
    height: 0

    // In-flight callbacks keyed by their curl command string (one at a time in practice)
    property var pending: ({})

    // Request context kept across a candidate-route retry
    property int activeRoute: 0
    property int routeAttempt: 0
    property string activeWorkspaceId: ""
    property string activeCookie: ""
    property var activeCallback: null

    // Runs curl for the currently selected candidate console route
    function attemptRoute() {
        var cmd = Api.buildCurlCommand(fetcher.activeWorkspaceId, fetcher.activeCookie, fetcher.activeRoute);
        // Stash the callback keyed by command so onNewData can route the result back to the caller
        var p = fetcher.pending;
        p[cmd] = fetcher.activeCallback;
        fetcher.pending = p;
        // Ask the executable engine to run curl once
        dataSource.connectSource(cmd);
    }

    // One-shot fetch; callback(errString, dataModel) mirrors the legacy api.js signature
    function fetch(workspaceId, authCookie, callback) {
        // No credentials -> demo mode (caller decides what to do)
        if (!authCookie || authCookie.trim() === "" || !workspaceId || workspaceId.trim() === "") {
            callback(null, Api.getMockData());
            return;
        }
        var cookieErr = Api.checkCookieError(authCookie);
        if (cookieErr) {
            callback(cookieErr, null);
            return;
        }
        // The console only accepts wrk_/org_ workspace ids, so catch bad values before spending a request
        var wsErr = Api.checkWorkspaceIdError(workspaceId);
        if (wsErr) {
            callback(wsErr, null);
            return;
        }

        // Remember the request context so a 404 on this path can walk to the next candidate route
        fetcher.activeWorkspaceId = workspaceId;
        fetcher.activeCookie = authCookie;
        fetcher.activeCallback = callback;
        fetcher.activeRoute = 0;
        fetcher.routeAttempt = 0;
        fetcher.attemptRoute();
    }

    // Plasma executable dataengine: runs the source string via the shell and returns stdout/stderr
    P5S.DataSource {
        id: dataSource
        engine: "executable"
        connectedSources: []
        interval: 0
        // Qt6: signal handlers are functions with explicit parameters (deprecated implicit injection)
        onNewData: function(sourceName, data) {
            var cb = fetcher.pending[sourceName];
            // Always release the source so repeated refreshes re-run curl cleanly
            dataSource.disconnectSource(sourceName);
            if (!cb) return;
            var p = fetcher.pending;
            delete p[sourceName];
            fetcher.pending = p;
            var stdout = (data["stdout"] || "").toString();
            var stderr = (data["stderr"] || "").toString();
            var exitCode = data["exit code"] !== undefined ? data["exit code"] : 0;
            var result = Api.parseCurlOutput(stdout, stderr, exitCode);
            // An unanswered candidate route means the console API moved — walk to the next path
            if (!result.error && !result.data && result.httpStatus === 404) {
                if (fetcher.activeRoute + 1 < Api.consoleRouteCount()) {
                    fetcher.activeRoute = fetcher.activeRoute + 1;
                    fetcher.routeAttempt = 0;
                    fetcher.attemptRoute();
                    return;
                }
                cb(Api.noRouteError(), null);
                return;
            }
            // The console API returns sporadic 5xx, so a transient failure is retried in place
            if (result.httpStatus >= 500 && fetcher.routeAttempt + 1 < Api.maxAttemptsPerRoute()) {
                fetcher.routeAttempt = fetcher.routeAttempt + 1;
                fetcher.attemptRoute();
                return;
            }
            cb(result.error, result.data);
        }
    }
}


// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Shared network transport: runs the curl command via the Plasma executable dataengine
// (Qt's QML XMLHttpRequest strips the Cookie header, so we shell out to curl instead)

import QtQuick
import org.kde.plasma.plasma5support as P5S
import "../code/api.js" as Api

QtObject {
    id: fetcher

    // In-flight callbacks keyed by their curl command string (one at a time in practice)
    property var pending: ({})

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

        var cmd = Api.buildCurlCommand(workspaceId, authCookie);
        // Stash the callback keyed by command so onNewData can route the result back to the caller
        var p = fetcher.pending;
        p[cmd] = callback;
        fetcher.pending = p;
        // Ask the executable engine to run curl once
        dataSource.connectSource(cmd);
    }

    // Plasma executable dataengine: runs the source string via the shell and returns stdout/stderr
    P5S.DataSource {
        id: dataSource
        engine: "executable"
        connectedSources: []
        interval: 0
        // Emitted once per source after the command finishes
        onNewData: {
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
            cb(result.error, result.data);
        }
    }
}


// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// API logic module for fetching, parsing, and exporting OpenCode Go subscription usage data

// Calculates integer percentage from used and total values safely
function calculatePercentage(used, total) {
    if (!total || total <= 0) return 0;
    return Math.min(100, Math.max(0, Math.round((used / total) * 100)));
}

// Normalizes a user-pasted auth credential into a valid HTTP Cookie header value
function buildCookieHeader(authCookie) {
    var val = (authCookie || "").trim();
    if (!val) return "";
    // Bare iron-session seal pasted without its cookie name (all opencode seals start with Fe26.2**)
    if (val.indexOf("Fe26") === 0) {
        return "auth=" + val;
    }
    // Already a name=value pair or a full Cookie header string (e.g. auth=...; __cf_bm=...)
    return val;
}

// Generates realistic mock usage data when no workspace credentials are provided
function getMockData() {
    var hourlyData = [];
    var currentHour = new Date().getHours();
    for (var i = 0; i < 24; i++) {
        var hourLabel = (i < 10 ? "0" + i : "" + i) + ":00";
        var val = (i === currentHour) ? 38 : Math.floor(Math.sin(i / 3) * 20 + 25);
        hourlyData.push({ label: hourLabel, value: val, maxValue: 50 });
    }

    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    var weeklyData = [];
    var currentDay = (new Date().getDay() + 6) % 7;
    for (var d = 0; d < 7; d++) {
        var dayVal = (d === currentDay) ? 680 : [420, 550, 710, 640, 890, 310, 250][d];
        weeklyData.push({ label: days[d], value: dayVal, maxValue: 1000 });
    }

    var monthlyData = [
        { label: "Week 1", value: 3450, maxValue: 5000 },
        { label: "Week 2", value: 4120, maxValue: 5000 },
        { label: "Week 3", value: 3890, maxValue: 5000 },
        { label: "Week 4", value: 2950, maxValue: 5000 }
    ];

    var activeWeeklyUsed = weeklyData[currentDay].value;
    var activeWeeklyMax = weeklyData[currentDay].maxValue;
    var usagePercent = calculatePercentage(activeWeeklyUsed, activeWeeklyMax);

    return {
        isMock: true,
        planName: "OpenCode Go (Demo Mode)",
        billingPeriod: "Aug 01 - Aug 31",
        usagePercent: usagePercent,
        // Demo reset countdowns so the per-window brackets are visible without real credentials
        resetSeconds: { hourly: 13500, weekly: 370800, monthly: 1659600 },
        hourly: hourlyData,
        weekly: weeklyData,
        monthly: monthlyData,
        lastRefreshed: new Date().toLocaleTimeString()
    };
}

// Wraps a string in POSIX single quotes so it is safe to inline in a shell command
function shellQuote(s) {
    // Single-quote the value, escaping any embedded single quotes via '"'"'
    return "'" + String(s).replace(/'/g, "'\\''") + "'";
}

// Validates the pasted auth credential and returns a user-facing error message, or "" when usable
function checkCookieError(authCookie) {
    var finalCookie = buildCookieHeader(authCookie);
    if (!finalCookie) return "";
    // Detect truncated cookie values copied from browser DevTools table
    if (finalCookie.indexOf("...") !== -1) {
        return "Auth Cookie is truncated (...). Double-click the cell in DevTools to copy the entire value, or copy the full Cookie header from the Network tab.";
    }
    // Real iron-session seals are several hundred characters long; shorter values are incomplete or bogus
    if (finalCookie.length < 150) {
        return "Auth Cookie looks incomplete or invalid. Paste the full 'auth' cookie for opencode.ai (starts with Fe26..., 500+ characters).";
    }
    return "";
}

// Builds the curl shell command used to fetch the Go page (Qt's QML XHR strips the Cookie header,
// so we shell out to curl which honors it; the executable Plasma dataengine runs the command)
function buildCurlCommand(workspaceId, authCookie) {
    var ws = String(workspaceId || "").trim();
    var cookie = buildCookieHeader(authCookie);
    var url = "https://opencode.ai/workspace/" + encodeURIComponent(ws) + "/go";
    // -sSL: silent + show errors + follow redirects (so an invalid cookie lands on the OpenAuth login page)
    // --max-time: bound the request so the widget never hangs
    var parts = [
        "curl", "-sSL", "--max-time", "15",
        "-H", shellQuote("Cookie: " + cookie),
        "-H", shellQuote("User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"),
        "-H", shellQuote("Accept: text/html,application/xhtml+xml,application/xml;q=0.9,application/json,*/*;q=0.8"),
        "-H", shellQuote("X-Workspace-Id: " + ws),
        shellQuote(url)
    ];
    return parts.join(" ");
}

// Parses the captured curl output (stdout HTML, stderr text, exit code) into the widget model
function parseCurlOutput(stdout, stderr, exitCode) {
    // curl exit 28 = timeout, 6 = DNS, 7 = connection refused, etc.
    if (exitCode && parseInt(exitCode, 10) !== 0) {
        // Non-zero exit: surface a helpful network/auth message
        var code = parseInt(exitCode, 10);
        if (code === 28) return { error: "Request timed out. Server did not respond within 15s.", data: null };
        if (code === 6 || code === 7) return { error: "Network unreachable. Please check your internet connection.", data: null };
        // Other codes still may have produced useful HTML on stdout (e.g. 200 body followed by a redirect chain error) — try parsing it
    }
    var body = stdout || "";
    if (!body && stderr) {
        return { error: "curl failed: " + String(stderr).slice(0, 200), data: null };
    }
    try {
        return { error: null, data: parseAnyResponse(body) };
    } catch (e) {
        return { error: e.message, data: null };
    }
}

// Detects the OpenAuth login page returned when auth credentials are rejected
function isOpenAuthLoginPage(text) {
    // Anchor on markers unique to the OpenAuth login page instead of a loose substring match
    return text.indexOf("<title>OpenAuth</title>") !== -1 ||
           text.indexOf("openauth.js.org") !== -1 ||
           text.indexOf("/github/authorize") !== -1 ||
           text.indexOf("/google/authorize") !== -1 ||
           text.indexOf("Continue with GitHub") !== -1 ||
           text.indexOf("Continue with Google") !== -1;
}

// Formats a seconds countdown into a natural multi-unit label (e.g. "3 hours 45 minutes")
function formatResetFull(sec) {
    sec = Math.max(0, Math.floor(Number(sec) || 0));
    if (sec <= 0) return "";
    var days = Math.floor(sec / 86400);
    var hours = Math.floor((sec % 86400) / 3600);
    var minutes = Math.floor((sec % 3600) / 60);
    var parts = [];
    if (days > 0) parts.push(days + (days === 1 ? " day" : " days"));
    if (hours > 0) parts.push(hours + (hours === 1 ? " hour" : " hours"));
    if (minutes > 0) parts.push(minutes + (minutes === 1 ? " minute" : " minutes"));
    if (parts.length === 0) {
        parts.push(sec + (sec === 1 ? " second" : " seconds"));
    }
    return parts.join(" ");
}

// Extracts usage windows from the authenticated SolidJS Go page's inlined store state
function parseSolidUsageStore(responseText) {
    // The three rolling usage windows the OpenCode Go page exposes
    var windows = ["rollingUsage", "weeklyUsage", "monthlyUsage"];
    var results = {};
    var found = false;
    for (var i = 0; i < windows.length; i++) {
        var key = windows[i];
        var keyIdx = responseText.indexOf(key + ":$R");
        if (keyIdx === -1) continue;
        found = true;
        // Read a fixed-size chunk after the marker to tolerate slightly different field ordering
        var chunk = responseText.substr(keyIdx, 300);
        var pctMatch = chunk.match(/usagePercent[^\d]*(\d+)/);
        var resetMatch = chunk.match(/resetInSec:(\d+)/);
        // Only record the window when its percentage was actually found
        if (pctMatch) {
            results[key] = parseInt(pctMatch[1], 10);
            if (resetMatch) results[key + "Reset"] = parseInt(resetMatch[1], 10);
        }
    }
    if (!found) return null;

    // Headline badge follows the same weekly-quota convention the widget's mock data uses
    var headline = results.weeklyUsage !== undefined ? results.weeklyUsage
                  : (results.monthlyUsage !== undefined ? results.monthlyUsage
                  : (results.rollingUsage !== undefined ? results.rollingUsage : 0));
    // Reset countdown of the headline window (weekly first), exposed for the header
    var headlineResetSec = results.weeklyUsageReset !== undefined ? results.weeklyUsageReset
                         : (results.monthlyUsageReset !== undefined ? results.monthlyUsageReset
                         : (results.rollingUsageReset !== undefined ? results.rollingUsageReset : 0));

    return {
        isMock: false,
        planName: "OpenCode Go Usage Tracker",
        billingPeriod: "Rolling / Weekly / Monthly",
        usagePercent: headline,
        // Per-window reset countdowns (seconds) used by the per-window bracket labels
        resetSeconds: {
            hourly: results.rollingUsageReset || 0,
            weekly: results.weeklyUsageReset || 0,
            monthly: results.monthlyUsageReset || 0
        },
        hourly: results.rollingUsage !== undefined ? [{ label: "Rolling", value: results.rollingUsage, maxValue: 100 }] : [],
        weekly: results.weeklyUsage !== undefined ? [{ label: "Weekly", value: results.weeklyUsage, maxValue: 100 }] : [],
        monthly: results.monthlyUsage !== undefined ? [{ label: "Monthly", value: results.monthlyUsage, maxValue: 100 }] : [],
        lastRefreshed: new Date().toLocaleTimeString()
    };
}

// Smart parser capable of extracting usage data from JSON responses, Next.js HTML payloads, or page text
function parseAnyResponse(responseText) {
    var trimmed = responseText.trim();
    
    // Case 1: Direct JSON payload
    if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
        try {
            var json = JSON.parse(trimmed);
            return parseUsageResponse(json);
        } catch (e) {}
    }

    // Case 2: OpenAuth login page returned (auth cookie invalid/expired)
    if (isOpenAuthLoginPage(trimmed)) {
        throw new Error("Auth Cookie is invalid or expired. Please update Auth Cookie in settings.");
    }

    // Case 3: Embedded __NEXT_DATA__ JSON in HTML
    var nextDataMatch = responseText.match(/<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)<\/script>/i);
    if (nextDataMatch && nextDataMatch[1]) {
        try {
            var nextObj = JSON.parse(nextDataMatch[1]);
            var props = nextObj.props || {};
            var pageProps = props.pageProps || {};
            var usageObj = pageProps.usage || pageProps.data || pageProps;
            return parseUsageResponse(usageObj);
        } catch (e) {}
    }

    // Case 4: SolidJS store state inlined on the authenticated Go page (rollingUsage/weeklyUsage/monthlyUsage)
    var solidModel = parseSolidUsageStore(responseText);
    if (solidModel) {
        return solidModel;
    }

    // Case 5: Regex pattern extraction for usagePercent values embedded in the page text
    var usagePercentMatch = responseText.match(/usagePercent[^\d]*(\d+)/i);
    if (usagePercentMatch) {
        var windowPct = parseInt(usagePercentMatch[1], 10);
        return {
            isMock: false,
        planName: "OpenCode Go Usage Tracker",
            billingPeriod: "Current Cycle",
            usagePercent: windowPct,
            resetSeconds: {},
            hourly: [],
            weekly: [{ label: "Usage", value: windowPct, maxValue: 100 }],
            monthly: [],
            lastRefreshed: new Date().toLocaleTimeString()
        };
    }

    throw new Error("Could not parse usage metrics. Server returned HTML instead of JSON.");
}

// Parses raw JSON response from OpenCode API into widget consumption model
function parseUsageResponse(data) {
    if (!data) data = {};
    return {
        isMock: false,
        planName: data.planName || data.name || "OpenCode Go Plan",
        billingPeriod: data.billingPeriod || data.period || "Current Billing Cycle",
        usagePercent: data.usagePercent || calculatePercentage(data.currentUsed || data.used || 0, data.currentLimit || data.limit || 100),
        resetSeconds: data.resetSeconds || {},
        hourly: data.hourly || [],
        weekly: data.weekly || [],
        monthly: data.monthly || [],
        lastRefreshed: new Date().toLocaleTimeString()
    };
}

// Generates formatted CSV content from usage data model
function generateCSV(data) {
    if (!data) return "";
    var lines = [];
    lines.push("Category,Label,Used,MaxLimit,Percentage");
    
    var weekly = data.weekly || [];
    for (var i = 0; i < weekly.length; i++) {
        var w = weekly[i];
        var pct = calculatePercentage(w.value, w.maxValue);
        lines.push("Weekly," + w.label + "," + w.value + "," + w.maxValue + "," + pct + "%");
    }

    var monthly = data.monthly || [];
    for (var m = 0; m < monthly.length; m++) {
        var mo = monthly[m];
        var pctMo = calculatePercentage(mo.value, mo.maxValue);
        lines.push("Monthly," + mo.label + "," + mo.value + "," + mo.maxValue + "," + pctMo + "%");
    }

    return lines.join("\n");
}

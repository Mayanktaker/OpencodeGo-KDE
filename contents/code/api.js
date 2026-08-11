// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// API logic module for fetching, parsing, and exporting OpenCode Go subscription usage data

// Calculates integer percentage from used and total values safely
function calculatePercentage(used, total) {
    if (!total || total <= 0) return 0;
    return Math.min(100, Math.max(0, Math.round((used / total) * 100)));
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
        hourly: hourlyData,
        weekly: weeklyData,
        monthly: monthlyData,
        lastRefreshed: new Date().toLocaleTimeString()
    };
}

// Primary API function to fetch usage data asynchronously using XMLHttpRequest
function fetchUsageData(workspaceId, authCookie, callback) {
    // Fallback to mock data if auth cookie or workspace ID is missing
    if (!authCookie || authCookie.trim() === "" || !workspaceId || workspaceId.trim() === "") {
        callback(null, getMockData());
        return;
    }

    var cleanWs = workspaceId.trim();
    // Default internal URL structure as requested
    var targetUrl = "https://opencode.ai/workspace/" + encodeURIComponent(cleanWs) + "/go";

    var xhr = new XMLHttpRequest();
    xhr.open("GET", targetUrl, true);

    // Set request headers for cookie authentication and session tracking
    var cookieVal = authCookie.trim();
    if (cookieVal.indexOf("=") !== -1) {
        xhr.setRequestHeader("Cookie", cookieVal);
    } else {
        xhr.setRequestHeader("Cookie", "auth=" + cookieVal + "; session=" + cookieVal);
        xhr.setRequestHeader("Authorization", "Bearer " + cookieVal);
    }
    
    xhr.setRequestHeader("Accept", "application/json, text/html, */*");
    xhr.setRequestHeader("X-Workspace-Id", cleanWs);

    // Configure timeout (10 seconds)
    xhr.timeout = 10000;

    // Handle ready state changes
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var responseText = xhr.responseText || "";
                    var parsedData = parseAnyResponse(responseText);
                    callback(null, parsedData);
                } catch (e) {
                    callback(e.message, null);
                }
            } else if (xhr.status === 401 || xhr.status === 403) {
                callback("Authentication failed (HTTP " + xhr.status + "). Check Auth Cookie.", null);
            } else {
                callback("Server error (HTTP " + xhr.status + ").", null);
            }
        }
    };

    xhr.onerror = function() {
        callback("Network request failed. Please check internet connection.", null);
    };

    xhr.ontimeout = function() {
        callback("Request timed out. Server did not respond.", null);
    };

    xhr.send();
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
    if (trimmed.indexOf("openauth") !== -1 || trimmed.indexOf("/github/authorize") !== -1 || trimmed.indexOf("/google/authorize") !== -1) {
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

    // Case 4: Regex pattern extraction for metrics embedded in text
    var hourlyMatch = responseText.match(/hourly[^\d]*(\d+)[^\d]+(\d+)/i);
    var weeklyMatch = responseText.match(/weekly[^\d]*(\d+)[^\d]+(\d+)/i);
    var monthlyMatch = responseText.match(/monthly[^\d]*(\d+)[^\d]+(\d+)/i);

    if (hourlyMatch || weeklyMatch || monthlyMatch) {
        return {
            isMock: false,
            planName: "OpenCode Go",
            billingPeriod: "Current Cycle",
            usagePercent: weeklyMatch ? calculatePercentage(parseInt(weeklyMatch[1], 10), parseInt(weeklyMatch[2], 10)) : 0,
            hourly: [],
            weekly: [],
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

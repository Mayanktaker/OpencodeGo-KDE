// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// API logic module for fetching, parsing, and exporting OpenCode Go subscription usage data

// Calculates integer percentage from used and total values safely
function calculatePercentage(used, total) {
    // Prevent division by zero
    if (!total || total <= 0) return 0;
    // Return clamped percentage
    return Math.min(100, Math.max(0, Math.round((used / total) * 100)));
}

// Generates realistic mock usage data when no workspace credentials are provided
function getMockData() {
    // Generate 24 hourly data points (00:00 to 23:00)
    var hourlyData = [];
    var currentHour = new Date().getHours();
    for (var i = 0; i < 24; i++) {
        var hourLabel = (i < 10 ? "0" + i : "" + i) + ":00";
        var val = (i === currentHour) ? 38 : Math.floor(Math.sin(i / 3) * 20 + 25);
        hourlyData.push({ label: hourLabel, value: val, maxValue: 50 });
    }

    // Generate 7 daily data points for current week (Mon-Sun)
    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    var weeklyData = [];
    var currentDay = (new Date().getDay() + 6) % 7;
    for (var d = 0; d < 7; d++) {
        var dayVal = (d === currentDay) ? 680 : [420, 550, 710, 640, 890, 310, 250][d];
        weeklyData.push({ label: days[d], value: dayVal, maxValue: 1000 });
    }

    // Generate 4 weekly data points for current month (W1-W4)
    var monthlyData = [
        { label: "Week 1", value: 3450, maxValue: 5000 },
        { label: "Week 2", value: 4120, maxValue: 5000 },
        { label: "Week 3", value: 3890, maxValue: 5000 },
        { label: "Week 4", value: 2950, maxValue: 5000 }
    ];

    // Calculate total usage percentage for current active period
    var activeWeeklyUsed = weeklyData[currentDay].value;
    var activeWeeklyMax = weeklyData[currentDay].maxValue;
    var usagePercent = calculatePercentage(activeWeeklyUsed, activeWeeklyMax);

    // Return complete mock response payload
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

    // Prepare target endpoint URL
    var targetUrl = "https://opencode.ai/api/workspace/" + encodeURIComponent(workspaceId.trim()) + "/usage";
    
    // Create XMLHttpRequest instance
    var xhr = new XMLHttpRequest();
    xhr.open("GET", targetUrl, true);

    // Set request headers for cookie authentication and session tracking
    xhr.setRequestHeader("Accept", "application/json");
    xhr.setRequestHeader("Cookie", "auth=" + authCookie.trim());
    xhr.setRequestHeader("X-Workspace-Id", workspaceId.trim());

    // Configure timeout (10 seconds)
    xhr.timeout = 10000;

    // Handle ready state changes
    xhr.onreadystatechange = function() {
        // Wait for request completion
        if (xhr.readyState === XMLHttpRequest.DONE) {
            // Check HTTP status code 200 OK
            if (xhr.status === 200) {
                try {
                    // Parse raw response text as JSON
                    var jsonResponse = JSON.parse(xhr.responseText);
                    var parsedData = parseUsageResponse(jsonResponse);
                    callback(null, parsedData);
                } catch (e) {
                    // Handle JSON parse error
                    callback("Failed to parse server response: " + e.message, getMockData());
                }
            } else if (xhr.status === 401 || xhr.status === 403) {
                // Handle unauthorized / invalid cookie
                callback("Authentication failed (HTTP " + xhr.status + "). Check Auth Cookie.", getMockData());
            } else {
                // Handle general server error
                callback("Server error (HTTP " + xhr.status + "). Showing cached data.", getMockData());
            }
        }
    };

    // Handle network level error
    xhr.onerror = function() {
        callback("Network request failed. Please check internet connection.", getMockData());
    };

    // Handle request timeout
    xhr.ontimeout = function() {
        callback("Request timed out. Server did not respond.", getMockData());
    };

    // Send HTTP request
    xhr.send();
}

// Parses raw JSON response from OpenCode API into widget consumption model
function parseUsageResponse(data) {
    // Return structured payload with fallbacks
    return {
        isMock: false,
        planName: data.planName || "OpenCode Go Plan",
        billingPeriod: data.billingPeriod || "Current Billing Cycle",
        usagePercent: data.usagePercent || calculatePercentage(data.currentUsed || 0, data.currentLimit || 100),
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
    
    // Process weekly records
    var weekly = data.weekly || [];
    for (var i = 0; i < weekly.length; i++) {
        var w = weekly[i];
        var pct = calculatePercentage(w.value, w.maxValue);
        lines.push("Weekly," + w.label + "," + w.value + "," + w.maxValue + "," + pct + "%");
    }

    // Process monthly records
    var monthly = data.monthly || [];
    for (var m = 0; m < monthly.length; m++) {
        var mo = monthly[m];
        var pctMo = calculatePercentage(mo.value, mo.maxValue);
        lines.push("Monthly," + mo.label + "," + mo.value + "," + mo.maxValue + "," + pctMo + "%");
    }

    return lines.join("\n");
}

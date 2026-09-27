#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# End-to-end tests for the GNOME extension against a real (headless) GNOME Shell.
#
#   ./run-live-tests.sh
#   LIVE_TEST_WS=wrk_… LIVE_TEST_COOKIE=st_… ./run-live-tests.sh   # adds a live-data check
#
# A stub server stands in for the console API so the outage, route-move,
# dead-session and network-failure paths are deterministic. gsettings is saved and
# restored and the installed copy is re-synced from the repo, so a run leaves no trace.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$(dirname "$HERE")"
REPO="$(dirname "$EXT_DIR")"
UUID="com.mayanktaker.opencodego-usage"
SCHEMA="org.gnome.shell.extensions.opencodego-usage"
INSTALL_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"
STUB_MODE="/tmp/opencodego-stub.mode"
STUB_HITS="/tmp/opencodego-stub.hits"
RIG="$HERE/live-test.sh"
# Fake but well-formed credentials for the stub scenarios
STUB_WS="wrk_01KE20AQRQ9QR7N15TWGJBE2V9"
STUB_COOKIE="st_0000000000000000000000000000000000"

# Seconds allowed for a scenario to produce its first PROBE line
SETTLE="${SETTLE:-16}"
# Longest wait for the outage scenario to observe the 5xx (needs a couple of polls)
OUTAGE_WAIT="${OUTAGE_WAIT:-150}"
STUB_PID=""

PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); printf '  \033[32mPASS\033[0m %s\n' "$1"; }
no() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m %s\n' "$1"; [ -n "${2:-}" ] && printf '        %s\n' "$2"; }
has() { case "$3" in *"$2"*) ok "$1" ;; *) no "$1" "expected to contain: $2" ;; esac; }
hasnt() { case "$3" in *"$2"*) no "$1" "unexpectedly contains: $2" ;; *) ok "$1" ;; esac; }
section() { printf '\n── %s\n' "$1"; }

# Re-syncs the pristine repo copy into the user extension directory
install_pristine() {
    "$RIG" down > /dev/null 2>&1
    rsync -a --delete --exclude 'install.sh' --exclude 'tests' --exclude '.git' "$EXT_DIR/" "$INSTALL_DIR/" || return 1
    glib-compile-schemas "$INSTALL_DIR/schemas/"
}

set_setting() { gsettings --schemadir "$INSTALL_DIR/schemas" set "$SCHEMA" "$1" "$2"; }
use_stub_credentials() {
    set_setting workspace-id "$STUB_WS"
    set_setting auth-cookie "$STUB_COOKIE"
    set_setting refresh-minutes "${1:-5}"
}
use_no_credentials() { set_setting workspace-id ""; set_setting auth-cookie ""; }

stub_mode() { printf '%s\n' "$1" > "$STUB_MODE"; : > "$STUB_HITS"; }
stub_log() { sort "$STUB_HITS" 2>/dev/null | uniq -c | tr -s ' ' | tr '\n' ';'; }

# probe <tag> -> the JSON object the injected reporter logged for that tag
probe() { "$RIG" log 6000 | grep "PROBE $1 " | tail -1 | sed -E "s/^.*PROBE $1 //"; }
# probe_last_tick -> the newest repeating-tick report, however many ticks have fired
probe_last_tick() { "$RIG" log 6000 | grep -oE "PROBE tick[0-9]+ .*" | tail -1 | sed -E "s/^PROBE tick[0-9]+ //"; }
field() { echo "$1" | grep -oE "\"$2\":(\"?[^\",}]*\"?)" | head -1 | sed -E "s/^\"$2\"://; s/^\"//; s/\"$//"; }

# Blocks until a probe tick reports the wanted status, so the test never races a
# refresh cycle. Returns non-zero if the status does not appear within the budget.
wait_for_status() {
    local want="$1" limit="${2:-$OUTAGE_WAIT}" waited=0 p
    while [ "$waited" -lt "$limit" ]; do
        p=$(probe_last_tick)
        case "$p" in *"\"status\":\"$want\""*) return 0 ;; esac
        sleep 5
        waited=$((waited + 5))
    done
    return 1
}

start_stub() {
    printf '500\n' > "$STUB_MODE"
    nohup python3 "$HERE/stub-server.py" 8899 "$STUB_MODE" "$STUB_HITS" > /dev/null 2>&1 &
    STUB_PID=$!
    sleep 1
}

cleanup() {
    "$RIG" down > /dev/null 2>&1
    [ -n "$STUB_PID" ] && kill "$STUB_PID" 2>/dev/null
    rm -f "$STUB_MODE" "$STUB_HITS"
    gsettings --schemadir "$INSTALL_DIR/schemas" reset-recursively "$SCHEMA" > /dev/null 2>&1
    install_pristine > /dev/null 2>&1
    printf '\n── %s passed, %s failed\n' "$PASS" "$([ "$FAIL" -eq 0 ] && echo 0 || echo "$FAIL")"
    [ "$FAIL" -eq 0 ]
}

# boot [extra settle seconds] — starts the rig and waits for the first PROBE line
boot() {
    "$RIG" up > /dev/null 2>&1 || { no "rig failed to start"; return 1; }
    sleep "$((${1:-$SETTLE}))"
}

# Scenarios that need the probe reporter and optionally repointed routes
boot_patched() {
    local routes="${1:-}" settle="${2:-$SETTLE}"
    install_pristine || { no "install"; return 1; }
    [ -n "$routes" ] && python3 "$HERE/live-patch.py" routes "$INSTALL_DIR/api.js" "$routes"
    python3 "$HERE/live-patch.py" probe "$INSTALL_DIR/extension.js" "$HERE/live-probe.js"
    boot "$settle"
}

trap cleanup EXIT
printf '══ GNOME extension live tests (headless shell rig)\n'
start_stub

# ---------------------------------------------------------------- demo mode
section "demo mode without credentials"
use_no_credentials
boot_patched
P=$(probe enable)
has "extension loads and enables" "State: ACTIVE" "$("$RIG" shell gnome-extensions info "$UUID" 2>&1)"
has "falls back to demo data" '"isMock":true' "$P"
has "renders the rolling window" "Rolling (5h)" "$P"
has "renders the weekly window" "Weekly" "$P"
has "renders the monthly window" "Monthly" "$P"
has "renders reset countdowns" "resets in" "$P"
has "labels the demo state" "Demo mode" "$P"
has "offers the console action" "Open OpenCode Console" "$P"
has "offers the settings action" "Settings" "$P"
ROWS=$(field "$P" menuRows)
[ "${ROWS:-0}" -gt 0 ] && [ "${ROWS:-0}" -lt 20 ] && ok "popup size is sane ($ROWS rows)" || no "popup size is sane" "menuRows=$ROWS"
has "panel uses the branded O✦ logo" "opencodego-symbolic.svg" "$(field "$P" icon)"
ERRS=$("$RIG" errors 20)
[ -z "$ERRS" ] && ok "journal is clean" || no "journal is clean" "$ERRS"

# ---------------------------------------------------------- transport rules
# transport_scenario <name> <routes target> <expected status> <message> <expectation>
transport_scenario() {
    local name="$1" target="$2" want_status="$3" want_msg="$4" want_hits="$5"
    section "$name"
    use_stub_credentials
    stub_mode "${target/refuse/500}"
    boot_patched "$target"
    local p hits
    p=$(probe enable)
    has "reports status=$want_status" "\"status\":\"$want_status\"" "$p"
    has "surfaces the expected message" "$want_msg" "$p"
    hits=$(stub_log)
    echo "        stub hits: ${hits:-none}"
    case "$want_hits" in
        same) hasnt "did not advance to another route" "/r1" "$hits" ;;
        walk) has "walked every candidate route" "/r2" "$hits" ;;
        one)  has "stopped after the first route" "/r0" "$hits" ;;
        none) [ -z "$hits" ] && ok "never reached the stub server" || no "never reached the stub server" "$hits" ;;
    esac
}

transport_scenario "HTTP 401 dead session"      401    error "Auth Cookie is invalid"    one
transport_scenario "HTTP 404 route moved"      404    error "route not found"           walk
transport_scenario "HTTP 500 transient storm"   500    error "temporarily unavailable"   same
# A closed port never reaches the stub, so "no hits" is the expected evidence
transport_scenario "network unreachable"       refuse error "Network unreachable"       none

# ------------------------------- an outage must not wipe the last known figures
section "5xx after live figures keeps them on screen"
use_stub_credentials 1
stub_mode flap
boot_patched flap
FIRST=$(probe enable)
has "first poll succeeded" '"status":"ok"' "$FIRST"
has "first poll was not mock data" '"isMock":false' "$FIRST"
# The stub serves one good response and then 5xx, so wait for the outage to land
# instead of guessing how many refresh cycles that takes
wait_for_status transient
LAST=$(probe_last_tick)
has "later polls report a transient outage" '"status":"transient"' "$LAST"
F_PCT=$(field "$FIRST" percent); L_PCT=$(field "$LAST" percent)
[ -n "$F_PCT" ] && [ "$F_PCT" = "$L_PCT" ] \
    && ok "last known figures retained ($F_PCT%)" \
    || no "last known figures retained" "$F_PCT vs $L_PCT"
has "popup still shows the windows" "Rolling (5h)" "$LAST"
has "popup notes the outage" "showing last known figures" "$LAST"
F_ROWS=$(field "$FIRST" menuRows); L_ROWS=$(field "$LAST" menuRows)
[ -n "$F_ROWS" ] && [ "$F_ROWS" = "$L_ROWS" ] \
    && ok "popup did not grow across refreshes ($L_ROWS rows)" \
    || no "popup did not grow across refreshes" "$F_ROWS -> $L_ROWS"

# ------------------------------------------------------------ prefs window
section "preferences window"
use_stub_credentials
boot_patched
DBUS_SESSION_BUS_ADDRESS="$(cat /tmp/opencodego-rig/bus.addr)" gnome-extensions prefs "$UUID" > /dev/null 2>&1
sleep 4
PREFS_LOG=$("$RIG" log 300)
hasnt "prefs window built a page" "did not provide any UI" "$PREFS_LOG"
hasnt "prefs window raised no error" "Failed to open preferences" "$PREFS_LOG"

# ------------------------------------------------------- enable/disable cycle
section "disable and re-enable"
"$RIG" shell gnome-extensions disable "$UUID" > /dev/null 2>&1
sleep 3
has "disable reports INACTIVE" "State: INACTIVE" "$("$RIG" shell gnome-extensions info "$UUID" 2>&1)"
TEARDOWN=$("$RIG" log 6000 | grep "PROBE teardown-before" | tail -1)
AFTER=$("$RIG" log 6000 | grep "PROBE teardown-after" | tail -1)
has "teardown released the poll slot" "inFlight=false" "$TEARDOWN"
hasnt "teardown dropped the panel entry" "opencodego-usage" "$AFTER"
[ "$("$RIG" alive)" = "up" ] && ok "shell survived the cycle" || no "shell survived the cycle"
"$RIG" shell gnome-extensions enable "$UUID" > /dev/null 2>&1
sleep 8
has "re-enable reports ACTIVE" "State: ACTIVE" "$("$RIG" shell gnome-extensions info "$UUID" 2>&1)"

# --------------------------------------------------------- real console data
if [ -n "${LIVE_TEST_WS:-}" ] && [ -n "${LIVE_TEST_COOKIE:-}" ]; then
    section "real console data"
    set_setting workspace-id "$LIVE_TEST_WS"
    set_setting auth-cookie "$LIVE_TEST_COOKIE"
    boot_patched
    P=$(probe enable)
    has "real figures loaded" '"status":"ok"' "$P"
    has "figures are live, not mock" '"isMock":false' "$P"
    PCT=$(field "$P" percent)
    case "$PCT" in
        ''|*[!0-9]*) no "headline percentage is numeric" "percent=$PCT" ;;
        *) ok "headline percentage is numeric ($PCT%)" ;;
    esac
    has "footer shows a refresh time" "Last refreshed" "$P"
    hasnt "no auth error" "Auth Cookie is invalid" "$P"
else
    section "real console data (skipped — set LIVE_TEST_WS and LIVE_TEST_COOKIE)"
fi

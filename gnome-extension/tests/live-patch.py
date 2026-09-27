#!/usr/bin/env python3
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Test-only surgery on an INSTALLED copy of the extension. The repo is never
# touched, and the install is re-synced from the repo after a test run.
#
#   live-patch.py probe  <installed>/extension.js <probe snippet>
#       Adds a `PROBE` reporter so shell tests can assert on runtime state.
#
#   live-patch.py routes <installed>/api.js <good|refuse>
#       Points CONSOLE_STATUS_ROUTES at a local stub server, or at a closed port
#       so the network-failure path can be exercised.
import sys

# Stub base URL and a port nothing listens on (curl exits 7 -> network error)
STUB_URLS = [
    "http://127.0.0.1:8899/r0/go/status",
    "http://127.0.0.1:8899/r1/go/status",
    "http://127.0.0.1:8899/r2/go/status",
]
DEAD_URLS = ["http://127.0.0.1:9/go/status"]


def patch_probe(path, snippet_path):
    src = open(path).read()
    snippet = open(snippet_path).read()
    replacements = [
        # import the probe helpers alongside the other module imports
        ("import * as Popup from './popup.js';", "import * as Popup from './popup.js';\n" + snippet),
        # report shortly after enable, then on a repeating tick so refresh cycles show up
        (
            "        this._indicator.refresh();\n    }\n\n    // Called on disable",
            "        this._indicator.refresh();\n"
            "        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 4, () => { probeState.call(this, 'enable'); return GLib.SOURCE_REMOVE; });\n"
            "        let tick = 0;\n"
            "        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 20, () => { probeState.call(this, 'tick' + (++tick)); return tick < 20 ? GLib.SOURCE_CONTINUE : GLib.SOURCE_REMOVE; });\n"
            "    }\n\n    // Called on disable",
        ),
        # report what teardown had to clean up, before and after the destroy
        (
            "        if (this._indicator) { this._indicator.destroy(); this._indicator = null; }",
            "        console.log('PROBE teardown-before inFlight=' + this._indicator._inFlight"
            " + ' hasTimer=' + (this._indicator._timerId !== null));\n"
            "        if (this._indicator) { this._indicator.destroy(); this._indicator = null; }\n"
            "        console.log('PROBE teardown-after statusArea=' + JSON.stringify(Object.keys(Main.panel.statusArea)));",
        ),
    ]
    for old, new in replacements:
        if old not in src:
            sys.exit(f"probe anchor not found: {old[:60]!r}")
        src = src.replace(old, new)
    open(path, "w").write(src)


def patch_routes(path, target):
    urls = DEAD_URLS if target == "refuse" else STUB_URLS
    src = open(path).read()
    anchor = "export const CONSOLE_STATUS_ROUTES = ["
    if anchor not in src:
        sys.exit("routes anchor not found")
    head, rest = src.split(anchor, 1)
    _, tail = rest.split("];", 1)
    body = "\n".join(f"    '{url}'," for url in urls)
    open(path, "w").write(f"{head}{anchor}\n{body}\n];{tail}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    command, target = sys.argv[1], sys.argv[2]
    if command == "probe":
        patch_probe(target, sys.argv[3])
    elif command == "routes":
        patch_routes(target, sys.argv[3])
    else:
        sys.exit(f"unknown command: {command}")

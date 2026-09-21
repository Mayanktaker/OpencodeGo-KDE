// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Panel indicator: fetches Go usage via curl and shows a hover popup with the three windows

import GObject from 'gi://GObject';
import GLib from 'gi://GLib';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

import * as Api from './api.js';
import * as Settings from './settings.js';
import * as Popup from './popup.js';

// Panel indicator button; hover opens the popup, click toggles it
const OpenCodeGoIndicator = GObject.registerClass(
class OpenCodeGoIndicator extends PanelMenu.Button {
    // Wires the icon, hover-to-open behavior, and the initial state
    _init() {
        super._init(0.0, 'OpenCode Go Usage', false);
        this._icon = new St.Icon({
            icon_name: 'applications-system-symbolic',
            style_class: 'system-status-icon'
        });
        this.add_child(this._icon);

        // Fetch state machine shared with popup.js
        this._state = { status: 'demo', data: null, error: null };

        // Hover opens the popup (GNOME tray tooltips do not exist, so the popup IS the tooltip)
        this.connect('enter-event', () => {
            if (!this.menu.isOpen) this.menu.open();
            return Clutter.EVENT_PROPAGATE;
        });

        // Initial paint with demo data so the popup is never empty
        this._setState({ status: 'demo', data: Api.getMockData(), error: null });
    }

    // Rebuilds popup content from state
    _setState(state) {
        this._state = state;
        Popup.buildMenuContent(this.menu, state);
    }

    // Runs one curl request honoring the route-walk and retry rules from api.js
    refresh() {
        // Single in-flight guard: a hover-triggered open never stacks curl processes
        if (this._inFlight) return;
        const ws = this._workspaceId;
        const cookie = this._authCookie;

        // No credentials -> demo mode, same as the KDE widget
        if (!cookie || !cookie.trim() || !ws || !ws.trim()) {
            this._setState({ status: 'demo', data: Api.getMockData(), error: null });
            this._scheduleNext();
            return;
        }
        const cookieErr = Api.checkCookieError(cookie);
        const wsErr = Api.checkWorkspaceIdError(ws);
        if (cookieErr || wsErr) {
            this._setState({ status: 'error', data: null, error: cookieErr || wsErr });
            this._scheduleNext();
            return;
        }

        this._inFlight = true;
        this._route = 0;
        this._attempt = 0;
        this._attemptRoute(ws, cookie);
    }

    // Fires curl for the current candidate route
    _attemptRoute(ws, cookie) {
        const cmd = Api.buildCurlCommand(ws, cookie, this._route);
        try {
            const [, stdout, stderr, exitStatus] = GLib.spawn_command_line_sync('sh -c ' + Api.shellQuote(cmd));
            // TextDecoder avoids deprecated Uint8Array.toString() (journal-warns today, garbage output in future gjs)
            this._handleOutput(new TextDecoder().decode(stdout), new TextDecoder().decode(stderr), exitStatus);
        } catch (e) {
            this._setState({ status: 'error', data: null, error: 'Network unreachable. Please check your internet connection.' });
            this._inFlight = false;
            this._scheduleNext();
        }
    }

    // Applies parse rules: 404 walks routes, 5xx retries in place, otherwise finalize
    _handleOutput(stdout, stderr, exitStatus) {
        const result = Api.parseCurlOutput(stdout, stderr, exitStatus);
        if (!result.error && !result.data && result.httpStatus === 404) {
            if (this._route + 1 < Api.consoleRouteCount()) {
                this._route += 1;
                this._attempt = 0;
                this._attemptRoute(this._workspaceId, this._authCookie);
                return;
            }
            this._setState({ status: 'error', data: null, error: Api.noRouteError() });
        } else if (result.httpStatus >= 500 && this._attempt + 1 < Api.maxAttemptsPerRoute()) {
            this._attempt += 1;
            this._attemptRoute(this._workspaceId, this._authCookie);
            return;
        } else if (result.error) {
            // Transient 5xx keeps only real live figures; mock data must never pose as "last known figures"
            if (result.httpStatus >= 500 && this._state.data && !this._state.data.isMock) {
                this._setState({ status: 'transient', data: this._state.data, error: result.error });
            } else {
                this._setState({ status: 'error', data: null, error: result.error });
            }
        } else {
            this._setState({ status: 'ok', data: result.data, error: null });
        }
        this._inFlight = false;
        this._scheduleNext();
    }

    // Arms the GLib timer for the next refresh; rebuilt whenever settings change
    _scheduleNext() {
        if (this._timerId) GLib.source_remove(this._timerId);
        this._timerId = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this._refreshSeconds, () => {
            this._timerId = null;
            this.refresh();
            return GLib.SOURCE_REMOVE;
        });
    }

    // Stops timer and any pending work (disable() must leave nothing behind)
    destroy() {
        if (this._timerId) { GLib.source_remove(this._timerId); this._timerId = null; }
        super.destroy();
    }
});

// Extension lifecycle: creates the indicator, reads settings, subscribes to changes
export default class OpenCodeGoExtension extends Extension {
    // Called on login/enable: build indicator, load settings, first fetch
    enable() {
        this._settings = Settings.getSettings();
        this._indicator = new OpenCodeGoIndicator();
        Main.panel.addToStatusArea(this.uuid, this._indicator, 0, 'right');

        // Settings reader bound onto the indicator so refresh() always sees current values
        this._applySettings = () => {
            this._indicator._workspaceId = Settings.getWorkspaceId(this._settings);
            this._indicator._authCookie = Settings.getAuthCookie(this._settings);
            this._indicator._refreshSeconds = Settings.getRefreshSeconds(this._settings);
        };
        this._applySettings();
        this._unsub = Settings.connectChanged(this._settings, ['workspace-id', 'auth-cookie', 'refresh-minutes'], () => {
            this._applySettings();
            this._indicator.refresh();
        });
        this._indicator.refresh();
    }

    // Called on disable/logout: tear down everything this extension created
    disable() {
        if (this._unsub) { this._unsub(); this._unsub = null; }
        if (this._indicator) { this._indicator.destroy(); this._indicator = null; }
        this._applySettings = null;
        this._settings = null;
    }
}

// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// libadwaita preferences: console credentials, refresh interval, connection test

import Adw from 'gi://Adw';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Gtk from 'gi://Gtk';
import * as Api from './api.js';
import { getSettings } from './settings.js';

// Bounds for the refresh spin row, in minutes
const REFRESH_MIN = 1;
const REFRESH_MAX = 60;

// Bounds for usage alert threshold percentage
const NOTIFY_THRESHOLD_MIN = 50;
const NOTIFY_THRESHOLD_MAX = 95;

// Colours for the connection test result
const RESULT_OK_COLOR = '#26a269';
const RESULT_ERROR_COLOR = '#ff5555';

// Decodes GLib's waitpid-encoded spawn status to the child exit code
const exitCodeOf = status => (status & 0xff00) >> 8;

// Preferences object built by the shell then asked to fill the Adw window it owns
export default class OpenCodeGoPrefs {
    // Adds credentials, panel appearance, and alert pages to preferences window
    fillPreferencesWindow(window) {
        const settings = getSettings();

        const page = new Adw.PreferencesPage({ title: 'OpenCode Go', icon_name: 'applications-system-symbolic' });
        const credentials = new Adw.PreferencesGroup({
            title: 'Console Credentials',
            description: 'In DevTools (F12) → Application → Cookies → opencode.ai: copy "__Host-console_session" (NOT "auth")',
        });
        page.add(credentials);

        // Workspace ID entry
        const wsRow = new Adw.EntryRow({ title: 'Workspace ID (wrk_…)' });
        settings.bind('workspace-id', wsRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        credentials.add(wsRow);

        // Session cookie entry with password reveal so the token is not left readable
        const cookieRow = new Adw.PasswordEntryRow({ title: 'Session Cookie (__Host-console_session, NOT "auth")' });
        settings.bind('auth-cookie', cookieRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        credentials.add(cookieRow);

        // Expandable browser guide explaining how to retrieve __Host-console_session
        const guideRow = new Adw.ExpanderRow({
            title: 'How to find your Session Cookie',
            subtitle: 'Step-by-step instructions for Chrome, Brave, Firefox & Edge',
        });
        const step1 = new Adw.ActionRow({
            title: '1. Open OpenCode Console',
            subtitle: 'Navigate to https://opencode.ai/console in your browser',
        });
        const step2 = new Adw.ActionRow({
            title: '2. Open Developer Tools',
            subtitle: 'Press F12 (or right-click → Inspect) to open the DevTools panel',
        });
        const step3 = new Adw.ActionRow({
            title: '3. Find __Host-console_session',
            subtitle: 'Go to Application tab (Storage in Firefox) → Cookies → https://opencode.ai',
        });
        const step4 = new Adw.ActionRow({
            title: '4. Copy the Cookie Value',
            subtitle: 'Copy the value of __Host-console_session (starts with st_...) and paste it above',
        });
        const stepNote = new Adw.ActionRow({
            title: '⚠️ Avoid "auth" (Fe26...) Cookie',
            subtitle: 'Do NOT copy "auth". That cookie belongs to the marketing site and causes HTTP 401.',
        });
        guideRow.add_row(step1);
        guideRow.add_row(step2);
        guideRow.add_row(step3);
        guideRow.add_row(step4);
        guideRow.add_row(stepNote);
        credentials.add(guideRow);

        // One-shot connection check, mirroring the KDE config's Test button
        const testRow = new Adw.ActionRow({ title: 'Test Connection' });
        const testButton = new Gtk.Button({
            label: 'Test',
            valign: Gtk.Align.CENTER,
            tooltip_text: 'Fetch usage once with the details above',
        });
        testButton.connect('clicked', () => this._testConnection(settings, testButton, testRow));
        testRow.add_suffix(testButton);
        testRow.activatable_widget = testButton;
        credentials.add(testRow);

        const behaviour = new Adw.PreferencesGroup({ title: 'Panel and Refresh' });
        page.add(behaviour);

        // Panel percentage badge toggle, mirroring the KDE widget's panel badge
        const badgeRow = new Adw.SwitchRow({
            title: 'Show percentage in the panel',
            subtitle: 'Enable or disable numeric metric in the top panel bar',
        });
        settings.bind('show-panel-badge', badgeRow, 'active', Gio.SettingsBindFlags.DEFAULT);
        behaviour.add(badgeRow);

        // Tray icon display mode selector
        const trayModes = [
            { id: 'weekly', name: 'Weekly Limit (Default)' },
            { id: 'fiveHour', name: '5-Hour Rolling Limit' },
            { id: 'monthly', name: 'Monthly Limit' },
            { id: 'all', name: 'All Three Limits (with icons)' },
            { id: 'none', name: 'Icon Only' },
        ];
        const stringList = new Gtk.StringList();
        trayModes.forEach(m => stringList.append(m.name));

        const trayRow = new Adw.ComboRow({
            title: 'Tray Icon Display',
            subtitle: 'Choose which quota metrics to display in the panel bar',
            model: stringList,
        });

        const currentMode = settings.get_string('tray-display-mode') || 'weekly';
        const currentIndex = Math.max(0, trayModes.findIndex(m => m.id === currentMode));
        trayRow.selected = currentIndex;

        trayRow.connect('notify::selected', () => {
            const selectedItem = trayModes[trayRow.selected];
            if (selectedItem) settings.set_string('tray-display-mode', selectedItem.id);
        });
        behaviour.add(trayRow);

        // Refresh interval spin row, 1–60 minutes
        const refreshRow = new Adw.SpinRow({
            title: 'Refresh interval (minutes)',
            subtitle: 'How often the panel icon re-checks your usage',
            adjustment: new Gtk.Adjustment({
                lower: REFRESH_MIN, upper: REFRESH_MAX, step_increment: 1,
                value: settings.get_uint('refresh-minutes'),
            }),
        });
        settings.bind('refresh-minutes', refreshRow, 'value', Gio.SettingsBindFlags.DEFAULT);
        behaviour.add(refreshRow);

        // Compact popup view toggle
        const compactRow = new Adw.SwitchRow({
            title: 'Compact popup view',
            subtitle: 'Reduces padding and height for a smaller popup menu footprint',
        });
        settings.bind('compact-mode', compactRow, 'active', Gio.SettingsBindFlags.DEFAULT);
        behaviour.add(compactRow);

        // Quota alerts group
        const notifyGroup = new Adw.PreferencesGroup({ title: 'Usage Alerts' });
        page.add(notifyGroup);

        const notifyRow = new Adw.SwitchRow({
            title: 'Enable quota notifications',
            subtitle: 'Alert when quota window crosses threshold percentage',
        });
        settings.bind('enable-notifications', notifyRow, 'active', Gio.SettingsBindFlags.DEFAULT);
        notifyGroup.add(notifyRow);

        const thresholdRow = new Adw.SpinRow({
            title: 'Alert threshold (%)',
            subtitle: 'Trigger alert when usage reaches this percentage',
            adjustment: new Gtk.Adjustment({
                lower: NOTIFY_THRESHOLD_MIN, upper: NOTIFY_THRESHOLD_MAX, step_increment: 5,
                value: settings.get_uint('notification-threshold'),
            }),
        });
        settings.bind('notification-threshold', thresholdRow, 'value', Gio.SettingsBindFlags.DEFAULT);
        notifyGroup.add(thresholdRow);

        window.add(page);
    }

    // Runs a single console request and reports the outcome on the row's subtitle
    _testConnection(settings, button, row) {
        const ws = settings.get_string('workspace-id');
        const cookie = settings.get_string('auth-cookie');

        // Reuse api.js validation so the message matches what the panel would show
        const problem = Api.checkWorkspaceIdError(ws) || Api.checkCookieError(cookie);
        if (problem) {
            this._report(row, problem, true);
            return;
        }

        button.sensitive = false;
        row.subtitle = 'Checking…';
        const proc = Gio.Subprocess.new(['sh', '-c', Api.buildCurlCommand(ws, cookie, 0)],
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE);
        proc.communicate_utf8_async(null, null, (obj, res) => {
            button.sensitive = true;
            let stdout = '', stderr = '', exitStatus = 0;
            try {
                [, stdout, stderr] = obj.communicate_utf8_finish(res);
                exitStatus = exitCodeOf(obj.get_if_exited() ? obj.get_status() : 0);
            } catch (e) {
                this._report(row, 'Could not reach the console. Check your internet connection.', true);
                return;
            }
            const result = Api.parseCurlOutput(stdout, stderr, exitStatus);
            if (result.error) {
                this._report(row, result.error, true);
                return;
            }
            const percent = result.data.usagePercent;
            this._report(row, `Connected — weekly usage ${percent}%`, false);
        });
    }

    // Shows a pass/fail message on the action row's subtitle
    _report(row, text, failed) {
        const color = failed ? RESULT_ERROR_COLOR : RESULT_OK_COLOR;
        // markup_escape_text needs an explicit length; -1 means "to the end"
        row.subtitle = `<span color="${color}">${GLib.markup_escape_text(text, -1)}</span>`;
    }
}

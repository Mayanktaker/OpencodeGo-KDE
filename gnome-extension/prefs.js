// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// libadwaita preferences: console credentials and refresh interval

import Adw from 'gi://Adw';
import Gio from 'gi://Gio';
import Gtk from 'gi://Gtk';
import { getSettings } from './settings.js';

// Bounds for the refresh spin row, in minutes
const REFRESH_MIN = 1;
const REFRESH_MAX = 60;

// Preferences object built by the shell (new prefsModule.default({...metadata, dir, path}))
// then asked to fill the Adw window it owns
export default class OpenCodeGoPrefs {
    // Adds the credentials + refresh page to the shell-provided preferences window
    fillPreferencesWindow(window) {
        const settings = getSettings();

        const page = new Adw.PreferencesPage({ title: 'OpenCode Go', icon_name: 'applications-system-symbolic' });
        const credentials = new Adw.PreferencesGroup({
            title: 'Console Credentials',
            description: 'Copy from opencode.ai/console → DevTools → Application → Cookies',
        });
        page.add(credentials);

        // Workspace ID entry
        const wsRow = new Adw.EntryRow({ title: 'Workspace ID (wrk_…)' });
        settings.bind('workspace-id', wsRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        credentials.add(wsRow);

        // Auth cookie entry with password reveal so the token is not left readable
        const cookieRow = new Adw.PasswordEntryRow({ title: 'Auth Cookie (__Host-console_session value)' });
        settings.bind('auth-cookie', cookieRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        credentials.add(cookieRow);

        const behaviour = new Adw.PreferencesGroup({ title: 'Refresh' });
        page.add(behaviour);

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

        window.add(page);
    }
}

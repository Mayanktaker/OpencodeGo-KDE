// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// libadwaita preferences window: credentials and refresh interval

import Adw from 'gi://Adw';
import Gtk from 'gi://Gtk';
import Gio from 'gi://Gio';
import { getSettings } from './settings.js';

// One preferences page binding the three gsettings keys to rows
export default class OpenCodeGoPrefs extends Adw.PreferencesWindow {
    // Builds rows and binds them bidirectionally to gsettings
    constructor(params = {}) {
        super(params);
        this.settings = getSettings();

        const page = new Adw.PreferencesPage({ title: 'OpenCode Go', icon_name: 'applications-system-symbolic' });
        const group = new Adw.PreferencesGroup({ title: 'Console Credentials', description: 'Copy from opencode.ai/console → DevTools → Application → Cookies' });
        page.add(group);

        // Workspace ID entry
        const wsRow = new Adw.EntryRow({ title: 'Workspace ID (wrk_…)' });
        this.settings.bind('workspace-id', wsRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        group.add(wsRow);

        // Auth cookie entry with password reveal so the token is not left readable
        const cookieRow = new Adw.PasswordEntryRow({ title: 'Auth Cookie (__Host-console_session value)' });
        this.settings.bind('auth-cookie', cookieRow, 'text', Gio.SettingsBindFlags.DEFAULT);
        group.add(cookieRow);

        // Refresh interval spin row, 1–60 minutes
        const refreshRow = new Adw.SpinRow({
            title: 'Refresh interval (minutes)', adjustment: new Gtk.Adjustment({
                lower: 1, upper: 60, step_increment: 1, value: this.settings.get_uint('refresh-minutes')
            })
        });
        this.settings.bind('refresh-minutes', refreshRow, 'value', Gio.SettingsBindFlags.DEFAULT);
        group.add(refreshRow);

        this.add(page);
    }
}

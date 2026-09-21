// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// gsettings access helpers for the extension runtime and prefs window

import Gio from 'gi://Gio';

// Schema id must match schemas/*.gschema.xml and the extension uuid family
const SCHEMA_ID = 'org.gnome.shell.extensions.opencodego-usage';

// Loads the compiled schema from the user extension directory (works installed and via gnome-session dev mode)
export function getSettings() {
    // GNOME Shell >= 45 resolves extension schemas automatically for installed extensions
    return new Gio.Settings({ schema_id: SCHEMA_ID });
}

// Workspace id accessor
export function getWorkspaceId(settings) { return settings.get_string('workspace-id'); }
// Auth cookie accessor
export function getAuthCookie(settings) { return settings.get_string('auth-cookie'); }
// Refresh interval in seconds (minutes * 60) with a one-minute floor
export function getRefreshSeconds(settings) {
    return Math.max(1, settings.get_uint('refresh-minutes')) * 60;
}
// Subscribes to key changes; cb receives the changed key name
export function connectChanged(settings, names, cb) {
    const ids = names.map(n => settings.connect('changed::' + n, (s, k) => cb(k)));
    return () => ids.forEach(id => settings.disconnect(id));
}

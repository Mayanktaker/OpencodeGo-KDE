// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Probe helpers injected by live-inject.py. Each reports a single `PROBE <tag> <json>`
// line so shell assertions can read one field at a time.

// Flips the panel badge preference from inside the shell process. The rig's
// private session bus has no dconf service, so an external `gsettings set` never
// reaches the shell; writing in-process is the only way to exercise the
// changed:: signal path here.
function probeToggleBadge(value) {
    this._settings.set_boolean('show-panel-badge', value);
    console.log('PROBE toggle ' + JSON.stringify({ sent: value }));
}

// Drives the preferences window's "Test Connection" without synthetic input: the
// shell stores the prefs object as the extension's stateObj, and the handler only
// touches .sensitive on the button and .subtitle on the row, so plain objects work.
function probeTestConnection() {
    const settings = this._settings;
    const row = { subtitle: '' };
    const button = { sensitive: true };
    // The shell keeps its prefs instance on its own internal wrapper, not on the
    // extension class, so the module is imported directly instead.
    import('./prefs.js').then(module => {
        const prefs = new module.default();
        prefs._testConnection(settings, button, row);
        let waited = 0;
        const poll = () => {
            if (row.subtitle && !row.subtitle.includes('Checking')) {
                console.log('PROBE conntest ' + JSON.stringify({ subtitle: row.subtitle, reenabled: button.sensitive }));
                return GLib.SOURCE_REMOVE;
            }
            if (++waited > 80) {
                console.log('PROBE conntest ' + JSON.stringify({ error: 'timed out', subtitle: row.subtitle }));
                return GLib.SOURCE_REMOVE;
            }
            return GLib.SOURCE_CONTINUE;
        };
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 250, poll);
    }).catch(e => {
        console.log('PROBE conntest ' + JSON.stringify({ error: e.message }));
    });
}

// Flattens the popup's labels so a test can assert on the rendered content
function probeLabels(root) {
    const out = [];
    const walk = actor => {
        for (const child of actor.get_children()) {
            if (child instanceof St.Label) out.push(child.text);
            walk(child);
        }
    };
    walk(root);
    return out;
}

// Reports fetch state, popup content size, action entries, panel icon and badge
function probeState(tag) {
    const ind = this._indicator;
    const data = ind._state.data;
    const icon = ind.get_children()[0]?.get_children()[0];
    const badge = ind.get_children()[0]?.get_children()[1];
    // WCAG relative luminance, so badge/panel readability can be asserted
    const channel = c => {
        const s = c / 255;
        return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
    };
    const luminance = rgba => 0.2126 * channel(rgba.red) + 0.7152 * channel(rgba.green) + 0.0722 * channel(rgba.blue);
    const contrast = (a, b) => {
        const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
        return (hi + 0.05) / (lo + 0.05);
    };
    const panelBg = Main.panel.get_theme_node().get_background_color();
    const badgeColor = badge?.get_theme_node().get_foreground_color();
    console.log('PROBE ' + tag + ' ' + JSON.stringify({
        status: ind._state.status,
        isMock: data ? !!data.isMock : null,
        percent: data ? data.usagePercent : null,
        error: ind._state.error,
        menuRows: ind.menu.box.get_n_children(),
        labels: probeLabels(ind.menu.box),
        // file:// means the branded O✦ logo loaded; a bare name means the stock fallback
        icon: icon?.gicon ? icon.gicon.to_string() : null,
        iconSize: icon ? icon.get_width() + 'x' + icon.get_height() : null,
        badgeText: badge?.text ?? null,
        badgeVisible: badge?.visible ?? null,
        // how readable the badge is against the panel background in this theme
        badgeContrast: badgeColor ? Number(contrast(panelBg, badgeColor).toFixed(2)) : null,
    }));
}

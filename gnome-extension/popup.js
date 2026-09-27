// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Builds the hover/click popup: header, three usage bars, footer status note

import St from 'gi://St';
import * as Api from './api.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

// Percent above which the bar fill turns red to signal quota pressure
const RED_TINT_THRESHOLD = 90;

// Fully opaque warning red for over-threshold fills (Cairo 0..1 channels)
const RED_TINT_RGB = { red: 0.9, green: 0.2, blue: 0.2 };

// Bar rendering constants: background/track and fill opacity, bar height in px
const TRACK_ALPHA = 0.25;
const FILL_ALPHA = 1.0;
const BAR_HEIGHT_PX = 8;

// Row definition shared by the three windows: popup label + model slot + reset key
const WINDOWS = [
    { label: 'Rolling (5h)', slot: 'hourly', resetKey: 'hourly' },
    { label: 'Weekly', slot: 'weekly', resetKey: 'weekly' },
    { label: 'Monthly', slot: 'monthly', resetKey: 'monthly' }
];

// Empties the menu so a refresh can rebuild it without stacking items.
// removeAll() only reaches registered PopupBaseMenuItem actors, so the plain St
// rows built here would survive every rebuild and duplicate the popup; the sweep
// after it clears the strays (and removeAll() first keeps menu.length accurate).
export function clearMenuContent(menu) {
    menu.removeAll();
    menu.box.destroy_all_children();
}

// Formats a seconds countdown for the bar sub-label (falls back to full formatter)
function resetLabel(seconds) {
    return Api.formatResetFull(seconds);
}

// Builds one usage row: label + percent on top, bar + countdown below
function addUsageRow(menu, labelText, percent, resetSeconds) {
    const rowLabel = new St.BoxLayout({ vertical: false, x_expand: true });
    rowLabel.add_child(new St.Label({ text: labelText, x_expand: true }));
    rowLabel.add_child(new St.Label({ text: percent + '%' }));
    menu.box.add_child(rowLabel);

    // Progress bar uses the theme accent; fill turns red above the quota-pressure threshold
    const bar = new St.DrawingArea({ style_class: 'popup-menu-item', x_expand: true, height: BAR_HEIGHT_PX });
    const fill = Math.max(0, Math.min(100, percent)) / 100;
    bar.connect('repaint', area => {
        const [w, h] = area.get_surface_size();
        const cr = area.get_context();
        const themeNode = area.get_theme_node();
        const fg = themeNode.get_foreground_color();
        const useRedTint = percent > RED_TINT_THRESHOLD;
        cr.setSourceRGBA(fg.red / 255, fg.green / 255, fg.blue / 255, TRACK_ALPHA);
        cr.rectangle(0, h / 4, w, h / 2);
        cr.fill();
        if (useRedTint) cr.setSourceRGB(RED_TINT_RGB.red, RED_TINT_RGB.green, RED_TINT_RGB.blue);
        else cr.setSourceRGBA(fg.red / 255, fg.green / 255, fg.blue / 255, FILL_ALPHA);
        cr.rectangle(0, h / 4, Math.round(w * fill), h / 2);
        cr.fill();
        cr.$dispose();
    });
    menu.box.add_child(bar);

    if (resetSeconds > 0) {
        const sub = new St.Label({ text: 'resets in ' + resetLabel(resetSeconds), style: 'font-size: 0.85em; opacity: 0.7;' });
        menu.box.add_child(sub);
    }
}

// One-line footer carrying the current state (demo/transient/error/last refreshed)
function addFooter(menu, state) {
    let text = 'Last refreshed: ' + (state.data ? state.data.lastRefreshed : '—');
    if (state.status === 'demo') text = 'Demo mode — add credentials in settings';
    else if (state.status === 'transient') text = 'Console API temporarily unavailable — showing last known figures';
    else if (state.status === 'error') text = String(state.error || 'Unknown error');
    const footer = new St.Label({ text: text, style: 'font-size: 0.85em; opacity: 0.75;' });
    menu.box.add_child(footer);
}

// Rebuilds the popup for the given state; safe to call on every open/refresh
export function buildMenuContent(menu, state) {
    clearMenuContent(menu);
    const header = new St.BoxLayout({ vertical: false, x_expand: true });
    header.add_child(new St.Label({ text: 'OpenCode Go', x_expand: true, style: 'font-weight: bold;' }));
    header.add_child(new St.Label({ text: state.data ? String(state.data.usagePercent) + '%' : '—', style: 'font-weight: bold;' }));
    menu.box.add_child(header);
    menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

    if (state.status === 'error') {
        addFooter(menu, state);
        return;
    }
    const data = state.data;
    if (!data) { addFooter(menu, state); return; }

    for (const w of WINDOWS) {
        const bars = data[w.slot] || [];
        // Percentage scaled against each bar's maxValue (identity for real data, correct for demo)
        const pct = bars.length ? Api.calculatePercentage(bars[0].value, bars[0].maxValue) : 0;
        addUsageRow(menu, w.label, pct, (data.resetSeconds || {})[w.resetKey] || 0);
    }
    menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
    addFooter(menu, state);
}

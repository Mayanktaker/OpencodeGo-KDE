// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Probe helpers injected by live-inject.py. Each reports a single `PROBE <tag> <json>`
// line so shell assertions can read one field at a time.

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

// Reports fetch state, popup content size, action entries, and the panel icon source
function probeState(tag) {
    const ind = this._indicator;
    const data = ind._state.data;
    const gicon = ind.get_children()[0]?.gicon;
    console.log('PROBE ' + tag + ' ' + JSON.stringify({
        status: ind._state.status,
        isMock: data ? !!data.isMock : null,
        percent: data ? data.usagePercent : null,
        error: ind._state.error,
        menuRows: ind.menu.box.get_n_children(),
        labels: probeLabels(ind.menu.box),
        // file:// means the branded O✦ logo loaded; a bare name means the stock fallback
        icon: gicon ? gicon.to_string() : null,
    }));
}

# Project Rules & Architecture - OpenCode Go Usage Plasmoid

© Mayanktaker Computers & Web Development | https://mayanktaker.com

## Code & Structure Conventions
- **Credit Header:** Every QML, JavaScript, and configuration source file must include the header:
  `// © Mayanktaker Computers & Web Development | https://mayanktaker.com`
- **Default Endpoint:** OpenCode Go usage data is retrieved via the workspace endpoint:
  `https://opencode.ai/workspace/{workspaceId}/go`
- **Response Handling:** `api.js` handles both raw JSON and HTML page payloads (Next.js `__NEXT_DATA__`, the authenticated SolidJS Go page's inlined store with `rollingUsage`/`weeklyUsage`/`monthlyUsage` windows, or text extraction) to prevent `JSON.parse` failures.
- **Authentication:** Auth cookies are passed via the `Cookie` header (`auth=<token>`). The server (sst/opencode via iron-session) reads **cookies only** — do not send an `Authorization` header; it is ignored. Iron-session seals begin with `Fe26.2**`, so bare pasted values are auto-prefixed with `auth=`. For testing, paste the value from DevTools → Application → Cookies → opencode.ai → `auth`.
- **Network Transport:** Qt's QML `XMLHttpRequest` **silently strips the `Cookie` header** (governed by `QNetworkRequest::CookieLoadControlAttribute`, regardless of `withCredentials`), so the plasmoid cannot authenticate via XHR. Instead, `UsageFetcher.qml` runs `curl` through Plasma's `executable` dataengine (`org.kde.plasma.plasma5support.DataSource`) and passes the captured stdout to `Api.parseCurlOutput`. The cookie value is shell-quoted (`shellQuote`) before inlining — never interpolate credentials into a shell string unescaped.
- **Error Handling:** When API errors or invalid credentials occur, the widget clears stale mock data and displays clean error messages without forcing Demo Mode.
- **Layout:** The widget uses horizontal-only layout (`layoutMode` hardcoded to `"horizontal"`). Tabbed and all-in-one views are disabled. Use `Plasmoid.configure()` (Plasma 6 API) — the old `plasmoid` id does not exist.
- **QML Binding Scope:** When passing properties to child components, always qualify with the parent's `id` (e.g., `fullRoot.usagePercent`) to avoid self-binding loops where the child resolves the unqualified name to its own property.
- **Branding & Assets:** Vector artwork uses the redesigned cyan-teal OpenCode Go logo SVG (`<O✦>` code brackets enclosing center ring and glowing spark) located in `assets/icon.svg` and `contents/icons/com.mayanktaker.opencodego-usage.svg`. `install.sh` generates PNG app icons across all system theme sizes (16px–128px) directly from this SVG.

## Testing Changes (MANDATORY after any QML/UI edit)
Plasma caches compiled QML and the config dialog does **not** pick up edits to `contents/ui/*.qml` or `contents/config/*.qml` until caches are cleared and the shell restarts. After changing widget UI or config pages you MUST:
1. Upgrade the installed plasmoid from the repo: `bash install.sh` (runs `kpackagetool6 -t Plasma/Applet -u .`, purges all Plasma QML bytecode caches, rebuilds the sycoca index, and restarts plasmashell).
2. **Fully close the settings/config dialog** before reopening it — a config window left open across the restart keeps a stale in-memory tab list (this is the usual cause of "old tabs / duplicate tabs" after a layout change).
3. If changes still don't appear, manually purge caches and restart: `rm -rf ~/.cache/plasmashell ~/.cache/plasmawindowed ~/.cache/qmlcache ~/.cache/kcmshell6 ~/.cache/systemsettings ~/.cache/kwin` then restart plasmashell, and `killall kcmshell6 systemsettings` to kill any lingering config processes.
Note: the installed copy under `~/.local/share/plasma/plasmoids/com.mayanktaker.opencodego-usage/` is a **separate copy**, not a symlink — edits in the repo are only live after the upgrade step above.

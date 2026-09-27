<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# Changelog — OpenCode Go Usage Tracker

## v2.6.0

**What's new**
- Clean monochrome tray icon for GNOME Shell top panel that renders crisply across light, dark, and custom system themes.
- Original vibrant full-color OpenCode Go `<O✦>` brand artwork displayed proudly inside the popup card header.
- Added an in-popup "Refresh" action button right before "Open OpenCode Console" that updates usage numbers instantly without closing the popup menu.
- Streamlined popup card design with cleaner typography and removed row icons for a sleek, uncluttered presentation.
- Interactive Session Cookie Guide built directly into the GNOME preferences window with step-by-step instructions.
- Interactive terminal setup wizard (`opencode-usage --interactive` / `-i`) to test and save credentials for both KDE and GNOME in seconds.
- Smarter cookie helper that immediately warns if an `auth` marketing token was copied instead of the required `__Host-console_session` token.

**Bug fixes**
- Fixed misleading authentication error messages by detecting marketing website cookies before testing connection.
- Fixed tray icon scaling in custom GNOME Shell themes by utilizing standard monochrome symbolic geometry.

## v2.5.1

**What's new**
- Redesigned GNOME panel icon with crisp, balanced proportions and vibrant brand colors that match standard desktop tray sizes.
- Added visible usage limit numbers (e.g. $4.80 / $20.00) directly beside your percentages in the popup card.
- New tray display selector in Settings: choose whether the panel shows your Weekly Limit, 5-Hour Rolling Limit, Monthly Limit, All Three Limits with icons, or Icon Only.
- Added a Compact View option in Settings to reduce popup height and spacing for smaller screens.
- Polished GNOME popup card with a branded header, distinct icons for Rolling, Weekly, and Monthly usage windows, and clear status badges.
- Smooth rounded progress bars with custom color accents (sky, cyan, and teal) and automatic warning highlights as usage increases.
- Added optional desktop notifications when usage crosses a chosen percentage threshold.
- Terminal CLI now displays formatted limit amounts and automatically detects GNOME extension settings.

**Bug fixes**
- Fixed the GNOME Settings link not opening when clicked from the popup menu.
- Fixed the GNOME panel tray icon appearing vertically squished and blurry.
- Fixed the vertical and horizontal center alignment between the tray icon and the usage percentage text.
- Fixed invisible or faint progress bars in the GNOME popup card across light and dark desktop themes.

## v2.5.0

**What's new**
- The usage tracker now runs on GNOME Shell too — a small panel icon that shows your Rolling (5h), Weekly, and Monthly usage when you hover it.
- The GNOME panel now shows your weekly percentage next to the icon, turning orange at 75% and red at 90% — the same idea as the KDE taskbar badge. You can turn it off in settings if you prefer the icon on its own.
- The GNOME panel icon now shows the same O✦ logo as the KDE widget.
- The GNOME popup has "Open OpenCode Console" and "Settings…" entries, and both still work when your sign-in has expired.
- GNOME settings now include a "Test" button that checks your details straight away instead of making you wait for a refresh.
- On GNOME you get a simple settings window for your sign-in details and how often the numbers refresh.
- Trying it on GNOME? No sign-in details yet? It shows sample numbers so you can see how it looks first.
- The downloadable bundle now includes the GNOME extension, and new builds always pick up the current version number.

**Bug fixes**
- Fixed the GNOME panel icon not appearing at all after a fresh install.
- Fixed the GNOME settings window not opening its contents.
- Fixed the GNOME "Test" button getting stuck on "Checking…" and never reporting back.
- Fixed your GNOME numbers being replaced by an error message during a brief OpenCode outage — it now keeps your last known figures, just like the KDE widget.
- Fixed the GNOME popup showing its contents twice after a refresh.
- Fixed GNOME waiting on the network in the background, which could make the desktop feel stuck while checking your usage.

## v2.4.0

**What's new**
- Works with the new OpenCode sign-in — paste your current session cookie and your numbers load.
- The first bar now reads Rolling (5h), so it's clear what time window it shows.
- When OpenCode has a brief outage, the widget keeps your last numbers on screen with a friendly note instead of going blank.
- Pasting your cookie is more forgiving — full rows, quoted copies, and older formats are all accepted.

**Bug fixes**
- Fixed the setup screen wrongly rejecting the new short session cookie.
- Fixed the "invalid config" dead-end when OpenCode moved its usage page.
- The widget now retries automatically during OpenCode's brief outages.

## v2.3.0

**What's new**
- Follows OpenCode to its new usage page and shows the same Rolling, Weekly, and Monthly numbers you see on the website.
- Clearer messages when your sign-in expires or a workspace has no subscription.

**Bug fixes**
- Fixed the widget going blank after OpenCode retired its old usage page.

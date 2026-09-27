<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# Changelog — OpenCode Go Usage Tracker

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

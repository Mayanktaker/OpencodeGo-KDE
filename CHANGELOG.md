<!-- © Mayanktaker Computers & Web Development | https://mayanktaker.com -->
# Changelog — OpenCode Go Usage Tracker

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

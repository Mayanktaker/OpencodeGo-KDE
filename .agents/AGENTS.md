# Project Rules & Architecture - OpenCode Go Usage Plasmoid

© Mayanktaker Computers & Web Development | https://mayanktaker.com

## Code & Structure Conventions
- **Credit Header:** Every QML, JavaScript, and configuration source file must include the header:
  `// © Mayanktaker Computers & Web Development | https://mayanktaker.com`
- **Default Endpoint:** OpenCode Go usage data is retrieved via the workspace endpoint:
  `https://opencode.ai/workspace/{workspaceId}/go`
- **Response Handling:** `api.js` handles both raw JSON and HTML page payloads (e.g. Next.js `__NEXT_DATA__` script blocks or text extraction) to prevent `JSON.parse` failures.
- **Authentication:** Auth cookies are passed via `Cookie` header (`auth=<token>`). The server (sst/opencode via iron-session) reads **cookies only** — do not send an `Authorization` header; it is ignored. Iron-session seals begin with `Fe26.2**`, so bare pasted values are auto-prefixed with `auth=`. For testing, paste the value from DevTools → Application → Cookies → opencode.ai → `auth`.
- **Error Handling:** When API errors or invalid credentials occur, the widget clears stale mock data and displays clean error messages without forcing Demo Mode.
